module datapath(input clk, input [15:0] mdata, input [7:0] pc, input [1:0] wb_sel,
                input [2:0] w_addr, input w_en, input [2:0] r_addr, input en_A,
                input en_B, input [1:0] shift_op, input sel_A, input sel_B,
                input [1:0] ALU_op, input en_C, input en_status,
		        input [15:0] sximm8, input [15:0] sximm5,
                output [15:0] datapath_out, output Z_out, output N_out, output V_out, output [15:0] ram_w_data);
    reg [15:0] w_data;
    always_comb
    begin
        case(wb_sel)
                2'b00: w_data = datapath_out;
                2'b01: w_data = {8'b0,pc};
                2'b10: w_data = sximm8;
                default: w_data = mdata;
        endcase
    end

    wire [15:0] r_data;  
    regfile registerfile(.w_data, .w_addr, .w_en, .r_addr, .clk, .r_data);

    reg [15:0] A, B;
    always_ff @(posedge clk) if (en_A) A <= r_data;
    always_ff @(posedge clk) if (en_B) B <= r_data;
    
    wire [15:0] shift_out;
    shifter shift(.shift_in(B), .shift_op, .shift_out);

    wire [15:0] val_A, val_B;
    assign val_A = (sel_A) ? 16'b0 : A;
    assign val_B = (sel_B) ? sximm5 : shift_out;

    wire [15:0] ALU_out;
    wire Z, N, V;
    ALU alu(.val_A, .val_B, .ALU_op, .ALU_out, .Z, .N, .V);

    reg out_z, out_n, out_v;
    reg [15:0] out_datapath;
    reg [15:0] data_w_ram;
    assign Z_out = out_z, N_out = out_n, V_out = out_v;
    assign datapath_out = out_datapath;
    assign ram_w_data = data_w_ram;
    always_ff @(posedge clk) if (en_C) out_datapath <= ALU_out;
    always_ff @(posedge clk) if (en_C) data_w_ram <= ALU_out;
    always_ff @(posedge clk)
    begin
        if (en_status) 
            begin
                out_z <= Z;
                out_n <= N;
                out_v <= V;
            end
    end
endmodule: datapath
