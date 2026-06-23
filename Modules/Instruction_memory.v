module Instruction_Memory #(parameter NOMU = 32)(
input reset,
input [7:0] PC_address,
output [23:0] instruction_out
);
reg [23:0] imemory [0:NOMU-1];
//FORMAT:- OPCODE=5, FUNC = 4, REGS = 5, IMM = 1+8, ;
initial begin
imemory[0] =24'b011000000000001000100000;           //RTYPE - ADD
imemory[1] =24'b011000000000001000110001;           //RTYPE - SUBTRACT
imemory[2] =24'b011000000000001001000010;           //RTYPE - MULTIPLY
imemory[3] =24'b011000000000001001010011;           //RTYPE - DIVIDE
imemory[4] =24'b011000000000001001100100;           //RTYPE - AND
imemory[5] =24'b011000000000001001110101;           //RTYPE - OR
imemory[6] =24'b011000000000001010000110;           //RTYPE - NOT
imemory[7] =24'b011000000000001010010111;           //RTYPE - XOR
imemory[8] =24'b000010101001011000000011;           //LOADI - reg no 10 is rs, contains data mem wala address, reg 11 is dest reg, offset to load = 3
imemory[9] =24'b000100110001101000000101;           //LOAD - reg no 12 is rs, contains actual data mem address , reg no 13 is rt, OFFSET for mem = 5
imemory[10] =24'b000110111001111000000100;          //STORE - offset = 4
imemory[11] =24'b001000000000000000000011;          //JUMP by 3 (PC+3)
imemory[12] =24'b001101000010001100100010;          //LEFT_SHIFT
imemory[13] =24'b001111001110100101010001;          //RIGHT_SHIFT
imemory[14] =24'b010000000000001000000011;          //BRANCH_OVF
imemory[15] =24'b010011011010111110000101;          //SLT
imemory[16] =24'b011011100111010000000010;          //BEQ- offset = 2
imemory[17] =24'b011101101111100000000010;          //BNE- offset = 2
imemory[18] =24'b011111110111110111110000;        //LSR
end

integer k;
initial begin
  for (k = 19; k < NOMU; k = k + 1) begin  
    imemory[k] <= 24'b0;                 
  end
end
  
assign instruction_out = imemory[PC_address];



endmodule

