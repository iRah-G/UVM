/************
For a 8 bit variable if the past randomization resulted in a odd value, 
the next randomization should be even with 75% probability else be even with 25% probability. Write a constraint
************/
class packet;

    rand bit [7:0] val;
    rand bit [7:0] prev_val;

    constraint c_odd_even_dist{
        if(prev_val[0] == 1){
            val[0] dist{
                0 := 75,
                1 := 25
            };
        }
        else {
            val[0] dist{
                0 := 25,
                1 := 75
            };
        }
        
    }

    function void post_randomize();
        prev_val = val;
    endfunction:post_randomize
endclass:packet

module test;
    packet p;

    initial begin
        p = new();
        repeat (10) begin
            if(p.randomize()) begin
                $display("----- Randomization successful: Value = %08b ----- ", p.val);
            end
            else $display(" ----- Randomization failed -----");
        end
    end
endmodule:test

