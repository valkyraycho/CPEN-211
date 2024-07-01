module tb_task3(output err);
    reg clk, rst_n;
    reg [7:0] start_pc;
    wire [15:0] out;

    integer numpass;
    integer numfail;
    reg error;
    assign err = error;

    task reset; rst_n = 1'b0; #5; clk = 1'b1; #5; rst_n = 1'b1; clk = 1'b0; #5; endtask
    task clock; clk = 1'b1; #5; clk = 1'b0; #5; endtask

    task3 dut(.clk, .rst_n, .start_pc, .out);

    initial
    begin
        {clk, rst_n} = 2'b01;
        start_pc = 8'd7;
        numfail = 1'b0;
        numpass = 1'b0;
        #5;

        reset;
        clock;clock;clock;clock;clock;clock;
        clock;clock;clock;clock;clock;
        clock;clock;clock;clock;clock;clock;
        assert(out === 16'd35)
        begin
            $display("[PASS]");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL]");
            numfail = numfail + 1;
            error = 1'b1;
        end      
        clock;clock;clock;clock;clock;clock;
        assert(out === 16'd28)
        begin
            $display("[PASS]");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL]");
            numfail = numfail + 1;
            error = 1'b1;
        end
        clock;clock;clock;clock;

        $display("\n");
        $display("Number of passed cases: %d", numpass);
        $display("Number of failed cases: %d", numfail);
        $stop();
    end
endmodule: tb_task3
