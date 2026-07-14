`timescale 1ns / 1ps
module MCPModule_final(
input clk,reset);
wire stall,flush;
//IF
wire [7:0] next_pc;
wire [7:0] pc;
wire [23:0] instruction_out;
wire [7:0] PC_Plus_1_wire;
//IF/ID outputs
wire [7:0] pc_ifid;
wire[23:0] instruction_ifid;
//ID
wire [4:0] opcode,Rs1,Rs2,Rd;
wire [3:0] func;
wire [7:0] immediate;

wire MemRead,MemWrite,ResultSrc,ALUSrc,RegWrite;
wire [3:0] alu_control;

wire[7:0] Read_data1,Read_data2;
//ID/EX
wire[7:0] pc_idex;
wire[4:0] rs_idex,rt_idex,rd_idex,opcode_idex;
wire [7:0] immediate_idex;
wire[7:0] Read_data1_idex,Read_data2_idex;

wire MemRead_idex,ResultSrc_idex,ALUSrc_idex,MemWrite_idex,RegWrite_idex;
wire [3:0] alu_control_idex;
//EX
wire[7:0] alu_result;
wire Zero,Overflow;
wire[7:0] alu_srcB;
wire [7:0] branch_target;
wire PCSrc;
//EX/MEM
wire [7:0] ALU_result_exmem;
wire [7:0] Read_data2_exmem;
wire [4:0] rd_exmem;
wire [4:0] rt_exmem; // Needed for MEM-MEM forwarding
wire MemRead_exmem,MemWrite_exmem,RegWrite_exmem,ResultSrc_exmem;
//MEM
wire[7:0] read_data;
//MEM/WB
wire[7:0] read_data_memwb;
wire[7:0] ALU_result_memwb;
wire[4:0] rd_memwb;
wire RegWrite_memwb,ResultSrc_memwb;
//WB
wire[7:0] writedata;
wire [7:0] Src_A_forward,Src_B_forward;
wire [7:0] mem_write_data_fwd;

// Forwarding Select Lines (To be driven by Forwarding Unit later)
wire [1:0] forward_A, forward_B;
wire ForwardMem;

//HDU Control Signals
wire PCWrite,IF_ID_Write,nop;

  
assign stall =1'b0;
assign flush =PCSrc;
//IF
PC counter( .clk(clk),.reset(reset),.next_pc(next_pc), .PCWrite(PCWrite), .pc(pc));
PC_Adder pc_a( .PC(pc), .PC_Plus1(PC_Plus_1_wire));
Instruction_Memory im( .reset(reset), .PC_Address(pc), .instruction_out(instruction_out));
MUX_2_1 pc_mux( .inA(branch_target), .inB(PC_Plus_1_wire), .sel(PCSrc), .out(next_pc) );
//IF/ID
IF_ID if_id( .clk(clk), .reset(reset), .IF_IDWrite(IF_ID_Write), .flush(flush), .pc_in(pc), .pc_out(pc_ifid), .instruction_in(instruction_out), .instruction_out(instruction_ifid) );
//ID
instruction_decoder id (.instruction(instruction_ifid), .opcode(opcode), .func(func), .rs(Rs1), .rt(Rs2), .rd(Rd), .immediate(immediate));
Control_Unit cu (.opcode(opcode), .func(func),  .RegWrite(RegWrite), .ALUSrc(ALUSrc), .MemWrite(MemWrite), .MemRead(MemRead), .alu_control(alu_control), .ResultSrc(ResultSrc), .nop(nop));
Register_file rg (.clk(clk), .reset(reset), .RegWrite(RegWrite_memwb), .Rs1(Rs1), .Rs2(Rs2), .Rd(rd_memwb), .WriteData(writedata), .Read_data1(Read_data1), .Read_data2(Read_data2));
//ID/EX                   
ID_EX id_ex( .clk(clk), .reset(reset), .stall(stall), .flush(flush),.pc_in(pc_ifid), .rs_in(Rs1),.rt_in(Rs2),.rd_in(Rd), .opcode_in(opcode), .immediate_in(immediate), .Read_data1_in(Read_data1), .Read_data2_in(Read_data2),
.MemRead_in(MemRead),.ResultSrc_in(ResultSrc),.ALUSrc_in(ALUSrc),.MemWrite_in(MemWrite),.RegWrite_in(RegWrite), .alu_control_in(alu_control),
.pc_out(pc_idex),.rs_out(rs_idex),.rt_out(rt_idex),.rd_out(rd_idex),.opcode_out(opcode_idex),.immediate_out(immediate_idex),.Read_data1_out(Read_data1_idex),.Read_data2_out(Read_data2_idex),
.MemRead_out(MemRead_idex),.ResultSrc_out(ResultSrc_idex),.ALUSrc_out(ALUSrc_idex),.MemWrite_out(MemWrite_idex),.RegWrite_out(RegWrite_idex),.alu_control_out(alu_control_idex));

//EX
alu ALU (.SrcA(Src_A_forward), .SrcB(alu_srcB), .alu_control(alu_control_idex), .Out(alu_result), .Zero(Zero), .Overflow(Overflow));
MUX_2_1 ALUSrc_mux (.inB(Src_B_forward), .inA(immediate_idex), .sel(ALUSrc_idex), .out(alu_srcB));
Branch_Adder ba(.PC(pc_idex),.Immediate(immediate_idex),.BranchTarget(branch_target));
Branch_Logic branch_logic(.opcode_out(opcode_idex),.Zero(Zero),.Overflow(Overflow),.PCSrc(PCSrc));

//EX/MEM (Note: Read_data2_in takes Src_B_forward so STORE sees forwarded data. rt_in/rt_out added)
EX_MEM ex_mem( .clk(clk), .reset(reset), .flush(1'b0), .ALU_result_in(alu_result), .Read_data2_in(Src_B_forward), .rd_in(rd_idex), .MemRead_in(MemRead_idex), .MemWrite_in(MemWrite_idex),.RegWrite_in(RegWrite_idex),.ResultSrc_in(ResultSrc_idex), .rt_in(rt_idex),
.ALU_result_out(ALU_result_exmem), .Read_data2_out(Read_data2_exmem), .rd_out(rd_exmem), .MemRead_out(MemRead_exmem),.MemWrite_out(MemWrite_exmem),.RegWrite_out(RegWrite_exmem),.ResultSrc_out(ResultSrc_exmem), .rt_out(rt_exmem));
//MEM
Data_Memory dm (.clk(clk), .reset(reset), .MemWrite(MemWrite_exmem), .MemRead(MemRead_exmem), .address(ALU_result_exmem), .write_data(mem_write_data_fwd), .read_data(read_data));
//MEM/WB
MEM_WB mem_wb( .clk(clk), .reset(reset), .flush(1'b0), .Read_data_in(read_data),.ALU_result_in(ALU_result_exmem), .rd_in(rd_exmem), .RegWrite_in(RegWrite_exmem), .ResultSrc_in(ResultSrc_exmem),
.Read_data_out(read_data_memwb), .ALU_result_out(ALU_result_memwb), .rd_out(rd_memwb), .RegWrite_out(RegWrite_memwb), .ResultSrc_out(ResultSrc_memwb));
//WB
MUX_2_1 wb_mux(.inA(read_data_memwb),.inB(ALU_result_memwb),.sel(ResultSrc_memwb),.out(writedata));

//Forwarding_Mux 
MUX_3_1 Forward_A(.Src_in(Read_data1_idex),.write_data(writedata),.alu_result(ALU_result_exmem),.forward(forward_A),.Src_out(Src_A_forward));
MUX_3_1 Forward_B(.Src_in(Read_data2_idex),.write_data(writedata),.alu_result(ALU_result_exmem),.forward(forward_B),.Src_out(Src_B_forward));
MUX_2_1 mem_forward_mux (
  .inB(Read_data2_exmem), // 0: Default value (from EX/MEM)
    .inA(writedata),        // 1: Forwarded from MEM/WB
    .sel(ForwardMem),       // 1-bit select line from Forwarding Unit
    .out(mem_write_data_fwd)
);
  Forwarding_Unit f_w(.rs_idex(rs_idex),.rt_idex(rt_idex),.rd_exmem(rd_exmem),.RegWrite_exmem(RegWrite_exmem),.rd_memwb(rd_memwb),.RegWrite_memwb(RegWrite_memwb),.rt_exmem(rt_exmem),.MemWrite_exmem(MemWrite_exmem),.forward_A(forward_A),.forward_B(forward_B),.forward_Mem(ForwardMem));
HDU hdu (.id_ex_MemRead(MemRead_idex), .id_ex_rt(rt_idex) , .if_id_rs(Rs1), .if_id_rt(Rs2), .PCWrite(PCWrite) , .IF_ID_Write(IF_ID_Write), .nop(nop));

endmodule
