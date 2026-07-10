`timescale 1ns / 1ps

module EX_MEM(
    input clk,
    input reset,
    input flush,
    
    // Data Inputs
    input [7:0] ALU_result_in,
    input [7:0] Read_data2_in,
    
    // Register Address Inputs
    input [4:0] rd_in,
    input [4:0] rt_in,       // Carries the source register ID for stores
    
    // Control Signal Inputs
    input MemRead_in,
    input MemWrite_in,
    input RegWrite_in,
    input ResultSrc_in,
    
    // Data Outputs
    output reg [7:0] ALU_result_out,
    output reg [7:0] Read_data2_out,
    
    // Register Address Outputs
    output reg [4:0] rd_out,
    output reg [4:0] rt_out, // Outputs the source register ID into the MEM stage
    
    // Control Signal Outputs
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg RegWrite_out,
    output reg ResultSrc_out
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            ALU_result_out <= 8'b0;
            Read_data2_out <= 8'b0;
            rd_out         <= 5'b0;
            rt_out         <= 5'b0; // Reset the rt register
            MemRead_out    <= 1'b0;
            MemWrite_out   <= 1'b0;
            RegWrite_out   <= 1'b0;
            ResultSrc_out  <= 1'b0;
        end else begin
            ALU_result_out <= ALU_result_in;
            Read_data2_out <= Read_data2_in;
            rd_out         <= rd_in;
            rt_out         <= rt_in; // Pass rt to the next stage
            MemRead_out    <= MemRead_in;
            MemWrite_out   <= MemWrite_in;
            RegWrite_out   <= RegWrite_in;
            ResultSrc_out  <= ResultSrc_in;
        end
    end

endmodule
