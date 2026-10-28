/*
- Constrained-random transaction generator
  Write a class containing:
- bit [7:0] addr
- bit [31:0] data
- bit write
Constraints:
- Address must be between 0 and 255.
- Address must be 4-byte aligned.
- If write == 0, data must equal zero.
- Generate 10 random transactions.
*/

class packet;

    bit[7:0] addr;
    bit[31:0] data;
    bit write;

    constraint c_addr_range{
        addr inside{[0:255]};
    }

    constraint c_addr_align{
        addr % 4 == 0;
    }

    constraint c_write_data{
        if(write == 0){
            data == 0;
        }
    }

endclass

module test;

    packet p = new();

    initial begin;
        repeat(10) begin
            if(p.randomize()) begin
                $display("Randomization successful addr = %0d, data = %0d", p.addr, p.data);
            end
            else
                $display("ERROR:Randomization failed");
        end
    end

endmodule