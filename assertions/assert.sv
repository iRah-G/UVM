/*
Write SystemVerilog assertions
Write assertions for these requirements:
1. If req is asserted, ack must arrive within 1 to 3 clock cycles.
2. If valid && !ready, valid and data remain stable on the next cycle.
3. A FIFO must never accept a write when full.
4. Reset must clear the FIFO's empty/full state as specified.
*/

property req_ack;
    @(posedge clk) disable iff(rst) begin
        req |-> ##[1:3] ack;
    end
endproperty

property data_stable;
    @(posedge clk) disable iff(rst) begin
        (valid && !ready) |=> (valid && $stable(data)); // |=> is next cycle, |-> is same cycle
    end
endproperty

property full_no_write;
    @(posedge clk) disable iff (rst)
    (full && wr_en) |-> !write_accept;
endproperty

property reset_clears_fifo;
    @(posedge clk)
    rst |=> (empty && !full);
endproperty

