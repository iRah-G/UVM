//=====================================================================
// SYSTEMVERILOG CONCEPTS NECESSARY FOR UVM
//=====================================================================


//=====================================================================
// 1. CLASS
//=====================================================================
// A class is a blueprint for creating objects.
// It is the core building block of UVM components.

class packet;

  int addr;
  int data;

  function new();
    addr = 0;
    data = 0;
  endfunction

  function void display();
    $display("Addr=%0d Data=%0d", addr, data);
  endfunction

endclass

// HOW USED IN UVM:
// - Every UVM component (driver, monitor, env) is a class.
// - Transactions, sequences, and configs are all classes.
// WHEN USED:
// - Whenever you model behavior/data in verification TB.



//=====================================================================
// 2. OBJECT
//=====================================================================
// An object is an instance of a class created using 'new()'.

class packet;
  int addr;
endclass

packet p1;

initial begin
  p1 = new();   // object creation
  p1.addr = 10;
end

// HOW USED IN UVM:
// - UVM factory creates objects dynamically at runtime.
// - Sequences and transactions are object-based.
// WHEN USED:
// - During simulation when stimulus or components are created.



//=====================================================================
// 3. INHERITANCE
//=====================================================================
// Child class inherits properties of parent using 'extends'.

class base_pkt;
  int id;
endclass

class axi_pkt extends base_pkt;
  int addr;
endclass

// HOW USED IN UVM:
// - uvm_driver extends uvm_component
// - uvm_sequence_item extends uvm_object
// WHEN USED:
// - When building reusable verification components.



//=====================================================================
// 4. POLYMORPHISM
//=====================================================================
// Base handle pointing to child object (runtime behavior).

class base_pkt;

  virtual function void display();
    $display("Base packet");
  endfunction

endclass

class child_pkt extends base_pkt;

  function void display();
    $display("Child packet");
  endfunction

endclass


base_pkt pkt;

initial begin
  pkt = new child_pkt();
  pkt.display();  // calls child version
end

// HOW USED IN UVM:
// - Factory overrides rely on polymorphism.
// - Base class handles point to extended UVM components.
// WHEN USED:
// - When selecting different implementations dynamically.



//=====================================================================
// 5. VIRTUAL METHODS
//=====================================================================
// Enables runtime method overriding (late binding).

class base_pkt;

  virtual function void display();
    $display("Base");
  endfunction

endclass

class child_pkt extends base_pkt;

  function void display();
    $display("Child");
  endfunction

endclass

// HOW USED IN UVM:
// - run_phase, build_phase are virtual methods.
// - Enables extensibility of UVM components.
// WHEN USED:
// - When child behavior must override base behavior in testbench flow.



//=====================================================================
// 6. PACKAGES
//=====================================================================
// Packages group related classes and prevent name conflicts.

package pkt_pkg;

class packet;
  int addr;
endclass

endpackage

import pkt_pkg::*;

// HOW USED IN UVM:
// - All UVM components are inside uvm_pkg.
// - Your TB components are grouped into packages.
// WHEN USED:
// - To organize verification environment modules cleanly.



//=====================================================================
// 7. INTERFACES
//=====================================================================
// Interface connects DUT and testbench signals.

interface bus_if;
  logic clk;
  logic reset;
  logic valid;
  logic ready;
endinterface

// HOW USED IN UVM:
// - Virtual interface passed to driver/monitor.
// - Connects SV signals to class-based UVM TB.
// WHEN USED:
// - When driving or sampling DUT signals.



//=====================================================================
// 8. RANDOMIZATION
//=====================================================================
// Generates automatic stimulus values using 'rand'.

class packet;
  rand bit [7:0] addr;
endclass

packet p;

initial begin
  p = new();
  p.randomize();
end

// HOW USED IN UVM:
// - Used in sequence items for stimulus generation.
// WHEN USED:
// - When creating constrained-random test scenarios.



//=====================================================================
// 9. CONSTRAINTS
//=====================================================================
// Restrict random values to valid ranges.

class packet;

  rand bit [7:0] addr;

  constraint addr_c {
    addr < 100;
    addr != 50;
  }

endclass

// HOW USED IN UVM:
// - Ensures valid protocol stimulus generation.
// WHEN USED:
// - When generating legal + corner-case test patterns.



//=====================================================================
// 10. MAILBOX
//=====================================================================
// Communication channel between processes.

mailbox mb = new();

initial begin
  int data;

  mb.put(10);   // sender
  mb.get(data); // receiver
end

// HOW USED IN UVM:
// - Rarely used in modern UVM (replaced by TLM).
// WHEN USED:
// - Basic SV communication learning / simple TBs.



//=====================================================================
// 11. EVENTS
//=====================================================================
// Used for synchronization between processes.

event done;

initial begin
  -> done;
end

initial begin
  @done;
end

// HOW USED IN UVM:
// - Used indirectly in phase synchronization.
// WHEN USED:
// - When coordinating parallel processes in TB.


//=====================================================================
// FINAL LINK TO UVM
//=====================================================================
// These SystemVerilog concepts are the foundation of UVM:
//
// class        → All UVM components
// object       → Factory-created components
// inheritance  → uvm_driver, uvm_env hierarchy
// polymorphism → factory overrides
// virtual      → run_phase/build_phase behavior
// interface    → DUT connectivity
// randomization→ stimulus generation
// constraints  → protocol correctness