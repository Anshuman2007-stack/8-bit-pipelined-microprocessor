module MCPModule(
input clk, rst1,rst2,rst3,
output [7:0] result
);
  
wire [7:0] next_pc;
wire [7:0] PC_address;//PC Wire
wire [23:0] instruction_out; //INST MEM
wire RegWrite_wire;
wire [4:0] Rs1,Rs2,Rd;
wire [7:0] WriteData;
wire [7:0] Read_data1,Read_data2;//REGISTERFILE
wire [4:0] opcode_wire;
wire [3:0] function_code_wire;
wire Zero_wire ,Overflow_wire;
wire PCSrc_wire;               //left are PCSrc, ALUSrc, ResultSrc because they drive the MUXes
wire [7:0] SrcB;
wire [3:0] alu_control_wire;                   
wire MemWrite_wire, MemRead_wire;
wire [7:0] read_data;    // DATA MEMORY                         
wire ResultSrc_wire;
wire [7:0] Out_wire;         
wire ALUSrc_wire;
wire [7:0] immediate_wire;   
wire [7:0] PC_Plus_1_wire,BranchTarget_wire;

assign result=Out_wire;

PC counter (.clk(clk), .reset(rst1), .next_pc(next_pc), .pc(PC_address));
Instruction_Memory im (.reset(rst2), .PC_address(PC_address), .instruction_out(instruction_out));
instruction_decoder id (.clk(clk), .instruction(instruction_out), .opcode(opcode_wire), .func(function_code_wire), .rs(Rs1), .rt(Rs2), .rd(Rd), .immediate(immediate_wire));
Register_file rg (.clk(clk), .reset(rst2), .RegWrite(RegWrite_wire), .Rs1(Rs1), .Rs2(Rs2), .Rd(Rd), .WriteData(WriteData), .Read_data1(Read_data1), .Read_data2(Read_data2));
Control_Unit cu (.opcode(opcode_wire), .func(function_code_wire), .Zero(Zero_wire), .Overflow(Overflow_wire), .RegWrite(RegWrite_wire), .ALUSrc(ALUSrc_wire), .MemWrite(MemWrite_wire), .MemRead(MemRead_wire), .alu_control(alu_control_wire), .ResultSrc(ResultSrc_wire), .PCSrc(PCSrc_wire) );
alu ALU (.SrcA(Read_data1), .SrcB(SrcB), .alu_control(alu_control_wire), .Out(Out_wire), .Zero(Zero_wire), .Overflow(Overflow_wire));
Data_Memory dm (.clk(clk), .reset(rst3), .MemWrite(MemWrite_wire), .MemRead(MemRead_wire), .address(Out_wire), .write_data(Read_data2), .read_data(read_data));
PC_Adder pc_a(.PC(PC_address),.PC_Plus1(PC_Plus_1_wire));
Branch_Adder ba(.PC(PC_address),.Immediate(immediate_wire),.BranchTarget(BranchTarget_wire));
MUX_2_1 MemtoReg_mux (.inA(read_data), .inB(Out_wire), .sel(ResultSrc_wire), .out(WriteData));
MUX_2_1 ALUSrc_mux (.inB(Read_data2), .inA(immediate_wire), .sel(ALUSrc_wire), .out(SrcB));
MUX_2_1 PCSrc_Mux (.inA(BranchTarget_wire), .inB(PC_Plus_1_wire), .sel(PCSrc_wire), .out(next_pc));


endmodule
