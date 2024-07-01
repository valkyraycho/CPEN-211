module task3(input clk, input rst_n, input [7:0] start_pc, output[15:0] out);
    wire [15:0] ram_r_data, ram_w_data;
    wire N, V, Z, ram_w_en;
    wire [7:0] ram_addr;
    cpu CPU(.clk, .rst_n, .start_pc, .ram_r_data, .out, .N, .V, .Z, .ram_w_en, .ram_addr, .ram_w_data);
    ram RAM(.clk, .ram_w_en, .ram_r_addr(ram_addr), .ram_w_addr(ram_addr), .ram_w_data, .ram_r_data);
endmodule: task3

module cpu(input clk, input rst_n, input [7:0] start_pc, input [15:0] ram_r_data, 
           output [15:0] out, output N, output V, output Z, output ram_w_en, output [7:0] ram_addr, output [15:0] ram_w_data);  
    
    wire w_en, en_A, en_B, en_C, sel_A, sel_B, en_status;
    wire [1:0] ALU_op, shift_op, wb_sel, reg_sel;
    wire [2:0] opcode, w_addr, r_addr;
    //wire [15:0] mdata = 16'b0;
    wire [15:0] sximm5, sximm8;

    reg [7:0] pc;
    reg [15:0] ir;
    reg [7:0] dr;

    wire load_ir, load_pc, load_addr, sel_addr, clear_pc;
    wire [7:0] next_pc;
    
    always_ff @(posedge clk) if(load_ir) ir <= ram_r_data;

    assign next_pc = (clear_pc) ? start_pc : pc+1;

    always_ff @(posedge clk) if(load_pc) pc <= next_pc;

    always_ff @(posedge clk) if(load_addr) dr <= out[7:0];

    assign ram_addr = (sel_addr) ? pc : dr;

    controller control(.clk, .rst_n, .opcode, .ALU_op, .shift_op, .Z, .N, .V, .reg_sel, .wb_sel, .w_en, .en_A, .en_B, .en_C, .en_status, .sel_A, .sel_B, .load_ir, .load_pc, .ram_w_en, .sel_addr, .clear_pc, .load_addr);
    datapath path(.clk, .mdata(ram_r_data), .pc, .wb_sel, .w_addr, .w_en, .r_addr, .en_A, .en_B, .shift_op, .sel_A, .sel_B, .ALU_op, .en_C, .en_status, .sximm8, .sximm5, .opcode, .datapath_out(out), .Z_out(Z), .N_out(N), .V_out(V), .ram_w_data);
    idecoder decoder(.ir, .reg_sel, .opcode, .ALU_op, .shift_op, .sximm5, .sximm8, .r_addr, .w_addr);    
endmodule: cpu

