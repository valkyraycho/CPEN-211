`timescale 1 ps / 1 ps
module tb_datapath(output err);
    reg clk, wb_sel, w_en, en_A, en_B, sel_A, sel_B, en_C, en_status;
    reg [15:0] datapath_in;
    reg [2:0] w_addr, r_addr;
    reg [1:0] shift_op, ALU_op;
    wire [15:0] datapath_out;
    wire Z_out;

    reg error;
    assign err = error;

    datapath dut(.clk, .datapath_in, .wb_sel, .w_addr, .w_en, .r_addr, .en_A, .en_B, .shift_op, .sel_A, .sel_B, .ALU_op, .en_C, .en_status, .datapath_out, .Z_out);

    initial
    begin
        // initialize values
        {clk, wb_sel, w_en, en_A, en_B, sel_A, sel_B, en_C, en_status} = 9'b0;
        datapath_in = 16'b0;
        {w_addr, r_addr} = 6'b0;
        {shift_op, ALU_op} = 4'b0;
        #5;

        // set values for registers
        datapath_in = 16'd1;
        wb_sel = 1'b1;
        w_addr = 3'd0; #5;
        w_en = 1'b1; #5;
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        datapath_in = 16'd2;
        w_addr = 3'd1; #5;
        w_en = 1'b1; #5;
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        datapath_in = 16'd3;
        w_addr = 3'd2; #5;
        w_en = 1'b1; #5;
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        datapath_in = 16'd4;
        w_addr = 3'd3; #5;
        w_en = 1'b1; #5;
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        datapath_in = 16'd5;
        w_addr = 3'd4; #5;
        w_en = 1'b1; #5;
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        datapath_in = 16'd6;
        w_addr = 3'd5; #5;
        w_en = 1'b1; #5;
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        datapath_in = 16'd7;
        w_addr = 3'd6; #5;
        w_en = 1'b1; #5;
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        datapath_in = 16'd8;
        w_addr = 3'd7; #5;
        w_en = 1'b1; #5;
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        wb_sel = 1'b0;

        // r5 = r2 + r3 (3 + 4 = 7)
        r_addr = 3'd2; #5;
        en_A = 1'b1; #5;
        clk = 1'b1; #5;
        en_A = 1'b0;
        clk = 1'b0; #5;

        r_addr = 3'd3; #5;
        en_B = 1'b1; #5;
        clk = 1'b1; #5;
        en_B = 1'b0;
        clk = 1'b0; #5;

        ALU_op = 2'b00;
        sel_A = 1'b0;
        sel_B = 1'b0;
        shift_op = 2'b00;

        en_C = 1'b1; en_status = 1'b1; #5;
        clk = 1'b1; #5;
        en_C = 1'b0; en_status = 1'b0;
        clk = 1'b0; #5;

        w_addr = 3'd5; #5
        w_en = 1'b1; #5
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        assert(datapath_out === 16'd7 && Z_out === 0)
         begin
            $display("[PASS] r5 = r2 + r3 (3 + 4 = 7)");
            error = 1'b0;
        end
        else 
        begin
            $error("[FAIL] r5 = r2 + r3 (3 + 4 = 7)");
            error = 1'b1;
        end
        // end of r5 = r2 + r3 (3 + 4 = 7)

        // r4 = r6 - r1 (7 - 2 = 5)
        r_addr = 3'd6; #5;
        en_A = 1'b1; #5;
        clk = 1'b1; #5;
        en_A = 1'b0;
        clk = 1'b0; #5;

        r_addr = 3'd1; #5;
        en_B = 1'b1; #5;
        clk = 1'b1; #5;
        en_B = 1'b0;
        clk = 1'b0; #5;

        ALU_op = 2'b01;
        sel_A = 1'b0;
        sel_B = 1'b0;
        shift_op = 2'b00;

        en_C = 1'b1; en_status = 1'b1; #5;
        clk = 1'b1; #5;
        en_C = 1'b0; en_status = 1'b0;
        clk = 1'b0; #5;

        w_addr = 3'd4; #5
        w_en = 1'b1; #5
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        assert(datapath_out === 16'd5 && Z_out === 0)
         begin
            $display("[PASS] r4 = r6 - r1 (7 - 2 = 5)");
            error = 1'b0;
        end
        else 
        begin
            $error("[FAIL] r4 = r6 - r1 (7 - 2 = 5)");
            error = 1'b1;
        end
        // end of r4 = r6 - r1 (7 - 2 = 5)

        // r0 = r7 & r5 (1000 & 0111 = 0000)
        r_addr = 3'd7; #5;
        en_A = 1'b1; #5;
        clk = 1'b1; #5;
        en_A = 1'b0;
        clk = 1'b0; #5;

        r_addr = 3'd5; #5;
        en_B = 1'b1; #5;
        clk = 1'b1; #5;
        en_B = 1'b0;
        clk = 1'b0; #5;

        ALU_op = 2'b10;
        sel_A = 1'b0;
        sel_B = 1'b0;
        shift_op = 2'b00;

        en_C = 1'b1; en_status = 1'b1; #5;
        clk = 1'b1; #5;
        en_C = 1'b0; en_status = 1'b0;
        clk = 1'b0; #5;

        w_addr = 3'd0; #5
        w_en = 1'b1; #5
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        assert(datapath_out === 16'd0 && Z_out === 1)
         begin
            $display("[PASS] r7 & r5 = r0 (1000 & 0111 = 0000)");
            error = 1'b0;
        end
        else 
        begin
            $error("[FAIL] r7 & r5 = r0 (1000 & 0111 = 0000)");
            error = 1'b1;
        end
        // end of r0 = r7 & r5(1000 & 0111 = 0000)

        // r2 = ~r4 (~00000000000000000101 = 1111111111111010)
        r_addr = 3'd4; #5;
        en_B = 1'b1; #5;
        clk = 1'b1; #5;
        en_B = 1'b0;
        clk = 1'b0; #5;

        ALU_op = 2'b11;
        sel_B = 1'b0;
        shift_op = 2'b00;

        en_C = 1'b1; en_status = 1'b1; #5;
        clk = 1'b1; #5;
        en_C = 1'b0; en_status = 1'b0;
        clk = 1'b0; #5;

        w_addr = 3'd2; #5
        w_en = 1'b1; #5
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        assert(datapath_out === 16'b1111111111111010 && Z_out === 0)
         begin
            $display("[PASS] ~r4 = r2 (~00000000000000000101 = 1111111111111010)");
            error = 1'b0;
        end
        else 
        begin
            $error("[FAIL] ~r4 = r2 (1000 & 0111 = 0000)");
            error = 1'b1;
        end
        // end of r2 = ~r4 (~00000000000000000101 = 1111111111111010)

        // r5 = r1 + r3 lsl#2 (2 + 4 * 2 = 10) (leftshift)
        r_addr = 3'd1; #5;
        en_A = 1'b1; #5;
        clk = 1'b1; #5;
        en_A = 1'b0;
        clk = 1'b0; #5;

        r_addr = 3'd3; #5;
        en_B = 1'b1; #5;
        clk = 1'b1; #5;
        en_B = 1'b0;
        clk = 1'b0; #5;

        ALU_op = 2'b00;
        sel_A = 1'b0;
        sel_B = 1'b0;
        shift_op = 2'b01;

        en_C = 1'b1; en_status = 1'b1; #5;
        clk = 1'b1; #5;
        en_C = 1'b0; en_status = 1'b0;
        clk = 1'b0; #5;

        w_addr = 3'd5; #5
        w_en = 1'b1; #5
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        assert(datapath_out === 16'd10 && Z_out === 0)
         begin
            $display("[PASS] r1 + r3 lsl#2 = r5 (2 + 4 * 2 = 10)");
            error = 1'b0;
        end
        else 
        begin
            $error("[FAIL] r1 + r3 lsl#2 = r5 (2 + 4 * 2 = 10)");
            error = 1'b1;
        end
        // end of r5 = r1 + r3 lsl#2 (2 + 4 * 2 = 10) (leftshift)

        // r7 = r4 - r6 lsr#2 (5 - 7 / 2 = 2) (rightshift)
        r_addr = 3'd4; #5;
        en_A = 1'b1; #5;
        clk = 1'b1; #5;
        en_A = 1'b0;
        clk = 1'b0; #5;

        r_addr = 3'd6; #5;
        en_B = 1'b1; #5;
        clk = 1'b1; #5;
        en_B = 1'b0;
        clk = 1'b0; #5;

        ALU_op = 2'b01;
        sel_A = 1'b0;
        sel_B = 1'b0;
        shift_op = 2'b10;

        en_C = 1'b1; en_status = 1'b1; #5;
        clk = 1'b1; #5;
        en_C = 1'b0; en_status = 1'b0;
        clk = 1'b0; #5;

        w_addr = 3'd7; #5
        w_en = 1'b1; #5
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        assert(datapath_out === 16'd2 && Z_out === 0)
         begin
            $display("[PASS] r4 - r6 lsr#2 = r7 (5 - 7 / 2 = 2)");
            error = 1'b0;
        end
        else 
        begin
            $error("[FAIL] r4 - r6 lsr#2 = r7 (5 - 7 / 2 = 2)");
            error = 1'b1;
        end
        // end of r7 = r4 - r6 lsr#2 (5 - 7 / 2 = 2) (rightshift)

        // r3 = r1 & r2 (ARS) (0000000000000010 & 1111111111111101(1111111111111010>>1) = 0000000000000000) (arithmetic rightshift)
        r_addr = 3'd1; #5;
        en_A = 1'b1; #5;
        clk = 1'b1; #5;
        en_A = 1'b0;
        clk = 1'b0; #5;

        r_addr = 3'd2; #5;
        en_B = 1'b1; #5;
        clk = 1'b1; #5;
        en_B = 1'b0;
        clk = 1'b0; #5;

        ALU_op = 2'b10;
        sel_A = 1'b0;
        sel_B = 1'b0;
        shift_op = 2'b11;

        en_C = 1'b1; en_status = 1'b1; #5;
        clk = 1'b1; #5;
        en_C = 1'b0; en_status = 1'b0;
        clk = 1'b0; #5;

        w_addr = 3'd3; #5
        w_en = 1'b1; #5
        clk = 1'b1; #5;
        w_en = 1'b0;
        clk = 1'b0; #5;

        assert(datapath_out === 16'd0 && Z_out === 1)
         begin
            $display("[PASS] r1 & r2 (ARS) = r3");
            error = 1'b0;
        end
        else 
        begin
            $error("[FAIL] r1 & r2 (ARS) = r3");
            error = 1'b1;
        end
        // end of r3 = r1 & r2 (ARS) (0000000000000010 & 1111111111111101(1111111111111010>>1) = 0000000000000000) (arithmetic rightshift)

        $stop();
    end
endmodule: tb_datapath