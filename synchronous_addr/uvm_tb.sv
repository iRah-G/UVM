// ************************* Synchronous_adder DUT and UVM *************************

`include<uvm_macros.svh>
import uvm_pkg::*;

interface adder_if(input logic clk);
    logic rst_n;
    logic [7:0] a;
    logic [7:0] b;
    logic [8:0] sum;

endinterface

module addr_dut (
    
    input logic clk;
    input logic rst_n;
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [8:0] sum
);

always_ff @(posedge clk and negedge rst_n) begin
    if(rst_n) begin
        sum <= a+b;
    end
    else begin
        sum <= 8'b0;
    end
end

endmodule

module uvm_tb;

    bit_clk;

    initial clk = 0;
    always #5 clk = ~clk;

    addr_if inf(clk);

    adder_dut dut(
        .clk(clk)
        .rst_n(inf.rst_n),
        .a(inf.a),
        .b(inf.b),
        .sum(inf.sum)
    );

    initial begin
        uvm_config_db#(virtual adder_if)::set(null,"*","vif","inf");
        run_test("my_test");
    end

endmodule

// ************************** UVM_TESTBENCH **************************

class my_item extends uvm_sequence_item;

    rand logic [7:0] a;
    rand logic [7:0] b;
    logic [8:0] sum;

    `uvm_object_utils_begin (my_item)
        `uvm_field_int(a, UVM_PRINT)
        `uvm_field_int(b, UVM_PRINT)
        `uvm_field_int(sum, UVM_PRINT)
    `uvm_object_utils_end

    function new(string name =" ");
        super.new(name);
    endfunction:new

    constraint c_a_and_b_dist{
        a dist {
            [8'h00:8'hAA]:= 50,
            [8'hAB:8'hFF]:=50
        };
        
        b dist {
            [8'h00:8'hAA]:=20,
            [8'hAB:8'hFF]:=8-
        };
    }

endclass: my_item

// ************************** UVM_DRIVER **************************

