module Branch_Adder(
input  [7:0] PC,
input  [7:0] Immediate,
output [7:0] BranchTarget
);

assign BranchTarget = PC + Immediate;

endmodule
