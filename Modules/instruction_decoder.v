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
        LEFT_SHIFT, RIGHT_SHIFT,LSR: begin
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
