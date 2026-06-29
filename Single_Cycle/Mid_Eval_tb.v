`timescale 1ns / 1ps
module tb_MCPModule();
    reg clk;
    reg rst1; 
    wire [7:0] result;
    MCPModule uut (
        .clk(clk), 
        .rst1(rst1), 
        .result(result)
    );
    always #5 clk = ~clk;
    always @(negedge clk) begin
        if (!rst1) begin
            $display("Time: %4t | R1(i)=%2d | R2(j)=%2d | R3(n)=%2d | R4(arr[i])=%2d | R5(arr[j])=%2d", 
                     $time, 
                     uut.rg.Registers[1], 
                     uut.rg.Registers[2], 
                     uut.rg.Registers[3], 
                     uut.rg.Registers[4], 
                     uut.rg.Registers[5]);
        end
    end
    initial begin
        clk = 0;
        rst1 = 1;
        #100;
        rst1 = 0;
        uut.dm.dmemory[0] = 8'd5;
        uut.dm.dmemory[1] = 8'd8;
        uut.dm.dmemory[2] = 8'd2;

        uut.im.imemory[ 0]  = 24'h080E00;  // 000010000000111000000000
        uut.im.imemory[ 1]  = 24'h080603;  // 000010000000011000000011
        uut.im.imemory[ 2]  = 24'h081001;  // 000010000001000000000001
        uut.im.imemory[ 3]  = 24'h080200;  // 000010000000001000000000
        uut.im.imemory[ 4]  = 24'h484660;  // 010010000100011001100000
        uut.im.imemory[ 5]  = 24'h698E11;  // 011010011000111000010001
        uut.im.imemory[ 6]  = 24'h604E20;  // 011000000100111000100000
        uut.im.imemory[ 7]  = 24'h488660;  // 010010001000011001100000
        uut.im.imemory[ 8]  = 24'h698E0D;  // 011010011000111000001101
        uut.im.imemory[ 9]  = 24'h600290;  // 011000000000001010010000
        uut.im.imemory[10]  = 24'h124800;  // 000100100100100000000000
        uut.im.imemory[11]  = 24'h600490;  // 011000000000010010010000
        uut.im.imemory[12]  = 24'h124A00;  // 000100100100101000000000
        uut.im.imemory[13]  = 24'h494860;  // 010010010100100001100000
        uut.im.imemory[14]  = 24'h698E05;  // 011010011000111000000101
        uut.im.imemory[15]  = 24'h600290;  // 011000000000001010010000
        uut.im.imemory[16]  = 24'h1A4A00;  // 000110100100101000000000
        uut.im.imemory[17]  = 24'h600490;  // 011000000000010010010000
        uut.im.imemory[18]  = 24'h1A4800;  // 000110100100100000000000
        uut.im.imemory[19]  = 24'h609020;  // 011000001001000000100000
        uut.im.imemory[20]  = 24'h2000F3;  // 001000000000000011110011
        uut.im.imemory[21]  = 24'h605010;  // 011000000101000000010000
        uut.im.imemory[22]  = 24'h2000EE;  // 001000000000000011101110
        uut.im.imemory[23]  = 24'h080000;  // 000010000000000000000000
        

        #2000;   //If your simulation is not executing like our results then set the XSim simulation runtime to 5000 ns instead of default 1000 ns

        $display("========================================");
        $display("Execution Complete. Checking Data Memory");
        $display("========================================");
        $display("arr[0] = %d (Expected: 2)", uut.dm.dmemory[0]);
        $display("arr[1] = %d (Expected: 5)", uut.dm.dmemory[1]);
        $display("arr[2] = %d (Expected: 8)", uut.dm.dmemory[2]);
        $display("========================================");

        $finish;
    end
endmodule
