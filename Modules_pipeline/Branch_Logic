`timescale 1ns / 1ps
module Branch_Logic(
input [4:0] opcode_out,
input Zero,
input Overflow,
output reg PCSrc
    );
    
   parameter JUMP       = 5'b00100;
   parameter BRANCH_OVF = 5'b01000;
   parameter BEQ        = 5'b01101; 
   parameter BNE        = 5'b01110;
   
   always @(*) begin
   PCSrc =1'b0;
   
   case(opcode_out)
   
    JUMP: begin
      PCSrc=1'b1;
      end
      
    BEQ: begin
      PCSrc = Zero;
      end 
      
    BNE: begin 
    PCSrc = ~Zero;
    end
    
    BRANCH_OVF: begin
    PCSrc = Overflow;
    end 
    
    endcase
  end
endmodule
