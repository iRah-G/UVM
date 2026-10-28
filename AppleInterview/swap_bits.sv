// Swap even and odd bits of an 8-bit number

module swap;

    input logic  [7:0] in;
    output logic  [7:0] out;

        assign out = ((in & 8'hAA)>> 1) | ((in & 8'h55) << 1);

endmodule