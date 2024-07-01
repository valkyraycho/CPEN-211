module q2_tb();
    reg clk, reset;
    reg [1:0] in;
    wire [1:0]out;

    q2 dut(.clk, .reset, .in, .out);

    initial
    begin
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    initial
    begin
        in <= 2'b00;
        reset <= 1'b1;
        #20;

        reset <= 1'b0;
        #20;
        assert(out === 2'b10) $display("[PASS] reset to A");
        else $error("[FAIL] reset to A");

        in <= 2'b10;
        #10;
        assert(out === 2'b01) $display("[PASS] A to B");
        else $error("[FAIL] A to B");

        in <= 2'b11;
        #10;
        assert(out === 2'b10) $display("[PASS] B to C");
        else $error("[FAIL] B to C");

        //in <= 2'b10;
        #10;
        assert(out === 2'b01) $display("[PASS] C back to B");
        else $error("[FAIL] C back to B");

        in <= 2'b01;
        #10;
        assert(out === 2'b00) $display("[PASS] B to E");
        else $error("[FAIL] B to E");

        in <= 2'b11;
        #10;
        assert(out === 2'b11) $display("[PASS] E to D");
        else $error("[FAIL] E to D");

        reset <= 1'b1;
        #10
        assert(out === 2'b10) $display("[PASS] reset to A");
        else $error("[FAIL] reset to A");

        $stop();
    end
endmodule: q2_tb