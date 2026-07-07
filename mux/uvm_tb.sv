//************************** MUX DUT and UVM TB for the same **************************

`include <uvm_macros.svh> //bring all uvm macros and tools to this file
import uvm_pkg::*;        //import entitre UVM package like classes, types etc

//UVM Interface
//The interface captures the signals used to drive and monitor the DUT
//Interface bundles the signals together so that the monitor and driver do not need to deal
//manually with each wire

interface mux_if (
    input logic clk,
    input logic rst,
);
    logic [7:0]a,
    logic [7:0]b,
    logic sel;
    logic [7:0]c;

endinterface

//MUX DUT

module mux_dut(
    input logic clk,
    input logic reset,
    input logic [7:0] a,
    input logic [7:0] b,
    input logic sel,
    output logic [7:0] c
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            c <= 0;
        else begin
            if (sel)
                c <= a;
            else
                c <= b;
        end
    end

endmodule

//top module

module top;
    //create interface instance
    mux_if mux_if_inst();

    //DUT instance: connect ports to interface signals
    mux_dut dut_instance (
        .clk(mux_if_inst.clk),
        .rst(mux_if_inst.rst),
        .a(mux_if_inst.a),
        .b(mux_if_inst.b),
        .sel(mux_if_inst.sel),
        .c(mux_if_inst.c)
    );

    initial begin
        run_test();  //run_test kicks off UVM, 
        //we need run_test in top.sv to start any UVM
    end
endmodule

//******************* UVM_ENV *******************

class mux_env extends uvm_env;

//env has agent and scoreboard their handles go here
    mux_agent uvm_agent;            
    mux_scoreboard uvm_scoreboard;

//Constructor for agent and scoreboard

endclass



