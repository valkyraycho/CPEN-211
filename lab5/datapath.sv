module datapath (
    input               clk,
    input        [15:0] datapath_in,
    input               wb_sel,
    input        [ 2:0] w_addr,
    input               w_en,
    input        [ 2:0] r_addr,
    input               en_A,
    input               en_B,
    input        [ 1:0] shift_op,
    input               sel_A,
    input               sel_B,
    input        [ 1:0] ALU_op,
    input               en_C,
    input               en_status,
    output logic [15:0] datapath_out,
    output logic        Z_out
);
    wire [15:0] w_data;
    assign w_data = (wb_sel) ? datapath_in : datapath_out;

    wire [15:0] r_data;
    regfile registerfile (
        .w_data,
        .w_addr,
        .w_en,
        .r_addr,
        .clk,
        .r_data
    );

    reg [15:0] A, B;
    always_ff @(posedge clk) if (en_A) A <= r_data;
    always_ff @(posedge clk) if (en_B) B <= r_data;

    wire [15:0] shift_out;
    shifter shift (
        .shift_in(B),
        .shift_op,
        .shift_out
    );

    wire [15:0] val_A, val_B;
    assign val_A = (sel_A) ? 16'b0 : A;
    assign val_B = (sel_B) ? {11'b0, datapath_in[4:0]} : shift_out;

    wire [15:0] ALU_out;
    wire Z;
    ALU alu (
        .val_A,
        .val_B,
        .ALU_op,
        .ALU_out,
        .Z
    );

    always_ff @(posedge clk) if (en_C) datapath_out <= ALU_out;
    always_ff @(posedge clk) if (en_status) Z_out <= Z;
endmodule : datapath