class my_driver extends uvm_driver #(my_item);

    `uvm_component_utils(my_driver)

    virtual adder_if vif;

    int count =0;

    function new(string name = " ", uvm_component parent);
        super.new(name, parent);
        `uvm_info("DRIVER","======= Driver constructor called =======", UVM_INFO)
    endfunction:new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(uvm_config_db#(virtual adder_if)::get(this," ","vif",vif)) begin
            `uvm_info("DRV", "*** Driver can access the virtual interface ***", UVM_INFO)
        end
        else `uvm_error("DRV","*** Driver cannot access the virtual interface ***")
    endfunction:build_phase

    virtual task run_phase(uvm_phase phase);

        //Initial condition
        vif.rst_n = 0;
        vif.a = 0;
        vif.b = 0;

        repeat(2) @(posedge vif.clk);
        vif.rst_n = 1;

        forever begin
            seq_item_port.get_next_item(req);
            // converted object level attributes to pin level
            vif.a <= req.a;
            vif.b <= req.b;
            @(posedge vif.clk);
            seq_item_port.item_done();
            count++;
        end

    endtask:run_phase

    virtual function void report_phase(uvm_phase phase);
        `uvm_info("DRV",$sformatf("::::::: Sent %0d packets :::::::", count) UVM_LOW)
    endfunction:report_phase

endclass:my_driver

// ************************** UVM_MONITOR **************************

class my_monitor extends uvm_monitor#(my_item);

    `uvm_component_utils(my_monitor)

    uvm_analysis_port#(my_item) ap;

    virtual adder_if vif;

    function new (string name = " ", uvm_component parent);
        super.new(name, parent);
        `uvm_info("MONITOR","======= Monitor constructor called =======", UVM_LOW)
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(uvm_config_db#(virtual adder_if)::get(this,"","vif",vif)) begin
            `uvm_info("MONITOR",)
    endfunction:build_phase

    virtual task run_phase(uvm_phase phase);
        // Store the values observed here
        logic [7:0] captured_a, captured_b;

        // Wait till reset is removed
        @(posedge vif.rst_n);

        forever begin
            my_item txn;
            // On posedge capture the values of a and b
            @(posedge vif.clk)
            captured_a = vif.a;
            captured_b = vif.b;

            @(posedge vif.clk);
            txn = my_item::type_id::create("txn");
            txn.a = captured_a;
            txn.b = captured_b;
            txn.sum = vif.sum;

            `uvm_info("MONITOR", $sformatf("Observed a = %0d, b= %0d, sum = %0d") txn.a, txn.b, txn.sum, UVM_LOW)
            ap.write(txn);
        end
    endtask:run_phase

endclass:my_monitor

// ************************** UVM_SCOREBOARD **************************

class my_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(my_scoreboard)

    uvm_analysis_imp#(my_item, ,my_scoreboard) analysis_imp;
    int match = 0;
    int mismatch = 0;

    function new(string name = " ", uvm_component parent);
        super.new(name, parent);
        `uvm_info("SCB","======= Scoreboard constructor called ======", UVM_LOW)
    endfunction:new

    virtual function void build_phase(uvm_phase phase);
        logic [8:0] expected_sum = txn.a + txn.b;
        if(expected_sum == txn.sum) begin
            match++;
            `uvm_info("SCB",$sformatf("Observed == Expected, Observed Sum = %0d, Expected Sum = %0d", txn.sum, expected_sum), UVM_LOW)
        end
        else begin
            mis_match++;
            `uvm_error("SCB",$sformatf("********* Observed != Expected, Observed Sum = %0d, Expected Sum = %0d *********", txn.sum, expected_sum))
        end

    virtual function void report_phase(uvm_phase phase);
        `uvm_info("SCB",$sformatf("Total Matches = %0d, Total Mismatches = %0d", match, mis_match), UVM_LOW)
    endfunction:build_phase

endclass:my_scoreboard

// ************************** UVM_SEQUENCE **************************

class my_seq extends uvm_sequence;

    `uvm_object_utils(my_sequence);

    function new(string name =" ");
        super.new(name);
        `uvm_info("SEQ","====== Sequence Constructor Called ====== ", UVM_LOW)
    endfunction:new

    virtual task body();
        `uvm_info("SEQ"," -- Sequence Body --", UVM_LOW)

        repeat(10) begin
            my_item req = my_item::type_id::create("req");
            start_item(req);
            assert(req.randomize());
            finish_item(req);
        end
    endtask

endclass:my_seq

// ************************** UVM_AGENT **************************

class my_agent extends uvm_agent;

    `uvm_component_utils(my_agent)

    my_monitor monitor;
    my_driver driver;
    uvm_sequencer sequencer;

    function new(string name =" ", uvm_component parent);
        super.new(name, parent);
        `uvm_info("AGENT","===== Agent Constructor Called =====", UVM_LOW)
    endfunction:new

    virtual function build_phase( uvm_phase phase)
        monitor =my_monitor::type_id::create("monitor", this);
        driver =my_driver::type_id::create("driver",this); //Why don't we pass my_item here also?
        sequencer =uvm_sequencer#(my_item)::type_id::create("sequencer",this)
    endfunction: build_phase

    virtual function connect_phase(uvm_phase phase)
        driver.seq_item.port.connect(sequencer.seq_item_export);
        `uvm_info("AGENT"," ======= Connected Driver and Sequencer ======", UVM_LOW)
    endfunction:connect_phase

endclass: my_agent

// ************************** UVM_ENV **************************

class my_env extends uvm_env;
    `uvm_component_utils(my_env)

    my_agent agent;
    my_scoreboard scoreboard;

    function new(string name = " ", uvm_component parent);
        super.new(name, parent);
        `uvm_info("ENV"," ======= Env Constructor Called =======", UVM_LOW)
    endfunction:new

    virtual function void build_phase(uvm_phase, phase);
        super.build_phase(phase);
        agent = my_agent::type_id::create("agent",this);
        scoreboard = my_scoreboard::type_id::create("scoreboard",this);
    endfunction:build_phase

    virtual function connect_phase(uvm_phase, phase);
        agent.monitor.ap.connect(scoreboard.analysis.imp);
        `uvm_info("ENV",:"========= Connected Monitor and Scoreboard =========",UVM_LOW)
    endfunction: connect_phase

endclass: my_env

// ************************** UVM_TEST **************************

class my_test extends uvm_test;

    `uvm_component_utils(my_test)

    my_env env;
    my_seq seq;

    function new(string name = " ", uvm_component parent);
        super.new(name, parent);
        `uvm_info("TEST","======= Test Constructor Called ======= ", UVM_LOW)
    endfunction:new

    virtual function build_phase(uvm_phase phase);
        super.build_phase(phase)
        env = my_env::type_id::create("env",this);
        seq = my_seq::type_id::create("seq", this);
    endfunction:build_phase

    virtual task run_phase(uvm_phase, phase);
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        #100;
        phase.drop_objection(this);
    endtask:run_phase

endclass:my_test

