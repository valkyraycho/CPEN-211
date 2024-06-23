module top_module(clk, reset, in, out);
    input clk, reset;
    input [1:0] in;
    output reg [1:0] out;

    enum reg [2:0] {A, B, C, D ,E} state;
    
    always_comb
    begin
        case (state)
            A: out = 2'b00;
            B: out = 2'b01;
            C: out = 2'b10;
            D: out = 2'b11;
            default: out = 2'b00;
        endcase
    end

    always_ff @(posedge clk)
    begin
        if(reset)
        begin
            state <= A;
        end
        else
        begin
            casex({state, in})
            {A, 2'b00}: state <= C;
            {A, 2'b11}: state <= B;
            {B, 2'b00}: state <= D;
            {C, 2'b01}: state <= D;
            {C, 2'b10}: state <= B;
            {D, 2'bxx}: state <= E;
            {E, 2'bxx}: state <= A;
            endcase
        end
    end
endmodule: top_module