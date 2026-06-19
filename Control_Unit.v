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
