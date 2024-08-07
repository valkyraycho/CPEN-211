module ALU (
    input        [15:0] val_A,
    input        [15:0] val_B,
    input        [ 1:0] ALU_op,
    output logic [15:0] ALU_out,
    output logic        Z,
    output logic        N,
    output logic        V
);
    reg [15:0] subtract;
    always_comb begin
        case (ALU_op)
            2'b00:   {ALU_out, Z, N, V, subtract} = {val_A + val_B, 3'b000, 16'b0};
            2'b01: begin
                subtract = val_A - val_B;
                if (subtract == 16'b0) {ALU_out, Z, N, V} = {subtract, 3'b100};
                else if ((val_A[15] ^ val_B[15]) == 1'b1 && (subtract[15] ^ val_A[15] == 1'b1)) {ALU_out, Z, N, V} = {subtract, 3'b001};
                else if (subtract[15] == 1'b1) {ALU_out, Z, N, V} = {subtract, 3'b010};
                else {ALU_out, Z, N, V} = {subtract, 3'b000};
            end
            2'b10:   {ALU_out, Z, N, V, subtract} = {val_A & val_B, 3'b000, 16'b0};
            default: {ALU_out, Z, N, V, subtract} = {~val_B, 3'b000, 16'd0};
        endcase
    end
endmodule : ALU
