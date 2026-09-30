/*
You have the following SystemVerilog class:

class packet;
    rand bit [7:0] addr;
    rand bit [7:0] data;
endclass

Normally, addr should be randomized over its full range, 0–255. However, for one particular test, you want addr to be restricted to 100–150.

How would you do this without modifying the original class constraint?

Answer

Use an inline constraint with randomize():
*/

class packet;

    rand bit [7:0] addr;
    rand bit [7:0] data;

endclass

module inline_constraint;

    packet p = new();

    initial begin
        
        repeat (5) begin

            if (p.randomize () with {
                addr inside {[100:150]};
            }) begin

                $display("Randomization successful: addr = %0d, data = %0d", p.addr, p.data);
            end
            else begin
                $display ("Randomizaton failed");
            end
        end
    end
endmodule

