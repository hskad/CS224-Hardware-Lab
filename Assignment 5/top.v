// top.v
module func_fsm(
    input clk,
    input rst,
    input [3:0] in,   // 4-bit input for loading values
    input ready,      // Signal to start iterative computation after inputs are loaded
    input s1, s2, s3, s4, // Signals to load x, dx, u, a respectively
    output signed [14:0] out, // Final output y (15-bit)
    output valid     // High when computation is complete
);

    // Wires for connecting datapath and controller.
    wire load_x, load_dx, load_u, load_a, load_in;
    wire stage1, stage2, stage3, update_reg;
    wire done;
    wire init_done; // initial condition check
    wire signed [14:0] y;
    
    // Instantiate datapath.
    datapath dp (
        .clk(clk),
        .rst(rst),
        .in(in),
        .load_x(load_x),
        .load_dx(load_dx),
        .load_u(load_u),
        .load_a(load_a),
        .load_in(load_in),
        .stage1(stage1),
        .stage2(stage2),
        .stage3(stage3),
        .update_reg(update_reg),
        .y(y),
        .done(done),
        .init_done(init_done)
    );
    
    // Instantiate controller.
    control_path ctrl (
        .clk(clk),
        .rst(rst),
        .ready(ready),
        .s1(s1),
        .s2(s2),
        .s3(s3),
        .s4(s4),
        .done(done),
        .init_done(init_done),
        .load_x(load_x),
        .load_dx(load_dx),
        .load_u(load_u),
        .load_a(load_a),
        .load_in(load_in),
        .stage1(stage1),
        .stage2(stage2),
        .stage3(stage3),
        .update_reg(update_reg),
        .valid(valid)
    );
    
    assign out = y;
    
endmodule
