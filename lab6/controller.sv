module controller (
    input        clk,
    input        rst_n,
    input        start,
    input  [2:0] opcode,
    input  [1:0] ALU_op,
    input  [1:0] shift_op,
    input        Z,
    input        N,
    input        V,
    output       waiting,
    output [1:0] reg_sel,
    output [1:0] wb_sel,
    output       w_en,
    output       en_A,
    output       en_B,
    output       en_C,
    output       en_status,
    output       sel_A,
    output       sel_B
);
    reg [1:0] sel_reg, sel_wb;
    assign reg_sel = sel_reg, wb_sel = sel_wb;
    reg Wait, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel;
    assign waiting = Wait, w_en = en_w, en_A = A_en, en_B = B_en, en_C = C_en, en_status = status_en, sel_A = A_sel, sel_B = B_sel;
    enum reg [2:0] {
        WAIT,
        WRITE_VALUE,
        READ_VALUEA,
        READ_VALUEB,
        ENABLE_C
    } state;

    always_comb begin
        casex ({
            state, opcode, ALU_op
        })
            {WAIT, 3'bxxx, 2'bxx} : {Wait, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {1'b1, 11'b0};

            //* MOV imm
            {
                WRITE_VALUE, 3'b110, 2'b10
            } :
            {Wait, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {1'b0, 2'b10, 2'b10, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};

            //* MOV
            {
                READ_VALUEB, 3'b110, 2'b00
            } :
            {Wait, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {
                1'b0, 2'b00, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0
            };  // select Rm and enable B
            {
                ENABLE_C, 3'b110, 2'b00
            } :
            {Wait, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {
                1'b0, 2'b00, 2'b01, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0
            };  // enable C
            {
                WRITE_VALUE, 3'b110, 2'b00
            } :
            {Wait, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {
                1'b0, 2'b00, 2'b01, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0
            };  // select Rd and enable write

            //* ADD & AND
            {
                READ_VALUEA, 3'b101, 2'bx0
            } :
            {Wait, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {
                1'b0, 2'b00, 2'b10, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0
            };  // select Rn and enable A
            {
                READ_VALUEB, 3'b101, 2'bx0
            } :
            {Wait, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {
                1'b0, 2'b00, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0
            };  // select Rm and enable B
            {
                ENABLE_C, 3'b101, 2'bx0
            } :
            {Wait, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {
                1'b0, 2'b00, 2'b01, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0
            };  // enable C
            {
                WRITE_VALUE, 3'b101, 2'bx0
            } :
            {Wait, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {
                1'b0, 2'b00, 2'b01, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0
            };  // select Rd and enable write

            //* CMP
            {
                READ_VALUEA, 3'b101, 2'b01
            } :
            {Wait, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {
                1'b0, 2'b00, 2'b10, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0
            };  // select Rn and enable A
            {
                READ_VALUEB, 3'b101, 2'b01
            } :
            {Wait, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {
                1'b0, 2'b00, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0
            };  // select Rm and enable B
            {
                ENABLE_C, 3'b101, 2'b01
            } :
            {Wait, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {1'b0, 2'b00, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0};

            // * MVN
            {
                READ_VALUEB, 3'b101, 2'b11
            } :
            {Wait, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {
                1'b0, 2'b00, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0
            };  // select Rm and enable B
            {
                ENABLE_C, 3'b101, 2'b11
            } :
            {Wait, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {
                1'b0, 2'b00, 2'b01, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0
            };  // enable C
            {
                WRITE_VALUE, 3'b101, 2'b11
            } :
            {Wait, sel_wb, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {
                1'b0, 2'b00, 2'b01, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0
            };  // select Rd and enable write

            default {Wait, sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = 12'b0;
        endcase
    end

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            state <= WAIT;
        end
        else begin
            case (state)
                WAIT:
                if (start) begin
                    if (opcode == 3'b110) begin
                        if (ALU_op == 2'b10) state <= WRITE_VALUE;
                        else if (ALU_op == 2'b00) state <= READ_VALUEB;
                    end
                    else if (opcode == 3'b101) begin
                        if (ALU_op == 2'b11) state <= READ_VALUEB;
                        else state <= READ_VALUEA;
                    end
                    else state <= WAIT;
                end
                WRITE_VALUE: state <= WAIT;
                READ_VALUEA: state <= READ_VALUEB;
                READ_VALUEB: state <= ENABLE_C;
                ENABLE_C:
                if (opcode == 3'b101 && ALU_op == 2'b01) state <= WAIT;
                else state <= WRITE_VALUE;
            endcase
        end
    end
endmodule : controller
