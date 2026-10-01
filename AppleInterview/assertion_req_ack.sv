// input req, clk
// output ack

//For every req, ack must be generated within 5 cycles
// There should be no spurious ack, req is independent of ack
// All are single bit ports
// There can be more than one outstanding req and there can be back to back req
// For every req there must be an individual ack
// Write a checker for this design