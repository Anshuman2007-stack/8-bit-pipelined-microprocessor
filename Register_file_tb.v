`timescale 1ns / 1ps

module Register_file_tb;

   
    reg clk;
    reg reset;
    reg RegWrite;

    reg [4:0] Rs1;
    reg [4:0] Rs2;
    reg [4:0] Rd;

    reg [7:0] WriteData;

   
    wire [7:0] Read_data1;
    wire [7:0] Read_data2;

 
    Register_file uut (
        .clk(clk),
        .reset(reset),
        .RegWrite(RegWrite),
        .Rs1(Rs1),
        .Rs2(Rs2),
        .Rd(Rd),
        .WriteData(WriteData),
        .Read_data1(Read_data1),
        .Read_data2(Read_data2)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        RegWrite = 0;

        Rs1 = 0;
        Rs2 = 0;
        Rd  = 0;
        WriteData = 0;

        $monitor(
        "Time=%0t Reset=%b RegWrite=%b Rd=%d WriteData=%d Rs1=%d Read1=%d Rs2=%d Read2=%d",
        $time, reset, RegWrite, Rd, WriteData,
        Rs1, Read_data1, Rs2, Read_data2);

        #10;
        reset = 0;

        RegWrite = 1;
        Rd = 5;
        WriteData = 8'd25;
        #10;

        RegWrite = 0;
        Rs1 = 5;
        #10;

        RegWrite = 1;
        Rd = 10;
        WriteData = 8'd100;
        #10;

        Rd = 15;
        WriteData = 8'd55;
        #10;

        RegWrite = 0;
        Rs1 = 10;
        Rs2 = 15;
        #10;

        RegWrite = 1;
        Rd = 20;
        WriteData = 8'd200;
        #10;

        RegWrite = 0;
        Rs1 = 20;
        #10;

        Rs1 = 5;
        Rs2 = 20;
        #10;

        reset = 1;
        #10;
        reset = 0;


        Rs1 = 5;
        Rs2 = 10;
        #10;

        $finish;

    end

endmodule
