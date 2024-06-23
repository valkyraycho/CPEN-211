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
        HALT, PC_START, PC_LOAD, PC_SEL, PC_READ, INSTR_SEND, 
        SELECT_VALUE, WRITE_VALUE, READ_VALUEA, READ_VALUEB , SELECT_AB, ENABLE_C,
        ADDR_LOAD, DATA_ADDR_SEL, DATA_ADDR_READ, DATA_ADDR_WRITE, SELECT_VALUE_LDR, READ_VALUEB_STR, SELECT_AB_STR, ENABLE_C_STR, DATA_ADDR_ENABLE_WRITE
    } state;

    always_comb
    begin
        casex({state, opcode, ALU_op})
            {HALT, 3'bxxx, 2'bxx}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {17'b0};
            {PC_START, 3'bxxx, 2'bxx}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {15'b0, 1'b1, 1'b0}; // start the first instruction
            {PC_LOAD, 3'bxxx, 2'bxx}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {12'b0, 1'b1, 2'b0, 1'b1, 1'b0}; // load to pc
            {PC_SEL, 3'bxxx, 2'bxx}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {14'b0, 1'b1, 2'b0}; // select pc addr
            {PC_READ, 3'bxxx, 2'bxx}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {14'b0, 1'b1, 2'b0}; // read delay
            {INSTR_SEND, 3'bxxx, 2'bxx}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {11'b0, 1'b1, 5'b0}; // load to IR                   
            
            //move_immediate
            {SELECT_VALUE, 3'b110, 2'b10}: {sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 15'b0};
            {WRITE_VALUE, 3'b110, 2'b10}: {sel_reg, en_w, sel_wb, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 1'b1, 2'b10, 12'b0};
            //MOV
            {SELECT_VALUE, 3'b110, 2'b00}: {sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 15'b0};
            {READ_VALUEB, 3'b110, 2'b00}: {sel_reg, B_en, sel_wb, en_w, A_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 1'b1, 14'b0}; //{sel_reg, B_en} = {2'b00, 1'b1};
            //{SELECT_AB, 3'b110, 2'b00}: {A_sel, B_sel, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 15'b0}; //{A_sel, B_sel, B_en} = {2'b10, 1'b0};
            {ENABLE_C, 3'b110, 2'b00}: {C_en, status_en, sel_wb, sel_reg, en_w, A_en, B_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b11, 7'b0, 2'b10, 6'b0}; //{C_en, status_en} = 2'b11;
            {WRITE_VALUE, 3'b110, 2'b00}: {sel_reg, en_w, sel_wb, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b01, 1'b1, 14'b0}; //{sel_reg, en_w} = {2'b01, 1'b1};
            //ADD
            {SELECT_VALUE, 3'b101, 2'b00}: {sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 15'b0};
            {READ_VALUEA, 3'b101, 2'b00}: {sel_reg, A_en, sel_wb, en_w, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 1'b1, 14'b0}; //{sel_reg, A_en} = {2'b01, 1'b1};
            {READ_VALUEB, 3'b101, 2'b00}: {sel_reg, A_en, B_en, sel_wb, en_w, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 1'b0, 1'b1, 13'b0}; //{sel_reg, A_en, B_en} = {2'b00, 1'b0, 1'b1};
            //{SELECT_AB, 3'b101, 2'b00}: {A_sel, B_sel, B_en, sel_wb, sel_reg, en_w, A_en, C_en, status_en, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 1'b0, 14'b0}; //{A_sel, B_sel, B_en} = {2'b00, 1'b0};
            {ENABLE_C, 3'b101, 2'b00}: {C_en, status_en, sel_wb, sel_reg, en_w, A_en, B_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b11, 15'b0};
            {WRITE_VALUE, 3'b101, 2'b00}: {sel_reg, en_w, sel_wb, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b01, 1'b1, 14'b0}; //{sel_reg, en_w} = {2'b01, 1'b1};
            //CMP
            {SELECT_VALUE, 3'b101, 2'b01}: {sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 15'b0};
            {READ_VALUEA, 3'b101, 2'b01}: {sel_reg, A_en, sel_wb, en_w, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 1'b1, 14'b0}; //{sel_reg, A_en} = {2'b01, 1'b1};
            {READ_VALUEB, 3'b101, 2'b01}: {sel_reg, A_en, B_en, sel_wb, en_w, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 1'b0, 1'b1, 13'b0}; //{sel_reg, A_en, B_en} = {2'b00, 1'b0, 1'b1};
            //{SELECT_AB, 3'b101, 2'b01}: {A_sel, B_sel, B_en, sel_wb, sel_reg, en_w, A_en, C_en, status_en, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 1'b0, 14'b0}; //{A_sel, B_sel, B_en} = {2'b00, 1'b0};
            {ENABLE_C, 3'b101, 2'b01}: {C_en, status_en, sel_wb, sel_reg, en_w, A_en, B_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b11, 15'b0};
            //AND
            {SELECT_VALUE, 3'b101, 2'b10}: {sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 15'b0};
            {READ_VALUEA, 3'b101, 2'b10}: {sel_reg, A_en, sel_wb, en_w, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 1'b1, 14'b0}; //{sel_reg, A_en} = {2'b01, 1'b1};
            {READ_VALUEB, 3'b101, 2'b10}: {sel_reg, A_en, B_en, sel_wb, en_w, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 1'b0, 1'b1, 13'b0}; //{sel_reg, A_en, B_en} = {2'b00, 1'b0, 1'b1};
            //{SELECT_AB, 3'b101, 2'b10}: {A_sel, B_sel, B_en, sel_wb, sel_reg, en_w, A_en, C_en, status_en, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 1'b0, 14'b0}; //{A_sel, B_sel, B_en} = {2'b00, 1'b0};
            {ENABLE_C, 3'b101, 2'b10}: {C_en, status_en, sel_wb, sel_reg, en_w, A_en, B_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b11, 15'b0};
            {WRITE_VALUE, 3'b101, 2'b10}: {sel_reg, en_w, sel_wb, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b01, 1'b1, 14'b0}; //{sel_reg, en_w} = {2'b01, 1'b1};
            //MVN
            {SELECT_VALUE, 3'b101, 2'b11}: {sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 15'b0};
            {READ_VALUEB, 3'b101, 2'b11}: {sel_reg, B_en, sel_wb, en_w, A_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 1'b1, 14'b0}; //{sel_reg, B_en} = {2'b00, 1'b1};
            //{SELECT_AB, 3'b101, 2'b11}: {A_sel, B_sel, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 15'b0}; //{A_sel, B_sel, B_en} = {2'b10, 1'b0};
            {ENABLE_C, 3'b101, 2'b11}: {C_en, status_en, sel_wb, sel_reg, en_w, A_en, B_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b11, 15'b0};
            {WRITE_VALUE, 3'b101, 2'b11}: {sel_reg, en_w, sel_wb, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b01, 1'b1, 14'b0}; //{sel_reg, en_w} = {2'b01, 1'b1};

            //LDR
            {SELECT_VALUE, 3'b011, 2'b00}: {sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 15'b0};
            {READ_VALUEA, 3'b011, 2'b00}: {sel_reg, A_en, sel_wb, en_w, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 1'b1, 14'b0}; 
            //{SELECT_AB, 3'b011, 2'b00}: {A_sel, B_sel, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b01, 15'b0};
            {ENABLE_C, 3'b011, 2'b00}: {C_en, status_en, sel_wb, sel_reg, en_w, A_en, B_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b11, 15'b0};
            {ADDR_LOAD, 3'b011, 2'b00}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {16'b0, 1'b1}; // load_addr = 1
            {DATA_ADDR_SEL, 3'b011, 2'b00}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {14'b0, 1'b1, 2'b0}; //sel_addr = 1
            {DATA_ADDR_READ, 3'b011, 2'b00}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {17'b0}; //delay to read 
            {SELECT_VALUE_LDR, 3'b011, 2'b00}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b01, 2'b11 ,13'b0}; // wb_sel = 11 to read mdata
            {WRITE_VALUE, 3'b011, 2'b00}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b01, 2'b11, 1'b1, 12'b0};

            //STR
            {SELECT_VALUE, 3'b100, 2'b00}: {sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b00, 15'b0};
            {READ_VALUEA, 3'b100, 2'b00}: {sel_reg, A_en, sel_wb, en_w, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 1'b1, 14'b0}; 
            //{SELECT_AB, 3'b100, 2'b00}: {A_sel, B_sel, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b01, 15'b0};
            {ENABLE_C, 3'b100, 2'b00}: {C_en, status_en, sel_wb, sel_reg, en_w, A_en, B_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b11, 15'b0};
            {ADDR_LOAD, 3'b100, 2'b00}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {16'b0, 1'b1}; // load_addr = 1
            {DATA_ADDR_SEL, 3'b100, 2'b00}: {sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {14'b0, 1'b1, 2'b0}; //sel_addr = 1
            {READ_VALUEB_STR, 3'b100, 2'b00}: {sel_reg, B_en, sel_wb, en_w, A_en, C_en, status_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b01, 1'b1, 14'b0};
            //{SELECT_AB_STR, 3'b100, 2'b00}: {A_sel, B_sel, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b10, 15'b0};
            {ENABLE_C_STR, 3'b100, 2'b00}: {C_en, status_en, sel_wb, sel_reg, en_w, A_en, B_en, A_sel, B_sel, ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load} = {2'b11, 15'b0};
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
                PC_LOAD: state <= PC_SEL;
                PC_SEL: state <= PC_READ;
                PC_READ: state <= INSTR_SEND;
                INSTR_SEND:
                    begin
                        if(opcode == 3'b111) state <= HALT;
                        else state <= SELECT_VALUE;
                    end 
                SELECT_VALUE: if(opcode == 3'b110 && ALU_op == 2'b10) state <= WRITE_VALUE;
                              else if((opcode == 3'b110 && ALU_op == 2'b00) || (opcode == 3'b101 && ALU_op == 2'b11)) state <= READ_VALUEB;
                              else state <= READ_VALUEA;
                WRITE_VALUE: state <= PC_LOAD;
                READ_VALUEA: if(opcode == 3'b011 || opcode == 3'b100) state <= ENABLE_C;
                             else state <= READ_VALUEB;
                READ_VALUEB: state <= ENABLE_C;
                //SELECT_AB: state <= ENABLE_C;
                ENABLE_C: if(opcode == 3'b101 && ALU_op == 2'b01) state <= PC_LOAD;
                          else if((opcode == 3'b110 && ALU_op == 2'b00) || (opcode == 3'b101)) state <= WRITE_VALUE;
                          else state <= ADDR_LOAD;
                ADDR_LOAD: state <= DATA_ADDR_SEL;
                DATA_ADDR_SEL: if(opcode == 3'b011) state <= DATA_ADDR_READ;
                               else state <= READ_VALUEB_STR;
                DATA_ADDR_READ: state <= SELECT_VALUE_LDR;
                SELECT_VALUE_LDR: state <= WRITE_VALUE;
                READ_VALUEB_STR: state <= ENABLE_C_STR;
                //SELECT_AB_STR: state <= ENABLE_C_STR;
                ENABLE_C_STR: state <= DATA_ADDR_ENABLE_WRITE;
                DATA_ADDR_ENABLE_WRITE: state <= DATA_ADDR_WRITE;
                DATA_ADDR_WRITE: state <= PC_LOAD;
            endcase
        end
    end
endmodule: controller

/*
//MOV imm
PC_START->PC_LOAD->PC_SEL->PC_READ->INSTR_SEND->SELECT_VALUE->WRITE_VALUE->PC_NEXT->PC_LOAD
//MOV
PC_START->PC_LOAD->PC_SEL->PC_READ->INSTR_SEND->SELECT_VALUE->READ_VALUEB->SELECT_AB->ENABLE_C->WRITE_VALUE->PC_NEXT->PC_LOAD
//ADD
PC_START->PC_LOAD->PC_SEL->PC_READ->INSTR_SEND->SELECT_VALUE->READ_VALUEA->READ_VALUEB->SELECT_AB->ENABLE_C->WRITE_VALUE->PC_NEXT->PC_LOAD
.
(for instructions unrelated to memory, just add the first five states in front and PC_NEXT->PC_LOAD at the end)

//LDR
PC_START->PC_LOAD->PC_SEL->PC_READ->INSTR_SEND->SELECT_VALUE->READ_VALUEA->SELECT_AB->ENABLE_C->ADDR_LOAD->DATA_ADDR_SEL->DATA_ADDR_READ->SELECT_VALUE_LDR->WRITE_VALUE->PC_NEXT->PC_LOAD
//STR
PC_START->PC_LOAD->PC_SEL->PC_READ->INSTR_SEND->SELECT_VALUE->READ_VALUEA->SELECT_AB->ENABLE_C->ADDR_LOAD->DATA_ADDR_SEL->READ_VALUEB_STR->SELECT_AB_STR->ENABLE_C_STR->DATA_ADDR_ENABLE_WRITE->DATA_ADDR_WRITE->PC_NEXT->PC_LOAD
//HALT
PC_START->PC_LOAD->PC_SEL->PC_READ->INSTR_SEND->HALT
*/
