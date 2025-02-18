`timescale 1ns / 1ps

module upDownCounter_tb;

    reg clk;
    reg reset;
    reg set;
    reg up;
    reg [3:0] value;

    wire [3:0] counter;

    upDownCounter uut (
        .clk(clk),
        .reset(reset),
        .set(set),
        .up(up),
        .value(value),
        .counter(counter)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        set = 0;
        up = 1;
        value = 4'b0000;

        #10 reset = 0;

        #50;

        set = 1;
        value = 4'b0111;
        #10 set = 0;

        #200;

        set = 1;
        value = 4'b0010;
        #10 set = 0;

        #50;

        reset = 1;
        #10 reset = 0;

        #50;

        up = 0;

        #20;
        
        reset=1;
        #10 reset=0;
        
        #100 up=1;
        $finish;
    end

endmodule
