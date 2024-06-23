module tb_controller(output err);
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
    controller dut(.clk, .rst_n, .opcode, .ALU_op, .shift_op, .Z, .N, .V, .reg_sel, .wb_sel, .w_en, .en_A, .en_B, .en_C, .en_status, .sel_A, .sel_B, .load_ir, .load_pc, .ram_w_en, .sel_addr, .clear_pc, .load_addr);
    task reset; rst_n = 1'b0; #5; clk = 1'b1; #5; rst_n = 1'b1; clk = 1'b0; #5; endtask
    task clock; clk = 1'b1; #5; clk = 1'b0; #5; endtask


    initial
    begin
        {clk, Z, N, V} = 4'b0;
        {opcode, ALU_op, shift_op} = 7'b0;
        rst_n = 1'b1;
        numfail = 1'b0;
        numpass = 1'b0;
        error = 1'b0;
        #5;

        reset;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {15'b0, 1'b1, 1'b0})
        begin
            $display("[PASS] reset to PC_START");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] reset to PC_START");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {12'b0, 1'b1, 4'b0})
        begin
            $display("[PASS] PC_START to PC_LOAD");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] PC_START to PC_LOAD");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {14'b0, 1'b1, 2'b0})
        begin
            $display("[PASS] PC_LOAD to PC_SEL");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] PC_LOAD to PC_SEL");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {14'b0, 1'b1, 2'b0})
        begin
            $display("[PASS] PC_SEL to PC_READ");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] PC_SEL to PC_READ");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {11'b0, 1'b1, 5'b0})
        begin
            $display("[PASS] PC_READ to INSTR_SEND");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] PC_READ to INSTR_SEND");
            numfail = numfail + 1;
            error = 1'b1;
        end

        opcode = 3'b110; ALU_op = 2'b10; #5;
        clock;
        assert({wb_sel, reg_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b10, 15'b0})
        begin
            $display("[PASS] MOV_IMM sel");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] MOV_IMM sel");
            numfail = numfail + 1;
            error = 1'b1;
        end
        
        clock;
        assert({reg_sel, w_en, wb_sel, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b10, 1'b1, 2'b10, 12'b0})
        begin
            $display("[PASS] MOV_IMM write");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] MOV_IMM write ");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {12'b0, 1'b1, 4'b0})
        begin
            $display("[PASS] back to PC_LOAD");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] back to PC_LOAD");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;clock;clock;

        opcode = 3'b110; ALU_op = 2'b00; #5;
        clock;
        assert({wb_sel, reg_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b00, 15'b0})
        begin
            $display("[PASS] MOV sel");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] MOV sel");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, en_B, wb_sel, w_en, en_A, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b00, 1'b1, 14'b0})
        begin
            $display("[PASS] MOV readB");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] MOV readB");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({sel_A, sel_B, reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status,  load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b10, 15'b0})
        begin
            $display("[PASS] MOV selAB");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] MOV selAB");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({en_C, en_status, reg_sel, wb_sel, w_en, en_A, en_B, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b11, 7'b0, 2'b10, 6'b0})
        begin
            $display("[PASS] MOV enC");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] MOV enC");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, w_en, wb_sel, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b01, 1'b1, 14'b0})
        begin
            $display("[PASS] MOV write");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] MOV write");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {12'b0, 1'b1, 4'b0})
        begin
            $display("[PASS] back to PC_LOAD");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] back to PC_LOAD");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;clock;clock;
        
        opcode = 3'b101; ALU_op = 2'b00; #5;
        clock;
        assert({wb_sel, reg_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b00, 15'b0})
        begin
            $display("[PASS] ADD sel");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] ADD sel");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, en_A, wb_sel, w_en, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b10, 1'b1, 14'b0})
        begin
            $display("[PASS] ADD readA");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] ADD readA");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, en_A, en_B, wb_sel, w_en, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b00, 1'b0, 1'b1, 13'b0})
        begin
            $display("[PASS] ADD readB");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] ADD readB");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({sel_A, sel_B, en_B, reg_sel, wb_sel, w_en, en_A, en_C, en_status, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b00, 1'b0, 14'b0})
        begin
            $display("[PASS] ADD selAB");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] ADD selAB");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({en_C, en_status, reg_sel, wb_sel, w_en, en_A, en_B, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b11, 15'b0})
        begin
            $display("[PASS] ADD enC");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] ADD enC");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, w_en, wb_sel, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b01, 1'b1, 14'b0})
        begin
            $display("[PASS] ADD write");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] ADD write");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {12'b0, 1'b1, 4'b0})
        begin
            $display("[PASS] back to PC_LOAD");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] back to PC_LOAD");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;clock;clock;

        
        opcode = 3'b101; ALU_op = 2'b01; #5;
        clock;
        assert({wb_sel, reg_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b00, 15'b0})
        begin
            $display("[PASS] CMP sel");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] CMP sel");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, en_A, wb_sel, w_en, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b10, 1'b1, 14'b0})
        begin
            $display("[PASS] CMP readA");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] CMP readA");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, en_A, en_B, wb_sel, w_en, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b00, 1'b0, 1'b1, 13'b0})
        begin
            $display("[PASS] CMP readB");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] CMP readB");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({sel_A, sel_B, en_B, reg_sel, wb_sel, w_en, en_A, en_C, en_status, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b00, 1'b0, 14'b0})
        begin
            $display("[PASS] CMP selAB");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] CMP selAB");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({en_C, en_status, reg_sel, wb_sel, w_en, en_A, en_B, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b11, 15'b0})
        begin
            $display("[PASS] CMP enC");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] CMP enC");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {12'b0, 1'b1, 4'b0})
        begin
            $display("[PASS] back to PC_LOAD");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] back to PC_LOAD");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;clock;clock;

        
        opcode = 3'b101; ALU_op = 2'b10; #5;
        clock;
        assert({wb_sel, reg_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b00, 15'b0})
        begin
            $display("[PASS] AND sel");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] AND sel");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, en_A, wb_sel, w_en, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b10, 1'b1, 14'b0})
        begin
            $display("[PASS] AND readA");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] AND readA");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, en_A, en_B, wb_sel, w_en, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b00, 1'b0, 1'b1, 13'b0})
        begin
            $display("[PASS] AND readB");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] AND readB");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({sel_A, sel_B, en_B, reg_sel, wb_sel, w_en, en_A, en_C, en_status, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b00, 1'b0, 14'b0})
        begin
            $display("[PASS] AND selAB");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] AND selAB");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({en_C, en_status, reg_sel, wb_sel, w_en, en_A, en_B, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b11, 15'b0})
        begin
            $display("[PASS] AND enC");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] AND enC");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, w_en, wb_sel, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b01, 1'b1, 14'b0})
        begin
            $display("[PASS] AND write");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] AND write");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {12'b0, 1'b1, 4'b0})
        begin
            $display("[PASS] back to PC_LOAD");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] back to PC_LOAD");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;clock;clock;
        
        opcode = 3'b110; ALU_op = 2'b00; #5;
        clock;
        assert({wb_sel, reg_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b00, 15'b0})
        begin
            $display("[PASS] MVN sel");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] MVN sel");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, en_B, wb_sel, w_en, en_A, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b00, 1'b1, 14'b0})
        begin
            $display("[PASS] MVN readB");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] MVN readB");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({sel_A, sel_B, reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status,  load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b10, 15'b0})
        begin
            $display("[PASS] MVN selAB");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] MVN selAB");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({en_C, en_status, reg_sel, wb_sel, w_en, en_A, en_B, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b11, 7'b0, 2'b10, 6'b0})
        begin
            $display("[PASS] MVN enC");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] MVN enC");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, w_en, wb_sel, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b01, 1'b1, 14'b0})
        begin
            $display("[PASS] MVN write");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] MVN write");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {12'b0, 1'b1, 4'b0})
        begin
            $display("[PASS] back to PC_LOAD");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] back to PC_LOAD");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;clock;clock;
        
        opcode = 3'b011; ALU_op = 2'b00; #5;
        clock;
        assert({wb_sel, reg_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b00, 15'b0})
        begin
            $display("[PASS] LDR sel");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] LDR sel");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, en_A, wb_sel, w_en, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b10, 1'b1, 14'b0})
        begin
            $display("[PASS] LDR readA");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] LDR readA");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({sel_A, sel_B, reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status,  load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b01, 15'b0})
        begin
            $display("[PASS] LDR selAB");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] LDR selAB");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({en_C, en_status, reg_sel, wb_sel, w_en, en_A, en_B, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b11, 15'b0})
        begin
            $display("[PASS] LDR enC");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] LDR enC");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {16'b0, 1'b1})
        begin
            $display("[PASS] LDR load address");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] LDR load address");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {14'b0, 1'b1, 2'b0})
        begin
            $display("[PASS] LDR select data address");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] LDR select data address");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {17'b0})
        begin
            $display("[PASS] LDR read data address");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] LDR read data address");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b01, 2'b11 ,13'b0})
        begin
            $display("[PASS] LDR sel");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] LDR sel");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b01, 2'b11, 1'b1, 12'b0})
        begin
            $display("[PASS] LDR write");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] LDR write");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {12'b0, 1'b1, 4'b0})
        begin
            $display("[PASS] back to PC_LOAD");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] back to PC_LOAD");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;clock;clock;

        opcode = 3'b100; ALU_op = 2'b00; #5;
        clock;
        assert({wb_sel, reg_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b00, 15'b0})
        begin
            $display("[PASS] STR sel");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] STR sel");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, en_A, wb_sel, w_en, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b10, 1'b1, 14'b0})
        begin
            $display("[PASS] STR readA");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] STR readA");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({sel_A, sel_B, reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status,  load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b01, 15'b0})
        begin
            $display("[PASS] STR selAB");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] STR selAB");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({en_C, en_status, reg_sel, wb_sel, w_en, en_A, en_B, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b11, 15'b0})
        begin
            $display("[PASS] STR enC");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] STR enC");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {16'b0, 1'b1})
        begin
            $display("[PASS] STR load address");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] STR load address");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {14'b0, 1'b1, 2'b0})
        begin
            $display("[PASS] STR select data address");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] STR select data address");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, en_B, wb_sel, w_en, en_A, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b01, 1'b1, 14'b0})
        begin
            $display("[PASS] STR readB");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] STR readB");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({sel_A, sel_B, reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status,  load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b10, 15'b0})
        begin
            $display("[PASS] STR selAB_str");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] STR selAB_str");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({en_C, en_status, reg_sel, wb_sel, w_en, en_A, en_B, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {2'b11, 15'b0})
        begin
            $display("[PASS] STR enC_str");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] STR enC_str");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {13'b0, 1'b1, 3'b0})
        begin
            $display("[PASS] STR enWrite To Memory");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] STR enWrite To Memory");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {17'b0})
        begin
            $display("[PASS] STR Write To Memory");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] STR Write To Memory");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {12'b0, 1'b1, 4'b0})
        begin
            $display("[PASS] back to PC_LOAD");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] back to PC_LOAD");
            numfail = numfail + 1;
            error = 1'b1;
        end

        clock;clock;clock;

        opcode = 3'b111; ALU_op = 2'b00; #5;
        clock;
        assert({reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B, load_ir, load_pc, ram_w_en, sel_addr, clear_pc, load_addr} === {17'b0})
        begin
            $display("[PASS] HALT");
            numpass = numpass + 1;
        end
        else 
        begin
            $error("[FAIL] HALT");
            numfail = numfail + 1;
            error = 1'b1;
        end

        $display("\n");
        $display("Number of passed cases: %d", numpass);
        $display("Number of failed cases: %d", numfail);
        $stop();
    end
endmodule: tb_controller
