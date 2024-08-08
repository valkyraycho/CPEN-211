module tb_idecoder (
    output err
);
    reg  [15:0] ir;
    reg  [ 1:0] reg_sel;
    wire [ 2:0] opcode;
    wire [1:0] ALU_op, shift_op;
    wire [15:0] sximm5, sximm8;
    wire [2:0] r_addr, w_addr;

    integer numpass;
    integer numfail;
    reg error;
    assign err = error;

    idecoder dut (
        .ir,
        .reg_sel,
        .opcode,
        .ALU_op,
        .shift_op,
        .sximm5,
        .sximm8,
        .r_addr,
        .w_addr
    );
    initial begin
        numfail = 1'b0;
        numpass = 1'b0;
        error   = 1'b0;
        ir      = 16'b0001001110010111;
        reg_sel = 2'b00;
        #5;
        assert(opcode === 3'b000 && 
               ALU_op === 2'b10 && 
               sximm5 === 16'b1111111111110111 && 
               sximm8 === 16'b1111111110010111 &&
               shift_op === 2'b10 &&
               r_addr === 3'b111 &&
               w_addr === 3'b111)
        begin
            $display("[PASS]");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL]");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        ir      = 16'b1001111001011100;
        reg_sel = 2'b01;
        #5;
        assert(opcode === 3'b100 && 
               ALU_op === 2'b11 && 
               sximm5 === 16'b1111111111111100 && 
               sximm8 === 16'b0000000001011100 &&
               shift_op === 2'b11 &&
               r_addr === 3'b010 &&
               w_addr === 3'b010) 
        begin
            $display("[PASS]");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL]");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        ir      = 16'b0101100110001000;
        reg_sel = 2'b10;
        #5;
        assert(opcode === 3'b010 && 
               ALU_op === 2'b11 && 
               sximm5 === 16'b0000000000001000&& 
               sximm8 === 16'b1111111110001000 &&
               shift_op === 2'b01 &&
               r_addr === 3'b001 &&
               w_addr === 3'b001) 
        begin
            $display("[PASS]");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL]");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        $display("\n");
        $display("Number of passed cases: %d", numpass);
        $display("Number of failed cases: %d", numfail);
    end
endmodule : tb_idecoder
