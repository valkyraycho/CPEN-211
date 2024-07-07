module tb_controller (
    output err
);
    reg clk, rst_n, Z, N, V;
    reg [2:0] opcode;
    reg [1:0] ALU_op, shift_op;
    wire w_en, en_A, en_B, en_C, en_status, sel_A, sel_B;
    wire [1:0] reg_sel, wb_sel;
    wire load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr;

    integer numpass;
    integer numfail;
    reg error;
    assign err = error;
    controller dut (
        .clk,
        .rst_n,
        .opcode,
        .ALU_op,
        .shift_op,
        .Z,
        .N,
        .V,
        .reg_sel,
        .wb_sel,
        .w_en,
        .en_A,
        .en_B,
        .en_C,
        .en_status,
        .sel_A,
        .sel_B,
        .load_ir,
        .load_pc,
        .ram_w_en,
        .sel_addr,
        .clear_pc,
        .load_addr
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
        {clk, Z, N, V}             = 4'b0;
        {opcode, ALU_op, shift_op} = 7'b0;
        rst_n                      = 1'b1;
        numfail                    = 1'b0;
        numpass                    = 1'b0;
        error                      = 1'b0;
        #5;

        reset;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b1 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b1 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] reset to FIRST_PC_LOAD");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] reset to FIRST_PC_LOAD");
            numfail = numfail + 1;
            error   = 1'b1;
        end


        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] PC_LOAD to PC_READ");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] PC_LOAD to PC_READ");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b1 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] PC_READ to INSTR_LOAD");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] PC_READ to INSTR_LOAD");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        //* MOV imm
        opcode = 3'b110;
        ALU_op = 2'b10;
        #5;
        clock;
        assert(
            wb_sel === 2'b10 && 
            reg_sel === 2'b10 && 
            w_en === 1'b1 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] MOV_IMM write");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MOV_IMM write ");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b1 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] back to PC_LOAD");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] back to PC_LOAD");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        //* MOV
        opcode = 3'b110;
        ALU_op = 2'b00;
        clock;
        clock;
        clock;

        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b1 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b1 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )        
        begin
            $display("[PASS] MOV readB");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MOV readB");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b01 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b1 && 
            en_status === 1'b0 && 
            sel_A === 1'b1 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] MOV enC");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MOV enC");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b01 && 
            w_en === 1'b1 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] MOV write");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MOV write");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b1 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] back to PC_LOAD");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] back to PC_LOAD");
            numfail = numfail + 1;
            error   = 1'b1;
        end


        opcode = 3'b101;
        ALU_op = 2'b00;
        clock;
        clock;
        clock;

        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b10 && 
            w_en === 1'b0 && 
            en_A === 1'b1 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] ADD readA");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] ADD readA");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b1 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] ADD readB");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] ADD readB");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b01 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b1 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] ADD enC");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] ADD enC");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b01 && 
            w_en === 1'b1 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] ADD write");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] ADD write");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b1 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] back to PC_LOAD");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] back to PC_LOAD");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        opcode = 3'b101;
        ALU_op = 2'b01;
        clock;
        clock;
        clock;

        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b10 && 
            w_en === 1'b0 && 
            en_A === 1'b1 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] CMP readA");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] CMP readA");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b1 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] CMP readB");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] CMP readB");
            numfail = numfail + 1;
            error   = 1'b1;
        end


        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b1 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] CMP enstatus");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] CMP enstatus");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b1 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] back to PC_LOAD");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] back to PC_LOAD");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        opcode = 3'b101;
        ALU_op = 2'b10;
        clock;
        clock;
        clock;

        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b10 && 
            w_en === 1'b0 && 
            en_A === 1'b1 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] AND readA");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] AND readA");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b1 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] AND readB");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] AND readB");
            numfail = numfail + 1;
            error   = 1'b1;
        end


        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b01 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b1 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] AND enC");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] AND enC");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b01 && 
            w_en === 1'b1 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] AND write");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] AND write");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b1 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] back to PC_LOAD");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] back to PC_LOAD");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        opcode = 3'b110;
        ALU_op = 2'b00;
        clock;
        clock;
        clock;

        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b1 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b1 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] MVN readB");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MVN readB");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b01 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b1 && 
            en_status === 1'b0 && 
            sel_A === 1'b1 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] MVN enC");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MVN enC");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b01 && 
            w_en === 1'b1 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] MVN write");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] MVN write");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b1 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] back to PC_LOAD");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] back to PC_LOAD");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        opcode = 3'b011;
        ALU_op = 2'b00;
        clock;
        clock;
        clock;

        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b10 && 
            w_en === 1'b0 && 
            en_A === 1'b1 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b1 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] LDR readA");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] LDR readA");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b1 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b1 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] LDR enC");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] LDR enC");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b0 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b1
        )
        begin
            $display("[PASS] LDR load address");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] LDR load address");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b11 && 
            reg_sel === 2'b01 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b0 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] LDR read data address");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] LDR read data address");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b11 && 
            reg_sel === 2'b01 && 
            w_en === 1'b1 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b0 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] LDR write");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] LDR write");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b1 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] back to PC_LOAD");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] back to PC_LOAD");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        opcode = 3'b100;
        ALU_op = 2'b00;
        clock;
        clock;
        clock;

        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b10 && 
            w_en === 1'b0 && 
            en_A === 1'b1 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b1 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] STR readA");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] STR readA");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b1 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b1 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] STR enC");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] STR enC");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b0 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b1
        )
        begin
            $display("[PASS] STR load address");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] STR load address");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b01 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b1 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b1 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b0 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] STR readB");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] STR readB");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b1 && 
            en_status === 1'b0 && 
            sel_A === 1'b1 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b0 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] STR enC_STR");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] STR enC_STR");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b1 && 
            sel_addr === 1'b0 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] STR enable write to RAM");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] STR enable write to RAM");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b1 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b0 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] back to PC_LOAD");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] back to PC_LOAD");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        opcode = 3'b111;
        ALU_op = 2'b00;
        clock;
        clock;
        clock;
        assert(
            wb_sel === 2'b00 && 
            reg_sel === 2'b00 && 
            w_en === 1'b0 && 
            en_A === 1'b0 && 
            en_B === 1'b0 && 
            en_C === 1'b0 && 
            en_status === 1'b0 && 
            sel_A === 1'b0 && 
            sel_B === 1'b0 && 
            load_ir === 1'b0 && 
            load_pc === 1'b0 && 
            ram_w_en === 1'b0 && 
            sel_addr === 1'b1 && 
            clear_pc === 1'b1 && 
            load_addr === 1'b0
        )
        begin
            $display("[PASS] HALT");
            numpass = numpass + 1;
        end
        else begin
            $error("[FAIL] HALT");
            numfail = numfail + 1;
            error   = 1'b1;
        end

        $display("\n");
        $display("Number of passed cases: %d", numpass);
        $display("Number of failed cases: %d", numfail);
        $stop();
    end
endmodule : tb_controller
