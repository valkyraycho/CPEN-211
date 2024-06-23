module q1_tb();
    reg clk, reset;
    reg [1:0] in;
    wire [1:0] out;

    top_module dut(clk, reset, in, out);

    initial
    begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial
    begin
        reset = 1'b0;
        #20;

        reset = 1'b1;
        #10;
        assert(out === 2'b00) $display("[PASS] A after reset");
        else $error("[FAIL] A after reset");

        reset = 1'b0;

        in = 2'b11;
        #10;
        assert(out === 2'b01) $display("[PASS] A -> B");
        else $error("[FAIL] A -> B");

        in = 2'b00;
        #10;
        assert(out === 2'b11) $display("[PASS] B -> D");
        else $error("[FAIL] B -> D");

        #10;
        assert(out === 2'b00) $display("[PASS] D -> E");
        else $error("[FAIL] D -> E");

        #10;
        assert(out === 2'b00) $display("[PASS] E -> A");
        else $error("[FAIL] E -> A");

        in = 2'b00;
        #10;
        assert(out === 2'b10) $display("[PASS] A -> C");
        else $error("[FAIL] A -> C");

        in = 2'b01;
        #10;
        assert(out === 2'b11) $display("[PASS] C -> D");
        else $error("[FAIL] C -> D");

        #10;
        assert(out === 2'b00) $display("[PASS] D -> E");
        else $error("[FAIL] D -> E");

        #10;
        assert(out === 2'b00) $display("[PASS] E -> A");
        else $error("[FAIL] E -> A");

        $stop();
    end
endmodule: q1_tb