module dff(clk, in, out);
    parameter n;
    input clk;
    input [n-1:0] in;
    input [n-1:0] out;
    always @(posedge clk)
        out <= in;
endmodule: dff

module q2(clk, A, B, Rn, Rd, C)
    input clk;
    input [7:0] A, B;
    input [2:0] Rn, Rd;
    output [7:0] C;

    wire eq;
    wire [2:0] n, d1, d2;
    wire [7:0] w1, w2, w3, w4;

    dff #8(.clk, A, w1);
    dff #8(.clk, B, w2);
    dff #8(.clk, w4, C);
    dff #3(.clk, Rn, n);
    dff #3(.clk, Rd, d1);
    dff #3(.clk, d1, d2);

    assign eq = (n == d2);
    assign w3 = eq ? C : w2;
    assign w4 = w3 + w1;
endmodule: q2