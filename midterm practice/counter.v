module counter(input clk, input rstn, output [7:0] out)
    wire over, under, down;
    datapath dpth(.clk, .rstn, .down, .over, .under, .out)
    control ctl(.clk, .rstn, .over, .under, .down);
endmodule: counter

module datapath(input clk, input rstn, input down, output over, output under, output [7:0] out)
    reg [7:0] count;
    assign out = count;

    wire [7:0] add = count + 8'd1;
    wire [7:0] sub = count - 8'd1;
    assign over = add == 8'd255;
    assign under = sub == 8'd0;

    always_ff @(posedge clk)
    begin
        if(~rstn)
        begin
            count <= 8'd0;
        end
        else
        begin
            count = down ? sub : add;
        end
    end
endmodule: datapath

module control(input clk, input rstn, input over, input under, output down)
    reg dir;
    assign down = dir;

    wire flip = dir ? under : over;

    always_ff @(posedge clk)
    begin
        if(~rstn)
        begin
            dir <= 1'd0;
        end
        else 
        begin
            dir = flip ? ~dir : dir;
        end
    end
endmodule: control