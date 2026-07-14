module PC(
    input clk,
    input reset,
    input [7:0] next_pc,
    input PCWrite,
    output reg [7:0] pc
);

always @(posedge clk or posedge reset) begin

    if (reset)
        pc <=8'b0;

    else if(PCWrite)
        pc <= next_pc;

end
endmodule
