module tb_controller (
    output err
);
    reg clk, rst_n, start, Z, N, V;
    reg [2:0] opcode;
    reg [1:0] ALU_op, shift_op;
    wire waiting, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B;
    wire [1:0] reg_sel, wb_sel;

    integer numpass;
    integer numfail;
    reg error;
    assign err = error;
    controller dut (
        .clk,
        .rst_n,
        .start,
        .opcode,
        .ALU_op,
        .shift_op,
        .Z,
        .N,
        .V,
        .waiting,
        .reg_sel,
        .wb_sel,
        .w_en,
        .en_A,
        .en_B,
        .en_C,
        .en_status,
        .sel_A,
        .sel_B
    );
    task reset;
        rst_n = 1'b0;
        #5;
        clk = 1'b1;
        #5;
        rst_n = 1'b1;
        clk   = 1'b0;
        #5;
    endtask
    task clock;
        clk = 1'b1;
        #5;
        clk = 1'b0;
        #5;
    endtask


    initial begin
        {clk, start, Z, N, V}      = 5'b0;
        {opcode, ALU_op, shift_op} = 7'b0;
        rst_n                      = 1'b1;
        numfail                    = 1'b0;
        numpass                    = 1'b0;
        error                      = 1'b0;
        #5;

        reset;
        assert (waiting === 1'b1) begin
            $display("[PASS] reset to wait");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] reset to wait");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        start  = 1'b1;
        opcode = 3'b110;
        ALU_op = 2'b10;
        #5;
        clock;
        start = 1'b0;
        #5;
        assert (wb_sel === 2'b10) begin
            $display("[PASS] MOV_IMM read instr");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MOV_IMM read instr");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (reg_sel === 2'b10 && wb_sel === 2'b10 && w_en === 1'b1) begin
            $display("[PASS] MOV_IMM write");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MOV_IMM write ");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (waiting === 1'b1) begin
            $display("[PASS] back to wait");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] back to wait");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        start  = 1'b1;
        opcode = 3'b110;
        ALU_op = 2'b00;
        #5;
        clock;
        start = 1'b0;
        #5;
        assert (wb_sel === 2'b00) begin
            $display("[PASS] MOV read instr");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MOV read instr");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (reg_sel === 2'b00 && en_B === 1'b1) begin
            $display("[PASS] MOV readB");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MOV readB");
            numfail = numfail + 1;
            error   = 1'b1;
        end


        clock;
        assert (en_C === 1'b1 && sel_A === 1'b1) begin
            $display("[PASS] MOV enC");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MOV enC");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (reg_sel === 2'b01 && w_en === 1'b1) begin
            $display("[PASS] MOV write");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MOV write");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (waiting === 1'b1) begin
            $display("[PASS] back to wait");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] back to wait");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        start  = 1'b1;
        opcode = 3'b101;
        ALU_op = 2'b00;
        #5;
        clock;
        start = 1'b0;
        #5;
        assert (wb_sel === 2'b00) begin
            $display("[PASS] ADD read instr");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] ADD read instr");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (reg_sel === 2'b10 && en_A === 1'b1) begin
            $display("[PASS] ADD readA");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] ADD readA");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (reg_sel === 2'b00 && en_B === 1'b1) begin
            $display("[PASS] ADD readB");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] ADD readB");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (en_C === 1'b1) begin
            $display("[PASS] ADD enC");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] ADD enC");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (reg_sel === 2'b01 && w_en === 1'b1) begin
            $display("[PASS] ADD write");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] ADD write");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (waiting === 1'b1) begin
            $display("[PASS] back to wait");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] back to wait");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        start  = 1'b1;
        opcode = 3'b101;
        ALU_op = 2'b01;
        #5;
        clock;
        start = 1'b0;
        #5;
        assert (wb_sel === 2'b00) begin
            $display("[PASS] CMP read instr");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] CMP read instr");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (reg_sel === 2'b10 && en_A === 1'b1) begin
            $display("[PASS] CMP readA");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] CMP readA");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (reg_sel === 2'b00 && en_B === 1'b1) begin
            $display("[PASS] CMP readB");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] CMP readB");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (en_C === 1'b0 && en_status === 1'b1) begin
            $display("[PASS] CMP enC");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] CMP enC");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (waiting === 1'b1) begin
            $display("[PASS] back to wait");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] back to wait");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        start  = 1'b1;
        opcode = 3'b101;
        ALU_op = 2'b10;
        #5;
        clock;
        start = 1'b0;
        #5;
        assert (wb_sel === 2'b00) begin
            $display("[PASS] AND read instr");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] AND read instr");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (reg_sel === 2'b10 && en_A === 1'b1) begin
            $display("[PASS] AND readA");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] AND readA");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (reg_sel === 2'b00 && en_B === 1'b1) begin
            $display("[PASS] AND readB");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] AND readB");
            numfail = numfail + 1;
            error   = 1'b1;
        end


        clock;
        assert (en_C === 1'b1) begin
            $display("[PASS] AND enC");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] AND enC");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (reg_sel === 2'b01 && w_en === 1'b1) begin
            $display("[PASS] AND write");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] AND write");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (waiting === 1'b1) begin
            $display("[PASS] back to wait");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] back to wait");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        start  = 1'b1;
        opcode = 3'b110;
        ALU_op = 2'b00;
        #5;
        clock;
        start = 1'b0;
        #5;
        assert (wb_sel === 2'b00) begin
            $display("[PASS] MVN read instr");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MVN read instr");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (reg_sel === 2'b00 && en_B === 1'b1) begin
            $display("[PASS] MVN readB");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MVN readB");
            numfail = numfail + 1;
            error   = 1'b1;
        end


        clock;
        assert (en_C === 1'b1 && sel_A === 1'b1) begin
            $display("[PASS] MVN enC");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MVN enC");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (reg_sel === 2'b01 && w_en === 1'b1) begin
            $display("[PASS] MVN write");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MVN write");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert (waiting === 1'b1) begin
            $display("[PASS] back to wait");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] back to wait");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        $display("\n");
        $display("Number of passed cases: %d", numpass);
        $display("Number of failed cases: %d", numfail);
        $stop();
    end
endmodule : tb_controller
