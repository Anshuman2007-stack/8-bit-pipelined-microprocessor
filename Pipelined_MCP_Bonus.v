`timescale 1ns / 1ps

module PC(
    input clk,
    input reset,
    input [7:0] next_pc,
    input PCWrite,
    output reg [7:0] pc
);

always @(posedge clk or posedge reset) begin

    if (reset)
        pc <=8'b0;

    else if(PCWrite)
        pc <= next_pc;

end

endmodule

module Instruction_Memory #(parameter NOMU = 128)(
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
imemory[22] =24'b100110000000000000000000;
end

integer k;
initial begin
  for (k = 22; k < NOMU; k = k + 1) begin  
    imemory[k] = 24'b0;                 
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
    output reg [7:0] immediate,
    output reg Illegal_Instruction
);
parameter NORMAL            =5'b0;
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
parameter TRAP          =5'b10010;
parameter ERET          =5'b10011;
parameter JAL           =5'b10000;
parameter JR            =5'b10001;

always @(*) begin
    opcode    = instruction[23:19];
    func      = 4'b0;
    rs        = 5'b0;
    rt        = 5'b0;
    rd        = 5'b0;
    immediate = 8'b0;
    Illegal_Instruction=1'b0;

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
        NORMAL,TRAP,ERET:begin
        end
        JAL: begin
        rd = instruction[13:9];
        immediate = instruction[7:0];
        end
        JR: begin
        rs = instruction[18:14];
        end
        default: begin
        Illegal_Instruction=1'b1;
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
reg temp_ovf;
reg [8:0]temp_Out;
always @(*) begin
    Out = 8'b0;
    Overflow = 1'b0;
    Zero = 1'b0;
    shift_amt=3'b0;

    case (alu_control)
        ADD: begin
            temp_Out = SrcA + SrcB;
            Out=temp_Out[7:0];
            Overflow = temp_Out[8];
        end
        SUBTRACT: begin
            temp_Out = SrcA + (~SrcB + 1'b1);
            Out=temp_Out[7:0];
            Overflow = ~temp_Out[8];
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
        SLT: begin 
            Out = (SrcA + (~SrcB + 8'b1));
            temp_ovf = (SrcA[7] != SrcB[7]) && (Out[7] != SrcA[7]) ? 1'b1 : 1'b0;
            
            // Explicitly force Overflow to 0 for logical comparisons
            Overflow = 1'b0; 
            
            Out = {7'b0, (Out[7] ^ temp_ovf)}; 
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
    input nop,
    output reg RegWrite,
    output reg ALUSrc,
    output reg MemWrite,
    output reg MemRead,
    output reg [3:0] alu_control,
    output reg ResultSrc,
    output reg Trap_flag,
    output reg Eret_Flag
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
parameter TRAP          =5'b10010;
parameter ERET          =5'b10011;      
parameter JAL = 5'b10000;
parameter JR = 5'b10001;    

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
parameter ALU_LSR               = 4'b0011;
parameter ALU_ROR               = 4'b0100;
parameter ALU_ROL               = 4'b0110;

always@(*) begin
    RegWrite = 0;
    ALUSrc = 0;
    MemWrite = 0;
    MemRead = 0;
    ResultSrc = 0;
    alu_control = 4'b0000;
    Trap_flag=1'b0;
    Eret_Flag=1'b0;
if(nop)
 begin
    RegWrite = 0;
    ALUSrc = 0;
    MemWrite = 0;
    MemRead = 0;
    ResultSrc = 0;
    alu_control = 4'b0000;
    Trap_flag=1'b0;
    Eret_Flag=1'b0;
 end
 else begin
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
        TRAP:Trap_flag=1'b1;
        LOAD: begin
            MemRead = 1;
            RegWrite = 1;
            ALUSrc = 1;
            alu_control = ALU_ADD;
            ResultSrc = 1;
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
        end
        SLT: begin
            RegWrite    = 1;
            ALUSrc      = 0;
            alu_control = ALU_SLT;
        end
        BEQ:begin
        ALUSrc = 0;
        alu_control=ALU_SUBTRACT;
        end
        BNE:begin
        ALUSrc=0;
        alu_control=ALU_SUBTRACT;
        end
        LSR:begin
        RegWrite = 1;
        alu_control = ALU_LSR;
        end
        ADDI:begin
        RegWrite=1;
        ALUSrc=1;
        alu_control = ALU_ADD;
        end
        ROR: begin
        RegWrite = 1;
        ALUSrc = 0;
        alu_control = ALU_ROR;
        end
        ROL: begin
        RegWrite = 1;
        ALUSrc = 0;
        alu_control = ALU_ROL;
        end
        ERET: begin
        Eret_Flag=1;
        end
        JAL: begin
         RegWrite    = 1;
         ALUSrc      = 0;
         alu_control = 4'b0000;
         ResultSrc   = 0;
        end
        JR: begin
         RegWrite    = 0;
         ALUSrc      = 0;
         alu_control = 4'b0000;
         ResultSrc   = 0;
        end
        default: alu_control = 4'b0000;
    endcase
  end
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

module Register_file(clk, reset, RegWrite, Rs1, Rs2, Rd, WriteData, Read_data1, Read_data2);
    input clk, reset, RegWrite;
    input [4:0] Rs1, Rs2, Rd;
    input [7:0] WriteData;
    output [7:0] Read_data1, Read_data2;

    reg [7:0] Registers [31:0];
    integer k;

    // FORWARDING / BYPASS LOGIC:
    // If we are writing to the same register we are currently reading,
    // return the WriteData immediately instead of the old value in the array.
    assign Read_data1 = (RegWrite && (Rd != 5'b0) && (Rs1 == Rd)) ? WriteData : Registers[Rs1];
    assign Read_data2 = (RegWrite && (Rd != 5'b0) && (Rs2 == Rd)) ? WriteData : Registers[Rs2];

    always @(posedge clk)
    begin
        if(reset)
        begin
            for(k = 0; k < 32; k = k + 1)
                Registers[k] <= 8'b0;
        end
        else if(RegWrite && (Rd != 5'b0)) // Prevent overwriting R0
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


module HDU (
input id_ex_MemRead,
input [4:0] id_ex_rt, if_id_rs, if_id_rt,
output PCWrite, IF_ID_Write, nop
);

assign PCWrite = (id_ex_MemRead == 1 && (id_ex_rt == if_id_rs || id_ex_rt == if_id_rt) && (id_ex_rt != 5'b0))? 0:1;
assign IF_ID_Write = (id_ex_MemRead == 1 && (id_ex_rt == if_id_rs || id_ex_rt == if_id_rt) && (id_ex_rt != 5'b0))? 0:1;
assign nop = (id_ex_MemRead == 1 && (id_ex_rt == if_id_rs || id_ex_rt == if_id_rt) && (id_ex_rt != 5'b0))? 1:0;

endmodule

module Branch_Logic(
input [4:0] opcode_out,
input Zero,
input Overflow,
output reg [1:0]PCSrc
    );
    
   parameter JUMP       = 5'b00100;
   parameter BRANCH_OVF = 5'b01000;
   parameter BEQ        = 5'b01101; 
   parameter BNE        = 5'b01110;
   parameter JAL        = 5'b10000;
   parameter JR = 5'b10001;
   
   
   always @(*) begin
   PCSrc =2'b00;
   
   case(opcode_out)
   
    JUMP: begin
      PCSrc=2'b01;
      end
      
    BEQ: begin
     if(Zero)
      PCSrc = 2'b01;
      end 
      
    BNE: begin 
    if(~Zero)
    PCSrc = 2'b01;
    end
    
    BRANCH_OVF: begin
    if(Overflow)
    PCSrc = 2'b01;
    end 
    
    JAL: PCSrc = 2'b01;
    JR: PCSrc = 2'b01;
    
    endcase
  end
endmodule

module EX_MEM(
    input clk,
    input reset,
    input flush,
    
    // Data Inputs
    input [7:0] ALU_result_in,
    input [7:0] Read_data2_in,
    
    // Register Address Inputs
    input [4:0] rd_in,
    input [4:0] rt_in,       // Carries the source register ID for stores
    
    // Control Signal Inputs
    input MemRead_in,
    input MemWrite_in,
    input RegWrite_in,
    input ResultSrc_in,
    
    // Data Outputs
    output reg [7:0] ALU_result_out,
    output reg [7:0] Read_data2_out,
    
    // Register Address Outputs
    output reg [4:0] rd_out,
    output reg [4:0] rt_out, // Outputs the source register ID into the MEM stage
    
    // Control Signal Outputs
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg RegWrite_out,
    output reg ResultSrc_out
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            ALU_result_out <= 8'b0;
            Read_data2_out <= 8'b0;
            rd_out         <= 5'b0;
            rt_out         <= 5'b0; // Reset the rt register
            MemRead_out    <= 1'b0;
            MemWrite_out   <= 1'b0;
            RegWrite_out   <= 1'b0;
            ResultSrc_out  <= 1'b0;
        end else begin
            ALU_result_out <= ALU_result_in;
            Read_data2_out <= Read_data2_in;
            rd_out         <= rd_in;
            rt_out         <= rt_in; // Pass rt to the next stage
            MemRead_out    <= MemRead_in;
            MemWrite_out   <= MemWrite_in;
            RegWrite_out   <= RegWrite_in;
            ResultSrc_out  <= ResultSrc_in;
        end
    end

endmodule

module Forwarding_Unit(
input [4:0] rs_idex,
input [4:0] rt_idex,
input [4:0] rd_exmem,
input RegWrite_exmem,
input [4:0]rd_memwb,
input RegWrite_memwb,
//For mem-mem forwarding
input [4:0] rt_exmem,
input MemWrite_exmem,

output reg[1:0] forward_A,
output reg[1:0] forward_B,
output reg forward_Mem
    );
always @(*) begin
//Default values assignment
forward_A=2'b0;
forward_B=2'b0;
forward_Mem=1'b0;
//Forward_A for ex-ex and mem-ex
if (RegWrite_exmem && (rd_exmem!=5'b0) && (rs_idex==rd_exmem))begin
forward_A=2'b10;
end
//Priority ex-ex>mem-ex
else if(RegWrite_memwb && (rd_memwb!=5'b0) && (rs_idex==rd_memwb))begin
forward_A=2'b01;
end
//Forward_B for ex-ex and mem-ex(change rs to rt)
if (RegWrite_exmem && (rd_exmem!=5'b0) && (rt_idex==rd_exmem))begin
forward_B=2'b10;
end
else if(RegWrite_memwb && (rd_memwb!=5'b0) && (rt_idex==rd_memwb))begin
forward_B=2'b01;
end
//mem-mem
if (MemWrite_exmem && RegWrite_memwb && (rd_memwb!=0) && (rt_exmem ==rd_memwb)) begin
forward_Mem=1'b1;
end
end
endmodule

module MUX_3_1 (
    input [7:0] Src_in,  // Default value (from ID/EX)
    input [7:0] write_data,  // Forwarded from MEM/WB (writedata)
    input [7:0] alu_result,  // Forwarded from EX/MEM (alu_result)
    input [1:0] forward,   // 2-bit select line from Forwarding Unit
    output [7:0] Src_out
);

    assign Src_out = (forward == 2'b01) ? write_data :
                 (forward == 2'b10) ? alu_result :
                 Src_in;

endmodule

module ID_EX(
input clk,
input reset,
input stall,
input flush,
input Illegal_Instruction_in,
input [7:0] pc_in,
input Trap_in,
input Eret_in,

input [4:0] rs_in,
input [4:0] rt_in,
input [4:0] rd_in,
input [4:0] opcode_in,
input [7:0] immediate_in,
input [7:0] Read_data1_in,
input [7:0] Read_data2_in,

input MemRead_in,ResultSrc_in,ALUSrc_in,MemWrite_in,RegWrite_in,
input [3:0] alu_control_in,
 
output reg [7:0] pc_out,

output reg [4:0] rs_out,
output reg [4:0] rt_out,
output reg [4:0] rd_out,
output reg [4:0] opcode_out,
output reg [7:0] immediate_out,
output reg [7:0] Read_data1_out,
output reg [7:0] Read_data2_out,

output reg MemRead_out,ResultSrc_out,ALUSrc_out,MemWrite_out,RegWrite_out,
output reg [3:0] alu_control_out,
output reg Illegal_Instruction_out,
output reg Trap_out,
output reg Eret_out
 );
 
 always@(posedge clk or posedge reset) begin
   if (reset==1) begin
   pc_out<= 8'b0;
   rs_out<= 5'b0;
   rt_out<= 5'b0;
   rd_out<= 5'b0;
   opcode_out<=5'b0;
   immediate_out<=8'b0;
   Read_data1_out<=8'b0;
   Read_data2_out<=8'b0;
   MemRead_out<=1'b0;
   ResultSrc_out<=1'b0;
   ALUSrc_out<=1'b0;
   MemWrite_out<=1'b0;
   RegWrite_out<=1'b0;
   alu_control_out<=4'b0;
   Illegal_Instruction_out<=1'b0;
   Trap_out<=1'b0;
   Eret_out<=1'b0;
   
   end
   
   else if (flush==1) begin
      pc_out<= 8'b0;
   rs_out<= 5'b0;
   rt_out<= 5'b0;
   rd_out<= 5'b0;
   opcode_out<=5'b0;
   immediate_out<=8'b0;
   Read_data1_out<=8'b0;
   Read_data2_out<=8'b0;
   MemRead_out<=1'b0;
   ResultSrc_out<=1'b0;
   ALUSrc_out<=1'b0;
   MemWrite_out<=1'b0;
   RegWrite_out<=1'b0;
   alu_control_out<=4'b0;
   Illegal_Instruction_out<=1'b0;
   Trap_out<=1'b0;
   Eret_out<=1'b0;

   end
   
   else if(stall==1) begin
   end
   
   else begin
   pc_out<= pc_in;
   rs_out<= rs_in;
   rt_out<= rt_in;
   rd_out<= rd_in;
   opcode_out<=opcode_in;
   immediate_out<=immediate_in;
   Read_data1_out<=Read_data1_in;
   Read_data2_out<=Read_data2_in;
   MemRead_out<=MemRead_in;
   ResultSrc_out<=ResultSrc_in;
   ALUSrc_out<=ALUSrc_in;
   MemWrite_out<=MemWrite_in;
   RegWrite_out<=RegWrite_in;
   alu_control_out<=alu_control_in;
   Illegal_Instruction_out<=Illegal_Instruction_in;
   Trap_out<=Trap_in;
   Eret_out<=Eret_in;

   end
 end
   

endmodule   
   
module IF_ID(
input clk,
input reset,
input IF_IDWrite,
input flush,
input [7:0] pc_in,
input [23:0] instruction_in,
output reg [7:0] pc_out,
output reg [23:0] instruction_out
  );
  
 always@(posedge clk or posedge reset) begin
 if(reset==1) begin
 pc_out <= 8'b0;
 instruction_out<=24'b0;
 end
 
   else if(IF_IDWrite==0) begin
 pc_out<=pc_out;
 instruction_out<=instruction_out;
 end
 
 else if(flush==1) begin
 pc_out <= 8'b0;
 instruction_out<=24'b0;
 end
 
 else begin
 pc_out<=pc_in;
 instruction_out<=instruction_in;
 end 
end
 
  
endmodule

module MEM_WB(
    input clk,reset,flush,
    input [7:0] Read_data_in,
    input [7:0] ALU_result_in,
    input [4:0] rd_in,
    input RegWrite_in,
    input ResultSrc_in,

    output reg [7:0] Read_data_out,
    output reg [7:0] ALU_result_out,
    output reg [4:0] rd_out,
    output reg RegWrite_out,
    output reg ResultSrc_out
);

always @(posedge clk or posedge reset) begin
    if(reset==1) begin
        Read_data_out <= 8'b0;
        ALU_result_out <= 8'b0;
        rd_out <= 5'b0;

        RegWrite_out <= 1'b0;
        ResultSrc_out <= 1'b0;
    end
    
    else if(flush==1) begin
        Read_data_out <= 8'b0;
        ALU_result_out <= 8'b0;
        rd_out <= 5'b0;

        RegWrite_out <= 1'b0;
        ResultSrc_out <= 1'b0;
    end

    else begin
        Read_data_out <= Read_data_in;
        ALU_result_out <= ALU_result_in;
        rd_out <= rd_in;

        RegWrite_out <= RegWrite_in;
        ResultSrc_out <= ResultSrc_in;
    end
end

endmodule

module Cause_register(
input clk,reset,
input Overflow,
input Illegal_Instruction,
input Trap,
output reg[1:0] Cause
    );
always @(posedge clk or posedge reset) begin
if(reset==1) begin
  Cause<=2'b0;
   end
else if(Overflow)Cause<=2'b01;
else if(Illegal_Instruction)Cause<=2'b10;
else if(Trap)Cause<=2'b11;
end
endmodule

module MUX_4_1(
input  [7:0] in0,
input  [7:0] in1,
input  [7:0] in2,
input  [7:0] in3,
input  [1:0] sel,
output [7:0] out);

assign out = (sel == 2'b00) ? in0:
             (sel == 2'b01) ? in1:
             (sel == 2'b10) ? in2:
             (sel == 2'b11) ? in3:

                              8'b0;
 endmodule       


`timescale 1ns / 1ps

