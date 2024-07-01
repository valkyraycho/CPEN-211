module train_top(input clk, input rstn, input train, 
             output green, output yellow, output red);
    reg g, y, r;
    assign {green, yellow, red} = {g, y, r};

    enum reg [1:0]
    {
        S_DANGER = 2'b00,
        S_CAUTION = 2'b01,
        S_CLEAR = 2'b10
    } r_state;

    always_ff @(posedge clk)
    begin
        if(~rstn) 
        begin
            r_state <= S_CLEAR;
        end
        else
        begin
            case({r_state, train})
            {S_CLEAR, 1'b1}: r_state <= S_DANGER;
            {S_CAUTION, 1'b1}: r_state <= S_DANGER;
            {S_DANGER, 1'b0}: r_state <= S_CAUTION;
            {S_CAUTION, 1'b0}: r_state <= S_CLEAR;
            endcase
        end    
    end

    always_comb
    begin
        case(r_state)
            S_CLEAR: {g, y, r} = 3'b100;
            S_CAUTION: {g, y, r} = 3'b010;
            default {g, y, r} = 3'b001;
        endcase
    end
endmodule: train_top