/*************************
You have 5 parallel tasks running. 
Once any 4 tasks complete, the 5th remaining task should be terminated. 
How would you implement this behavior using SystemVerilog?

Approach: Semaphore based approach
In this approach each process will put a key into the semaphore upon completion. 
A 6th parallel process monitors the semaphore/waits till it can collect 4 keys. Once it collects 4 keys, it disables the fork

*************************/
module parallel_tasks;

    semaphore sem = new(0); //Initialize with 0  keys at the start.
    // As each of the parallel processes complete, they will put a key. 
    //Monitor process checks if 4 keys are available. If yes, it will disable the fork
    initial begin
        fork: processes

            begin: process_1
                automatic int random_delay = $urandom_range(10,20);
                #(random_delay);
                sem.put(1);
                $display("[TIME: %0t], Process 1 completed", $time);
            end

            begin: process_2
                automatic int random_delay = $urandom_range(5,20);
                #(random_delay);
                sem.put(1);
                $display("[TIME: %0t], Process 2 completed", $time);
            end

            begin: process_3
                automatic int random_delay = $urandom_range(5,20);
                #(random_delay);
                sem.put(1);
                $display("[TIME: %0t], Process 3 completed", $time);
            end

            begin
    end

