Assertions (SVA - SystemVerilog Assertions)
Two kinds:

Immediate Assertions: Procedural, checked instantly like an if-statement, executed within initial/always blocks. No time advance.

Concurrent Assertions: Sampled on every clock edge, can span multiple cycles, defined outside procedural blocks using "property"/"assert property".

1. Immediate Assertions:

    always @(posedge clk) begin
        assert(a == b)
            $display("Passed");
        else
            $error("Mismatch: a=%0d b=%0d", a, b);
    end

    Executes like a normal if-else, zero simulation time, no temporal/clocking behavior.

2. Concurrent Assertions: Basic Syntax

    property prop_name;
        @(posedge clk) disable iff(!rst_n)
        a |-> b;
    endproperty

    assert property(prop_name);

    property = the temporal check.
    assert property = actually evaluates it and reports pass/fail.

3. assert / assume / cover

    assert property(p);   --> checks the property, fails simulation if violated
    assume property(p);   --> tells the tool/formal engine to treat this as always true (constrains inputs, doesn't check)
    cover property(p);    --> just records how many times the property was seen true (coverage, not a check)

4. Implication Operators (|-> and |=>)

    a |-> b;   --> Overlapped implication. If a is true, b must be true in the SAME cycle.
    a |=> b;   --> Non-overlapped implication. If a is true, b must be true in the NEXT cycle.

    Antecedent (a) is the trigger, consequent (b) is what must follow.
    If antecedent is false, the whole property is vacuously true (passes trivially).

5. Sequence Operators

    ##N     --> delay of N cycles       a ##2 b        (b is true 2 cycles after a)
    ##[M:N] --> delay range              a ##[1:3] b    (b true anywhere between 1 to 3 cycles after a)
    [*N]    --> consecutive repetition   a[*3]          (a true for 3 consecutive cycles)
    [*M:N]  --> consecutive repetition range
    [->N]   --> goto repetition (non-consecutive, N-th occurrence)
    [=N]    --> non-consecutive repetition, no requirement on final match

    and       --> both sequences must hold, can end at different times
    or        --> either sequence holds
    intersect --> both must hold AND end at the same time
    throughout--> a signal must stay true for the entire duration of a sequence
                  req throughout (a ##1 b ##1 c)
    within    --> one sequence occurs entirely within the time window of another

6. Sampling & Built-in Functions

    $rose(sig)    --> 1 if sig transitioned 0 -> 1 this cycle
    $fell(sig)    --> 1 if sig transitioned 1 -> 0 this cycle
    $stable(sig)  --> 1 if sig did NOT change from previous cycle
    $past(sig,N)  --> value of sig N cycles ago (default N=1)
    $changed(sig) --> 1 if sig value changed from previous cycle

7. disable iff

    property prop_name;
        @(posedge clk) disable iff(!rst_n)
        req |-> ##[1:3] gnt;
    endproperty

    Disables/aborts the assertion check whenever the condition is true (typically reset).
    Keeps the property from firing false failures during reset.

8. Local Variables in Sequences

    property addr_check;
        int addr;
        @(posedge clk)
        (req, addr = addr_in) |-> ##[1:5] (gnt && data == addr);
    endproperty

    Lets you capture a value at one point in the sequence and check it later — used to correlate request and response.

9. Multiclocking

    property p;
        @(posedge clk1) a ##1 @(posedge clk2) b;
    endproperty

    Each term in the sequence can sample on a different clock — used for CDC (clock domain crossing) checks.

10. Binding assertions to a module (bind)

    bind dut_module checker_module u_chk(.clk(clk), .a(a), .b(b));

    Attaches an assertion/checker module to a DUT module without modifying the DUT source. 
    Commonly used to attach SVA checker modules onto RTL from a separate verification-only file.

11. Sequence vs Property

    sequence: describes a pattern of events over time (building block)
    property: wraps a sequence with a pass/fail verdict (usually with an implication)

    sequence seq_ab;
        a ##1 b;
    endsequence

    property prop_ab;
        @(posedge clk) seq_ab |-> c;
    endproperty

***Important***
    Vacuous success: if the antecedent of |-> or |=> never becomes true, the assertion is considered PASSED by default (it was never actually exercised). This inflates pass counts silently — always pair assertions with cover property to confirm the antecedent actually triggered.

    assert property(p);
    cover property(a);   --> proves the trigger condition "a" was actually hit during simulation

    Negative/never-happen checks: 
    not (a ##1 b)         --> a followed by b must NEVER occur