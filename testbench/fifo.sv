/*
FIFO testbench

Assume a synchronous FIFO with wr_en, rd_en, din, dout, full, and empty.
Write a testbench that:
- Writes and reads multiple values.
- Tests empty and full conditions.
- Tests simultaneous read and write.
- Uses a SystemVerilog queue as a reference model.
- Detects data mismatches.
*/

module test;

    logic clk, rst;
    logic wr_en, rd_en;
    logic [7:0] wr_data, rd_data;
    logic full, empty;

    // Reference queue: stores expected FIFO contents
    logic [7:0] ref_q[$];

    // Expected data returned by a read
    logic [7:0] expected_data;

    // Clock: 10ns period
    initial clk = 0;
    always #clk = ~clk;

    // Instantiate the FIFO
    fifo dut(
        .*
    )

    task automatic fifo_cycle(
        input logic wr, 
        input logic rd,
        input logic [7:0] data_in
    );

        begin
            // 

    endtask


endmodule