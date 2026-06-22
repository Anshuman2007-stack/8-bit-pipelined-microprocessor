`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.06.2026 16:21:44
// Design Name: 
// Module Name: data_memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_data_memory();
reg clk,reset,MemWrite, MemRead;
reg [7:0] address, write_data;
wire [7:0] read_data;
Data_Memory dm_1(.clk(clk),.reset(reset),.MemWrite(MemWrite),.MemRead(MemRead),.address(address),.write_data(write_data),.read_data(read_data));
always #5 clk=~clk;//10ns clk with 5 seconds high and 5 seconds low
initial begin//Initialize
clk=0;
reset=1;
MemWrite=0;
MemRead=0;
address=8'b0;
write_data=8'b0;
$display("Time|Reset|MemWrite|MemRead|Address|Write_Data|Read_Data");
$display("---------------------------------------------------------");
//Printing the standard format
$monitor("%4t|%b|%b|%b|%h|%h|%h",$time,reset,MemWrite,MemRead,address,write_data,read_data);//updates the values
//reset=0
#20;
reset = 0;

#10;
MemWrite = 1;         // Enable writing
address = 8'h05;      // Select address 5
write_data = 8'hAA;   // Write 10101010

#10;
address = 8'h0A;      // Select address 10
write_data = 8'h55;   // Write 01010101

#10;
MemWrite = 0;         // Turn off writing to protect data


#10;
MemRead = 1;          // Enable reading
address = 8'h05;      // Check address 5 (Should read AA)

#10;
address = 8'h0A;      // Check address 10 (Should read 55)

#10;
address = 8'h00;      // Check an unwritten address (Should read 00)


#10;
MemRead = 0;          // Turn off reading
address = 8'h05;      // Address 5 holds AA, but since MemRead is 0, read_data should be 00

    
#10;
reset = 1;            // reset
#10;
reset = 0;
MemRead = 1;          // Turn reading back on
address = 8'h05;      // Address 5 should now be 00 because memory was wiped

    
#20;
$display("--- End of Simulation ---");
$finish;
end
endmodule
/*Time|Reset|MemWrite|MemRead|Address|Write_Data|Read_Data
---------------------------------------------------------
                   0|1|0|0|00|00|00
               20000|0|0|0|00|00|00
               30000|0|1|0|05|aa|00
               40000|0|1|0|0a|55|00
               50000|0|0|0|0a|55|00
               60000|0|0|1|05|55|aa
               70000|0|0|1|0a|55|55
               80000|0|0|1|00|55|00
               90000|0|0|0|05|55|00
              100000|1|0|0|05|55|00
              110000|0|0|1|05|55|00 */
