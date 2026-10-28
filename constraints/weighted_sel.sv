/* 
Create bit [1:0] mode. Randomize it so that:
- Mode 0 has weight 60.
- Mode 1 has weight 30.
- Mode 2 has weight 10.
- Mode 3 is not allowed.

*/

class packet p;

    rand bit [1:0] mode;

    constraint c_mode{
        mode dist{
            00 := 60;
            01 := 30;
            10 := 10;
            11 := 0;
        }
    }
endclass

module test;

    packet p = new();

    initial begin
        repeat(5) begin
            if(p.randomize()) begin
                $display("Randomization pass mode = %0b", p.mode);
            else
                $display("Randomization failed");
            end
        end
    end
endmodule