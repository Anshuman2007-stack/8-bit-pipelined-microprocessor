`timescale 1ns / 1ps
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
