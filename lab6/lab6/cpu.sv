module cpu(input clk, input rst_n, input load, input start, input [15:0] instr,
           output waiting, output [15:0] out, output N, output V, output Z);
    reg [15:0] ir;
    always_ff @(posedge clk) if(load) ir <= instr;

    wire w_en, en_A, en_B, en_C, sel_A, sel_B, en_status;
    wire [1:0] ALU_op, shift_op, wb_sel, reg_sel;
    wire [2:0] opcode, w_addr, r_addr;
    wire [7:0] pc = 8'b0;
    wire [15:0] mdata = 16'b0;
    wire [15:0] sximm5, sximm8;

    controller control(.clk, .rst_n, .start, .opcode, .ALU_op, .shift_op, .Z, .N, .V, .waiting, .reg_sel, .wb_sel, .w_en, .en_A, .en_B, .en_C, .en_status, .sel_A, .sel_B);
    datapath path(.clk, .mdata, .pc, .wb_sel, .w_addr, .w_en, .r_addr, .en_A, .en_B, .shift_op, .sel_A, .sel_B, .ALU_op, .en_C, .en_status, .sximm8, .sximm5, .datapath_out(out), .Z_out(Z), .N_out(N), .V_out(V));
    idecoder decoder(.ir, .reg_sel, .opcode, .ALU_op, .shift_op, .sximm5, .sximm8, .r_addr, .w_addr);
    
endmodule: cpu