module ExceptionProgramCounter_Register(
input clk,reset,
input epc_write,
input [7:0] current_pc,

output reg [7:0] epc
 );
 
always@(posedge clk or posedge reset) begin
 if(reset==1)begin
   epc <= 8'b0;
   end      
  else if (epc_write==1) begin
   epc <= current_pc;
   end
 end

endmodule

`timescale 1ns / 1ps

module Exception_Control_Unit(
input overflow,illegal_instruction,trap,

output reg exception,
output reg flush,
output reg epc_write,
output reg[7:0] exception_pc
   );
   
 parameter Exception_Vector = 8'd100;

 
 always@(*)
 begin
  exception    =0;
  flush        =0;
  epc_write    =0;
  exception_pc = Exception_Vector;
   if(overflow==1) begin
    exception   =1;
    flush       =1;
    epc_write   =1;

    exception_pc   = Exception_Vector;
   end 
   
   else if(illegal_instruction==1) begin
    exception    =1;
    flush        =1;
    epc_write    =1;
    exception_pc   = Exception_Vector;   
   end    
   
   else if(trap==1) begin
    exception   =1;
    flush       =1;
    epc_write   =1;
    exception_pc  = Exception_Vector;   
   end         
  
  end


  
  
endmodule



module MCPModule_final(
input clk,reset);
wire stall;
wire flush;
wire branch_flush;
wire exception_flush;

//IF
wire [7:0] next_pc;
wire [7:0] pc;
wire [23:0] instruction_out;
wire [7:0] PC_Plus_1_wire;
//IF/ID outputs
wire [7:0] pc_ifid;
wire[23:0] instruction_ifid;
//ID
wire [4:0] opcode,Rs1,Rs2,Rd;
wire [3:0] func;
wire [7:0] immediate;

wire MemRead,MemWrite,ResultSrc,ALUSrc,RegWrite;
wire [3:0] alu_control;

wire[7:0] Read_data1,Read_data2;
//ID/EX
wire[7:0] pc_idex;
wire[4:0] rs_idex,rt_idex,rd_idex,opcode_idex;
wire [7:0] immediate_idex;
wire[7:0] Read_data1_idex,Read_data2_idex;


wire MemRead_idex,ResultSrc_idex,ALUSrc_idex,MemWrite_idex,RegWrite_idex;
wire [3:0] alu_control_idex;
//EX
wire[7:0] alu_result;
wire Zero,Overflow;
wire[7:0] alu_srcB;
wire [7:0] branch_target;
wire [1:0]branchPCSrc;
wire [1:0]PCSrc;
//EX/MEM
wire [7:0] ALU_result_exmem;
wire [7:0] Read_data2_exmem;
wire [4:0] rd_exmem;
wire [4:0] rt_exmem; // Needed for MEM-MEM forwarding
wire MemRead_exmem,MemWrite_exmem,RegWrite_exmem,ResultSrc_exmem;
//MEM
wire[7:0] read_data;
//MEM/WB
wire[7:0] read_data_memwb;
wire[7:0] ALU_result_memwb;
wire[4:0] rd_memwb;
wire RegWrite_memwb,ResultSrc_memwb;
//WB
wire[7:0] writedata;
wire [7:0] Src_A_forward,Src_B_forward;
wire [7:0] mem_write_data_fwd;

// Forwarding Select Lines (To be driven by Forwarding Unit later)
wire [1:0] forward_A, forward_B;
wire ForwardMem;

//HDU Control Signals
wire PCWrite,IF_ID_Write,nop;
wire Trap_id;
wire Trap_ex;
wire Illegal_Instruction_id;
wire Illegal_Instruction_ex;
wire [1:0] Cause_wire;
wire  exception;
wire epc_write;
wire [7:0] exception_pc;
wire [7:0] epc_wire;
wire Eret_id;
wire Eret_ex;

  
assign stall =1'b0;
assign PCSrc= exception ? 2'b10: 
              Eret_ex   ? 2'b11: branchPCSrc;
assign branch_flush = (branchPCSrc == 2'b01);
assign flush = branch_flush | exception_flush | Eret_ex;
//IF
PC counter( .clk(clk),.reset(reset),.next_pc((opcode_idex == 5'b10001)?Src_A_forward : next_pc), .PCWrite(PCWrite), .pc(pc));
PC_Adder pc_a( .PC(pc), .PC_Plus1(PC_Plus_1_wire));
Instruction_Memory im( .reset(reset), .PC_address(pc), .instruction_out(instruction_out));
//IF/ID
IF_ID if_id( .clk(clk), .reset(reset), .IF_IDWrite(IF_ID_Write), .flush(flush), .pc_in(pc), .pc_out(pc_ifid), .instruction_in(instruction_out), .instruction_out(instruction_ifid) );
//ID
instruction_decoder id (.instruction(instruction_ifid), .opcode(opcode), .func(func), .rs(Rs1), .rt(Rs2), .rd(Rd), .immediate(immediate),.Illegal_Instruction(Illegal_Instruction_id));
Control_Unit cu (.opcode(opcode), .func(func),  .RegWrite(RegWrite), .ALUSrc(ALUSrc), .MemWrite(MemWrite), .MemRead(MemRead), .alu_control(alu_control), .ResultSrc(ResultSrc), .nop(nop),.Trap_flag(Trap_id), .Eret_Flag(Eret_id));
Register_file rg (.clk(clk), .reset(reset), .RegWrite(RegWrite_memwb), .Rs1(Rs1), .Rs2(Rs2), .Rd(rd_memwb), .WriteData(writedata), .Read_data1(Read_data1), .Read_data2(Read_data2));
//ID/EX                   
ID_EX id_ex( .clk(clk), .reset(reset), .stall(stall), .flush(flush),.pc_in(pc_ifid), .rs_in(Rs1),.rt_in(Rs2),.rd_in(Rd), .opcode_in(nop ? 5'b0 : opcode), .immediate_in(immediate), .Read_data1_in(Read_data1), .Read_data2_in(Read_data2),
.MemRead_in(MemRead),.ResultSrc_in(ResultSrc),.ALUSrc_in(ALUSrc),.MemWrite_in(MemWrite),.RegWrite_in(RegWrite), .alu_control_in(alu_control),.Trap_in(Trap_id),.Illegal_Instruction_in(Illegal_Instruction_id),
.pc_out(pc_idex),.rs_out(rs_idex),.rt_out(rt_idex),.rd_out(rd_idex),.opcode_out(opcode_idex),.immediate_out(immediate_idex),.Read_data1_out(Read_data1_idex),.Read_data2_out(Read_data2_idex),
.MemRead_out(MemRead_idex),.ResultSrc_out(ResultSrc_idex),.ALUSrc_out(ALUSrc_idex),.MemWrite_out(MemWrite_idex),.RegWrite_out(RegWrite_idex),.alu_control_out(alu_control_idex),.Trap_out(Trap_ex),.Illegal_Instruction_out(Illegal_Instruction_ex), .Eret_in(Eret_id), .Eret_out(Eret_ex));

//EX
alu ALU (.SrcA(Src_A_forward), .SrcB(alu_srcB), .alu_control(alu_control_idex), .Out(alu_result), .Zero(Zero), .Overflow(Overflow));
MUX_2_1 ALUSrc_mux (.inB(Src_B_forward), .inA(immediate_idex), .sel(ALUSrc_idex), .out(alu_srcB));
Branch_Adder ba(.PC(pc_idex),.Immediate(immediate_idex),.BranchTarget(branch_target));
Branch_Logic branch_logic(.opcode_out(opcode_idex),.Zero(Zero),.Overflow(Overflow),.PCSrc(branchPCSrc));

//EX/MEM (Note: Read_data2_in takes Src_B_forward so STORE sees forwarded data. rt_in/rt_out added)
EX_MEM ex_mem( .clk(clk), .reset(reset), .flush(1'b0), .ALU_result_in((opcode_idex == 5'b10000)? (pc_idex+8'b1):alu_result), .Read_data2_in(Src_B_forward), .rd_in(rd_idex), .MemRead_in(MemRead_idex), .MemWrite_in(MemWrite_idex),.RegWrite_in(RegWrite_idex),.ResultSrc_in(ResultSrc_idex), .rt_in(rt_idex),
.ALU_result_out(ALU_result_exmem), .Read_data2_out(Read_data2_exmem), .rd_out(rd_exmem), .MemRead_out(MemRead_exmem),.MemWrite_out(MemWrite_exmem),.RegWrite_out(RegWrite_exmem),.ResultSrc_out(ResultSrc_exmem), .rt_out(rt_exmem));
//MEM
Data_Memory dm (.clk(clk), .reset(reset), .MemWrite(MemWrite_exmem), .MemRead(MemRead_exmem), .address(ALU_result_exmem), .write_data(mem_write_data_fwd), .read_data(read_data));
//MEM/WB
MEM_WB mem_wb( .clk(clk), .reset(reset), .flush(1'b0), .Read_data_in(read_data),.ALU_result_in(ALU_result_exmem), .rd_in(rd_exmem), .RegWrite_in(RegWrite_exmem), .ResultSrc_in(ResultSrc_exmem),
.Read_data_out(read_data_memwb), .ALU_result_out(ALU_result_memwb), .rd_out(rd_memwb), .RegWrite_out(RegWrite_memwb), .ResultSrc_out(ResultSrc_memwb));
//WB
MUX_2_1 wb_mux(.inA(read_data_memwb),.inB(ALU_result_memwb),.sel(ResultSrc_memwb),.out(writedata));

//Forwarding_Mux 
MUX_3_1 Forward_A(.Src_in(Read_data1_idex),.write_data(writedata),.alu_result(ALU_result_exmem),.forward(forward_A),.Src_out(Src_A_forward));
MUX_3_1 Forward_B(.Src_in(Read_data2_idex),.write_data(writedata),.alu_result(ALU_result_exmem),.forward(forward_B),.Src_out(Src_B_forward));
MUX_2_1 mem_forward_mux (
  .inB(Read_data2_exmem), // 0: Default value (from EX/MEM)
    .inA(writedata),        // 1: Forwarded from MEM/WB
    .sel(ForwardMem),       // 1-bit select line from Forwarding Unit
    .out(mem_write_data_fwd)
);
 Forwarding_Unit f_w(.rs_idex(rs_idex),.rt_idex(rt_idex),.rd_exmem(rd_exmem),.RegWrite_exmem(RegWrite_exmem),.rd_memwb(rd_memwb),.RegWrite_memwb(RegWrite_memwb),.rt_exmem(rt_exmem),.MemWrite_exmem(MemWrite_exmem),.forward_A(forward_A),.forward_B(forward_B),.forward_Mem(ForwardMem));
HDU hdu (.id_ex_MemRead(MemRead_idex), .id_ex_rt(rt_idex) , .if_id_rs(Rs1), .if_id_rt(Rs2), .PCWrite(PCWrite) , .IF_ID_Write(IF_ID_Write), .nop(nop));
Cause_register cr(.clk(clk), .reset(reset), .Overflow(Overflow),.Trap(Trap_ex),.Illegal_Instruction(Illegal_Instruction_ex),.Cause(Cause_wire));
ExceptionProgramCounter_Register epc( .clk(clk), .reset(reset),.epc_write(epc_write), .current_pc(pc_idex), .epc(epc_wire));
Exception_Control_Unit ecu(  .overflow(Overflow), .illegal_instruction(Illegal_Instruction_ex), .trap(Trap_ex), .exception(exception), .flush(exception_flush), .epc_write(epc_write), .exception_pc(exception_pc));
MUX_4_1 pc_mux( .in0(PC_Plus_1_wire), .in1(branch_target), .in2(exception_pc), .in3(epc_wire), .sel(PCSrc), .out(next_pc));

endmodule
