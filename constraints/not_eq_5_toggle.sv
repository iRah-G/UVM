/*************
Write a constraint for two random variables such that one variable does not match
the other, and five bits are toggled.
*************/

class packet;

    rand bit [9:0] val;
    rand bit [9:0] prev_val;

    constraint_c_not_equal{
        prev_val != val ;
    }

    constraint_c_toggle{
        $countones(val) == 5;
        $countones(prev_val) == 5;
    }

endclass:packet

module not_equal_five_toggle;

    packet p = new();

    initial begin
        repeat(10) begin
            if(p.randomize()) begin
                $display("Randomization is successful --- Val1: %09b -- Val2: %09b", p.val, p.prev_val);
            end
            else $display("Randomization has failed");
        end
    end
endmodule: not_equal_five_toggle