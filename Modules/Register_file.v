module Register_file(clk,reset,RegWrite,Rs1,Rs2,Rd,WriteData,Read_data1,Read_data2);
    input clk,reset,RegWrite;
    
    input [4:0] Rs1;
    input [4:0] Rs2;
    input [4:0] Rd;

    input [7:0] WriteData;

    output [7:0] Read_data1;
    output [7:0] Read_data2;


reg [7:0] Registers [31:0];
integer k;


assign Read_data1 = Registers[Rs1];
assign Read_data2 = Registers[Rs2];


always @(posedge clk)
begin
    if(reset)
    begin
        for(k = 0; k < 32; k = k + 1)
            Registers[k] <= 8'b0;
    end
    else if(RegWrite)
    begin
        Registers[Rd] <= WriteData;
    end
end
endmodule
