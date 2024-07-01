module tb_regfile(output err);
    reg [15:0] w_data;
    reg [2:0] w_addr;
    reg w_en;
    reg [2:0] r_addr;
    reg clk;
    wire [15:0] r_data;

    integer numpass;
    integer numfail;
    reg error;
    assign err = error;

    regfile dut(.w_data, .w_addr, .w_en, .r_addr, .clk, .r_data);
    initial
    begin
        //set initial values
        numfail = 1'b0;
        numpass = 1'b0;
        error = 1'b0;
        w_data = 16'b0;
        w_addr = 3'b0;
        w_en = 1'b0;
        r_addr = 3'b0;
        clk = 1'b0;
        #5;

        //set values(1~8) to each register (r0~r7)
        w_data = 16'd1;
        w_addr = 3'd0; #5;
        w_en = 1'b1; #5;
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        w_data = 16'd2;
        w_addr = 3'd1; #5;
        w_en = 1'b1; #5;
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        w_data = 16'd3;
        w_addr = 3'd2; #5;
        w_en = 1'b1; #5;
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        w_data = 16'd4;
        w_addr = 3'd3; #5;
        w_en = 1'b1; #5;
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        w_data = 16'd5;
        w_addr = 3'd4; #5;
        w_en = 1'b1; #5;
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        w_data = 16'd6;
        w_addr = 3'd5; #5;
        w_en = 1'b1; #5;
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        w_data = 16'd7;
        w_addr = 3'd6; #5;
        w_en = 1'b1; #5;
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        w_data = 16'd8;
        w_addr = 3'd7; #5;
        w_en = 1'b1; #5;
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        r_addr = 3'd0; #5;
        assert(r_data === 16'd1)
        begin
          $display("[PASS] r0 has value 1");
          numpass = numpass + 1;
        end 
        else 
        begin
          $error("[FAIL] r0 has value 1");
          numfail = numfail + 1;
          error = 1'b1;
        end

        r_addr = 3'd1; #5;
        assert(r_data === 16'd2)
        begin
          $display("[PASS] r1 has value 2");
          numpass = numpass + 1;
        end 
        else 
        begin
          $error("[FAIL] r1 has value 2");
          numfail = numfail + 1;
          error = 1'b1;
        end

        r_addr = 3'd2; #5;
        assert(r_data === 16'd3)
        begin
          $display("[PASS] r2 has value 3");
          numpass = numpass + 1;
        end 
        else 
        begin
          $error("[FAIL] r2 has value 3");
          numfail = numfail + 1;
          error = 1'b1;
        end

        r_addr = 3'd3; #5;
        assert(r_data === 16'd4)
        begin
          $display("[PASS] r3 has value 4");
          numpass = numpass + 1;
        end 
        else 
        begin
          $error("[FAIL] r3 has value 4");
          numfail = numfail + 1;
          error = 1'b1;
        end

        r_addr = 3'd4; #5;
        assert(r_data === 16'd5)
        begin
          $display("[PASS] r4 has value 5");
          numpass = numpass + 1;
        end 
        else 
        begin
          $error("[FAIL] r4 has value 5");
          numfail = numfail + 1;
          error = 1'b1;
        end

        r_addr = 3'd5; #5;
        assert(r_data === 16'd6)
        begin
          $display("[PASS] r5 has value 6");
          numpass = numpass + 1;
        end 
        else 
        begin
          $error("[FAIL] r5 has value 6");
          numfail = numfail + 1;
          error = 1'b1;
        end

        r_addr = 3'd6; #5;
        assert(r_data === 16'd7)
        begin
          $display("[PASS] r6 has value 7");
          numpass = numpass + 1;
        end 
        else 
        begin
          $error("[FAIL] r6 has value 7");
          numfail = numfail + 1;
          error = 1'b1;
        end

        r_addr = 3'd7; #5;
        assert(r_data === 16'd8)
        begin
          $display("[PASS] r7 has value 8");
          numpass = numpass + 1;
        end 
        else 
        begin
          $error("[FAIL] r7 has value 8");
          numfail = numfail + 1;
          error = 1'b1;
        end

        $display("\n");
        $display("Number of passed cases: %d", numpass);
        $display("Number of failed cases: %d", numfail);
        $stop();
    end
endmodule: tb_regfile
