module MEM_WB(
    input clk,reset,flush,
    input [7:0] Read_data_in,
    input [7:0] ALU_result_in,
    input [4:0] rd_in,
    input RegWrite_in,
    input ResultSrc_in,

    output reg [7:0] Read_data_out,
    output reg [7:0] ALU_result_out,
    output reg [4:0] rd_out,
    output reg RegWrite_out,
    output reg ResultSrc_out
);

always @(posedge clk or posedge reset) begin
    if(reset==1) begin
        Read_data_out <= 8'b0;
        ALU_result_out <= 8'b0;
        rd_out <= 5'b0;

        RegWrite_out <= 1'b0;
        ResultSrc_out <= 1'b0;
    end
    
    else if(flush==1) begin
        Read_data_out <= 8'b0;
        ALU_result_out <= 8'b0;
        rd_out <= 5'b0;

        RegWrite_out <= 1'b0;
        ResultSrc_out <= 1'b0;
    end

    else begin
        Read_data_out <= Read_data_in;
        ALU_result_out <= ALU_result_in;
        rd_out <= rd_in;

        RegWrite_out <= RegWrite_in;
        ResultSrc_out <= ResultSrc_in;
    end
end

endmodule
