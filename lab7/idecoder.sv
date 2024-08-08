module idecoder (
    input  [15:0] ir,
    input  [ 1:0] reg_sel,
    output [ 2:0] opcode,
    output [ 1:0] ALU_op,
    output [ 1:0] shift_op,
    output [15:0] sximm5,
    output [15:0] sximm8,
    output [ 2:0] r_addr,
    output [ 2:0] w_addr
);
    wire [2:0] Rm, Rd, Rn;
    wire [7:0] imm8;
    wire [4:0] imm5;
    assign shift_op = ir[4:3];
    assign ALU_op   = ir[12:11];
    assign opcode   = ir[15:13];
    assign sximm8   = {{8{ir[7]}}, ir[7:0]};
    assign sximm5   = {{11{ir[4]}}, ir[4:0]};
    assign Rm       = ir[2:0];
    assign Rd       = ir[7:5];
    assign Rn       = ir[10:8];
    reg [2:0] addr_r, addr_w;
    assign {r_addr, w_addr} = {addr_r, addr_w};
    always_comb begin
        case (reg_sel)
            2'b00:   {addr_w, addr_r} = {Rm, Rm};
            2'b01:   {addr_w, addr_r} = {Rd, Rd};
            2'b10:   {addr_w, addr_r} = {Rn, Rn};
            default: {addr_w, addr_r} = 6'b0;
        endcase
    end
endmodule : idecoder
