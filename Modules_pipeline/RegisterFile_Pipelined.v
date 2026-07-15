module Register_file(clk, reset, RegWrite, Rs1, Rs2, Rd, WriteData, Read_data1, Read_data2);
    input clk, reset, RegWrite;
    input [4:0] Rs1, Rs2, Rd;
    input [7:0] WriteData;
    output [7:0] Read_data1, Read_data2;

    reg [7:0] Registers [31:0];
    integer k;

    // FORWARDING / BYPASS LOGIC:
    // If we are writing to the same register we are currently reading,
    // return the WriteData immediately instead of the old value in the array.
    assign Read_data1 = (RegWrite && (Rd != 5'b0) && (Rs1 == Rd)) ? WriteData : Registers[Rs1];
    assign Read_data2 = (RegWrite && (Rd != 5'b0) && (Rs2 == Rd)) ? WriteData : Registers[Rs2];

    always @(posedge clk)
    begin
        if(reset)
        begin
            for(k = 0; k < 32; k = k + 1)
                Registers[k] <= 8'b0;
        end
        else if(RegWrite && (Rd != 5'b0)) // Prevent overwriting R0
        begin
            Registers[Rd] <= WriteData;
        end
    end
endmodule
module MUX_2_1(
input [7:0] inA,inB,
input sel,
output [7:0] out
);

assign out = sel? inA:inB;
endmodule
