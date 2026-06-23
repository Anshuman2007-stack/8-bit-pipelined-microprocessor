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
        
        default: Out = 8'b0;
    endcase

    Zero = (Out == 0) ? 1'b1 : 1'b0;
end
endmodule

