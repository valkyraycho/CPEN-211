module controller (
    input              clk,
    input              rst_n,
    input        [2:0] opcode,
    input        [1:0] ALU_op,
    input        [1:0] shift_op,
    input              Z,
    input              N,
    input              V,
    output logic [1:0] reg_sel,
    output logic [1:0] wb_sel,
    output logic       w_en,
    output logic       en_A,
    output logic       en_B,
    output logic       en_C,
    output logic       en_status,
    output logic       sel_A,
    output logic       sel_B,
    output logic       load_ir,
    output logic       load_pc,
    output logic       ram_w_en,
    output logic       sel_addr,
    output logic       clear_pc,
    output logic       load_addr
);

    typedef enum {
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
    } state_t;

    state_t state, next_state;

    localparam [4:0] MOVIMM = 5'b11010;
    localparam [4:0] MOV = 5'b11000;
    localparam [4:0] ADD = 5'b10100;
    localparam [4:0] CMP = 5'b10101;
    localparam [4:0] AND = 5'b10110;
    localparam [4:0] MVN = 5'b10111;
    localparam [4:0] LDR = 5'b01100;
    localparam [4:0] STR = 5'b10000;

    logic [4:0] INSTR;
    assign INSTR = {opcode, ALU_op};


    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) state <= FIRST_PC_LOAD;
        else state <= next_state;
    end

    always_comb begin
        wb_sel     = 2'b0;
        reg_sel    = 2'b0;
        w_en       = 1'b0;
        en_A       = 1'b0;
        en_B       = 1'b0;
        en_C       = 1'b0;
        en_status  = 1'b0;
        sel_A      = 1'b0;
        sel_B      = 1'b0;
        load_ir    = 1'b0;
        load_pc    = 1'b0;
        ram_w_en   = 1'b0;
        sel_addr   = 1'b1;
        clear_pc   = 1'b0;
        load_addr  = 1'b0;
        next_state = state;

        case (state)
            HALT: begin
                clear_pc = 1'b1;
                if (!rst_n) next_state = FIRST_PC_LOAD;
            end

            FIRST_PC_LOAD, PC_LOAD: begin
                load_pc    = 1'b1;
                clear_pc   = (state == FIRST_PC_LOAD);
                next_state = PC_READ;
            end

            PC_READ: begin
                next_state = INSTR_LOAD;
            end

            INSTR_LOAD: begin
                load_ir    = 1'b1;
                next_state = DELAY;
            end

            DELAY: begin
                load_ir = 1'b1;
                if (opcode == 3'b111) next_state = HALT;
                else if (opcode == 3'b110) begin
                    if (ALU_op == 2'b10) next_state = WRITE_VALUE;
                    else if (ALU_op == 2'b00) next_state = READ_VALUEB;
                end
                else if (opcode == 3'b101) begin
                    if (ALU_op == 2'b11) next_state = READ_VALUEB;
                    else next_state = READ_VALUEA;
                end
                else if (opcode == 3'b011 || opcode == 3'b100) next_state = READ_VALUEA;
            end

            WRITE_VALUE: begin
                w_en    = 1'b1;
                reg_sel = 2'b01;
                case (INSTR)
                    MOVIMM: begin
                        reg_sel = 2'b10;
                        wb_sel  = 2'b10;
                    end
                    MOV: wb_sel = 2'b00;
                    ADD, AND: wb_sel = 2'b00;
                    MVN: wb_sel = 2'b00;
                    LDR: begin
                        wb_sel   = 2'b11;
                        sel_addr = 1'b0;
                    end
                endcase
                next_state = PC_LOAD;
            end
            READ_VALUEA: begin
                en_A       = 1'b1;
                next_state = READ_VALUEB;
                reg_sel    = 2'b10;
                case (INSTR)
                    LDR, STR: begin
                        sel_B      = 1'b1;
                        next_state = ENABLE_C;
                    end
                endcase
            end
            READ_VALUEB: begin
                en_B       = 1'b1;
                next_state = ENABLE_C;
                reg_sel    = 2'b00;
                case (INSTR)
                    MOV: sel_A = 1'b1;
                    ADD, AND: sel_A = 1'b0;
                    CMP: sel_A = 1'b0;
                    MVN: sel_A = 1'b1;
                    STR: begin
                        reg_sel    = 2'b01;
                        sel_A      = 1'b1;
                        sel_addr   = 1'b0;
                        next_state = ENABLE_C_STR;
                    end
                endcase
            end
            ENABLE_C: begin
                en_C       = 1'b1;
                next_state = WRITE_VALUE;
                case (INSTR)
                    MOV: begin
                        reg_sel = 2'b01;
                        sel_A   = 1'b1;
                    end
                    ADD, AND: reg_sel = 2'b01;
                    CMP: begin
                        reg_sel    = 2'b00;
                        en_C       = 1'b0;
                        en_status  = 1'b1;
                        next_state = PC_LOAD;
                    end
                    MVN: begin
                        reg_sel = 2'b01;
                        sel_A   = 1'b1;
                    end
                    LDR: begin
                        reg_sel    = 2'b00;
                        sel_B      = 1'b1;
                        next_state = ADDR_LOAD;
                    end
                    STR: begin
                        reg_sel    = 2'b00;
                        sel_B      = 1'b1;
                        next_state = ADDR_LOAD;
                    end
                endcase
            end
            ENABLE_C_STR: begin
                en_C       = 1'b1;
                sel_A      = 1'b1;
                sel_addr   = 1'b0;
                next_state = RAM_DATA_WRITE;
            end
            ADDR_LOAD: begin
                load_addr = 1'b1;
                sel_addr  = 1'b0;
                if (INSTR === LDR) next_state = RAM_DATA_READ;
                else if (INSTR === STR) next_state = READ_VALUEB;
            end
            RAM_DATA_READ: begin
                next_state = WRITE_VALUE;
                wb_sel     = 2'b11;
                reg_sel    = 2'b01;
                sel_addr   = 1'b0;
            end
            RAM_DATA_WRITE: begin
                next_state = PC_LOAD;
                ram_w_en   = 1'b1;
                sel_addr   = 1'b0;
            end
        endcase
    end
endmodule : controller
