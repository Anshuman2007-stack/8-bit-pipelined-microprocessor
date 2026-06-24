`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2026 13:27:44
// Design Name: 
// Module Name: mcm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module PC(
    input clk,
    input reset,
    input [7:0] next_pc,
    output reg [7:0] pc
);

always @(posedge clk or posedge reset) begin

    if (reset)
        pc <=8'b0;

    else
        pc <= next_pc;

end

endmodule

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
imemory[19] =24'b001010010100110000000011;          //ADDI r6,r5,3
imemory[20] =24'b010101110111110111110000;         // ROR
imemory[21] =24'b010111110111110111110000;         // ROL r31,r29,r30
end

integer k;
initial begin
  for (k = 22; k < NOMU; k = k + 1) begin  
    imemory[k] <= 24'b0;                 
  end
end
  
assign instruction_out = imemory[PC_address];



endmodule

module instruction_decoder (
    input [23:0] instruction,
    output reg [4:0] opcode,
    output reg [3:0] func,
    output reg [4:0] rs,
    output reg [4:0] rt,
    output reg [4:0] rd,
    output reg [7:0] immediate
);

parameter R_TYPE            = 5'b01100;
parameter LOADI             = 5'b00001;
parameter LOAD              = 5'b00010;
parameter STORE             = 5'b00011;
parameter JUMP              = 5'b00100;
parameter LEFT_SHIFT        = 5'b00110;
parameter RIGHT_SHIFT       = 5'b00111;
parameter BRANCH_OVF        = 5'b01000;
parameter SLT               = 5'b01001;
parameter BEQ           =5'b01101;
parameter BNE           =5'b01110;
parameter LSR           =5'b01111;
parameter ADDI          =5'b00101;
parameter ROR           =5'b01010;
parameter ROL           =5'b01011;

always @(*) begin
    opcode    = instruction[23:19];
    func      = 4'b0;
    rs        = 5'b0;
    rt        = 5'b0;
    rd        = 5'b0;
    immediate = 8'b0;

    case (opcode)
        R_TYPE: begin
            rs   = instruction[18:14];
            rt   = instruction[13:9];
            rd   = instruction[8:4];
            func = instruction[3:0];
        end
        LOADI, LOAD, STORE: begin
            rs        = instruction[18:14];
            rt        = instruction[13:9];
            rd = instruction[13:9];
            immediate = instruction[7:0];
        end
        JUMP: begin
            immediate = instruction[7:0];
        end
        LEFT_SHIFT, RIGHT_SHIFT,LSR,ROR,ROL: begin
            rs = instruction[18:14];
            rt = instruction[13:9];
            rd = instruction[8:4];
        end
        BRANCH_OVF: begin
        rs = instruction[18:14];      
        rt = instruction[13:9];
        immediate = instruction[7:0];
        end
        SLT: begin
            rs = instruction[18:14];
            rt = instruction[13:9];
            rd = instruction[8:4];
        end
        BEQ: begin
        rs = instruction[18:14];      
        rt = instruction[13:9];       
        immediate= instruction[7:0];
         end
        BNE: begin
        rs = instruction[18:14];      
        rt = instruction[13:9];       
        immediate= instruction[7:0];
        end
        ADDI: begin
        rs = instruction[18:14];
        rd = instruction[13:9];
        immediate = instruction[7:0];
        end
            
        default: begin
        end
    endcase
end
endmodule
module alu(
    input  [7:0] SrcA,
    input  [7:0] SrcB,
    input  [3:0] alu_control,
    output reg [7:0] Out,
    output reg Zero,
    output reg Overflow
);

parameter ADD               = 4'b1000;
parameter SUBTRACT          = 4'b1001;
parameter MULTIPLY          = 4'b1010;
parameter DIVIDE            = 4'b1011;
parameter AND               = 4'b1100;
parameter OR                = 4'b1101;
parameter NOT               = 4'b1110;
parameter XOR               = 4'b1111;
parameter Right_Shift       = 4'b0001;
parameter Left_Shift        = 4'b0010;
parameter SLT               = 4'b0101;
parameter LSR               = 4'b0011;
parameter ROR               = 4'b0100;
parameter ROL               = 4'b0110;

reg [2:0] shift_amt;

always @(*) begin
    Out = 8'b0;
    Overflow = 1'b0;
    Zero = 1'b0;

    case (alu_control)
        ADD: begin
            Out = SrcA + SrcB;
            Overflow = (SrcA[7] == SrcB[7]) && (Out[7] != SrcA[7]) ? 1'b1 : 1'b0;
        end
        SUBTRACT: begin
            Out = SrcA + (~SrcB + 1'b1);
            Overflow = (SrcA[7] != SrcB[7]) && (Out[7] != SrcA[7]) ? 1'b1 : 1'b0;
        end
        MULTIPLY: Out = SrcA * SrcB;
        DIVIDE: Out = (SrcB != 0) ? SrcA / SrcB : 8'b0;
        AND: Out = SrcA & SrcB;
        OR: Out = SrcA | SrcB;
        NOT: Out = ~SrcA;
        XOR: Out = SrcA ^ SrcB;
        Right_Shift: Out = $signed(SrcA) >>> SrcB;
        Left_Shift: Out = SrcA << SrcB;
        LSR: Out = SrcA >> SrcB;
        SLT:begin Out = (SrcA + (~SrcB + 8'b1));
        Overflow = (SrcA[7] != SrcB[7]) && (Out[7] != SrcA[7]) ? 1'b1 : 1'b0;
        Out = {7'b0, (Out[7] ^ Overflow)};//XOR with overflow to preserve logic for opposite sign comparisons
        end
        ROR: begin
       shift_amt = SrcB % 8;
    
        if (shift_amt == 0)
        Out = SrcA;
        else
        Out = ((SrcA >> shift_amt) | (SrcA << (8 - shift_amt)));
        end
        ROL: begin
       shift_amt = SrcB % 8;
    
        if (shift_amt == 0)
        Out = SrcA;
        else
         Out = ((SrcA << shift_amt) | (SrcA >> (8 - shift_amt)));
        end
      
        default: Out = 8'b0;
    endcase

    Zero = (Out == 0) ? 1'b1 : 1'b0;
end
endmodule


module Control_Unit(
    input [4:0] opcode,
    input [3:0] func,
    input Zero,
    input Overflow,
    output reg RegWrite,
    output reg ALUSrc,
    output reg MemWrite,
    output reg MemRead,
    output reg [3:0] alu_control,
    output reg ResultSrc,
    output reg PCSrc
);

parameter R_TYPE            = 5'b01100;
parameter LOADI             = 5'b00001;
parameter LOAD              = 5'b00010;
parameter STORE             = 5'b00011;
parameter JUMP              = 5'b00100;
parameter LEFT_SHIFT        = 5'b00110;
parameter RIGHT_SHIFT       = 5'b00111;
parameter BRANCH_OVF        = 5'b01000;
parameter SLT               = 5'b01001;
parameter BEQ           =5'b01101;
parameter BNE           =5'b01110;

parameter F_ADD = 4'b0000;
parameter F_SUB = 4'b0001;
parameter F_MUL = 4'b0010;
parameter F_DIV = 4'b0011;
parameter F_AND = 4'b0100;
parameter F_OR  = 4'b0101;
parameter F_NOT = 4'b0110;
parameter F_XOR = 4'b0111;
parameter F_BEQ = 4'b1000;
parameter F_BNE = 4'b1001;

parameter ALU_ADD               = 4'b1000;
parameter ALU_SUBTRACT          = 4'b1001;
parameter ALU_MULTIPLY          = 4'b1010;
parameter ALU_DIVIDE            = 4'b1011;
parameter ALU_AND               = 4'b1100;
parameter ALU_OR                = 4'b1101;
parameter ALU_NOT               = 4'b1110;
parameter ALU_XOR               = 4'b1111;
parameter ALU_Right_Shift       = 4'b0001;
parameter ALU_Left_Shift        = 4'b0010;
parameter ALU_SLT               = 4'b0101;

always@(*) begin
    RegWrite = 0;
    ALUSrc = 0;
    MemWrite = 0;
    MemRead = 0;
    ResultSrc = 0;
    alu_control = 4'b0000;
    ResultSrc   = 0;
    PCSrc       = 0;

    case(opcode)
        R_TYPE: begin
            RegWrite = 1;
            ALUSrc   = 0;
            case(func)
                F_ADD: alu_control = ALU_ADD;
                F_SUB: alu_control = ALU_SUBTRACT;
                F_MUL: alu_control = ALU_MULTIPLY;
                F_DIV: alu_control = ALU_DIVIDE;
                F_AND: alu_control = ALU_AND;
                F_OR:  alu_control = ALU_OR;
                F_NOT: alu_control = ALU_NOT;
                F_XOR: alu_control = ALU_XOR;
                default: alu_control = 4'b0000;
            endcase
        end
        LOADI: begin
            RegWrite    = 1;
            ALUSrc      = 1;
            alu_control = ALU_ADD;
            ResultSrc   = 0;
        end
        LOAD: begin
            MemRead = 1;
            RegWrite = 1;
            ALUSrc = 1;
            alu_control = ALU_ADD;
            ResultSrc = 1;
        end
        JUMP: begin
            PCSrc = 1;
        end
        STORE: begin
            ALUSrc = 1;
            MemWrite = 1;
            alu_control = ALU_ADD;
        end
       
        LEFT_SHIFT: begin
            RegWrite    = 1;
            ALUSrc      = 0;
            alu_control = ALU_Left_Shift;
        end
        RIGHT_SHIFT: begin
            RegWrite    = 1;
            ALUSrc      = 0;
            alu_control = ALU_Right_Shift;
        end
        BRANCH_OVF: begin
            alu_control=ALU_ADD;
            PCSrc = Overflow;
        end
        SLT: begin
            RegWrite    = 1;
            ALUSrc      = 0;
            alu_control = ALU_SLT;
        end
        BEQ:begin
        ALUSrc = 0;
        alu_control=ALU_SUBTRACT;
        PCSrc = Zero;
        end
        BNE:begin
        ALUSrc=0;
        alu_control=ALU_SUBTRACT;
        PCSrc= ~Zero;
        end
        default: alu_control = 4'b0000;
    endcase
end
endmodule

module PC_Adder(
input  [7:0] PC,
output [7:0] PC_Plus1
);

assign PC_Plus1 = PC + 8'd1;

endmodule

module Branch_Adder(
input  [7:0] PC,
input  [7:0] Immediate,
output [7:0] BranchTarget
);

assign BranchTarget = PC + Immediate;

endmodule

module Register_file(clk,reset,RegWrite,Rs1,Rs2,Rd,WriteData,Read_data1,Read_data2);
    input clk,reset,RegWrite;
    
    input [4:0] Rs1;
    input [4:0] Rs2;
    input [4:0] Rd;

    input [7:0] WriteData;

    output [7:0] Read_data1;
    output [7:0] Read_data2;


reg [7:0] Registers [31:0];
integer k;


assign Read_data1 = Registers[Rs1];
assign Read_data2 = Registers[Rs2];


always @(posedge clk)
begin
    if(reset)
    begin
        for(k = 0; k < 32; k = k + 1)
            Registers[k] <= 8'b0;
    end
    else if(RegWrite)
    begin
        Registers[Rd] <= WriteData;
    end
end
endmodule

module Data_Memory(clk, reset, MemWrite, MemRead, address, write_data, read_data);

    input clk, reset, MemWrite, MemRead;
    input [7:0] address, write_data;
    output [7:0] read_data;
    reg [7:0] dmemory[0:31];
    integer k;
    assign read_data = (MemRead) ? dmemory[address] : 8'b0;
     
    always @ (posedge clk)
    begin
        if(reset == 1'b1)
          for (k = 0; k<32; k = k+1)
            dmemory[k] <= 8'b0;
        else if(MemWrite) dmemory[address] <= write_data;
    end

endmodule

module MUX_2_1(
input [7:0] inA,inB,
input sel,
output [7:0] out
);

assign out = sel? inA:inB;
endmodule

module MCPModule(
input clk, rst1,  //rst2,rst3,
output [7:0] result
);
  
wire [7:0] next_pc;
wire [7:0] PC_address;//PC Wire
wire [23:0] instruction_out; //INST MEM
wire RegWrite_wire;
wire [4:0] Rs1,Rs2,Rd;
wire [7:0] WriteData;
wire [7:0] Read_data1,Read_data2;//REGISTERFILE
wire [4:0] opcode_wire;
wire [3:0] function_code_wire;
wire Zero_wire ,Overflow_wire;
wire PCSrc_wire;               
wire [7:0] SrcB;
wire [3:0] alu_control_wire;                   
wire MemWrite_wire, MemRead_wire;
wire [7:0] read_data;    // DATA MEMORY                         
wire ResultSrc_wire;
wire [7:0] Out_wire;         
wire ALUSrc_wire;
wire [7:0] immediate_wire;   
wire [7:0] PC_Plus_1_wire,BranchTarget_wire;

assign result=Out_wire;

PC counter (.clk(clk), .reset(rst1), .next_pc(next_pc), .pc(PC_address));
Instruction_Memory im (.reset(rst1), .PC_address(PC_address), .instruction_out(instruction_out));
instruction_decoder id (.instruction(instruction_out), .opcode(opcode_wire), .func(function_code_wire), .rs(Rs1), .rt(Rs2), .rd(Rd), .immediate(immediate_wire));
Register_file rg (.clk(clk), .reset(rst1), .RegWrite(RegWrite_wire), .Rs1(Rs1), .Rs2(Rs2), .Rd(Rd), .WriteData(WriteData), .Read_data1(Read_data1), .Read_data2(Read_data2));
Control_Unit cu (.opcode(opcode_wire), .func(function_code_wire), .Zero(Zero_wire), .Overflow(Overflow_wire), .RegWrite(RegWrite_wire), .ALUSrc(ALUSrc_wire), .MemWrite(MemWrite_wire), .MemRead(MemRead_wire), .alu_control(alu_control_wire), .ResultSrc(ResultSrc_wire), .PCSrc(PCSrc_wire) );
alu ALU (.SrcA(Read_data1), .SrcB(SrcB), .alu_control(alu_control_wire), .Out(Out_wire), .Zero(Zero_wire), .Overflow(Overflow_wire));
Data_Memory dm (.clk(clk), .reset(rst1), .MemWrite(MemWrite_wire), .MemRead(MemRead_wire), .address(Out_wire), .write_data(Read_data2), .read_data(read_data));
PC_Adder pc_a(.PC(PC_address),.PC_Plus1(PC_Plus_1_wire));
Branch_Adder ba(.PC(PC_address),.Immediate(immediate_wire),.BranchTarget(BranchTarget_wire));
MUX_2_1 MemtoReg_mux (.inA(read_data), .inB(Out_wire), .sel(ResultSrc_wire), .out(WriteData));
MUX_2_1 ALUSrc_mux (.inB(Read_data2), .inA(immediate_wire), .sel(ALUSrc_wire), .out(SrcB));
MUX_2_1 PCSrc_Mux (.inA(BranchTarget_wire), .inB(PC_Plus_1_wire), .sel(PCSrc_wire), .out(next_pc));


endmodule
