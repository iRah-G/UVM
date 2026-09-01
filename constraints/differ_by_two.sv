/**********
Write a constraint where you have a 32 bit value bit [31:0] val where you’d want to randomize this to 
where every randomization would only allow 2 bits to differ from the previous randomization.
***********/
class packet;
    rand bit [31:0] val;
    bit [31:0] prev_val;

    constraint c_2bit_not_eq{
        $countones(val ^ prev_val) == 2;
    }

    function void post_randomize();
        prev_val = val;
    endfunction:post_randomize

endclass:packet

module differ_by_2;

    packet p = new();

    initial begin
        repeat (10) begin
            if(p.randomize()) begin
                $display("Randomized values = %04b", p.val);
            end
            else $display("Randomization failed");
        end    
    end

endmodule:differ_by_2


/* Use this as reference = xor gives difference, if differ by 2 then

$countones ( a ^ b ) == differ by number

1011
1101
0110

11111111
10010010
01101101

*/