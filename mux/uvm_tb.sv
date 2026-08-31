// ************************** MUX DUT and UVM TB for the same **************************

`include <uvm_macros.svh> //bring all uvm macros and tools to this file
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

// TESTBENCH
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
        uvm_config_db#(virtual mux_if)::set(null, "*","vif",inf);
        run_test("my_test");
   end
    
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
            a   = $urandom;
            b   = $urandom;
            sel = $urandom;
        end
        @(posedge clk);
        $finish;
    end

    initial begin
        $monitor("time: %t, a: %0d, b: %0d, sel: %0d, c: %0d", $time, a, b, sel, c);
    end

endmodule

// ******************* UVM_TESTBENCH ******************* 
// use either this testbench or the above SV testbench comment other one out while implementing

class my_item extends uvm_sequence_item;

    rand logic[7:0] a;
    rand logic[7:0] b;
    rand logic[7:0] c;
    rand logic[1:0] sel;

    `uvm_object_utils_begin(my_item)
        `uvm_field_int(a, UVM_PRINT)
        `uvm_field_int(b, UVM_PRINT)
        `uvm_field_int(c, UVM_PRINT)
        `uvm_field_int(sel, UVM_PRINT)
    `uvm_object_utils_end

    function new(string name = " ");
        super.new(name);
    endfunction:new

    constraint a_and_b_dist{
        a dist{
            [8'h00:8'hAA]:=50,
            [8'hAB:8'hFF]:=50
        };

        b dist{
            [8'h00:8'hAA]:=80,
            [8'hAB:8'hFF]:=20
        }
    }

endclass: my_item

// ******************* UVM_ENV *******************

class mux_env extends uvm_env;

`uvm_component_utils(mux_env) //registers the class with the factory

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

`uvm_component_utils(mux_agent)

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

class mux_driver extends uvm_driver #(my_item);

    `uvm_component_utils(mux_driver)

    // Constructor and member variables (if any)
    virtual mux_if vif;  //handle to the interface

    int count =0;

    function new(string name = "", uvm_component parent)
         super.new(name, parent);
         `uvm_info("DRIVER","*****Driver constructor called*****", uvm_info)
    endfunction

    virtual function void build_phase(uvm_phase phase);
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

        // Initial condition
        vif.rst = 1;
        vif.a = 0;
        vif.b = 0;
        vif.sel = 0;

        repeat(2) @(posedge vif.clk);
        vif.rst =0;

        forever begin
            seq_item_port.get_next_item(req);
            //Coonverted object level attributes to pin level
            vif.a <= req.a;
            vif.b <= req.b;
            vif.sel <= req.sel;
            @(posedge vif.clk);
            seq_item_port.item_done();
            count++;
        end

    endtask:run_phase

    virtual function void report_phase(uvm_phase phase);
        `uvm_info("DRV", $sformatf(":::::::Sent %0d packets:::::::", count), UVM_LOW);
    endfunction:report_phase

endclass:mux_driver

//******************* UVM_MONITOR *******************

class mux_monitor extends uvm_monitor;

    `uvm_component_utils(mux_monitor)

    uvm_analysis_port#(my_item) ap;

    virtual mux_if vif;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase)
        ap = new("ap", this);
        if (uvm_config_db#(virtual mux_if)::get(this, "", "vif", vif)) begin
            `uvm_info("MON_VIF","Monitor can access the virtual function")
        end
        else
            `uvm_error("ERROR: Monitor cannot access virtual function")
    endfunction

    task run_phase(uvm_phase phase);
        // Code to sample interface signals, package into transactions
        // Usually forever loop sampling signals

        // Store the values observed here
        logic[7:0] captured_a, captured_b;
        logic[1:0] captured_sel;

        // wait till reset is removed
        @(posedge vif.rst);

        forever begin
                my_item txn;
                // on posedge capture values of a, b and sel
                @(posedge vif.clk);
                captured_a = vif.a;
                captured_b = vif.b;
                captured_sel = vif.sel;

                @(posedge vif.clk);
                txn = my_item::type_id::create("txn");
                txn.a = captured_a;
                txn.b = captured_b;
                txn.sel = captured_sel;
                txn.c = vif.c;

                `uvm_info("MONITOR",$sformatf("Observed a = %0d, b = %0d, sel =%0d", txn.a, txn.b, txn.sel));
                ap.write(txn);
        end

    endtask:run_phase

endclass: my_monitor

//******************* UVM_SCOREBOARD *******************

