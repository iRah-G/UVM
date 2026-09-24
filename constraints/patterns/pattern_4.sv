
/****
1. Write a constraint to generate the following pattern in an array
N=3: 1 11 111
N=4: 1 11 111 1111

2. Write a constraint to generate the following pattern in a 2D array
N=4:
[1]
[1, 1]
[1, 1, 1]
[1, 1, 1, 1]
****/

class packet_1#(parameter int N = 3);
     rand int unsigned array[];

     constraint c_array_sizr{
        array.size() == N;
     }

     constraint c_fill_array{

        foreach(array[i])
     }