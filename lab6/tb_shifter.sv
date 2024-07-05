module tb_shifter (
    output err
);
    reg [15:0] shift_in;
    reg [1:0] shift_op;
    wire [15:0] shift_out;

    integer numpass;
    integer numfail;
    reg error;
    assign err = error;

    shifter dut (
        .shift_in,
        .shift_op,
        .shift_out
    );

    initial begin
        shift_op = 2'b00;
        shift_in = 16'b1111000011001111;
        #5;
        assert (shift_out === 16'b1111000011001111) begin
            $display("[PASS] no shift");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] no shift");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        shift_op = 2'b01;
        shift_in = 16'b1111000011001111;
        #5;
        assert (shift_out === 16'b1110000110011110) begin
            $display("[PASS] left shift");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] left shift");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        shift_op = 2'b10;
        shift_in = 16'b1111000011001111;
        #5;
        assert (shift_out === 16'b0111100001100111) begin
            $display("[PASS] right shift");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] right shift");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        shift_op = 2'b11;
        shift_in = 16'b1111000011001111;
        #5;
        assert (shift_out === 16'b1111100001100111) begin
            $display("[PASS] arithmetic right shift");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] arithmetic right shift");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        shift_op = 2'b00;
        shift_in = 16'b0010001001110011;
        #5;
        assert (shift_out === 16'b0010001001110011) begin
            $display("[PASS] no shift");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] no shift");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        shift_op = 2'b01;
        shift_in = 16'b0010001001110011;
        #5;
        assert (shift_out === 16'b0100010011100110) begin
            $display("[PASS] left shift");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] left shift");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        shift_op = 2'b10;
        shift_in = 16'b0010001001110011;
        #5;
        assert (shift_out === 16'b0001000100111001) begin
            $display("[PASS] right shift");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] right shift");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        shift_op = 2'b11;
        shift_in = 16'b0010001001110011;
        #5;
        assert (shift_out === 16'b0001000100111001) begin
            $display("[PASS] arithmetic right shift");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] arithmetic right shift");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        $display("\n");
        $display("Number of passed cases: %d", numpass);
        $display("Number of failed cases: %d", numfail);
    end
endmodule : tb_shifter
