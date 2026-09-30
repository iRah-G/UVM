/*
You have:

class packet;
    rand bit        write;
    rand bit [7:0]  addr;
    rand bit [31:0] data;
endclass
Write constraints such that:

When write == 1, addr must be word-aligned. Word aligned means multiple of 4 
When write == 0, data must be 0.
Follow-up: Why would you use -> or if/else for this?
*/

class packet;
    rand bit write;
    rand bit [7:0] addr;
    rand bit [31:0] data;

    constraint word_align{
        if (write == 1) begin
            addr % 4 == 0;
        end
        
        if (write == 0) begin
            data == 0;
        end

    }
endclass

module wordalign;

    packet p = new ();
    
    initial begin;
        repeat(5)
        if(p.randomize()) begin
            $display("Randomization successful write = %0b, addr = %0d, data = %0d ", p.write, p.addr, p.data);
        end
        else
        $display("Randomization has failed");

    end

endmodule

/* above can be also done with the implication operator
constraint c_write {
    write == 1 -> addr % 4 == 0;
    write == 0 -> data == 0;
}
*/
