module controller(input clk, input rst_n, input start,
                  input [2:0] opcode, input [1:0] ALU_op, input [1:0] shift_op,
                  input Z, input N, input V,
                  output waiting,
                  output [1:0] reg_sel, output [1:0] wb_sel, output w_en,
                  output en_A, output en_B, output en_C, output en_status,
                  output sel_A, output sel_B);
    reg [1:0] sel_reg, sel_wb;
    assign reg_sel = sel_reg, wb_sel = sel_wb;
    reg Wait, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel;
    assign waiting = Wait, w_en = en_w, en_A = A_en, en_B = B_en, en_C = C_en, en_status = status_en, sel_A = A_sel, sel_B = B_sel;
    enum reg [2:0] {WAIT, SELECT_VALUE, WRITE_VALUE, READ_VALUEA, READ_VALUEB , ENABLE_C} state;

    always_comb
    begin
        casex({state, opcode, ALU_op})
            {WAIT, 3'bxxx, 2'bxx}: {Wait, sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {1'b1, 11'b0};
            //move_immediate
            {SELECT_VALUE, 3'b110, 2'b10}: {sel_wb, Wait, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {2'b10, 10'b0};
            {WRITE_VALUE, 3'b110, 2'b10}: {sel_reg, en_w, sel_wb, Wait, A_en, B_en, C_en, status_en, A_sel, B_sel} = {2'b10, 1'b1, 2'b10, 7'b0};
            //MOV
            {SELECT_VALUE, 3'b110, 2'b00}: {sel_wb, Wait, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {2'b00, 10'b0};
            {READ_VALUEB, 3'b110, 2'b00}: {sel_reg, B_en, sel_wb, Wait, en_w, A_en, C_en, status_en, A_sel, B_sel} = {2'b00, 1'b1, 9'b0}; //{sel_reg, B_en} = {2'b00, 1'b1};
            {ENABLE_C, 3'b110, 2'b00}: {C_en, status_en, sel_wb, Wait, sel_reg, en_w, A_en, B_en, A_sel, B_sel} = {2'b11, 8'b0, 2'b10}; //{C_en, status_en} = 2'b11;
            {WRITE_VALUE, 3'b110, 2'b00}: {sel_reg, en_w, sel_wb, Wait, A_en, B_en, C_en, status_en, A_sel, B_sel} = {2'b01, 1'b1, 9'b0}; //{sel_reg, en_w} = {2'b01, 1'b1};
            //ADD
            {SELECT_VALUE, 3'b101, 2'b00}: {sel_wb, Wait, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {2'b00, 10'b0};
            {READ_VALUEA, 3'b101, 2'b00}: {sel_reg, A_en, sel_wb, Wait, en_w, B_en, C_en, status_en, A_sel, B_sel} = {2'b10, 1'b1, 9'b0}; //{sel_reg, A_en} = {2'b01, 1'b1};
            {READ_VALUEB, 3'b101, 2'b00}: {sel_reg, A_en, B_en, sel_wb, Wait, en_w, C_en, status_en, A_sel, B_sel} = {2'b00, 1'b0, 1'b1, 8'b0}; //{sel_reg, A_en, B_en} = {2'b00, 1'b0, 1'b1};
            {ENABLE_C, 3'b101, 2'b00}: {C_en, status_en, sel_wb, Wait, sel_reg, en_w, A_en, B_en, A_sel, B_sel} = {2'b11, 10'b0};
            {WRITE_VALUE, 3'b101, 2'b00}: {sel_reg, en_w, sel_wb, Wait, A_en, B_en, C_en, status_en, A_sel, B_sel} = {2'b01, 1'b1, 9'b0}; //{sel_reg, en_w} = {2'b01, 1'b1};
            //CMP
            {SELECT_VALUE, 3'b101, 2'b01}: {sel_wb, Wait, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {2'b00, 10'b0};
            {READ_VALUEA, 3'b101, 2'b01}: {sel_reg, A_en, sel_wb, Wait, en_w, B_en, C_en, status_en, A_sel, B_sel} = {2'b10, 1'b1, 9'b0}; //{sel_reg, A_en} = {2'b10, 1'b1};
            {READ_VALUEB, 3'b101, 2'b01}: {sel_reg, A_en, B_en, sel_wb, Wait, en_w, C_en, status_en, A_sel, B_sel} = {2'b00, 1'b0, 1'b1, 8'b0}; //{sel_reg, A_en, B_en} = {2'b00, 1'b0, 1'b1};
            {ENABLE_C, 3'b101, 2'b01}: {C_en, status_en, sel_wb, Wait, sel_reg, en_w, A_en, B_en, A_sel, B_sel} = {2'b11, 10'b0};
            //AND
            {SELECT_VALUE, 3'b101, 2'b10}: {sel_wb, Wait, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {2'b00, 10'b0};
            {READ_VALUEA, 3'b101, 2'b10}: {sel_reg, A_en, sel_wb, Wait, en_w, B_en, C_en, status_en, A_sel, B_sel} = {2'b10, 1'b1, 9'b0}; //{sel_reg, A_en} = {2'b01, 1'b1};
            {READ_VALUEB, 3'b101, 2'b10}: {sel_reg, A_en, B_en, sel_wb, Wait, en_w, C_en, status_en, A_sel, B_sel} = {2'b00, 1'b0, 1'b1, 8'b0}; //{sel_reg, A_en, B_en} = {2'b00, 1'b0, 1'b1};
            {ENABLE_C, 3'b101, 2'b10}: {C_en, status_en, sel_wb, Wait, sel_reg, en_w, A_en, B_en, A_sel, B_sel} = {2'b11, 10'b0};
            {WRITE_VALUE, 3'b101, 2'b10}: {sel_reg, en_w, sel_wb, Wait, A_en, B_en, C_en, status_en, A_sel, B_sel} = {2'b01, 1'b1, 9'b0}; //{sel_reg, en_w} = {2'b10, 1'b1};
            //MVN
            {SELECT_VALUE, 3'b101, 2'b11}: {sel_wb, Wait, sel_reg, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = {2'b00, 10'b0};
            {READ_VALUEB, 3'b101, 2'b11}: {sel_reg, B_en, sel_wb, Wait, en_w, A_en, C_en, status_en, A_sel, B_sel} = {2'b00, 1'b1, 9'b0}; //{sel_reg, B_en} = {2'b00, 1'b1};
            {ENABLE_C, 3'b101, 2'b11}: {C_en, status_en, sel_wb, Wait, sel_reg, en_w, A_en, B_en, A_sel, B_sel} = {2'b11, 8'b0, 2'b10}; //{C_en, status_en} = 2'b11;
            {WRITE_VALUE, 3'b101, 2'b11}: {sel_reg, en_w, sel_wb, Wait, A_en, B_en, C_en, status_en, A_sel, B_sel} = {2'b01, 1'b1, 9'b0}; //{sel_reg, en_w} = {2'b01, 1'b1};
            default {Wait, sel_reg, sel_wb, en_w, A_en, B_en, C_en, status_en, A_sel, B_sel} = 12'b000000000000;
        endcase
    end

    always_ff @(posedge clk)
    begin
        if(~rst_n)
        begin
            state <= WAIT;
        end
        else 
        begin
            case(state)
                WAIT: if(start) state <= SELECT_VALUE;
                SELECT_VALUE: if(opcode == 3'b110 && ALU_op == 2'b10) state <= WRITE_VALUE;
                              else if((opcode == 3'b110 && ALU_op == 2'b00) || (opcode == 3'b101 && ALU_op == 2'b11)) state <= READ_VALUEB;
                              else state <= READ_VALUEA;
                WRITE_VALUE: state <= WAIT;
                READ_VALUEA: state <= READ_VALUEB;
                READ_VALUEB: state <= ENABLE_C;
                ENABLE_C: if(opcode == 3'b101 && ALU_op == 2'b01) state <= WAIT;
                          else state <= WRITE_VALUE;
            endcase
        end
    end
endmodule: controller
