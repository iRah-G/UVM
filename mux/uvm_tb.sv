// ************************** MUX DUT and UVM TB for the same **************************

include <uvm_macros.svh> //bring all uvm macros and tools to this file
 import uvm_pkg::*;        //import entitre UVM package like classes, types etc

//UVM Interface
//The interface captures the signals used to drive and monitor the DUT
//Interface bundles the signals together so that the monitor and driver do not need to deal
//manually with each wire

interface mux_if (
    input logic clk,
    input logic rst
);
    logic [7:0] a;
    logic [7:0] b;
    logic sel;
    logic [7:0] c;
    
    modport driver (input clk, rst, output a, b, sel, input c);
    modport monitor (input clk, rst, a, b, sel, c);
endinterface

module mux_dut(
    input logic clk,
    input logic reset,
    input logic [7:0] a,
    input logic [7:0] b,
    input logic sel,
    output logic [7:0] c
);
    always_comb begin
        if (reset)
            c <= 0;
        else
            c <= sel ? a : b;
    end
endmodule

module top;
    logic clk, rst;
    logic [7:0]a;
    logic [7:0]b;
    logic [7:0]c;
    logic sel;
    
    mux_if mux_if_inst(.clk(clk), .rst(rst));
    
    mux_dut dut_instance (
        .*
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("mux.vcd");
        $dumpvars(1,top);
    end

    initial begin
        rst = 1;
        a = 0; 
        b = 0; 
        sel = 0;
        repeat(2) @(posedge clk);
        rst = 0;
        repeat(10) begin
            @(negedge clk);
            a = $urandom;
            b = $urandom;
            sel = $urandom;
        end
        @(posedge clk);
        $finish;
    end

    initial begin
        $monitor("time: %t, a: %0d, b: %0d, sel: %0d, c: %0d", $time, a, b, sel, c);
    end
    
 //   initial begin
   //     run_test();
   // end
endmodule
/*
******************* UVM_ENV *******************

class mux_env extends uvm_env;

uvm_component_utils(mux_env); //registers the class with the factory

//env has agent and scoreboard their handles go here
    mux_agent agent_h;            
    mux_scoreboard scoreboard_h;

//Build phase to construct sub components
function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //::type_id::create makes the TB flexible to swap implementation 
    //type_id is part of factory overrides
    agent_h = mux_agent::type_id::create("agent_h",this);
    scoreboard_h = mux_scoreboard::type_id::create("scoreboard_h",this);
endfunction

endclass

//******************* UVM_AGENT *******************

class mux_agent extends uvm_agent;

uvm_component_utils(mux_agent);

    mux_driver driver_h;
    mux_monitor monitor_h;
    mux_sequencer sequencer_h;

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver_h = mux_driver::type_id::create("driver_h",this);
    monitor_h = mux_monitor::type_id::create("monitor_h",this);
    sequencer_h =mux_sequencer::type_id::create("sequencer_h",this);
endfunction

endclass

//******************* UVM_DRIVER *******************

class mux_driver extends uvm_driver #(mux_transaction);

    `uvm_component_utils(mux_driver);

    // Constructor and member variables (if any)
    virtual mux_if vif;  //handle to the interface

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //get interface handle from config_db
        if (uvm_config_db#(virtual mux_if)::get(this, "", "vif", vif)) begin
            `uvm_info("DRV_VIF","Driver can access the virtual function")
        end
        else
            `uvm_error("ERROR: Driver cannot access virtual function")
    endfunction

    task run_phase(uvm_phase phase);
        // Task where actual driving logic goes
        // For now, leave empty
    endtask

endclass

//******************* UVM_MONITOR *******************

class mux_monitor extends uvm_monitor;

    `uvm_component_utils(mux_monitor);

    virtual mux_if vif;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase)
        if (uvm_config_db#(virtual mux_if)::get(this, "", "vif", vif)) begin
            `uvm_info("MON_VIF","Monitor can access the virtual function")
        end
        else
            `uvm_error("ERROR: Monitor cannot access virtual function")
    endfunction

    task run_phase(uvm_phase phase);
        // Code to sample interface signals, package into transactions
        // Usually forever loop sampling signals
        // For now, leave empty or comments
    endtask

endclass

//******************* UVM_SCOREBOARD *******************

class mux_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(mux_scoreboard)

    virtual mux_if vif;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(uvm_config_db#(virtual mux_if)::get(this,"","vif",vif)) begin
          `uvm_info("SCB_VIF","Scoreboard can access the virtual function")
        end
        else
            `uvm_error("ERROR: Scoreboard cannot access virtual function")
    endfunction  

     // Method to check outputs (stub for now)
    function void check_output(mux_transaction trans);
        // Compare actual with expected values; for now, leave this empty
    endfunction

endclass       

//*******************  UVM_SEQUENCE  *******************

class mux_sequence extends uvm_sequence;

    `uvm_component_utils(mux_sequence);

    virtual mux_if vif;

    function new(string name = "mux_sequence");
        super.new(name);
    endfunction

    task body();
        mux_transaction tr;
        tr = mux_transaction::type_id::create("tr");
        //Optionally randomize transaction fields
        //Start item, randomize, finish item
        start_item(tr);
        //randomize(tr); //If you use randomization
        finish_item(tr);
    endtask

endclass

//*******************  UVM_SEQUENCER *******************

class mux_sequencer extends uvm_sequencer #(mux_transaction);

    `uvm_component_utils(mux_sequencer);

    function new(string name = "mux_sequencer");
        super.new(name);
    endfunction

    //No extra methods for a basic sequencer

endclass
*/



