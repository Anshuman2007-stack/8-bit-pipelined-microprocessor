`timescale 1ns / 1ps

/*
 * Testbench: Single-Cycle Processor 
 *Basically, we load up 3 unsorted numbers (5, 8, 2) into the data 
 * memory right at the start. Then, we feed the instruction memory with 
 * the machine code. 
 *
 * The C code logic we're mimicking is a standard double-loop array sort:
 * * int arr[3] = {5, 8, 2};
 * int n = 3;
 * for(int i=0; i<n; i++) {
 * for(int j=i; j<n; j++) {
 * if(arr[i] > arr[j]) {
 * // Swap them
 * int temp = arr[j];
 * arr[j] = arr[i];
 * arr[i] = temp;
 * }
 * }
 * }
 * * And here is the rough assembly breakdown of what those 24-bit hex codes 
 * are actually doing under the hood:
 * // --- Initialization ---
 * LI R3, 3          ; R3 = n = 3 (Array size)
 * LI R1, 0          ; R1 = i = 0 (Outer loop counter starts at 0)
 * * OUTER_LOOP: 
 * CMP R1, R3        ; Are we done with the outer loop? (i vs n)
 * BGE EXIT          ; If i >= n, bail out.
 * MOV R2, R1        ; R2 = j = i (Inner loop counter starts at i)
 * * INNER_LOOP: 
 * CMP R2, R3        ; Are we done with the inner loop? (j vs n)
 * BGE END_INNER     ; If j >= n, break out of the inner loop.
 * * // --- Memory Fetch ---
 * LOAD R4, [R1]     ; R4 = arr[i]
 * LOAD R5, [R2]     ; R5 = arr[j]
 * * // --- Compare & Swap ---
 * CMP R4, R5        ; Is arr[i] > arr[j]?
 * BLE SKIP_SWAP     ; Nope, they are in the right order. Skip the swap!
 * STORE R5, [R1]    ; Swap part 1: arr[i] gets the value of arr[j]
 * STORE R4, [R2]    ; Swap part 2: arr[j] gets the old value of arr[i]
 * * SKIP_SWAP:  
 * ADD R2, 1         ; j++
 * JMP INNER_LOOP    ; Back to the top of the inner loop
 * * END_INNER:
 * ADD R1, 1         ; i++
 * JMP OUTER_LOOP    ; Back to the top of the outer loop
 * * EXIT:  
 */

module tb_MCPModule();

    reg clk;
    reg rst1; 

    wire [7:0] result;

    MCPModule uut (
        .clk(clk), 
        .rst1(rst1), 
        .result(result)
    );

    always #5 clk = ~clk;

    initial begin
        // Fire up the clock and hold resets high initially
        clk = 0;
        rst1 = 1;

        #100;
        // Drop resets to let the processor start running
        rst1 = 0;

        // Load our unsorted array into data memory
        uut.dm.dmemory[0] = 8'd5;
        uut.dm.dmemory[1] = 8'd8;
        uut.dm.dmemory[2] = 8'd2;

        // Load the compiled machine code into instruction memory
        uut.im.imemory[0]  = 24'h080000; 
        uut.im.imemory[1]  = 24'h080603; 
        uut.im.imemory[2]  = 24'h080E01; 
        uut.im.imemory[3]  = 24'h080200; 
        
        uut.im.imemory[4]  = 24'h68460D; 
        uut.im.imemory[5]  = 24'h604020; 
        
        uut.im.imemory[6]  = 24'h688609; 
        uut.im.imemory[7]  = 24'h104800; 
        uut.im.imemory[8]  = 24'h108A00; 
        
        uut.im.imemory[9]  = 24'h494880; 
        uut.im.imemory[10] = 24'h6A0003; 
        
        uut.im.imemory[11] = 24'h188800; 
        uut.im.imemory[12] = 24'h184A00; 
        
        uut.im.imemory[13] = 24'h608E20; 
        uut.im.imemory[14] = 24'h2000F8; 
        
        uut.im.imemory[15] = 24'h604E10; 
        uut.im.imemory[16] = 24'h2000F4; 

        // Let the simulation run for enough time to finish the sorting loops
        #500; 
        
        // Print the results to the console!
        $display("========================================");
        $display("Execution Complete. Checking Data Memory");
        $display("========================================");
        $display("arr[0] = %d (Expected: 2)", uut.dm.dmemory[0]);
        $display("arr[1] = %d (Expected: 5)", uut.dm.dmemory[1]);
        $display("arr[2] = %d (Expected: 8)", uut.dm.dmemory[2]);
        $display("========================================");
        
        $finish;
    end

endmodule
