/* 
Basic testbench for a counter
Write a testbench for a synchronous 4-bit counter with clk, active-high synchronous rst, 
enable, and count outputs.

Requirements:
- Clock period = 10 ns.
- Reset the counter.
- Verify counting when enable = 1.
- Verify holding when enable = 0.
- Verify wraparound from 15 to 0.
- Automatically check expected values.
*/

//****************** DUT ******************

module counter (
    input  logic       clk,
    input  logic       rst,
    input  logic       enable,
    output logic [3:0] count
);

    always_ff @(posedge clk) begin
        if (rst)
            count <= 4'd0;       // Synchronous reset
        else if (enable)
            count <= count + 1;  // Increment counter
    end

endmodule

//****************** TB ******************

module tb;

    logic clk;
    logic rst;
    logic enable;
    logic [3:0] count;

    dut interface( 
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .count(count)
    )

    // Generate a 10ns clk
    initial clk = 0;
    always #5 clk = ~clk;

    // Test stimulus
    initial begin
        rst = 1;
        enable = 0;
        expected_count = 0;

        // hold rst for two rising edges
        repeat (2) @(posedge clk);

        // deassert rst away from the sampling edge
        @(negedge clk);
        rst = 0;

        // Test 1: Counter increments
        enable = 1

        repeat(5) begin
            @(posdege clk);
            expected_count = expected_count +1;

            // wait for nonblocking assignment to update count
            #1;
            if (count !== expected_count)
                $error("Increment FAIL: expected=%0d actual=%0d", expected_count, count);
            else
                $display("Increment PASS: count=%0d", count);
        end

        // Test 2: Counter holds when enable is low
        @(negedge clk);
        enable = 0;

        repeat(3) begin
            @(posedge clk);
            #1;

            if(count !== expected_count)
                $error("Hold FAIL: expected=%0d actual=%0d", expected_count, count);
            else
                $display("Hold PASS: count=%0d", count);
        end

        // Test 3: Drive counter to 15 and test wraparound
        @(negedge clk)
        enable 1;

        while (expected_count != 15) begin
            @(posedge clk);
            expected_count = expected_count +1;
            #1;

            if(count !== expected_count)
                $error("Count FAIL: expected=%0d actual=%0d", expected_count, count);
        end

        // Next increment must wrap from 15 to 0 
        @(posedge clk);
        expected_count = expected_count +1; //4-bit wraparound
        #1;

        if (count !== expected_count)
            $error("Wraparound FAIL: expected= %0d actual=%0d", expected_count, count);
        else
            $display("Wraparound PASS: count=%0d", count);

        $display("Test completed");
        $finish;
    end
endmodule