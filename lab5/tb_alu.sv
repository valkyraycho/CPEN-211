module tb_ALU(output err);
    reg [15:0] val_A;
    reg [15:0] val_B;
    reg [1:0] ALU_op;
    wire [15:0] ALU_out;
    wire Z;

    reg error;
    assign err = error;

    ALU dut(.val_A, .val_B, .ALU_op, .ALU_out, .Z);
    initial
    begin
        ALU_op = 2'b0;
        val_A = 16'd2;
        val_B = 16'd3;
        #5;
        assert(ALU_out === 16'd5 && Z === 0) 
        begin
            $display("[PASS] 2+3=5");
            error = 1'b0;
        end
        else 
        begin
            $error("[FAIL] 2+3=5");
            error = 1'b1;
        end

        ALU_op = 2'b0;
        val_A = 16'd0;
        val_B = 16'd0;
        #5;
        assert(ALU_out === 16'd0 && Z === 1) 
        begin
            $display("[PASS] 0+0=0");
            error = 1'b0;
        end
        else 
        begin
            $error("[FAIL] 0+0=0");
            error = 1'b1;
        end

        ALU_op = 2'b01;
        val_A = 16'd2;
        val_B = 16'd3;
        #5;
        assert(ALU_out === 16'b1111111111111111 && Z === 0) 
        begin
            $display("[PASS] 2-3=-1");
            error = 1'b0;
        end
        else 
        begin
            $error("[FAIL] 2-3=-1");
            error = 1'b1;
        end

        ALU_op = 2'b01;
        val_A = 16'd10;
        val_B = 16'd9;
        #5;
        assert(ALU_out === 16'd1 && Z === 0) 
        begin
            $display("[PASS] 10-9=1");
            error = 1'b0;
        end
        else 
        begin
            $error("[FAIL] 10-9=1");
            error = 1'b1;
        end

        ALU_op = 2'b01;
        val_A = 16'd10;
        val_B = 16'd10;
        #5;
        assert(ALU_out === 16'd0 && Z === 1) 
        begin
            $display("[PASS] 10-10=0");
            error = 1'b0;
        end
        else 
        begin
            $error("[FAIL] 10-10=0");
            error = 1'b1;
        end
        
        ALU_op = 2'b10;
        val_A = 16'b0101;
        val_B = 16'b0110;
        #5;
        assert(ALU_out === 16'b0100 && Z === 0) 
        begin
            $display("[PASS] 0101 & 0110 = 0100");
            error = 1'b0;
        end
        else 
        begin
            $error("[FAIL] 0101 & 0110 = 0100");
            error = 1'b1;
        end

        ALU_op = 2'b10;
        val_A = 16'b1110;
        val_B = 16'b0001;
        #5;
        assert(ALU_out === 16'd0 && Z === 1) 
        begin
            $display("[PASS] 1110 & 0001 = 0000");
            error = 1'b0;
        end
        else 
        begin
            $error("[FAIL] 1110 & 0001 = 0000");
            error = 1'b1;
        end

        ALU_op = 2'b11;
        val_B = 16'b0110;
        #5;
        assert(ALU_out === 16'b1111111111111001 && Z === 0) 
        begin
            $display("[PASS] ~0110 = 11111111111110011001");
            error = 1'b0;
        end
        else 
        begin
            $error("[FAIL] ~0110 = 11111111111110011001");
            error = 1'b1;
        end

        ALU_op = 2'b11;
        val_B = 16'b1111111111111111;
        #5;
        assert(ALU_out === 16'b0 && Z === 1) 
        begin
            $display("[PASS] ~1111111111111111 = 0");
            error = 1'b0;
        end
        else 
        begin
            $error("[FAIL] ~1111111111111111 = 0");
            error = 1'b1;
        end
    end
endmodule: tb_ALU
