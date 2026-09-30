/*
Write a SystemVerilog constraint for a 4-bit variable addr such that:

addr is between 4 and 12
addr can only take even values.

Then explain how your constraint works.
*/
shortint name = value;
class packet;

    rand int [3:0] addr;

    constraint btwn4_12 {
        addr inside {[4:12]};
    }

    constraint even{
        addr % 2 == 0;
    }
endclass

module btwn_even;
    packet p = new ();

    initial begin;
          repeat(10) begin
            if(p.randomize()) begin
                $display("Randomization is successful addr = %0d",p.addr);
            end
            else $display("Randomization has failed");
        end
    end
endmodule