/*****
Whenever req is asserted on a rising edge of clk, ack must be asserted on the same clock cycle.
*****/

logic clk;
logic req;
logic ack;

property req_ack_same_cycle;
    @(posedge clk)
    req |-> ack;
endproperty;

assert property(req_ack_same_cycle)
    else $error("ERROR: ACK was not asserted when REQ was asserted");

/*****
Whenever start is asserted, done must be asserted exactly 3 clock cycles later.
*****/

logic clk;
logic start;
logic done;

property done_3_aft_start;
    @(posedge clk)
    start |-> ##3 done;
endproperty;

assert property(done_3_aft_start)
    else("ERROR: DONE is not asserted 3 cycles after start");

/*****
Whenever req is asserted, ack must be asserted within 2 to 5 clock cycles after the request.
*****/

property ack_2_5_aftr_req;
    @(posedge clk)
    req |-> ##[2:5] ack;
endproperty;

assert property(ack_2_5_aftr_req)
    else("ERROR: ACK is not asserted within the required cycles after REQ");

/*****
Whenever start is asserted, done must occur between 3 and 7 clock cycles later.
*****/

property done_3_7_btwn_start;
    @(posedge clk)
    start |-> ##[3:7] done;
endproperty;

assert property(done_3_7_btwn_start)
    else("ERROR: DONE not asserted in time");

/*****
Whenever busy becomes high, it must remain high for at least 2 and at most 4 consecutive clock cycles.
*****/
property busy_high;
    @(posedge clk)
    $rose(busy) |-> busy[*2:4] ##1 !busy; //when busy becomes high, it should stay high for 2 to 4 cycles after that it should go low
endproperty

assert property(busy_high)
    else $error("ERROR: BUSY duration is not between 2 and 4 cycles");
