module PC_Adder(
input  [7:0] PC,
output [7:0] PC_Plus1
);

assign PC_Plus1 = PC + 8'd1;

endmodule
