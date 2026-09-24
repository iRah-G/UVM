
// A fork join_none starts all the child processes but never waits for any of them to complete. 
// Hence, as the for loop executes, each iteration spawns a child process
// and immediately continues to the next iteration without waiting.

module automatic_fork_join;
    initial begin
        for (int i = 0; i < 5; i++) begin
            // automatic int j = i; //creates a separate copy of j for each iteration, j gets current i value
            fork
                begin
                    #10;
                    $display("Time: %0t | Driver ID: %0d active", $time, i);
                end
            join_none
        end
        wait fork; //Parent waits until all forked child processes finish. 
    end
endmodule
