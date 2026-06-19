`timescale 1ns / 1ps

module alu_tb;
    reg [7:0] SrcA;
    reg [7:0] SrcB;
    reg [3:0] alu_control;
    wire [7:0] Out;
    wire Zero;
    wire Overflow;

   
    alu uut (
        .SrcA(SrcA),
        .SrcB(SrcB),
        .alu_control(alu_control),
        .Out(Out),
        .Zero(Zero),
        .Overflow(Overflow)
    );

    initial begin

        $monitor("Time=%0t | Ctrl=%b | A=%d | B=%d | Out=%d | Zero=%b | Overflow=%b",
                  $time, alu_control, SrcA, SrcB, Out, Zero, Overflow);

        SrcB = 8'd37;
        alu_control = 4'b1000;
        #10;

        SrcA = 8'd127;
        SrcB = 8'd1;
        alu_control = 4'b1000;
        #10;

        SrcA = 8'd50;
        SrcB = 8'd18;
        alu_control = 4'b1001;
        #10;

        SrcA = 8'd77;
        SrcB = 8'd77;
        alu_control = 4'b1001;
        #10;

        SrcA = 8'd7;
        SrcB = 8'd6;
        alu_control = 4'b1010;
        #10;

        SrcA = 8'd81;
        SrcB = 8'd9;
        alu_control = 4'b1011;
        #10;

        SrcA = 8'd45;
        SrcB = 8'd0;
        alu_control = 4'b1011;
        #10;

        SrcA = 8'b11110000;
        SrcB = 8'b10101010;
        alu_control = 4'b1100;
        #10;

        SrcA = 8'b01010101;
        SrcB = 8'b00111100;
        alu_control = 4'b1101;
        #10;

        SrcA = 8'b11001100;
        SrcB = 8'b00000000;
        alu_control = 4'b1110;
        #10;

        SrcA = 8'b10101010;
        SrcB = 8'b11110000;
        alu_control = 4'b1111;
        #10;

        SrcA = 8'b11101000;
        SrcB = 8'b00000000;
        alu_control = 4'b0001;
        #10;

        SrcA = 8'b00001101;
        SrcB = 8'b00000000;
        alu_control = 4'b0010;
        #10;

        SrcA = 8'd12;
        SrcB = 8'd20;
        alu_control = 4'b0101;
        #10;

        SrcA = 8'd40;
        SrcB = 8'd15;
        alu_control = 4'b0101;
        #10;

        $finish;

    end

endmodule
