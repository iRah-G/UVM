/***********************
Write a constraint to generate 5 to 15 numbers of power of 2. Without using inbuilt function
***********************/

class packet;

    // Array of powers of 2
    rand int array[];

    rand int random_number;
    rand int power_of_2val;

    constraint c_random_number{
        random_number inside {[0:10]};  //Generating a random number
    }

    constraint c_power_of_2{
        power_of_2val == 1 << random_number;
        solve random_number before power_of_2val; //shift by that random number's place to get onehot in 2s power
    }

    constraint c_array_size{
        array.size() inside {[5:15]}; //size required
    }

    constraint c_array_power_of_2{
        foreach(array[i]){
            array[i] ==1<<i; //without using the random number directly shifting by index size
        }
    }
    
endclass:packet

module test;
    packet p;
    initial begin
        p = new();
        repeat(10) begin
            if(p.randomize()) begin
                $display("%0d", p.power_of_2val);
                $display("----------");
                $display("%p",p.array);
        end
    end
    end
endmodule


// 1 << 2 100
// 1 << 3 1000