class mux_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(mux_scoreboard)

    virtual mux_if vif;
    
    uvm_analysis_imp#(my_item, mux_scoreboard) analysis_imp;
    int match = 0;
    int mis_match = 0;
    
    function new(string name = " ",uvm_component parent)
        super.new(name, parent);
        `uvm_info("SCB", "::::::::Scoreboard constructor called :::::::", UVM_INFO)
    endfunction:new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(uvm_config_db#(virtual mux_if)::get(this,"","vif",vif)) begin
          `uvm_info("SCB_VIF","Scoreboard can access the virtual function")
        end
        else
            `uvm_error("ERROR: Scoreboard cannot access virtual function")

        analysis_imp = new("analysis_imp",this);
    endfunction: build_phase

    virtual function void write(my_item txn);
        logic [7:0] expected_data;

        //Calculate expected output based on mux logic
        if(txn.sel ==0)
            expected_data = txn.a;
        else
            expected_data = txn.b;

        // Compare actual with expected
        if(expected_data == txn.c) begin
            match++
            `uvm_info("SCB", $sformatf("MATCH: sel =%0d, a = %0d, b=%0d, expected =%0d, actual =%0d", 
            txn.sel, txn.a, txn.b, expected_data, txn.out), UVM_LOW)
        end
        else begin
            mis_match++;
            `uvm_error("SCB",$sformatf("MISMATCH: sel =%0d, a = %0d, b=%0d, expected =%0d, actual =%0d", 
            txn.sel, txn.a, txn.b, expected_data, txn.out), UVM_LOW)
        end
    endfunction:write

    virtual function void report_phase(uvm_phase phase)
        `uvm_info("SCB",$sformatf("Total Matches = %0d, Total Mismatches = %0d", match, mis_match), UVM_LOW);
    endfunction:report_phase


endclass: mux_scoreboard    

//*******************  UVM_SEQUENCE  *******************

class mux_sequence extends uvm_sequence#(my_item);

    `uvm_object_utils(mux_sequence)

    function new(string name = "");
        super.new(name);
        `uvm_info("SEQ",":::::::Sequence constructor Called:::::::", UVM_INFO)
    endfunction:new


    virtual task body();
        `uvm_info("SEQ","-- Sequence body --", UVM_LOW)

        repeat(10) begin
            my_item req = my_item::type_id::create("req");
            start_item(req);
            assert(req.randomize());
            finish_item(req);
        end
    endtask

endclass: mux_sequence

//*******************  UVM_SEQUENCER *******************

class mux_sequencer extends uvm_sequencer #(my_item);

    `uvm_component_utils(mux_sequencer)

    function new(string name = "", uvm_component parent);
        super.new(name, parent);
    endfunction

    //No extra methods for a basic sequencer

endclass

//*******************  UVM_AGENT *******************

class mux_agent extends uvm_agent;

    `uvm_component_utils(mux_agent)

    mux_driver driver;
    mux_monitor monitor;
    mux_sequencer sequencer;

    `uvm_component_utils(mux_agent)

    function new(string name =" ", uvm_component parent);
        super.new(name, parent);
        `uvm_info("AGENT",":::::::Agent constructor called:::::::", UVM_INFO);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        monitor = mux_monitor::type_id::create("monitor", this);
        driver = mux_driver::type_id::create("driver",this);
        sequencer = mux_sequencer::type_id::create("sequencer",this);
    endfunction:build_phase

    virtual function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
        `uvm_info("AGENT","::::::: Connected Driver and Sequencer :::::::", UVM_LOW);
    endfunction:connect_phase

endclass:my_agent

//*******************  UVM_ENV *******************

class mux_env extends uvm_env;
    `uvm_component_utils(mux_env)

    mux_agent agent;
    mux_scoreboard scoreboard;

    function new(string name =" ", uvm_component parent);
        super.new(name,parent);
        `uvm_info("ENV":"::::::: Env Constructor Called :::::::", UVM_LOW);
    endfunction:new

    virtual function build_phase(uvm_phase phase);
        agent = mux_agent::type_id::create("agent", this);
        scoreboard = mux_scoreboard::type_id::create("scoreboard",this);
    endfunction:build_phase

    virtual function connect_phase(uvm_phase phase);
        agent.monitor.ap.connect(scoreboard.analysis_imp);
        `uvm_info("ENV","::::::::: Connected Monitor and Scoreboard::::::::", UVM_LOW);
    endfunction:connect_phase

endclass:uvm_env

//*******************  UVM_TEST *******************

class mux_test extends uvm_test;

    `uvm_component_utils(mux_test)

    mux_env env;
    mux_sequence sequence;

    function new(string name =" ", uvm_component parent);
        super.new(name, parent);
        `uvm_info("TEST","::::::::Test constructor called ::::::::", UVM_INFO);
    endfunction:new

    virtual function build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = mux_env::type_id::create("env", this);
        sequence = mux_sequence::type_id::create("sequence",this);
    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
         #100;
         phase.drop_objection(this);
    endtask:run_phase

endclass:mux_test
