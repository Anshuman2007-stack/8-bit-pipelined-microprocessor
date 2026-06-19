`timescale 1ns / 1ps

module Instruction_Memory_tb;

    reg reset;
    reg [7:0] PC_address;

    wire [23:0] instruction_out;

    Instruction_Memory uut (
        .reset(reset),
        .PC_address(PC_address),
        .instruction_out(instruction_out)
    );

    initial begin

        $monitor("Time=%0t Reset=%b Address=%d Instruction=%h",
                 $time, reset, PC_address, instruction_out);

        reset = 0;
        PC_address = 0;

        uut.imemory[0] = 24'h123456;
        uut.imemory[1] = 24'hABCDEF;
        uut.imemory[2] = 24'hFEDCBA;
        uut.imemory[3] = 24'h654321;

        #10;
        PC_address = 0;
        #10;

        PC_address = 1;
        #10;

        PC_address = 2;
        #10;

        PC_address = 3;
        #10;

        reset = 1;
        #10;
        reset = 0;

        PC_address = 0;
        #10;

        PC_address = 1;
        #10;

        PC_address = 2;
        #10;

        PC_address = 3;
        #10;

        $finish;

    end

endmodule
