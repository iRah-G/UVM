// Write a basic SystemVerilog testbench for a 4-bit adder. The testbench should:

// Drive inputs a and b
// Observe sum
// Check whether sum == a + b

// *********** adder.sv ***********

module adder (
    input  logic [3:0] a,
    input  logic [3:0] b,
    output logic [4:0] sum
);

    assign sum = a + b;

endmodule

// *********** basic tb.sv ***********

module tb(
    input logic [3:0] a,
    input logic [3:0] b,
    output logic [4:0] sum
);

// Instantiate DUT
 adder dut(
    .a(a),
    .b(b),
    .sum(sum)
 ); 

initial begin
    //  Apply stimulus 
    a =4;
    b =5;

    #10;

    // Check result
    if( sum == a + b)
        $display("PASS");
    else
        $display("FAIL");
end

endmodule

// *********** UVM tb.sv ***********
module tb;

    adder_if aif();

    adder dut (
        .a(aif.a),
        .b(aif.b),
        .sum(aif.sum)
    );

    initial begin

        uvm_config_db#(virtual adder_if)::set(
            null, "*", "vif", aif);

        run_test("adder_test");

    end

endmodule

// :::::::::::: adder_if.sv :::::::::

interface adder_if;
     
    logic [3:0] a;
    logic [3:0] b;
    logic [4:0] sum;

endinterface

// :::::::::::: transaction.sv :::::::::
// Transaction is the data being passed around the uvm tb

class transaction extends uvm_sequence_item;

    rand bit [3:0] a;
    rand bit [3:0] b;

    `uvm_object_utils(transaction)

    function new(string name = "transaction");
        super.new(name);
    endfunction

endclass

// :::::::::::: sequence.sv :::::::::

class adder_sequence extends uvm_sequence;

    `uvm_object_utils(adder_sequence)

    function new(string name = "adder_sequence");
        super.new(name);
    endfunction

    task body();

        transaction tr;

        repeat(10) begin

            tr = transaction::type_id::create("tr");

            start_item(tr);

            assert(tr.randomize());

            finish_item(tr);

        end
    endtask
    
endclass

// :::::::::::: driver.sv :::::::::

class adder_driver extends uvm_driver #(transaction);

    `uvm_component_utils(adder_driver)

    virtual adder_if vif;

// Constructor new()
    function new(string name = "adder_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

// Build
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(virtual adder_if)::get(this, "", "vif", vif);
    endfunction

    task run_phase(uvm_phase phase);

        forever begin

            seq_item_port.get_next_item(req);

            vif.a = req.a;
            vif.b = req.b;

            #1;

            seq_item_port.item_done();
        end

    endtask
endclass

// :::::::::::: monitor.sv :::::::::

class adder_monitor extends uvm_monior;

    `uvm_component_utils(adder_monitor)

    function new(string name = "adder_monitor",uvm_component parent = null);
        super.new(name, parent)
    endfunction

    function build_phase( uvm_phase phase)
        
    endfunction


endclass






