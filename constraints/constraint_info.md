Rand(rand)
Standard Randomization: Each randomization is independent of the previous one. 

randc: Cyclic randomization. Randomizes through all possible values in the range before repeating any value. 

1. Constraints: constraints are defined using "constraint" keyword.

class Packet;
    rand bit[3:0] length;
    rand bit[7:0] payload_sizel

    constraint valid_length{
        length > 10;
        length <= 50;
        payload_size == length -4;
    }

2. Basic Constraint Syntax: 

    constraint name_of_constraint {

        length >= 10;
        payload_size = 15;

    }

    Basic constraint just uses the mathematical operations. 

3. Set membership(inside)

    src_adder inside {5,10,15, [10:12]}
    !(src-add inside {54,55})

    ! --> means not inside

4. Distribution Constraints(dist)

    Operators
    1.  := Weight is applied individually to every item in the range
        (it means each item gets the same specified weight)

    2. :/ Weight is divided equally across the range
        [1:3] := 10  --> 1 gets weight 10, 2 gets weight 10, 3 gets weight 10
        [1:3] :/ 10 --> 1 gets weight 3, 2 gets weight 3, 3 gets weight 3


5. Conditional Constraints

    Operator : -->
        {type == SINGLE} --> {length == 1}

        if(condition ){
          constraint
        }
        else {
            constraint
        }

6. Inline constraints

    pkt.randomize( ) with {length == 50;}

    soft vs hard constraints

    Hard Constraints : These are mandatory laws. If hard constraint cannot be satisfied, the randmoize method will return 0. 
    All constraints are hard constraints by default. 

    Soft Constraints: These can be overridden by the inline constraints because they have more priority. 

    randc : Cyclic randomization
    Must return every possibele value within the range exactly once in a pseudo-random order. 

    ***Important***
        arr.sum with (int '(item == arr [i])) == 1
        This basically means that the total count of values with value arr[i] should only be one. 

        In other words, there should only be one value/unique value of arr[i]

        arr.sum( ) with (int '(item == arr[i])) == 1