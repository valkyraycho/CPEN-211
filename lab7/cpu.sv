module cpu(input clk, input rst_n, input [7:0] start_pc, input [15:0] ram_r_data, 
           output [15:0] out, output N, output V, output Z, output ram_w_en, output [7:0] ram_addr, output [15:0] ram_w_data);  
    
    wire w_en, en_A, en_B, en_C, sel_A, sel_B, en_status;
    wire [1:0] ALU_op, shift_op, wb_sel, reg_sel;
    wire [2:0] opcode, w_addr, r_addr;
    //wire [15:0] mdata = 16'b0;
    wire [15:0] sximm5, sximm8;

    reg [7:0] pc;
    reg [15:0] ir;
    reg [7:0] dr;

    wire load_ir, load_pc, load_addr, sel_addr, clear_pc;
    wire [7:0] next_pc;
    
    always_ff @(posedge clk) if(load_ir) ir <= ram_r_data;

    assign next_pc = (clear_pc) ? start_pc : pc+1;

    always_ff @(posedge clk) if(load_pc) pc <= next_pc;

    always_ff @(posedge clk) if(load_addr) dr <= out[7:0];

    assign ram_addr = (sel_addr) ? pc : dr;

    controller control(.clk, .rst_n, .opcode, .ALU_op, .shift_op, .Z, .N, .V, .reg_sel, .wb_sel, .w_en, .en_A, .en_B, .en_C, .en_status, .sel_A, .sel_B, .load_ir, .load_pc, .ram_w_en, .sel_addr, .clear_pc, .load_addr);
    datapath path(.clk, .mdata(ram_r_data), .pc, .wb_sel, .w_addr, .w_en, .r_addr, .en_A, .en_B, .shift_op, .sel_A, .sel_B, .ALU_op, .en_C, .en_status, .sximm8, .sximm5, .datapath_out(out), .Z_out(Z), .N_out(N), .V_out(V), .ram_w_data);
    idecoder decoder(.ir, .reg_sel, .opcode, .ALU_op, .shift_op, .sximm5, .sximm8, .r_addr, .w_addr);
    
endmodule: cpu


