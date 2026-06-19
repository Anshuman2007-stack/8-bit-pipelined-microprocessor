`timescale 1ns / 1ps

module PC_tb;

    reg clk;
    reg reset;
    reg [7:0] next_pc;
    wire [7:0] pc;

    PC uut (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        next_pc = 8'd0;

        $monitor("Time=%0t | reset=%b | next_pc=%d | pc=%d",
                  $time, reset, next_pc, pc);

       
        #10;
        reset = 0;   // reset test

        
        next_pc = 8'd4;  // load pc=4
        #10;

        
        next_pc = 8'd8;  
        #10;

        
        next_pc = 8'd12; 
        #10;

        
        next_pc = 8'd20;
        #10;

        reset = 1;
        #10;

        reset = 0;
        next_pc = 8'd50;
        #10;

        $finish;

    end

endmodule
