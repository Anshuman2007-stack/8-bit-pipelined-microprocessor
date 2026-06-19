`timescale 10ns/1ns

module instruction_decoder_tb;

reg clk;
reg [23:0] instruction;

wire [4:0] opcode;
wire [3:0] func;
wire [4:0] rs;
wire [4:0] rt;
wire [4:0] rd;
wire [7:0] immediate;

instruction_decoder DUT (
    .clk(clk),
    .instruction(instruction),
    .opcode(opcode),
    .func(func),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .immediate(immediate)
);

parameter R_TYPE      = 5'b01100;
parameter LOADI       = 5'b00001;
parameter LOAD        = 5'b00010;
parameter STORE       = 5'b00011;
parameter JUMP        = 5'b00100;
parameter LEFT_SHIFT  = 5'b00110;
parameter RIGHT_SHIFT = 5'b00111;
parameter BRANCH_OVF  = 5'b01000;
parameter SLT         = 5'b01001;
parameter BEQ         = 5'b01101;
parameter BNE         = 5'b01110;

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

initial begin
    // R-Type ADD
    #1 instruction = {R_TYPE,5'd1,5'd2,5'd3,F_ADD};

    // R-Type SUB
    #5 instruction = {R_TYPE,5'd4,5'd5,5'd6,F_SUB};

    // R-Type MUL
    #5 instruction = {R_TYPE,5'd7,5'd8,5'd9,F_MUL};

    // R-Type DIV
    #5 instruction = {R_TYPE,5'd10,5'd11,5'd12,F_DIV};

    // LOADI
    #5 instruction = {LOADI,5'd1,5'd2,6'b0,8'hAA};

    // LOAD
    #5 instruction = {LOAD,5'd3,5'd4,6'b0,8'h55};

    // STORE
    #5 instruction = {STORE,5'd5,5'd6,6'b0,8'hF0};

    // JUMP
    #5 instruction = {JUMP,11'b0,8'h20};

    // LEFT SHIFT
    #5 instruction = {LEFT_SHIFT,5'd1,5'd2,5'd3,4'b0000};

    // RIGHT SHIFT
    #5 instruction = {RIGHT_SHIFT,5'd4,5'd5,5'd6,4'b0000};

    // BRANCH_OVF
    #5 instruction = {BRANCH_OVF,5'd7,5'd8,6'b0,8'h10};

    // SLT
    #5 instruction = {SLT,5'd9,5'd10,5'd11,4'b0000};

    // BEQ
    #5 instruction = {BEQ,5'd12,5'd13,6'b0,8'h08};

    // BNE
    #5 instruction = {BNE,5'd14,5'd15,6'b0,8'h04};

    #5 $finish;
end

initial begin
    $dumpfile("instruction_decoder.vcd");
    $dumpvars(0, instruction_decoder_tb);

    $monitor(
        "time=%0d instruction=%b opcode=%b func=%b rs=%d rt=%d rd=%d immediate=%h",
        $time,
        instruction,
        opcode,
        func,
        rs,
        rt,
        rd,
        immediate
    );
end

endmodule
