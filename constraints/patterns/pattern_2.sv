/******
123451234512345.....
******/

class packet;
    rand int arr [0:31];
    constraint c_12345{
        foreach(arr[i]) {
            arr[i] == (i % 5) +1;
        }
    }
endclass

module pattern_2;
    packet p = new();

    initial begin
        repeat(1) begin
            if (p.randmoize()) begin
                $display("Randomization is successful: %p", p.arr);
            end
            else $display("Randomization has failed");
        end
    end
endmodule
