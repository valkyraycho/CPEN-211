module task1 (
    input         clk,
    input         rst_n,
    input  [ 7:0] start_pc,
    output [15:0] out
);
    wire [15:0] ram_r_data, ram_w_data;
    wire N, V, Z, ram_w_en;
    wire [7:0] ram_addr;
    cpu CPU (
        .clk,
        .rst_n,
        .start_pc,
        .ram_r_data,
        .out,
        .N,
        .V,
        .Z,
        .ram_w_en,
        .ram_addr,
        .ram_w_data
    );
    ram RAM (
        .clk,
        .ram_w_en,
        .ram_r_addr(ram_addr),
        .ram_w_addr(ram_addr),
        .ram_w_data,
        .ram_r_data
    );
endmodule : task1

module cpu (
    input         clk,
    input         rst_n,
    input  [ 7:0] start_pc,
    input  [15:0] ram_r_data,
    output [15:0] out,
    output        N,
    output        V,
    output        Z,
    output        ram_w_en,
    output [ 7:0] ram_addr,
    output [15:0] ram_w_data
);

    wire w_en, en_A, en_B, en_C, sel_A, sel_B, en_status;
    wire [1:0] ALU_op, shift_op, wb_sel, reg_sel;
    wire [2:0] opcode, w_addr, r_addr;
    wire [15:0] sximm5, sximm8;

    reg [ 7:0] pc;
    reg [15:0] ir;
    reg [ 7:0] dr;

    wire load_ir, load_pc, load_addr, sel_addr, clear_pc;
    wire [7:0] next_pc;

    always_ff @(posedge clk) if (load_ir) ir <= ram_r_data;

    assign next_pc = (clear_pc) ? start_pc : pc + 1;

    always_ff @(posedge clk) if (load_pc) pc <= next_pc;

    always_ff @(posedge clk) if (load_addr) dr <= out[7:0];

    assign ram_addr = (sel_addr) ? pc : dr;

    controller control (
        .clk,
        .rst_n,
        .opcode,
        .ALU_op,
        .shift_op,
        .Z,
        .N,
        .V,
        .reg_sel,
        .wb_sel,
        .w_en,
        .en_A,
        .en_B,
        .en_C,
        .en_status,
        .sel_A,
        .sel_B,
        .load_ir,
        .load_pc,
        .ram_w_en,
        .sel_addr,
        .clear_pc,
        .load_addr
    );
    datapath path (
        .clk,
        .mdata(ram_r_data),
        .pc,
        .wb_sel,
        .w_addr,
        .w_en,
        .r_addr,
        .en_A,
        .en_B,
        .shift_op,
        .sel_A,
        .sel_B,
        .ALU_op,
        .en_C,
        .en_status,
        .sximm8,
        .sximm5,
        .datapath_out(out),
        .Z_out(Z),
        .N_out(N),
        .V_out(V),
        .ram_w_data
    );
    idecoder decoder (
        .ir,
        .reg_sel,
        .opcode,
        .ALU_op,
        .shift_op,
        .sximm5,
        .sximm8,
        .r_addr,
        .w_addr
    );

endmodule : cpu

