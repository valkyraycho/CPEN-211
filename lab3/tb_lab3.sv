module tb_lab3();
    reg [9:0] SW;
    reg [3:0] KEY;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    wire [9:0] LEDR;
    reg clk, rst_n;
    assign KEY[0] = ~clk;
    assign KEY[3] = rst_n;

    lab3 dut(.SW, .KEY, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .LEDR);
    
    task reset; rst_n = 1'b0; #5; clk = 1'b1; #5; rst_n = 1'b1; clk = 1'b0; endtask
    task zero; SW[3:0] = 4'b0000; #5; clk = 1'b1; #5; clk = 1'b0; #5;endtask
    task one; SW[3:0] = 4'b0001; #5;clk = 1'b1; #5; clk = 1'b0;#5; endtask
    task two; SW[3:0] = 4'b0010; #5;clk = 1'b1; #5; clk = 1'b0; #5;endtask
    task three; SW[3:0] = 4'b0011; #5;clk = 1'b1; #5; clk = 1'b0;#5; endtask
    task four; SW[3:0] = 4'b0100; #5;clk = 1'b1; #5; clk = 1'b0; #5;endtask
    task five; SW[3:0] = 4'b0101; #5;clk = 1'b1; #5; clk = 1'b0;#5; endtask
    task six; SW[3:0] = 4'b0110; #5;clk = 1'b1; #5; clk = 1'b0; #5;endtask
    task seven; SW[3:0] = 4'b0111; #5;clk = 1'b1; #5; clk = 1'b0; #5;endtask
    task eight; SW[3:0] = 4'b1000; #5;clk = 1'b1; #5; clk = 1'b0; #5;endtask
    task nine; SW[3:0] = 4'b1001; #5;clk = 1'b1; #5; clk = 1'b0;#5; endtask
    
    initial
    begin
        // set initial values
        clk = 1'b0;
        rst_n = 1'b1;
        SW[9:0] = 4'b0000;
        #5;
        reset;

        assert(HEX0 === 7'b1000000 &&
               HEX1 === 7'b1111111 &&
               HEX2 === 7'b1111111 &&
               HEX3 === 7'b1111111 &&
               HEX4 === 7'b1111111 &&
               HEX5 === 7'b1111111) //initial value is 0000 = 0
                $display("[PASS] reset pressed with initial value 0");
        else $error("[FAIL] reset pressed with initial value 0");

        //test one switch at a time
        
        SW[0] <= 1'b1; //gives 0001 = 1;
        #5;
        assert(HEX0 === 7'b1111001 &&
               HEX1 === 7'b1111111 &&
               HEX2 === 7'b1111111 &&
               HEX3 === 7'b1111111 &&
               HEX4 === 7'b1111111 &&
               HEX5 === 7'b1111111)
                $display("[PASS] 0001: shows 1");
        else $error("[FAIL] 0001: shows 1");

        SW[1] <= 1'b1; //gives 0011 = 3;
        #5; 
        assert(HEX0 === 7'b0110000 &&
               HEX1 === 7'b1111111 &&
               HEX2 === 7'b1111111 &&
               HEX3 === 7'b1111111 &&
               HEX4 === 7'b1111111 &&
               HEX5 === 7'b1111111)
                $display("[PASS] 0011: shows 3");
        else $error("[FAIL] 0011: shows 3");

        SW[0] <= 1'b0; //gives 0010 = 2;
        #5; 
        assert(HEX0 === 7'b0100100 &&
               HEX1 === 7'b1111111 &&
               HEX2 === 7'b1111111 &&
               HEX3 === 7'b1111111 &&
               HEX4 === 7'b1111111 &&
               HEX5 === 7'b1111111)
                $display("[PASS] 0010: shows 2");
        else $error("[FAIL] 0010: shows 2");

        SW[2] = 1'b1; //gives 0110 = 6;
        #5; 
        assert(HEX0 === 7'b0000010 &&
               HEX1 === 7'b1111111 &&
               HEX2 === 7'b1111111 &&
               HEX3 === 7'b1111111 &&
               HEX4 === 7'b1111111 &&
               HEX5 === 7'b1111111)
                $display("[PASS] 0110: shows 6");
        else $error("[FAIL] 0110: shows 6");

        SW[0] = 1'b1; //gives 0111 = 7;
        #5; 
        assert(HEX0 === 7'b1111000 &&
               HEX1 === 7'b1111111 &&
               HEX2 === 7'b1111111 &&
               HEX3 === 7'b1111111 &&
               HEX4 === 7'b1111111 &&
               HEX5 === 7'b1111111)
                $display("[PASS] 0111: shows 7");
        else $error("[FAIL] 0111: shows 7");

        SW[1] = 1'b0; //gives 0101 = 5;
        #5; 
        assert(HEX0 === 7'b0010010 &&
               HEX1 === 7'b1111111 &&
               HEX2 === 7'b1111111 &&
               HEX3 === 7'b1111111 &&
               HEX4 === 7'b1111111 &&
               HEX5 === 7'b1111111)
                $display("[PASS] 0101: shows 5");
        else $error("[FAIL] 0101: shows 5");

        SW[0] = 1'b0; //gives 0100 = 4;
        #5; 
        assert(HEX0 === 7'b0011001 &&
               HEX1 === 7'b1111111 &&
               HEX2 === 7'b1111111 &&
               HEX3 === 7'b1111111 &&
               HEX4 === 7'b1111111 &&
               HEX5 === 7'b1111111)
                $display("[PASS] 0100: shows 4");
        else $error("[FAIL] 0100: shows 4");

        SW[3] = 1'b1; //gives 1100 = 12 (Error)
        #5; 
        assert(HEX0 === 7'b0101111 &&
               HEX1 === 7'b0100011 &&
               HEX2 === 7'b0101111 &&
               HEX3 === 7'b0101111 &&
               HEX4 === 7'b0000110 &&
               HEX5 === 7'b1111111)
                $display("[PASS] 1100: value 12 shows error");
        else $error("[FAIL] 1100: value 12 shows error");

        SW[2] = 1'b0; //gives 1000 = 8;
        #5; 
        assert(HEX0 === 7'b0000000 &&
               HEX1 === 7'b1111111 &&
               HEX2 === 7'b1111111 &&
               HEX3 === 7'b1111111 &&
               HEX4 === 7'b1111111 &&
               HEX5 === 7'b1111111)
                $display("[PASS] 1000: shows 8");
        else $error("[FAIL] 1000: shows 8");

        SW[0] = 1'b1; //gives 1001 = 9;
        #5; 
        assert(HEX0 === 7'b0011000 &&
               HEX1 === 7'b1111111 &&
               HEX2 === 7'b1111111 &&
               HEX3 === 7'b1111111 &&
               HEX4 === 7'b1111111 &&
               HEX5 === 7'b1111111)
                $display("[PASS] 1001: shows 9");
        else $error("[FAIL] 1001: shows 9");

        SW[1] = 1'b1; //gives 1011 = 11 (Error)
        #5; 
        assert(HEX0 === 7'b0101111 &&
               HEX1 === 7'b0100011 &&
               HEX2 === 7'b0101111 &&
               HEX3 === 7'b0101111 &&
               HEX4 === 7'b0000110 &&
               HEX5 === 7'b1111111)
                $display("[PASS] 1011: value 11 shows error");
        else $error("[FAIL] 1011: value 11 shows error");

        SW[0] = 1'b0; //gives 1010 = 10 (Error)
        #5; 
        assert(HEX0 === 7'b0101111 &&
               HEX1 === 7'b0100011 &&
               HEX2 === 7'b0101111 &&
               HEX3 === 7'b0101111 &&
               HEX4 === 7'b0000110 &&
               HEX5 === 7'b1111111)
                $display("[PASS] 1010: value 10 shows error");
        else $error("[FAIL] 1010: value 10 shows error");

        SW[2] = 1'b1; //gives 1110 = 14 (Error)
        #5; 
        assert(HEX0 === 7'b0101111 &&
               HEX1 === 7'b0100011 &&
               HEX2 === 7'b0101111 &&
               HEX3 === 7'b0101111 &&
               HEX4 === 7'b0000110 &&
               HEX5 === 7'b1111111)
                $display("[PASS] 1110: value 14 shows error");
        else $error("[FAIL] 1110: value 14 shows error");

        SW[0] = 1'b1; //gives 1111 = 15 (Error)
        #5; 
        assert(HEX0 === 7'b0101111 &&
               HEX1 === 7'b0100011 &&
               HEX2 === 7'b0101111 &&
               HEX3 === 7'b0101111 &&
               HEX4 === 7'b0000110 &&
               HEX5 === 7'b1111111)
                $display("[PASS] 1111: value 15 shows error");
        else $error("[FAIL] 1111: value 15 shows error");

        SW[1] = 1'b0; //gives 1101 = 13 (Error)
        #5; 
        assert(HEX0 === 7'b0101111 &&
               HEX1 === 7'b0100011 &&
               HEX2 === 7'b0101111 &&
               HEX3 === 7'b0101111 &&
               HEX4 === 7'b0000110 &&
               HEX5 === 7'b1111111)
                $display("[PASS] 1011: value 13 shows error");
        else $error("[FAIL] 1011: value 13 shows error");

        reset;

        assert(HEX0 === 7'b0101111 &&
               HEX1 === 7'b0100011 &&
               HEX2 === 7'b0101111 &&
               HEX3 === 7'b0101111 &&
               HEX4 === 7'b0000110 &&
               HEX5 === 7'b1111111) //value is still 1011 13 (Error)
                $display("[PASS] reset with value 13 shows error");
        else $error("[FAIL] reset with value 13 shows error");

        //reset the switches
        SW[3:0] = 4'b0000;
        #5;
       
        //test success: 320474
        three; two; zero; four; seven; four;
        assert(HEX0 === 7'b1001000 &&
               HEX1 === 7'b0000110 &&
               HEX2 === 7'b0001100 &&
               HEX3 === 7'b1000000 &&
               HEX4 === 7'b1111111 &&
               HEX5 === 7'b1111111) // show OPEN
                $display("[PASS] input succeeded: OPEN");
        else $error("[FAIL] input succeeded: OPEN");

        reset;

        assert(HEX0 === 7'b0011001 &&
               HEX1 === 7'b1111111 &&
               HEX2 === 7'b1111111 &&
               HEX3 === 7'b1111111 &&
               HEX4 === 7'b1111111 &&
               HEX5 === 7'b1111111)  
                $display("[PASS] remains 4 after reset");
        else $error("[FAIL] remains 4 after reset");


        //test fail: 320475
        three; two; zero; four; seven; five;
        assert(HEX0 === 7'b0100001 &&
               HEX1 === 7'b0000110 &&
               HEX2 === 7'b0010010 &&
               HEX3 === 7'b1000000 &&
               HEX4 === 7'b1000111 &&
               HEX5 === 7'b1000110) // show CLOSEd
                $display("[PASS] input failed: CLOSEd");
        else $error("[FAIL] input failed: CLOSEd");

        reset;

        //test fail: 320424
        three; two; zero; four; two; four;
        assert(HEX0 === 7'b0100001 &&
               HEX1 === 7'b0000110 &&
               HEX2 === 7'b0010010 &&
               HEX3 === 7'b1000000 &&
               HEX4 === 7'b1000111 &&
               HEX5 === 7'b1000110) // show CLOSEd
                $display("[PASS] input failed: CLOSEd");
        else $error("[FAIL] input failed: CLOSEd");

        reset;

        //test fail: 320174
        three; two; zero; one; seven; four;
        assert(HEX0 === 7'b0100001 &&
               HEX1 === 7'b0000110 &&
               HEX2 === 7'b0010010 &&
               HEX3 === 7'b1000000 &&
               HEX4 === 7'b1000111 &&
               HEX5 === 7'b1000110) // show CLOSEd
                $display("[PASS] input failed: CLOSEd");
        else $error("[FAIL] input failed: CLOSEd");
        
        reset;

        //test fail: 329474
        three; two; nine; four; seven; four;
        assert(HEX0 === 7'b0100001 &&
               HEX1 === 7'b0000110 &&
               HEX2 === 7'b0010010 &&
               HEX3 === 7'b1000000 &&
               HEX4 === 7'b1000111 &&
               HEX5 === 7'b1000110) // show CLOSEd
                $display("[PASS] input failed: CLOSEd");
        else $error("[FAIL] input failed: CLOSEd");

        reset;

        //test fail: 370474
        three; seven; zero; four; seven; four;
        assert(HEX0 === 7'b0100001 &&
               HEX1 === 7'b0000110 &&
               HEX2 === 7'b0010010 &&
               HEX3 === 7'b1000000 &&
               HEX4 === 7'b1000111 &&
               HEX5 === 7'b1000110) // show CLOSEd
                $display("[PASS] input failed: CLOSEd");
        else $error("[FAIL] input failed: CLOSEd");

        reset;

        //test fail: 120474
        one; two; zero; four; seven; four;
        assert(HEX0 === 7'b0100001 &&
               HEX1 === 7'b0000110 &&
               HEX2 === 7'b0010010 &&
               HEX3 === 7'b1000000 &&
               HEX4 === 7'b1000111 &&
               HEX5 === 7'b1000110) // show CLOSEd
                $display("[PASS] input failed: CLOSEd");
        else $error("[FAIL] input failed: CLOSEd");
        
        reset;

        //test reset in process
        three; seven; reset;
        assert(HEX0 === 7'b1111000 &&
               HEX1 === 7'b1111111 &&
               HEX2 === 7'b1111111 &&
               HEX3 === 7'b1111111 &&
               HEX4 === 7'b1111111 &&
               HEX5 === 7'b1111111) 
                $display("[PASS] remain seven after reset");
        else $error("[FAIL] remain seven after reset");

        //test fail: 123474
        one; two; three; four; seven; four;
        assert(HEX0 === 7'b0100001 &&
               HEX1 === 7'b0000110 &&
               HEX2 === 7'b0010010 &&
               HEX3 === 7'b1000000 &&
               HEX4 === 7'b1000111 &&
               HEX5 === 7'b1000110) // show CLOSEd
                $display("[PASS] input failed again after reset in process: CLOSEd");
        else $error("[FAIL] input failed again after reset in process: CLOSEd");

    end
endmodule: tb_lab3