module controller(input clk, input rst_n, 
                  input [2:0] opcode, input [1:0] ALU_op, input [1:0] shift_op,
                  input Z, input N, input V,
                  output [1:0] reg_sel, output [1:0] wb_sel, output w_en,
                  output en_A, output en_B, output en_C, output en_status,
                  output sel_A, output sel_B, output load_ir, output load_pc, output ram_w_en, output sel_addr, output clear_pc, output load_addr);
     
    reg [1:0] sel_reg, sel_wb;
    assign reg_sel = sel_reg, wb_sel = sel_wb;
    reg en_w, A_en, B_en, C_en, status_en, A_sel, B_sel;
    assign  w_en = en_w, en_A = A_en, en_B = B_en, en_C = C_en, en_status = status_en, sel_A = A_sel, sel_B = B_sel;
    reg ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load;
    assign load_ir = ir_load, load_pc = pc_load, ram_w_en = en_w_ram, sel_addr = addr_sel, clear_pc = pc_clear, load_addr = addr_load;

    enum reg [4:0] 
    {
        HALT, PC_START, PC_LOAD, PC_READ, INSTR_SEND, PC_LOAD_NEXT,
        READ_INSTR, WRITE_VALUE, READ_VALUEA, READ_VALUEB, ENABLE_C,
        ADDR_LOAD, DATA_ADDR_SEL, DATA_ADDR_READ, DATA_ADDR_WRITE, SELECT_VALUE_LDR, READ_VALUEB_STR, ENABLE_C_STR, DATA_ADDR_ENABLE_WRITE
    } state;

    always_comb
    begin
        casex({state, opcode, ALU_op})
            {HALT, 3'bxxx, 2'bxx}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {17'b0};
            {PC_START, 3'bxxx, 2'bxx}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {15'b0, 1'b1, 1'b0}; // start the first instruction
            {PC_LOAD, 3'bxxx, 2'bxx}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {12'b0, 1'b1, 2'b0, 1'b1, 1'b0}; // load to pc
            {PC_LOAD_NEXT, 3'bxxx, 2'bxx}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {12'b0, 1'b1, 1'b0, 1'b1, 2'b0}; // load to pc
            {PC_READ, 3'bxxx, 2'bxx}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {14'b0, 1'b1, 2'b0}; // read delay
            {INSTR_SEND, 3'bxxx, 2'bxx}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {11'b0, 1'b1, 5'b0}; // load to IR                   
            
            //move_immediate
            {READ_INSTR, 3'b110, 2'b10}: {sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 15'b0};
            {WRITE_VALUE, 3'b110, 2'b10}: {sel_reg, en_w, sel_wb, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 1'b1, 2'b10, 12'b0};
            //MOV
            {READ_INSTR, 3'b110, 2'b00}: {sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 15'b0};
            {READ_VALUEB, 3'b110, 2'b00}: {sel_reg, B_en, sel_wb, en_w, A_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 1'b1, 14'b0}; //{sel_reg, B_en} = {2'b00, 1'b1};
            {ENABLE_C, 3'b110, 2'b00}: {C_en, status_en, sel_wb, sel_reg, en_w, A_en, B_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b11, 7'b0, 2'b10, 6'b0}; //{C_en, status_en} = 2'b11;
            {WRITE_VALUE, 3'b110, 2'b00}: {sel_reg, en_w, sel_wb, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b01, 1'b1, 14'b0}; //{sel_reg, en_w} = {2'b01, 1'b1};
            //ADD
            {READ_INSTR, 3'b101, 2'b00}: {sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 15'b0};
            {READ_VALUEA, 3'b101, 2'b00}: {sel_reg, A_en, sel_wb, en_w, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 1'b1, 14'b0}; //{sel_reg, A_en} = {2'b01, 1'b1};
            {READ_VALUEB, 3'b101, 2'b00}: {sel_reg, A_en, B_en, sel_wb, en_w, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 1'b0, 1'b1, 13'b0}; //{sel_reg, A_en, B_en} = {2'b00, 1'b0, 1'b1};
            {ENABLE_C, 3'b101, 2'b00}: {C_en, status_en, sel_wb, sel_reg, en_w, A_en, B_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b11, 15'b0};
            {WRITE_VALUE, 3'b101, 2'b00}: {sel_reg, en_w, sel_wb, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b01, 1'b1, 14'b0}; //{sel_reg, en_w} = {2'b01, 1'b1};
            //CMP
            {READ_INSTR, 3'b101, 2'b01}: {sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 15'b0};
            {READ_VALUEA, 3'b101, 2'b01}: {sel_reg, A_en, sel_wb, en_w, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 1'b1, 14'b0}; //{sel_reg, A_en} = {2'b01, 1'b1};
            {READ_VALUEB, 3'b101, 2'b01}: {sel_reg, A_en, B_en, sel_wb, en_w, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 1'b0, 1'b1, 13'b0}; //{sel_reg, A_en, B_en} = {2'b00, 1'b0, 1'b1};
            {ENABLE_C, 3'b101, 2'b01}: {C_en, status_en, sel_wb, sel_reg, en_w, A_en, B_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b11, 15'b0};
            //AND
            {READ_INSTR, 3'b101, 2'b10}: {sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 15'b0};
            {READ_VALUEA, 3'b101, 2'b10}: {sel_reg, A_en, sel_wb, en_w, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 1'b1, 14'b0}; //{sel_reg, A_en} = {2'b01, 1'b1};
            {READ_VALUEB, 3'b101, 2'b10}: {sel_reg, A_en, B_en, sel_wb, en_w, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 1'b0, 1'b1, 13'b0}; //{sel_reg, A_en, B_en} = {2'b00, 1'b0, 1'b1};
            {ENABLE_C, 3'b101, 2'b10}: {C_en, status_en, sel_wb, sel_reg, en_w, A_en, B_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b11, 15'b0};
            {WRITE_VALUE, 3'b101, 2'b10}: {sel_reg, en_w, sel_wb, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b01, 1'b1, 14'b0}; //{sel_reg, en_w} = {2'b01, 1'b1};
            //MVN
            {READ_INSTR, 3'b101, 2'b11}: {sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 15'b0};
            {READ_VALUEB, 3'b101, 2'b11}: {sel_reg, B_en, sel_wb, en_w, A_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 1'b1, 14'b0}; //{sel_reg, B_en} = {2'b00, 1'b1};
            {ENABLE_C, 3'b101, 2'b11}: {C_en, status_en, sel_wb, sel_reg, en_w, A_en, B_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b11, 15'b0};
            {WRITE_VALUE, 3'b101, 2'b11}: {sel_reg, en_w, sel_wb, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b01, 1'b1, 14'b0}; //{sel_reg, en_w} = {2'b01, 1'b1};

            //LDR
            {READ_INSTR, 3'b011, 2'b00}: {sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 15'b0};
            {READ_VALUEA, 3'b011, 2'b00}: {sel_reg, A_en, sel_wb, en_w, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 1'b1, 14'b0}; 
            {ENABLE_C, 3'b011, 2'b00}: {C_en, status_en, A_sel, B_sel, sel_wb, sel_reg, en_w, A_en, B_en, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b11, 2'b01, 13'b0};
            {ADDR_LOAD, 3'b011, 2'b00}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {16'b0, 1'b1}; // load_addr = 1
            {DATA_ADDR_SEL, 3'b011, 2'b00}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {14'b0, 1'b1, 2'b0}; //sel_addr = 1
            {DATA_ADDR_READ, 3'b011, 2'b00}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {17'b0}; //delay to read 
            {SELECT_VALUE_LDR, 3'b011, 2'b00}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b01, 2'b11 ,13'b0}; // wb_sel = 11 to read mdata
            {WRITE_VALUE, 3'b011, 2'b00}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b01, 2'b11, 1'b1, 12'b0};

            //STR
            {READ_INSTR, 3'b100, 2'b00}: {sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 15'b0};
            {READ_VALUEA, 3'b100, 2'b00}: {sel_reg, A_en, sel_wb, en_w, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 1'b1, 14'b0}; 
            {ENABLE_C, 3'b100, 2'b00}: {C_en, status_en, A_sel, B_sel, sel_wb, sel_reg, en_w, A_en, B_en, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b11, 2'b01,13'b0};
            {ADDR_LOAD, 3'b100, 2'b00}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {16'b0, 1'b1}; // load_addr = 1
            {DATA_ADDR_SEL, 3'b100, 2'b00}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {14'b0, 1'b1, 2'b0}; //sel_addr = 1
            {READ_VALUEB_STR, 3'b100, 2'b00}: {sel_reg, B_en, sel_wb, en_w, A_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b01, 1'b1, 14'b0};
            {ENABLE_C_STR, 3'b100, 2'b00}: {C_en, status_en, A_sel, B_sel, sel_wb, sel_reg, en_w, A_en, B_en, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b11, 2'b10, 13'b0};
            {DATA_ADDR_ENABLE_WRITE, 3'b100, 2'b00}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {13'b0, 1'b1, 3'b0}; // ram_w_en = 1
            {DATA_ADDR_WRITE, 3'b100, 2'b00}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {17'b0}; //delay to write

            default {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = 17'b0;
        endcase
    end

    always_ff @(posedge clk)
    begin
        if(~rst_n)
        begin
            state <= PC_START;
        end
        else 
        begin
            case(state)
                HALT: if(~rst_n) state <= PC_START;
                PC_START: state <= PC_LOAD;
                PC_LOAD: state <= PC_READ;
                PC_LOAD_NEXT: state <= PC_READ;
                PC_READ: state <= INSTR_SEND;
                INSTR_SEND: state <= READ_INSTR;
                READ_INSTR: if(opcode == 3'b110 && ALU_op == 2'b10) state <= WRITE_VALUE;
                              else if((opcode == 3'b110 && ALU_op == 2'b00) || (opcode == 3'b101 && ALU_op == 2'b11)) state <= READ_VALUEB;
                              else if(opcode == 3'b111) state <= HALT;
                              else state <= READ_VALUEA;
                WRITE_VALUE: state <= PC_LOAD_NEXT;
                READ_VALUEA: if(opcode == 3'b011 || opcode == 3'b100) state <= ENABLE_C;
                             else state <= READ_VALUEB;
                READ_VALUEB: state <= ENABLE_C;
                ENABLE_C: if(opcode == 3'b101 && ALU_op == 2'b01) state <= PC_LOAD_NEXT;
                          else if((opcode == 3'b110 && ALU_op == 2'b00) || (opcode == 3'b101)) state <= WRITE_VALUE;
                          else state <= ADDR_LOAD;
                ADDR_LOAD: state <= DATA_ADDR_SEL;
                DATA_ADDR_SEL: if(opcode == 3'b011) state <= DATA_ADDR_READ;
                               else state <= READ_VALUEB_STR;
                DATA_ADDR_READ: state <= SELECT_VALUE_LDR;
                SELECT_VALUE_LDR: state <= WRITE_VALUE;
                READ_VALUEB_STR: state <= ENABLE_C_STR;
                ENABLE_C_STR: state <= DATA_ADDR_ENABLE_WRITE;
                DATA_ADDR_ENABLE_WRITE: state <= DATA_ADDR_WRITE;
                DATA_ADDR_WRITE: state <= PC_LOAD_NEXT;
            endcase
        end
    end
endmodule: controller

module ALU(input [15:0] val_A, input [15:0] val_B, input [1:0] ALU_op, output [15:0] ALU_out, output Z, output N, output V);
    reg [15:0] alu_out;
    assign ALU_out = alu_out;
    reg z, n, v;
    assign Z = z, N = n, V = v;
    reg [15:0] subtract;
    always_comb
    begin
        case(ALU_op)
            2'b00: {alu_out, z, n ,v, subtract} = {val_A+val_B, 3'b000, 16'b0};   
            2'b01: begin
                   subtract = val_A - val_B;
                   if(subtract == 16'b0) {alu_out, z, n ,v} = {subtract, 3'b100};
                   else if((val_A[15]^val_B[15]) == 1'b1 && (subtract[15]^val_A[15] == 1'b1)) {alu_out, z, n ,v} = {subtract, 3'b001};
                   else if(subtract[15] == 1'b1) {alu_out, z, n ,v} = {subtract, 3'b010};
                   else {alu_out, z, n ,v} = {subtract, 3'b000};
                   end   
            2'b10: {alu_out, z, n ,v, subtract} = {val_A&val_B, 3'b000, 16'b0};     
            default: {alu_out, z, n, v, subtract} = {~val_B, 3'b000, 16'd0};   
        endcase
    end
endmodule: ALU

module shifter(input [15:0] shift_in, input [1:0] shift_op, input [2:0] opcode, output reg [15:0] shift_out);
    always_comb
    begin
        case(shift_op)
            2'b00: shift_out = shift_in;
            2'b01: if(opcode != 3'b100) shift_out = {shift_in[14:0], 1'b0}; else shift_out = shift_in;
            2'b10: if(opcode != 3'b100) shift_out = {1'b0, shift_in[15:1]}; else shift_out = shift_in;
            default if(opcode != 3'b100) shift_out = {shift_in[15], shift_in[15:1]}; else shift_out = shift_in;
        endcase
    end
endmodule: shifter

module idecoder(input [15:0] ir, input [1:0] reg_sel,
                output [2:0] opcode, output [1:0] ALU_op, output [1:0] shift_op,
		        output [15:0] sximm5, output [15:0] sximm8,
                output [2:0] r_addr, output [2:0] w_addr);
        wire [2:0] Rm, Rd, Rn;
        wire [7:0] imm8;
        wire [4:0] imm5;
        assign shift_op = ir[4:3];
        assign ALU_op = ir[12:11];
        assign opcode = ir[15:13];
        assign sximm8 = {{8{ir[7]}}, ir[7:0]};
        assign sximm5 = {{11{ir[4]}}, ir[4:0]};
        assign Rm = ir[2:0];
        assign Rd = ir[7:5];
        assign Rn = ir[10:8];
        reg [2:0] addr_r, addr_w;
        assign {r_addr, w_addr} = {addr_r, addr_w};
        always_comb 
        begin
            case(reg_sel)
                2'b00: {addr_w, addr_r} = {Rm, Rm};
                2'b01: {addr_w, addr_r} = {Rd, Rd};
                2'b10: {addr_w, addr_r} = {Rn, Rn}; 
                default: {addr_w, addr_r} = 6'b0;
            endcase
        end
endmodule: idecoder

module datapath(input clk, input [15:0] mdata, input [7:0] pc, input [1:0] wb_sel,
                input [2:0] w_addr, input w_en, input [2:0] r_addr, input en_A,
                input en_B, input [1:0] shift_op, input sel_A, input sel_B,
                input [1:0] ALU_op, input en_C, input en_status,
		        input [15:0] sximm8, input [15:0] sximm5, input [2:0] opcode,
                output [15:0] datapath_out, output Z_out, output N_out, output V_out, output [15:0] ram_w_data);
    reg [15:0] w_data;
    always_comb
    begin
        case(wb_sel)
                2'b00: w_data = datapath_out;
                2'b01: w_data = {8'b0,pc};
                2'b10: w_data = sximm8;
                default: w_data = mdata;
        endcase
    end

    wire [15:0] r_data;  
    regfile registerfile(.w_data, .w_addr, .w_en, .r_addr, .clk, .r_data);

    reg [15:0] A, B;
    always_ff @(posedge clk) if (en_A) A <= r_data;
    always_ff @(posedge clk) if (en_B) B <= r_data;
    
    wire [15:0] shift_out;
    shifter shift(.shift_in(B), .shift_op, .opcode, .shift_out);

    wire [15:0] val_A, val_B;
    assign val_A = (sel_A) ? 16'b0 : A;
    assign val_B = (sel_B) ? sximm5 : shift_out;

    wire [15:0] ALU_out;
    wire Z, N, V;
    ALU alu(.val_A, .val_B, .ALU_op, .ALU_out, .Z, .N, .V);

    reg out_z, out_n, out_v;
    reg [15:0] out_datapath;
    reg [15:0] data_w_ram;
    assign Z_out = out_z, N_out = out_n, V_out = out_v;
    assign datapath_out = out_datapath;
    assign ram_w_data = data_w_ram;
    always_ff @(posedge clk) if (en_C) out_datapath <= ALU_out;
    always_ff @(posedge clk) if (en_C) data_w_ram <= ALU_out;
    always_ff @(posedge clk)
    begin
        if (en_status) 
            begin
                out_z <= Z;
                out_n <= N;
                out_v <= V;
            end
    end
endmodule: datapath


