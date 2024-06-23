module lab3(input [9:0] SW, input [3:0] KEY,
            output [6:0] HEX0, output [6:0] HEX1, output [6:0] HEX2,
            output [6:0] HEX3, output [6:0] HEX4, output [6:0] HEX5,
            output [9:0] LEDR);
    wire clk = ~KEY[0]; // this is your clock
    wire rst_n = KEY[3]; // this is your reset; your reset should be synchronous and active-low
    
    reg [6:0] hex_0, hex_1, hex_2, hex_3, hex_4, hex_5;
    assign {HEX0, HEX1, HEX2, HEX3, HEX4, HEX5} = {hex_0, hex_1, hex_2, hex_3, hex_4, hex_5};

    enum reg [3:0]
    {
        first, first_fail, 
        second, second_fail, 
        third, third_fail, 
        fourth, fourth_fail, 
        fifth, fifth_fail, 
        sixth, CLOSEd,
        OPEN
    } state;

    reg HEXON;

    always_comb 
    begin
        casex({SW [3:0], state, HEXON})
            {4'b0000, 4'bxxxx, 1'b1}: {hex_0,hex_1,hex_2,hex_3,hex_4,hex_5} = 
            {7'b1000000,7'b1111111, 7'b1111111, 7'b1111111,7'b1111111,7'b1111111};

            {4'b0001, 4'bxxxx, 1'b1}: {hex_0,hex_1,hex_2,hex_3,hex_4,hex_5} = 
            {7'b1111001,7'b1111111, 7'b1111111, 7'b1111111,7'b1111111,7'b1111111};

            {4'b0010, 4'bxxxx, 1'b1}: {hex_0,hex_1,hex_2,hex_3,hex_4,hex_5} = 
            {7'b0100100,7'b1111111, 7'b1111111, 7'b1111111,7'b1111111,7'b1111111};

            {4'b0011, 4'bxxxx, 1'b1}: {hex_0,hex_1,hex_2,hex_3,hex_4,hex_5} = 
            {7'b0110000,7'b1111111, 7'b1111111, 7'b1111111,7'b1111111,7'b1111111};

            {4'b0100, 4'bxxxx, 1'b1}: {hex_0,hex_1,hex_2,hex_3,hex_4,hex_5} = 
            {7'b0011001,7'b1111111, 7'b1111111, 7'b1111111,7'b1111111,7'b1111111};

            {4'b0101, 4'bxxxx, 1'b1}: {hex_0,hex_1,hex_2,hex_3,hex_4,hex_5} = 
            {7'b0010010,7'b1111111, 7'b1111111, 7'b1111111,7'b1111111,7'b1111111};

            {4'b0110, 4'bxxxx, 1'b1}: {hex_0,hex_1,hex_2,hex_3,hex_4,hex_5} = 
            {7'b0000010,7'b1111111, 7'b1111111, 7'b1111111,7'b1111111,7'b1111111};

            {4'b0111, 4'bxxxx, 1'b1}: {hex_0,hex_1,hex_2,hex_3,hex_4,hex_5} = 
            {7'b1111000,7'b1111111, 7'b1111111, 7'b1111111,7'b1111111,7'b1111111};

            {4'b1000, 4'bxxxx, 1'b1}: {hex_0,hex_1,hex_2,hex_3,hex_4,hex_5} = 
            {7'b0000000,7'b1111111, 7'b1111111, 7'b1111111,7'b1111111,7'b1111111};
            
            {4'b1001, 4'bxxxx, 1'b1}: {hex_0,hex_1,hex_2,hex_3,hex_4,hex_5} = 
            {7'b0011000,7'b1111111, 7'b1111111, 7'b1111111,7'b1111111,7'b1111111};

            {4'bxxxx, CLOSEd, 1'b0}: {hex_0,hex_1,hex_2,hex_3,hex_4,hex_5} = 
            {7'b0100001,7'b0000110, 7'b0010010, 7'b1000000,7'b1000111,7'b1000110};

            {4'bxxxx, OPEN, 1'b0}: {hex_0,hex_1,hex_2,hex_3,hex_4,hex_5} = 
            {7'b1001000,7'b0000110, 7'b0001100, 7'b1000000,7'b1111111,7'b1111111};

            default {hex_0,hex_1,hex_2,hex_3,hex_4,hex_5} = 
            {7'b0101111,7'b0100011, 7'b0101111, 7'b0101111,7'b0000110,7'b1111111};

        endcase    
    end

    always_ff @(posedge clk)
    begin
        if(~rst_n)
        begin
            state <= first;
            HEXON <= 1'b1;
        end
        else
        begin
            HEXON <= 1'b1;
            case(state)
                first: if(SW[3:0] == 4'b0011) state <= second; else state <= first_fail;
                first_fail: state <= second_fail;
                second: if(SW[3:0] == 4'b0010) state <= third; else state <= second_fail;
                second_fail: state <= third_fail;
                third: if(SW[3:0] == 4'b0000) state <= fourth; else state <= third_fail;
                third_fail: state <= fourth_fail;
                fourth: if(SW[3:0] == 4'b0100) state <= fifth; else state <= fourth_fail;
                fourth_fail: state <= fifth_fail;
                fifth: if(SW[3:0] == 4'b0111) state <= sixth; else state <= fifth_fail;
                fifth_fail: {state, HEXON} <= {CLOSEd, 1'b0};
                sixth: if(SW[3:0] == 4'b0100) 
                begin
                    state <= OPEN; HEXON <= 1'b0;
                end
                else 
                begin
                    state <= CLOSEd; HEXON <= 1'b0;
                end
            endcase
        end
    end
endmodule: lab3
