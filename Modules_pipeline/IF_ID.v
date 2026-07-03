`timescale 1ns / 1ps
module IF_ID(
input clk,
input reset,
input stall,
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
 
 else if(stall==1) begin
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
