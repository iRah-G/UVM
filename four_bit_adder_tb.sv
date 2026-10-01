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

