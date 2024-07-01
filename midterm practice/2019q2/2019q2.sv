module q2(input clk, input reset, input [1:0] in, output [1:0] out);
    reg [1:0] tmp;
    assign out = tmp;

    enum reg [2:0] // assign each state
    {
        A = 3'b000,
        B = 3'b001,
        C = 3'b010,
        D = 3'b011,
        E = 3'b100
    } state;

    always_comb // assign each output
    begin
        case(state)
        A: tmp = 2'b10;
        B: tmp = 2'b01;
        C: tmp = 2'b10;
        D: tmp = 2'b11;
        default tmp = 2'b00;
        endcase
    end

    always_ff @(posedge clk)
    begin
        if(reset) state <= A;
        else
        begin
            casex({state, in})
            {A, 2'b10}: state <= B;
            {A, 2'b01}: state <= E;
            {B, 2'b01}: state <= E;
            {B, 2'b10}: state <= D;
            {B, 2'b11}: state <= C;
            {C, 2'bxx}: state <= B;
            {D, 2'b11}: state <= C;
            {E, 2'b11}: state <= D;
            endcase
        end
    end
endmodule: q2