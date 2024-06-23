`timescale 1 ps / 1 ps
module tb_cpu(output err);
    reg clk, rst_n, load, start;
    reg [15:0] instr;
    wire waiting, N, V, Z;
    wire [15:0] out;

    integer numpass;
    integer numfail;
    reg error;
    assign err = error;

    task reset; rst_n = 1'b0; #5; clk = 1'b1; #5; rst_n = 1'b1; clk = 1'b0; #5; endtask
    task clock; clk = 1'b1; #5; clk = 1'b0; #5; endtask
    task initiate; start = 1'b1; load = 1'b1; #5; clock; start = 1'b0; load = 1'b0; #5; endtask
    task set_value(input [15:0] ir); instr = ir; initiate; clock; clock; endtask
    cpu dut(.clk, .rst_n, .load, .start, .instr, .waiting, .out, .N, .V, .Z);
    initial
    begin
        {clk, load, start} = 3'b0;
        rst_n = 1'b1;
        instr = 16'b0;
        numfail = 1'b0;
        numpass = 1'b0;
        error = 1'b0;
        #5;

        reset;
        assert(waiting === 1'b1)
        begin
            $display("[PASS] reset to wait");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] reset to wait");
            numfail = numfail + 1;
            error = 1'b1;
        end

        set_value(16'b1101000000000001);
        set_value(16'b1101000100000010);
        set_value(16'b1101001000000011);
        set_value(16'b1101001100000100);
        set_value(16'b1101010000000101);
        set_value(16'b1101010100000110);
        set_value(16'b1101011000000111);
        set_value(16'b1101011100001000);

        //MOV r2 r6
        instr = 16'b1100000001000110;
        initiate;
        clock; clock; clock; clock;
        assert(waiting === 1'b0)
        begin
            $display("[PASS] waiting is 0 during calculation");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] waiting is 0 during calculation");
            numfail = numfail + 1;
            error = 1'b1;
        end
        clock;
        assert(out === 16'd7 && {Z, V, N} === 3'b000 && waiting === 1'b1)
        begin
            $display("[PASS] MOV r2 r6");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] MOV r2 r6");
            numfail = numfail + 1;
            error = 1'b1;
        end
        
        //ADD r7 r2 r6
        instr = 16'b1010011101000110;
        initiate;
        clock; clock; clock; clock; clock; clock;
        assert(out === 16'd14 && {Z, V, N} === 3'b000 && waiting === 1'b1)
        begin
            $display("[PASS] ADD r7 r2 r6");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] ADD r7 r2 r6");
            numfail = numfail + 1;
            error = 1'b1;
        end
        
        //CMP r3 r5
        instr = 16'b1010101100000101;
        initiate;
        clock; clock; clock; clock; clock;
        assert(out === 16'b1111111111111110 && {Z, V, N} === 3'b001 && waiting === 1'b1)
        begin
            $display("[PASS] CMP r3 r5");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] CMP r3 r5");
            numfail = numfail + 1;
            error = 1'b1;
        end 

        //AND r3 r5 r0
        instr = 16'b1011001110100000;
        initiate;
        clock; clock; clock; clock; clock; clock;
        assert(out === 16'b0 && {Z, V, N} === 3'b000 && waiting === 1'b1)
        begin
            $display("[PASS] AND r3 r5 r0");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] AND r3 r5 r0");
            numfail = numfail + 1;
            error = 1'b1;
        end 

        //MVN r7 r4
        instr = 16'b1011100011100100;
        initiate;
        clock; clock; clock; clock; clock;     
        assert(out === 16'b1111111111111010 && {Z, V, N} === 3'b000 && waiting === 1'b1)
        begin
            $display("[PASS] MVN r7 r4");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] MVN r7 r4");
            numfail = numfail + 1;
            error = 1'b1;
        end

        //MOV r2 r1 lsl#1
        instr = 16'b1100000001001001;
        initiate;
        clock; clock; clock; clock; clock;
        assert(out === 16'd4 && {Z, V, N} === 3'b000 && waiting === 1'b1)
        begin
            $display("[PASS] MOV r2 r1 lsl#1");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] MOV r2 r1 lsl#1");
            numfail = numfail + 1;
            error = 1'b1;
        end

        //ADD r7 r2 r6 lsr#1
        instr = 16'b1010011101010110;
        initiate;
        clock; clock; clock; clock; clock; clock;
        assert(out === 16'd7 && {Z, V, N} === 3'b000 && waiting === 1'b1)
        begin
            $display("[PASS] ADD r7 r2 r6 lsr#1");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] ADD r7 r2 r6 lsr#1");
            numfail = numfail + 1;
            error = 1'b1;
        end

        //CMP r3 r5 arith rs #1
        instr = 16'b1010101100011101;
        initiate;
        clock; clock; clock; clock; clock;
        assert(out === 16'b1111111111111101 && {Z, V, N} === 3'b001 && waiting === 1'b1)
        begin
            $display("[PASS] CMP r3 r5 arith rs #1");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] CMP r3 r5 arith rs #1");
            numfail = numfail + 1;
            error = 1'b1;
        end

        set_value(16'b1101000010000011);
        set_value(16'b1101000110000011);
        //CMP zero result
        instr = 16'b1010100100000000;
        initiate;
        clock; clock; clock; clock; clock;
        assert(out === 16'b0 && {Z, V, N} === 3'b100 && waiting === 1'b1)
        begin
            $display("[PASS] CMP zero result");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] CMP zero result");
            numfail = numfail + 1;
            error = 1'b1;
        end 

        set_value(16'b1101000001111111);
        set_value(16'b1101000110000000);
        //CMP neg result
        instr = 16'b1010100100000000;
        initiate;
        clock; clock; clock; clock; clock;
        assert(out === 16'b1111111100000001 && {Z, V, N} === 3'b001 && waiting === 1'b1)
        begin
            $display("[PASS] CMP neg result");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] CMP neg result");
            numfail = numfail + 1;
            error = 1'b1;
        end 

        $display("\n");
        $display("Number of passed cases: %d", numpass);
        $display("Number of failed cases: %d", numfail);
        $stop();
    end
endmodule: tb_cpu