module controller (
    input        clk,
    input        rst_n,
    input  [2:0] opcode,
    input  [1:0] ALU_op,
    input  [1:0] shift_op,
    input        Z,
    input        N,
    input        V,
    output [1:0] reg_sel,
    output [1:0] wb_sel,
    output       w_en,
    output       en_A,
    output       en_B,
    output       en_C,
    output       en_status,
    output       sel_A,
    output       sel_B,
    output       load_ir,
    output       load_pc,
    output       ram_w_en,
    output       sel_addr,
    output       clear_pc,
    output       load_addr
);

    reg [1:0] sel_reg, sel_wb;
    assign reg_sel = sel_reg, wb_sel = sel_wb;

    reg en_w, A_en, B_en, C_en, status_en, A_sel, B_sel;
    assign w_en = en_w, en_A = A_en, en_B = B_en, en_C = C_en, en_status = status_en, sel_A = A_sel, sel_B = B_sel;

    reg ir_load, pc_load, en_w_ram, addr_sel, pc_clear, addr_load;
    assign load_ir = ir_load, load_pc = pc_load, ram_w_en = en_w_ram, sel_addr = addr_sel, clear_pc = pc_clear, load_addr = addr_load;

    enum reg [4:0] {
        HALT,
        FIRST_PC_LOAD,
        PC_LOAD,
        PC_READ,
        INSTR_LOAD,
        DELAY,
        WRITE_VALUE,
        READ_VALUEA,
        READ_VALUEB,
        ENABLE_C,
        ENABLE_C_STR,
        ADDR_LOAD,
        RAM_DATA_READ,
        RAM_DATA_WRITE
    } state;

    always_comb begin
        casex ({
            state, opcode, ALU_op
        })
            {
                DELAY, 3'bxxx, 2'bxx
            } : begin
                sel_wb    = sel_wb;
                sel_reg   = sel_reg;
                en_w      = en_w;
                A_en      = A_en;
                B_en      = B_en;
                C_en      = C_en;
                status_en = status_en;
                A_sel     = A_sel;
                B_sel     = B_sel;
                ir_load   = ir_load;
                pc_load   = pc_load;
                en_w_ram  = en_w_ram;
                addr_sel  = addr_sel;
                pc_clear  = pc_clear;
                addr_load = addr_load;
            end

            {
                HALT, 3'bxxx, 2'bxx
            } : begin
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b1;  //* clear_pc = 1'b1 to be ready for the next start_pc
                addr_load = 1'b0;
            end

            {
                FIRST_PC_LOAD, 3'bxxx, 2'bxx
            } : begin
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b1;  //* load_pc = 1'b1
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b1;
                addr_load = 1'b0;
            end

            {
                PC_LOAD, 3'bxxx, 2'bxx
            } : begin
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b1;  //* load_pc = 1'b1
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end

            {
                PC_READ, 3'bxxx, 2'bxx
            } : begin
                //* delay reading program from RAM 
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end

            {
                INSTR_LOAD, 3'bxxx, 2'bxx
            } : begin
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b1;  //* load_ir = 1'b1  
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end

            //* MOV imm
            {
                WRITE_VALUE, 3'b110, 2'b10
            } : begin
                sel_wb    = 2'b10;
                sel_reg   = 2'b10;
                en_w      = 1'b1;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end

            //* MOV
            {
                READ_VALUEB, 3'b110, 2'b00
            } : begin
                //* select Rm and enable B
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b1;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b1;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            {
                ENABLE_C, 3'b110, 2'b00
            } : begin
                sel_wb    = 2'b00;
                sel_reg   = 2'b01;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b1;
                status_en = 1'b0;
                A_sel     = 1'b1;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            {
                WRITE_VALUE, 3'b110, 2'b00
            } : begin
                //* select Rd and enable write
                sel_wb    = 2'b00;
                sel_reg   = 2'b01;
                en_w      = 1'b1;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end

            //* ADD & AND
            {
                READ_VALUEA, 3'b101, 2'bx0
            } : begin
                //* select Rn and enable A
                sel_wb    = 2'b00;
                sel_reg   = 2'b10;
                en_w      = 1'b0;
                A_en      = 1'b1;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            {
                READ_VALUEB, 3'b101, 2'bx0
            } : begin
                //* select Rm and enable B
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b1;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            {
                ENABLE_C, 3'b101, 2'bx0
            } : begin
                sel_wb    = 2'b00;
                sel_reg   = 2'b01;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b1;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            {
                WRITE_VALUE, 3'b101, 2'bx0
            } : begin
                //* select Rd and enable write
                sel_wb    = 2'b00;
                sel_reg   = 2'b01;
                en_w      = 1'b1;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end

            //* CMP
            {
                READ_VALUEA, 3'b101, 2'b01
            } : begin
                //* select Rn and enable A
                sel_wb    = 2'b00;
                sel_reg   = 2'b10;
                en_w      = 1'b0;
                A_en      = 1'b1;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            {
                READ_VALUEB, 3'b101, 2'b01
            } : begin
                //* select Rm and enable B
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b1;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            {
                ENABLE_C, 3'b101, 2'b01
            } : begin
                //* enable status only for CMP
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b1;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end

            // * MVN
            {
                READ_VALUEB, 3'b101, 2'b11
            } : begin
                //* select Rm and enable B
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b1;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b1;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            {
                ENABLE_C, 3'b101, 2'b11
            } : begin
                sel_wb    = 2'b00;
                sel_reg   = 2'b01;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b1;
                status_en = 1'b0;
                A_sel     = 1'b1;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            {
                WRITE_VALUE, 3'b101, 2'b11
            } : begin
                //* select Rd and enable write
                sel_wb    = 2'b00;
                sel_reg   = 2'b01;
                en_w      = 1'b1;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end

            //* LDR
            {
                READ_VALUEA, 3'b011, 2'b00
            } : begin
                //* select Rn and enable A
                sel_wb    = 2'b00;
                sel_reg   = 2'b10;
                en_w      = 1'b0;
                A_en      = 1'b1;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b1;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            {
                ENABLE_C, 3'b011, 2'b00
            } : begin
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b1;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b1;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            {
                ADDR_LOAD, 3'b011, 2'b00
            } : begin
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b0;
                pc_clear  = 1'b0;
                addr_load = 1'b1;
            end
            {
                RAM_DATA_READ, 3'b011, 2'b00
            } : begin
                //* delay to read from RAM
                //* also wb_sel = 2'b11 and to prepare for mdata
                //* rg_sel for Rd to receive mdata
                sel_wb    = 2'b11;
                sel_reg   = 2'b01;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b0;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            {
                WRITE_VALUE, 3'b011, 2'b00
            } : begin
                //* write to Rd
                sel_wb    = 2'b11;
                sel_reg   = 2'b01;
                en_w      = 1'b1;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b0;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end

            {
                READ_VALUEA, 3'b100, 2'b00
            } : begin
                //* select Rn and enable A
                sel_wb    = 2'b00;
                sel_reg   = 2'b10;
                en_w      = 1'b0;
                A_en      = 1'b1;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b1;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            {
                ENABLE_C, 3'b100, 2'b00
            } : begin
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b1;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b1;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b1;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            {
                ADDR_LOAD, 3'b100, 2'b00
            } : begin
                //* load_addr and sel_addr = 0
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b0;
                pc_clear  = 1'b0;
                addr_load = 1'b1;
            end
            {
                READ_VALUEB, 3'b100, 2'b00
            } : begin
                //* select Rd and enable B
                sel_wb    = 2'b00;
                sel_reg   = 2'b01;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b1;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b1;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b0;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            {
                ENABLE_C_STR, 3'b100, 2'b00
            } : begin
                //* enable C for writing RAM data
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b1;
                status_en = 1'b0;
                A_sel     = 1'b1;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b0;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            {
                RAM_DATA_WRITE, 3'b100, 2'b00
            } : begin
                //* enable write to RAM
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b1;
                addr_sel  = 1'b0;
                pc_clear  = 1'b0;
                addr_load = 1'b0;
            end
            default: begin
                sel_wb    = 2'b00;
                sel_reg   = 2'b00;
                en_w      = 1'b0;
                A_en      = 1'b0;
                B_en      = 1'b0;
                C_en      = 1'b0;
                status_en = 1'b0;
                A_sel     = 1'b0;
                B_sel     = 1'b0;
                ir_load   = 1'b0;
                pc_load   = 1'b0;
                en_w_ram  = 1'b0;
                addr_sel  = 1'b0;
                pc_clear  = 1'b1;
                addr_load = 1'b0;
            end

        endcase
    end

    always_ff @(posedge clk) begin

        if (~rst_n) begin
            state <= FIRST_PC_LOAD;
        end
        else begin
            case (state)
                HALT: if (~rst_n) state <= FIRST_PC_LOAD;
                PC_LOAD: state <= PC_READ;
                FIRST_PC_LOAD: state <= PC_READ;
                PC_READ: state <= INSTR_LOAD;
                INSTR_LOAD: state <= DELAY;
                DELAY: begin
                    if (opcode == 3'b111) state <= HALT;
                    else if (opcode == 3'b110) begin
                        if (ALU_op == 2'b10) state <= WRITE_VALUE;
                        else if (ALU_op == 2'b00) state <= READ_VALUEB;
                    end
                    else if (opcode == 3'b101) begin
                        if (ALU_op == 2'b11) state <= READ_VALUEB;
                        else state <= READ_VALUEA;
                    end
                    else if (opcode == 3'b011 || opcode == 3'b100) state <= READ_VALUEA;
                end
                WRITE_VALUE: state <= PC_LOAD;
                READ_VALUEA: begin
                    if (opcode == 3'b011 || opcode == 3'b100) state <= ENABLE_C;
                    else state <= READ_VALUEB;
                end
                READ_VALUEB: begin
                    if (sel_addr == 1'b0) state <= ENABLE_C_STR;
                    else state <= ENABLE_C;
                end
                ENABLE_C: begin
                    if (opcode == 3'b101 && ALU_op == 2'b01) state <= PC_LOAD;
                    else if (opcode == 3'b011 || opcode == 3'b100) state <= ADDR_LOAD;
                    else state <= WRITE_VALUE;
                end
                ENABLE_C_STR: state <= RAM_DATA_WRITE;
                ADDR_LOAD: begin
                    if (opcode === 3'b011) state <= RAM_DATA_READ;
                    else if (opcode === 3'b100) state <= READ_VALUEB;
                end
                RAM_DATA_READ: state <= WRITE_VALUE;
                RAM_DATA_WRITE: state <= PC_LOAD;
            endcase
        end
    end
endmodule : controller

module ALU (
    input  [15:0] val_A,
    input  [15:0] val_B,
    input  [ 1:0] ALU_op,
    output [15:0] ALU_out,
    output        Z,
    output        N,
    output        V
);
    reg [15:0] alu_out;
    assign ALU_out = alu_out;
    reg z, n, v;
    assign Z = z, N = n, V = v;
    reg [15:0] subtract;
    always_comb begin
        case (ALU_op)
            2'b00:   {alu_out, z, n, v, subtract} = {val_A + val_B, 3'b000, 16'b0};
            2'b01: begin
                subtract = val_A - val_B;
                if (subtract == 16'b0) {alu_out, z, n, v} = {subtract, 3'b100};
                else if ((val_A[15] ^ val_B[15]) == 1'b1 && (subtract[15] ^ val_A[15] == 1'b1)) {alu_out, z, n, v} = {subtract, 3'b001};
                else if (subtract[15] == 1'b1) {alu_out, z, n, v} = {subtract, 3'b010};
                else {alu_out, z, n, v} = {subtract, 3'b000};
            end
            2'b10:   {alu_out, z, n, v, subtract} = {val_A & val_B, 3'b000, 16'b0};
            default: {alu_out, z, n, v, subtract} = {~val_B, 3'b000, 16'd0};
        endcase
    end
endmodule : ALU

module shifter (
    input      [15:0] shift_in,
    input      [ 1:0] shift_op,
    output reg [15:0] shift_out
);
    always_comb begin
        case (shift_op)
            2'b00: shift_out = shift_in;
            2'b01: shift_out = {shift_in[14:0], 1'b0};
            2'b10: shift_out = {1'b0, shift_in[15:1]};
            default shift_out = {shift_in[15], shift_in[15:1]};
        endcase
    end
endmodule : shifter
module idecoder (
    input  [15:0] ir,
    input  [ 1:0] reg_sel,
    output [ 2:0] opcode,
    output [ 1:0] ALU_op,
    output [ 1:0] shift_op,
    output [15:0] sximm5,
    output [15:0] sximm8,
    output [ 2:0] r_addr,
    output [ 2:0] w_addr
);
    wire [2:0] Rm, Rd, Rn;
    wire [7:0] imm8;
    wire [4:0] imm5;
    assign shift_op = ir[4:3];
    assign ALU_op   = ir[12:11];
    assign opcode   = ir[15:13];
    assign sximm8   = {{8{ir[7]}}, ir[7:0]};
    assign sximm5   = {{11{ir[4]}}, ir[4:0]};
    assign Rm       = ir[2:0];
    assign Rd       = ir[7:5];
    assign Rn       = ir[10:8];
    reg [2:0] addr_r, addr_w;
    assign {r_addr, w_addr} = {addr_r, addr_w};
    always_comb begin
        case (reg_sel)
            2'b00:   {addr_w, addr_r} = {Rm, Rm};
            2'b01:   {addr_w, addr_r} = {Rd, Rd};
            2'b10:   {addr_w, addr_r} = {Rn, Rn};
            default: {addr_w, addr_r} = 6'b0;
        endcase
    end
endmodule : idecoder

module datapath (
    input         clk,
    input  [15:0] mdata,
    input  [ 7:0] pc,
    input  [ 1:0] wb_sel,
    input  [ 2:0] w_addr,
    input         w_en,
    input  [ 2:0] r_addr,
    input         en_A,
    input         en_B,
    input  [ 1:0] shift_op,
    input         sel_A,
    input         sel_B,
    input  [ 1:0] ALU_op,
    input         en_C,
    input         en_status,
    input  [15:0] sximm8,
    input  [15:0] sximm5,
    output [15:0] datapath_out,
    output        Z_out,
    output        N_out,
    output        V_out,
    output [15:0] ram_w_data
);
    reg [15:0] w_data;
    always_comb begin
        case (wb_sel)
            2'b00:   w_data = datapath_out;
            2'b01:   w_data = {8'b0, pc};
            2'b10:   w_data = sximm8;
            default: w_data = mdata;
        endcase
    end

    wire [15:0] r_data;
    regfile registerfile (
        .w_data,
        .w_addr,
        .w_en,
        .r_addr,
        .clk,
        .r_data
    );

    reg [15:0] A, B;
    always_ff @(posedge clk) if (en_A) A <= r_data;
    always_ff @(posedge clk) if (en_B) B <= r_data;

    wire [15:0] shift_out;
    shifter shift (
        .shift_in(B),
        .shift_op,
        .shift_out
    );

    wire [15:0] val_A, val_B;
    assign val_A = (sel_A) ? 16'b0 : A;
    assign val_B = (sel_B) ? sximm5 : shift_out;

    wire [15:0] ALU_out;
    wire Z, N, V;
    ALU alu (
        .val_A,
        .val_B,
        .ALU_op,
        .ALU_out,
        .Z,
        .N,
        .V
    );

    reg out_z, out_n, out_v;
    reg [15:0] out_datapath;
    reg [15:0] data_w_ram;
    assign Z_out        = out_z,        N_out = out_n, V_out = out_v;
    assign datapath_out = out_datapath;
    assign ram_w_data   = data_w_ram;
    always_ff @(posedge clk) if (en_C) out_datapath <= ALU_out;
    always_ff @(posedge clk) if (en_C) data_w_ram <= ALU_out;
    always_ff @(posedge clk) begin
        if (en_status) begin
            out_z <= Z;
            out_n <= N;
            out_v <= V;
        end
    end
endmodule : datapath

