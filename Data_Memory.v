module Data_Memory(clk, reset, MemWrite, MemRead, address, write_data, read_data);

    input clk, reset, MemWrite, MemRead;
    input [7:0] address, write_data;
    output [7:0] read_data;
    reg [7:0] dmemory[0:31];
    integer k;
    assign read_data = (MemRead) ? dmemory[address] : 8'b0;
     
    always @ (posedge clk)
    begin
        if(reset == 1'b1)
          for (k = 0; k<32; k = k+1)
            dmemory[k] <= 8'b0;
        else if(MemWrite) dmemory[address] <= write_data;
    end

endmodule
