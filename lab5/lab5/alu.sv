module ALU(input [15:0] val_A, input [15:0] val_B, input [1:0] ALU_op, output [15:0] ALU_out, output Z);
    reg [15:0] alu_out;
    assign ALU_out = alu_out;
    reg z;
    assign Z = z;
    always_comb
    begin
        case(ALU_op)
            2'b00: if(val_A+val_B == 16'b0) {alu_out, z} = {val_A+val_B, 1'b1}; else {alu_out, z} = {val_A+val_B, 1'b0};
            2'b01: if(val_A-val_B == 16'b0) {alu_out, z} = {val_A-val_B, 1'b1}; else {alu_out, z} = {val_A-val_B, 1'b0};
            2'b10: if(val_A&val_B != 16'b0) {alu_out, z} = {val_A&val_B, 1'b0}; else {alu_out, z} = {val_A&val_B, 1'b1};
            default if(~val_B != 16'b0) {alu_out, z} = {~val_B, 1'b0}; else {alu_out, z} = {~val_B, 1'b1};
        endcase
    end
endmodule: ALU
