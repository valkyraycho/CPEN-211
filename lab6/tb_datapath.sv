module tb_datapath (
    output err
);
    reg clk, w_en, en_A, en_B, sel_A, sel_B, en_C, en_status;
    reg [15:0] mdata, sximm8, sximm5;
    reg [7:0] pc;
    reg [2:0] w_addr, r_addr;
    reg [1:0] wb_sel, shift_op, ALU_op;
    wire [15:0] datapath_out;
    wire Z_out, N_out, V_out;

    integer numpass;
    integer numfail;
    reg error;
    assign err = error;

    datapath dut (
        .clk,
        .mdata,
        .pc,
        .wb_sel,
        .w_addr,
        .w_en,
        .r_addr,
        .en_A,
        .en_B,
        .shift_op,
        .sel_A,
        .sel_B,
        .ALU_op,
        .en_C,
        .en_status,
        .sximm8,
        .sximm5,
        .datapath_out,
        .Z_out,
        .N_out,
        .V_out
    );
    task set_value([15:0] value, [2:0] address);
        sximm8 = value;
        w_addr = address;
        #5;
        w_en = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        w_en = 1'b0;
        clk  = 1'b0;
        #5;
    endtask

    initial begin
        // initialize values
        {clk, wb_sel, w_en, en_A, en_B, sel_A, sel_B, en_C, en_status} = 9'b0;
        mdata                                                          = 16'b0;
        sximm8                                                         = 16'b0;
        sximm5                                                         = 16'b0;
        pc                                                             = 8'b0;
        {w_addr, r_addr}                                               = 6'b0;
        {shift_op, ALU_op}                                             = 4'b0;
        numfail                                                        = 1'b0;
        numpass                                                        = 1'b0;
        error                                                          = 1'b0;
        #5;

        // set values for registers
        wb_sel = 2'b10;
        #5;
        set_value(16'd1, 3'd0);
        set_value(16'd2, 3'd1);
        set_value(16'd3, 3'd2);
        set_value(16'd4, 3'd3);
        set_value(16'd5, 3'd4);
        set_value(16'd6, 3'd5);
        set_value(16'd7, 3'd6);
        set_value(16'd8, 3'd7);
        wb_sel = 2'b00;

        // r5 = r2 + r3 (3 + 4 = 7)
        r_addr = 3'd2;
        #5;
        en_A = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_A = 1'b0;
        clk  = 1'b0;
        #5;

        r_addr = 3'd3;
        #5;
        en_B = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_B = 1'b0;
        clk  = 1'b0;
        #5;

        ALU_op    = 2'b00;
        sel_A     = 1'b0;
        sel_B     = 1'b0;
        shift_op  = 2'b00;

        en_C      = 1'b1;
        en_status = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_C      = 1'b0;
        en_status = 1'b0;
        clk       = 1'b0;
        #5;

        w_addr = 3'd5;
        #5 w_en = 1'b1;
        #5 clk = 1'b1;
        #5;
        w_en = 1'b0;
        clk  = 1'b0;
        #5;

        assert (datapath_out === 16'd7 && {Z_out, N_out, V_out} === 3'b000) begin
            $display("[PASS] r5 = r2 + r3 (3 + 4 = 7)");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] r5 = r2 + r3 (3 + 4 = 7)");
            numfail = numfail + 1;
            error   = 1'b1;
        end
        // end of r5 = r2 + r3 (3 + 4 = 7)

        // r4 = r6 - r1 (7 - 2 = 5)
        r_addr = 3'd6;
        #5;
        en_A = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_A = 1'b0;
        clk  = 1'b0;
        #5;

        r_addr = 3'd1;
        #5;
        en_B = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_B = 1'b0;
        clk  = 1'b0;
        #5;

        ALU_op    = 2'b01;
        sel_A     = 1'b0;
        sel_B     = 1'b0;
        shift_op  = 2'b00;

        en_C      = 1'b1;
        en_status = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_C      = 1'b0;
        en_status = 1'b0;
        clk       = 1'b0;
        #5;

        w_addr = 3'd4;
        #5 w_en = 1'b1;
        #5 clk = 1'b1;
        #5;
        w_en = 1'b0;
        clk  = 1'b0;
        #5;

        assert (datapath_out === 16'd5 && {Z_out, N_out, V_out} === 3'b000) begin
            $display("[PASS] r4 = r6 - r1 (7 - 2 = 5)");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] r4 = r6 - r1 (7 - 2 = 5)");
            numfail = numfail + 1;
            error   = 1'b1;
        end
        // end of r4 = r6 - r1 (7 - 2 = 5)

        // r0 = r7 & r5 (1000 & 0111 = 0000)
        r_addr = 3'd7;
        #5;
        en_A = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_A = 1'b0;
        clk  = 1'b0;
        #5;

        r_addr = 3'd5;
        #5;
        en_B = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_B = 1'b0;
        clk  = 1'b0;
        #5;

        ALU_op    = 2'b10;
        sel_A     = 1'b0;
        sel_B     = 1'b0;
        shift_op  = 2'b00;

        en_C      = 1'b1;
        en_status = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_C      = 1'b0;
        en_status = 1'b0;
        clk       = 1'b0;
        #5;

        w_addr = 3'd0;
        #5 w_en = 1'b1;
        #5 clk = 1'b1;
        #5;
        w_en = 1'b0;
        clk  = 1'b0;
        #5;

        assert (datapath_out === 16'd0 && {Z_out, N_out, V_out} === 3'b000) begin
            $display("[PASS] r7 & r5 = r0 (1000 & 0111 = 0000)");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] r7 & r5 = r0 (1000 & 0111 = 0000)");
            numfail = numfail + 1;
            error   = 1'b1;
        end
        // end of r0 = r7 & r5(1000 & 0111 = 0000)

        // r2 = ~r4 (~00000000000000000101 = 1111111111111010)
        r_addr = 3'd4;
        #5;
        en_B = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_B = 1'b0;
        clk  = 1'b0;
        #5;

        ALU_op    = 2'b11;
        sel_B     = 1'b0;
        shift_op  = 2'b00;

        en_C      = 1'b1;
        en_status = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_C      = 1'b0;
        en_status = 1'b0;
        clk       = 1'b0;
        #5;

        w_addr = 3'd2;
        #5 w_en = 1'b1;
        #5 clk = 1'b1;
        #5;
        w_en = 1'b0;
        clk  = 1'b0;
        #5;

        assert (datapath_out === 16'b1111111111111010 && {Z_out, N_out, V_out} === 3'b000) begin
            $display("[PASS] ~r4 = r2 (~00000000000000000101 = 1111111111111010)");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] ~r4 = r2 (1000 & 0111 = 0000)");
            numfail = numfail + 1;
            error   = 1'b1;
        end
        // end of r2 = ~r4 (~00000000000000000101 = 1111111111111010)

        // r5 = r1 + r3 lsl#2 (2 + 4 * 2 = 10) (leftshift)
        r_addr = 3'd1;
        #5;
        en_A = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_A = 1'b0;
        clk  = 1'b0;
        #5;

        r_addr = 3'd3;
        #5;
        en_B = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_B = 1'b0;
        clk  = 1'b0;
        #5;

        ALU_op    = 2'b00;
        sel_A     = 1'b0;
        sel_B     = 1'b0;
        shift_op  = 2'b01;

        en_C      = 1'b1;
        en_status = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_C      = 1'b0;
        en_status = 1'b0;
        clk       = 1'b0;
        #5;

        w_addr = 3'd5;
        #5 w_en = 1'b1;
        #5 clk = 1'b1;
        #5;
        w_en = 1'b0;
        clk  = 1'b0;
        #5;

        assert (datapath_out === 16'd10 && {Z_out, N_out, V_out} === 3'b000) begin
            $display("[PASS] r1 + r3 lsl#2 = r5 (2 + 4 * 2 = 10)");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] r1 + r3 lsl#2 = r5 (2 + 4 * 2 = 10)");
            numfail = numfail + 1;
            error   = 1'b1;
        end
        // end of r5 = r1 + r3 lsl#2 (2 + 4 * 2 = 10) (leftshift)

        // r7 = r4 - r6 lsr#2 (5 - 7 / 2 = 2) (rightshift)
        r_addr = 3'd4;
        #5;
        en_A = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_A = 1'b0;
        clk  = 1'b0;
        #5;

        r_addr = 3'd6;
        #5;
        en_B = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_B = 1'b0;
        clk  = 1'b0;
        #5;

        ALU_op    = 2'b01;
        sel_A     = 1'b0;
        sel_B     = 1'b0;
        shift_op  = 2'b10;

        en_C      = 1'b1;
        en_status = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_C      = 1'b0;
        en_status = 1'b0;
        clk       = 1'b0;
        #5;

        w_addr = 3'd7;
        #5 w_en = 1'b1;
        #5 clk = 1'b1;
        #5;
        w_en = 1'b0;
        clk  = 1'b0;
        #5;

        assert (datapath_out === 16'd2 && {Z_out, N_out, V_out} === 3'b000) begin
            $display("[PASS] r4 - r6 lsr#2 = r7 (5 - 7 / 2 = 2)");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] r4 - r6 lsr#2 = r7 (5 - 7 / 2 = 2)");
            numfail = numfail + 1;
            error   = 1'b1;
        end
        // end of r7 = r4 - r6 lsr#2 (5 - 7 / 2 = 2) (rightshift)

        // r3 = r1 & r2 (ARS) (0000000000000010 & 1111111111111101(1111111111111010>>1) = 0000000000000000) (arithmetic rightshift)
        r_addr = 3'd1;
        #5;
        en_A = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_A = 1'b0;
        clk  = 1'b0;
        #5;

        r_addr = 3'd2;
        #5;
        en_B = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_B = 1'b0;
        clk  = 1'b0;
        #5;

        ALU_op    = 2'b10;
        sel_A     = 1'b0;
        sel_B     = 1'b0;
        shift_op  = 2'b11;

        en_C      = 1'b1;
        en_status = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_C      = 1'b0;
        en_status = 1'b0;
        clk       = 1'b0;
        #5;

        w_addr = 3'd3;
        #5 w_en = 1'b1;
        #5 clk = 1'b1;
        #5;
        w_en = 1'b0;
        clk  = 1'b0;
        #5;

        assert (datapath_out === 16'd0 && {Z_out, N_out, V_out} === 3'b000) begin
            $display("[PASS] r1 & r2 (ARS) = r3");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] r1 & r2 (ARS) = r3");
            numfail = numfail + 1;
            error   = 1'b1;
        end
        // end of r3 = r1 & r2 (ARS) (0000000000000010 & 1111111111111101(1111111111111010>>1) = 0000000000000000) (arithmetic rightshift)

        // r5 = r2 - r4 (-6 - 5 = -11)
        r_addr = 3'd2;
        #5;
        en_A = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_A = 1'b0;
        clk  = 1'b0;
        #5;

        r_addr = 3'd4;
        #5;
        en_B = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_B = 1'b0;
        clk  = 1'b0;
        #5;

        ALU_op    = 2'b01;
        sel_A     = 1'b0;
        sel_B     = 1'b0;
        shift_op  = 2'b00;

        en_C      = 1'b1;
        en_status = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_C      = 1'b0;
        en_status = 1'b0;
        clk       = 1'b0;
        #5;

        w_addr = 3'd5;
        #5 w_en = 1'b1;
        #5 clk = 1'b1;
        #5;
        w_en = 1'b0;
        clk  = 1'b0;
        #5;

        assert (datapath_out === 16'b1111111111110101 && {Z_out, N_out, V_out} === 3'b010) begin
            $display("[PASS] r5 = r2 - r4 (-6 - 5 = -11)");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] r5 = r2 - r4 (-6 - 5 = -11)");
            numfail = numfail + 1;
            error   = 1'b1;
        end
        // end of r5 = r2 - r4 (-6 - 5 = -11)

        // r5 = r2 + r4 but sel_A and sel_B are 1 and sximm5 = -10
        sximm5 = 16'd10;
        r_addr = 3'd2;
        #5;
        en_A = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_A = 1'b0;
        clk  = 1'b0;
        #5;

        r_addr = 3'd4;
        #5;
        en_B = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_B = 1'b0;
        clk  = 1'b0;
        #5;

        ALU_op   = 2'b00;
        sel_A    = 1'b1;
        sel_B    = 1'b1;
        shift_op = 2'b00;
        #5;

        en_C      = 1'b1;
        en_status = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_C      = 1'b0;
        en_status = 1'b0;
        clk       = 1'b0;
        #5;

        w_addr = 3'd5;
        #5 w_en = 1'b1;
        #5 clk = 1'b1;
        #5;
        w_en = 1'b0;
        clk  = 1'b0;
        #5;

        assert (datapath_out === 16'd10 && {Z_out, N_out, V_out} === 3'b000) begin
            $display("[PASS] 0+10(sximm5) = 10");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] 0+10(sximm5) = 10");
            numfail = numfail + 1;
            error   = 1'b1;
        end
        // end of r5 = r2 - r4 

        // r0 = r1 - r7 (2 - 2 = 0)
        r_addr = 3'd1;
        #5;
        en_A = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_A = 1'b0;
        clk  = 1'b0;
        #5;

        r_addr = 3'd7;
        #5;
        en_B = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_B = 1'b0;
        clk  = 1'b0;
        #5;

        ALU_op    = 2'b01;
        sel_A     = 1'b0;
        sel_B     = 1'b0;
        shift_op  = 2'b00;

        en_C      = 1'b1;
        en_status = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_C      = 1'b0;
        en_status = 1'b0;
        clk       = 1'b0;
        #5;

        w_addr = 3'd0;
        #5 w_en = 1'b1;
        #5 clk = 1'b1;
        #5;
        w_en = 1'b0;
        clk  = 1'b0;
        #5;

        assert (datapath_out === 16'b0 && {Z_out, N_out, V_out} === 3'b100) begin
            $display("[PASS] r0 = r1 - r7 (2 - 2 = 0)");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] r0 = r1 - r7 (2 - 2 = 0)");
            numfail = numfail + 1;
            error   = 1'b1;
        end
        // end of r0 = r1 - r7 (2 - 2 = 0)

        //test overflow
        wb_sel = 2'b10;
        #5;
        set_value(16'b1000000000000000, 3'd0);
        set_value(16'b0111111111111111, 3'd1);
        wb_sel = 2'b00;

        r_addr = 3'd1;
        #5;
        en_A = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_A = 1'b0;
        clk  = 1'b0;
        #5;

        r_addr = 3'd0;
        #5;
        en_B = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_B = 1'b0;
        clk  = 1'b0;
        #5;

        ALU_op    = 2'b01;
        sel_A     = 1'b0;
        sel_B     = 1'b0;
        shift_op  = 2'b00;

        en_C      = 1'b1;
        en_status = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_C      = 1'b0;
        en_status = 1'b0;
        clk       = 1'b0;
        #5;

        w_addr = 3'd2;
        #5 w_en = 1'b1;
        #5 clk = 1'b1;
        #5;
        w_en = 1'b0;
        clk  = 1'b0;
        #5;

        assert (datapath_out === 16'b1111111111111111 && {Z_out, N_out, V_out} === 3'b001) begin
            $display("[PASS] Overflow");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] Overflow");
            numfail = numfail + 1;
            error   = 1'b1;
        end
        // end of test overflow

        //test underflow
        r_addr = 3'd0;
        #5;
        en_A = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_A = 1'b0;
        clk  = 1'b0;
        #5;

        r_addr = 3'd1;
        #5;
        en_B = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_B = 1'b0;
        clk  = 1'b0;
        #5;

        ALU_op    = 2'b01;
        sel_A     = 1'b0;
        sel_B     = 1'b0;
        shift_op  = 2'b00;

        en_C      = 1'b1;
        en_status = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        en_C      = 1'b0;
        en_status = 1'b0;
        clk       = 1'b0;
        #5;

        w_addr = 3'd2;
        #5 w_en = 1'b1;
        #5 clk = 1'b1;
        #5;
        w_en = 1'b0;
        clk  = 1'b0;
        #5;

        assert (datapath_out === 16'b0000000000000001 && {Z_out, N_out, V_out} === 3'b001) begin
            $display("[PASS] Underflow");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] Underflow");
            numfail = numfail + 1;
            error   = 1'b1;
        end
        // end of test underflow

        $display("\n");
        $display("Number of passed cases: %d", numpass);
        $display("Number of failed cases: %d", numfail);
        $stop();
    end
endmodule : tb_datapath
