module train_top_tb();
    reg clk, rstn, train;
    wire g, y, r;

    train_top dut(.clk, .rstn, .train, .green(g), .yellow(y), .red(r));

    initial // create a clock
    begin
        clk <= 1'b0;
        forever #5 clk <= ~clk; // clock with period of 10 ticks
    end

    initial
    begin
        train <= 1'b0;
        rstn <= 1'b0;
        #20; // the initial setup usually takes longer

        rstn <= 1'b1; // try the reset case: any state -> green
        #20; // always remember to delay, and give rstn a longer time
        assert({g, y, r} === 3'b100) $display("[PASS] green after reset"); // must use ===
        else $error("[FAIL] green after reset");

        train <= 1'b1; // train enters when green
        #10;
        assert({g, y, r} === 3'b001) $display("[PASS] green -> red if train");
        else $error("[FAIL] green -> red if train");

        train <= 1'b0; // train leaves
        #10;
        assert({g,y,r} === 3'b010) $display("[PASS] red -> yellow when no train");
        else $error("[FAIL] red -> yellow when no train");

        #10;
        assert({g, y, r} === 3'b100) $display("[PASS] yellow -> green when no train");
        else $error("[FAIL] yellow -> green when no train");

        $stop();
    end
endmodule: train_top_tb