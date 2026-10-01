//You have an 8-bit rand data variable. Can you write a constraint such that exactly 5 of the 8 bits are 1? 
//Now, we want these 5 bits of 1s to be consecutive.

class packet begin
    rand int [0:7]data;
    rand logic[1:0] shift_num;

  //  constraint c_five_ones {
  //       $countones(data) == 5;
  //  }

// To make those 5 bits consecutive we can take the bits 0001_1111 
// and shift left by 1, 2, or 3 times
// Lets use a random 2 bit value it can be between 0 and 3 
// and hence doesnt need to be constrained

   constraint c_shift{
        data == 8'b0001_1111 << shift_num;
    }
endclass

module test;

    packet p = new();
    initial begin
        repeat(10) begin
            if(p.randomize()) begin
                $display("data = %08b",p.data);
            end
        end
    end
endmodule