module MUX_2_1(
input [7:0] inA,inB,
input sel,
output [7:0] out
);

assign out = sel? inA:inB;
endmodule
