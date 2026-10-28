/* Create bit [7:0] addr. Constrain addr to be between 16 and 100, and divisible by 4.*/

class packet p;

    rand bit [7:0] addr;

    constraint c_addr{
        addr inside{[7:0]};
    }

    constraint c_div_four{
        addr % 4 == 0;
    }
    
endclass