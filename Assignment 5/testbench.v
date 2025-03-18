// testbench.v
`timescale 1ns/1ps
module testbench;
    // Inputs to the design
    reg clk;
    reg rst;
    reg [3:0] in;
    reg ready;
    reg s1, s2, s3, s4;
    
    // Output from the design (15-bit signed)
    wire signed [14:0] out;
    wire valid;
    
    // Instantiate the top-level module
    func_fsm uut (
        .clk(clk),
        .rst(rst),
        .in(in),
        .ready(ready),
        .s1(s1),
        .s2(s2),
        .s3(s3),
        .s4(s4),
        .out(out),
        .valid(valid)
    );
    
    // Clock generation: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Dump waveforms for debugging (optional)
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, testbench);
    end
    
    // Test stimulus
    initial begin
        // Initialize signals
        rst = 1;
        in = 4'd0;
        ready = 0;
        s1 = 0;
        s2 = 0;
        s3 = 0;
        s4 = 0;
        
        // Hold reset
        #20;
        rst = 0;
        
        // Load inputs sequentially:
        // Load x = 1 using s1
        in = 4'd1;
        s1 = 1;
        #10;
        s1 = 0;
        
        // Load dx = 1 using s2
        #10;
        in = 4'd1;
        s2 = 1;
        #10;
        s2 = 0;
        
        // Load u = 5 using s3
        #10;
        in = 4'd5;
        s3 = 1;
        #10;
        s3 = 0;
        
        // Load a = 6 using s4
        #10;
        in = 4'd6;
        s4 = 1;
        #10;
        s4 = 0;
        
        // Wait a cycle and assert ready to start computation
        #10;
        ready = 1;
        #10;
        ready = 0;
        
        // Wait until computation is finished
        wait(valid == 1);
        $display("Final output y = %d", out);
        
        #20;
        $finish;
    end

endmodule
