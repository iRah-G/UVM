/**********
Write a constraint where you have a 10 bit value bit [9:0] val where you’d want to randomize this to 
where every randomization would only allow 5 bits to differ from the previous randomization.
***********/

class packet;

    rand bit [9:0] val;
    bit [9:0] prev_val;

    constraint c_differ_by_five{
        $countones(val ^ prev_val) == 5;
    }

    function void post_randomize();
        prev_val = val;
    endfunction:post_randomize

endclass:packet

module differ_by_five;

    packet p = new();

    initial begin
        repeat(10) begin
            if(p.randomize()) begin
                $display("Randomization is successful");;
                $display("%010b", p.val);
            end
            else $display("Randomization has failed");
        end
    end

endmodule: differ_by_five

