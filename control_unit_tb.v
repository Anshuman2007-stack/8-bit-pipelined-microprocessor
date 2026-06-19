`timescale 10ns / 1ns

module Ctrl_Unit_Testbench;
reg [4:0] opcode;
reg [3:0] func;
reg Zero, Overflow;

wire RegWrite, ALUSrc, MemWrite, MemRead, ResultSrc, PCSrc;
wire [3:0] alu_control;

Control_Unit DUT (.opcode(opcode), .func(func), .Zero(Zero), .Overflow(Overflow), .RegWrite(RegWrite), .ALUSrc(ALUSrc), .MemWrite(MemWrite), .MemRead(MemRead), .ResultSrc(ResultSrc), .PCSrc(PCSrc), .alu_control(alu_control));

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

initial
begin
    opcode = R_TYPE;      func = F_ADD; Zero = 0; Overflow = 0;
    #5  func = F_SUB;
    #5  func = F_MUL;
    #5  func = F_DIV;
    #5  func = F_AND;
    #5  func = F_OR;
    #5  func = F_NOT;
    #5  func = F_XOR;
    #5  func = F_BEQ;
    #5  func = F_BNE;

    // Non-R-type instructions
    #5  opcode = LOADI;
    #5  opcode = LOAD;
    #5  opcode = STORE;
    #5  opcode = JUMP;
    #5  opcode = LEFT_SHIFT;
    #5  opcode = RIGHT_SHIFT;
    #5  opcode = SLT;

    // Branch overflow
    #5  opcode = BRANCH_OVF; Overflow = 0;
    #5  opcode = BRANCH_OVF; Overflow = 1;

    // BEQ tests
    #5  opcode = BEQ; Zero = 0;
    #5  opcode = BEQ; Zero = 1;

    // BNE tests
    #5  opcode = BNE; Zero = 0;
    #5  opcode = BNE; Zero = 1;
    #5  $finish;
end

initial
begin
$dumpfile("ctrl_unit.vcd");
$dumpvars(0,Ctrl_Unit_Testbench);
$monitor(
    "time=%0d, opcode=%b, func=%b, Zero=%b, Overflow=%b, RegWrite=%b, ALUSrc=%b, MemWrite=%b, MemRead=%b, alu_control=%b, ResultSrc=%b, PCSrc=%b",
    $time, opcode, func, Zero, Overflow,
    RegWrite, ALUSrc, MemWrite, MemRead,
    alu_control, ResultSrc, PCSrc
);
end
endmodule
