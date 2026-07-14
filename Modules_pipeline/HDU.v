module HDU (
input id_ex_MemRead,
input [4:0] id_ex_rt, if_id_rs, if_id_rt,
output PCWrite, IF_ID_Write, nop
);

assign PCWrite = (id_ex_MemRead == 1 && (id_ex_rt == if_id_rs || id_ex_rt == if_id_rt) && (id_ex_rt != 5'b0))? 0:1;
assign IF_ID_Write = (id_ex_MemRead == 1 && (id_ex_rt == if_id_rs || id_ex_rt == if_id_rt) && (id_ex_rt != 5'b0))? 0:1;
assign nop = (id_ex_MemRead == 1 && (id_ex_rt == if_id_rs || id_ex_rt == if_id_rt) && (id_ex_rt != 5'b0))? 1:0;

endmodule
