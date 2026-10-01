// SVA repetitions
// 1[*10]     // 1 for 10 CONSECUTIVE cycles
// req[*4]    // req = 1 for 4 CONSECUTIVE cycles
// req[=4]    // req occurs 4 times, NOT necessarily consecutive
// req[->4]   // req occurs 4 times, with the last occurrence ending the sequence

// *************** EXAMPLE ***************

//Write an SV assertion/checker to ensure that at any given point,
//  within a window of 10 clock cycles, req is asserted for exactly 4 cycles.

property a_req_four begin
    @(posedge clk) disable iff(rst) begin
        1'b1 |-> req[=4] intersect 1[*10]; // 1'b1 checks on every clk cycle, [=4] means any 4 cycles, 
        // intersect 1[*10] is should be 4 times 1 in the 10 clk cycle window
    end
endproperty

// *************** Slightly different ***************

// Write an SV checker to ensure that at any given window of 10 clock (clk) cycles, 
// req is asserted no more than 4 times

property a_req_max_four begin
    @(posedge clk) disable iff(rst) begin
        req |-> req[=0:3] intersect 1[*9]; //if there is req in one cycle then 
        // there can be 0 to 3 req in the next 9 cycles
    end

endproperty