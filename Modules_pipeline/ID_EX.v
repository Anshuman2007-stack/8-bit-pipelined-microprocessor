`timescale 1ns / 1ps
module ID_EX(
input clk,
input reset,
input stall,
input flush,

input [7:0] pc_in,

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
output reg [3:0] alu_control_out
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
   end
 end
   

endmodule   
   

