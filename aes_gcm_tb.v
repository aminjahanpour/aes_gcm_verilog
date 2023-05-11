
`timescale 1ps/1ps
`default_nettype none
`define DUMPSTR(x) `"x.vcd`"


module soc_tb ();



    reg                                                     clk;
    reg                                                     reset;
    wire                                                    finished;



    soc soc_inst (
        .clk(clk),
        .reset(reset),
        .finished(finished)
    );


    always #1 clk = ~clk;


    parameter DURATION = 3_100_000;

    initial begin
        clk = 0;

        #1;
        $display("\n running...");

        reset = 0;
        #1;
        reset = 1;
        
    end


    initial begin

        #(DURATION);
        $display("End of simulation at:%d", $time);
        $finish;

    end


    endmodule

