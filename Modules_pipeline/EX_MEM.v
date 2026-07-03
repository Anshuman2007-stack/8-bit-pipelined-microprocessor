`timescale 1ns / 1ps
module EX_MEM(
input clk,reset,flush,
input [7:0] ALU_result_in,
input [7:0] Read_data2_in,
input [4:0] rd_in,
input MemRead_in,MemWrite_in,RegWrite_in,ResultSrc_in,

output reg [7:0] ALU_result_out,
output reg [7:0] Read_data2_out,
output reg [4:0] rd_out,
output reg MemRead_out,MemWrite_out,RegWrite_out,ResultSrc_out
);

always@(posedge clk or posedge reset) begin
   if(reset==1) begin
   ALU_result_out<=8'b0;
   Read_data2_out<=8'b0;
   rd_out<=5'b0;
   MemRead_out<=1'b0;
   MemWrite_out<=1'b0;
   RegWrite_out<=1'b0;
   ResultSrc_out<=1'b0;
   end
   
   else if(flush==1) begin
   ALU_result_out<=8'b0;
   Read_data2_out<=8'b0;
   rd_out<=5'b0;
   MemRead_out<=1'b0;
   MemWrite_out<=1'b0;
   RegWrite_out<=1'b0;
   ResultSrc_out<=1'b0;
   end
   
   else begin
      ALU_result_out<=ALU_result_in;
   Read_data2_out<=Read_data2_in;
   rd_out<=rd_in;
   MemRead_out<=MemRead_in;
   MemWrite_out<=MemWrite_in;
   RegWrite_out<=RegWrite_in;
   ResultSrc_out<=ResultSrc_in;
   end
end
    
endmodule
