module controller (
    input              clk,
    input              rst_n,
    input              start,
    input        [2:0] opcode,
    input        [1:0] ALU_op,
    input        [1:0] shift_op,
    input              Z,
    input              N,
    input              V,
    output logic       waiting,
    output logic [1:0] reg_sel,
    output logic [1:0] wb_sel,
    output logic       w_en,
    output logic       en_A,
    output logic       en_B,
    output logic       en_C,
    output logic       en_status,
    output logic       sel_A,
    output logic       sel_B
);
    typedef enum {
        WAIT,
        READ_INSTR,
        WRITE_VALUE,
        READ_VALUEA,
        READ_VALUEB,
        ENABLE_C
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) state <= WAIT;
        else state <= next_state;
    end


    localparam [4:0] MOVIMM = 5'b11010;
    localparam [4:0] MOV = 5'b11000;
    localparam [4:0] ADD = 5'b10100;
    localparam [4:0] CMP = 5'b10101;
    localparam [4:0] AND = 5'b10110;
    localparam [4:0] MVN = 5'b10111;

    logic [4:0] INSTR;
    assign INSTR = {opcode, ALU_op};


    always_comb begin
        waiting    = 1'b0;
        reg_sel    = 2'b0;
        wb_sel     = 2'b0;
        w_en       = 1'b0;
        en_A       = 1'b0;
        en_B       = 1'b0;
        en_C       = 1'b0;
        en_status  = 1'b0;
        sel_A      = 1'b0;
        sel_B      = 1'b0;
        next_state = state;
        case (state)
            WAIT: begin
                waiting = 1'b1;
                if (start) next_state = READ_INSTR;
            end

            READ_INSTR: begin
                case (INSTR)
                    MOVIMM: begin
                        wb_sel     = 2'b10;
                        next_state = WRITE_VALUE;
                    end

                    MOV, MVN: begin
                        wb_sel     = 2'b00;
                        next_state = READ_VALUEB;
                    end

                    ADD, AND, CMP: begin
                        wb_sel     = 2'b00;
                        next_state = READ_VALUEA;
                    end
                endcase
            end

            WRITE_VALUE: begin
                next_state = WAIT;
                w_en       = 1'b1;
                case (INSTR)

                    MOVIMM: begin
                        reg_sel = 2'b10;
                        wb_sel  = 2'b10;
                    end

                    MOV, ADD, AND, MVN: begin
                        reg_sel = 2'b01;
                        wb_sel  = 2'b00;
                    end
                endcase
            end

            READ_VALUEA: begin
                next_state = READ_VALUEB;
                en_A       = 1'b1;
                reg_sel    = 2'b10;
            end

            READ_VALUEB: begin
                next_state = ENABLE_C;
                en_B       = 1'b1;
                reg_sel    = 2'b00;
            end

            ENABLE_C: begin
                next_state = WRITE_VALUE;
                en_C       = 1'b1;
                case (INSTR)

                    MOV: begin
                        wb_sel = 2'b10;
                        sel_A  = 1'b1;
                    end

                    ADD, AND: begin
                        wb_sel = 2'b00;
                    end

                    CMP: begin
                        en_C       = 1'b0;
                        en_status  = 1'b1;
                        wb_sel     = 2'b00;
                        next_state = WAIT;
                    end

                    MVN: begin
                        wb_sel = 2'b00;
                        sel_A  = 1'b1;
                    end
                endcase
            end
        endcase
    end

endmodule : controller
