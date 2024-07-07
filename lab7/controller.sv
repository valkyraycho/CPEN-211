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
