/**************************
Write a constraint to generate two dynamic arrays such that array1 size = [6:9], array2 size = array1 size. 
Array 1 should be assembled in ascending order while array2 should have all the values picked from array1
**************************/

class packet;
    rand int unsigned array1[];
    rand int unsigned array2[];

    constraint c_array1_size{
        array1.size() inside {[6:9]};
    }

    constraint c_array_values{
        foreach(array1[i]){
        array1[i]<=100; //To make sure the array values are less than 100
        }
    }

    constraint c_arraay2_size{
        array2.size() == array1.size();
    }

    constraint c_array1_ascending{
       foreach(array1[i]){
        if(i>0){
        array1[i] >= array1[i-1];
        }
       }
    }

    constraint c_array2_equals_array1{
        foreach(array1[i]){
            array2[i] == array1[i];
        }
    }
endclass

module test;

    packet p = new();

    initial begin
        repeat(5) begin
            if(p.randomize()) begin
                $display("Randomization successful array1 = %p",p.array1);
                $display("------------------------ array2 = %p",p.array2);
            end
            else begin
                $display("Randomization failed!");
            end
        end
    end
endmodule