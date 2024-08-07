module shifter (
    input      [15:0] shift_in,
    input      [ 1:0] shift_op,
    output reg [15:0] shift_out
);
    always_comb begin
        shift_out = 16'b0;
        case (shift_op)
            2'b00: shift_out = shift_in;
            2'b01: shift_out = {shift_in[14:0], 1'b0};
            2'b10: shift_out = {1'b0, shift_in[15:1]};
            2'b11: shift_out = {shift_in[15], shift_in[15:1]};
        endcase
    end
endmodule : shifter
