// datapath.v
module datapath(
    input clk,
    input rst,
    input [3:0] in,         // 4-bit input used during input-loading phases
    input load_x,           // Load x from input
    input load_dx,          // Load dx from input
    input load_u,           // Load u from input
    input load_a,           // Load a from input
    input load_in,          // Load initial value for y (set y to 0 only once)
    input stage1,           // Control for Stage 1 operations
    input stage2,           // Control for Stage 2 operations
    input stage3,           // Control for Stage 3 operations
    input update_reg,       // Control to update registers with new computed values
    output reg signed [14:0] y,  // Output: computed y (final answer)
    output done,          // Registered done signal (from x_new)
    output init_done      // Combinational: true if initial x >= a
);

    // State registers (15-bit signed)
    reg signed [14:0] x, dx, u, a;
    // Temporary registers for scheduled operations (15-bit signed)
    reg signed [14:0] t1, t2, t3, t4, t5, t6, t7;
    // New computed values for next iteration (15-bit signed)
    reg signed [14:0] x_new, u_new, y_new;
    
    // Compute init_done combinationally: if x is not less than a, then no iteration should run.
    assign init_done = (x < a) ? 0 : 1;
    
    // Registered done signal computed using x_new.
    reg done_reg;
    always @(posedge clk or posedge rst) begin
        if (rst)
            done_reg <= 0;
        else if (update_reg)
            done_reg <= (x_new < a-1) ? 0 : 1;
    end
    assign done = done_reg;
    
    //--------------------------------------------------------------------------
    // Instantiate Multipliers and Adders for scheduled operations.
    // Stage 1 multiplications:
    //   t1 = u * dx, t2 = 3 * x, t3 = 3 * y, and t4 = u * dx.
    wire signed [14:0] mult_u_dx;
    multiplier mul0(.a(u), .b(dx), .product(mult_u_dx));
    
    wire signed [14:0] mult_3_x;
    multiplier mul1(.a(15'sd3), .b(x), .product(mult_3_x));
    
    wire signed [14:0] mult_3_y;
    multiplier mul2(.a(15'sd3), .b(y), .product(mult_3_y));
    
    // Stage 2 multiplications:
    //   t5 = t1 * t2, t6 = t3 * dx.
    wire signed [14:0] mult_t1_t2;
    multiplier mul3(.a(t1), .b(t2), .product(mult_t1_t2));
    
    wire signed [14:0] mult_t3_dx;
    multiplier mul4(.a(t3), .b(dx), .product(mult_t3_dx));
    
    // Stage 3 additions/subtractions:
    //   u_new = (u - t5) - t6, y_new = y + t4, x_new = x + dx.
    // For subtraction, we use the adder module with two's complement.
    wire signed [14:0] neg_t5;
    adder neg_adder1(.a(~t5 + 1), .b(15'd0), .sum(neg_t5));  // Compute -t5
    
    wire signed [14:0] sub_u_t5;
    adder adder0(.a(u), .b(neg_t5), .sum(sub_u_t5)); // u - t5
    
    wire signed [14:0] neg_t6;
    adder neg_adder2(.a(~t6 + 1), .b(15'd0), .sum(neg_t6));  // Compute -t6
    
    wire signed [14:0] u_new_wire;
    adder adder1(.a(sub_u_t5), .b(neg_t6), .sum(u_new_wire)); // (u - t5) - t6
    
    wire signed [14:0] add_y_t4;
    adder adder2(.a(y), .b(t4), .sum(add_y_t4)); // y + t4
    
    wire signed [14:0] add_x_dx;
    adder adder3(.a(x), .b(dx), .sum(add_x_dx));  // x + dx
    //--------------------------------------------------------------------------

    // Sequential block: input loading and scheduled arithmetic.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x      <= 0;   dx   <= 0;   u    <= 0;   a   <= 0;  
            y      <= 0;
            t1     <= 0;   t2   <= 0;   t3   <= 0;   t4  <= 0;
            t5     <= 0;   t6   <= 0;   t7   <= 0;
            x_new  <= 0;   u_new <= 0;   y_new <= 0;
        end else begin
            // Input loading phase.
            if (load_x)
                x <= {11'd0, in};  // Zero–extend the 4-bit input to 15 bits.
            if (load_dx)
                dx <= {11'd0, in};
            if (load_u)
                u <= {11'd0, in};
            if (load_a)
                a <= {11'd0, in};
            if (load_in)
                y <= 0;
            
            // Stage 1: Compute t1, t2, t3, t4 using the multiplier outputs.
            if (stage1) begin
                t1 <= mult_u_dx;
                t2 <= mult_3_x;
                t3 <= mult_3_y;
                t4 <= mult_u_dx;  // reuse u * dx for updating y
            end
            
            // Stage 2: Compute t5 and t6.
            if (stage2) begin
                t5 <= mult_t1_t2;  // t5 = t1 * t2
                t6 <= mult_t3_dx;  // t6 = t3 * dx
            end
            
            // Stage 3: Compute new values.
            if (stage3) begin
                t7    <= u - t5;       // (optional intermediate signal)
                u_new <= u_new_wire;    // u_new computed using adders
                y_new <= add_y_t4;      // y_new = y + t4
                x_new <= add_x_dx;      // x_new = x + dx
            end
            
            // Update registers with new computed values.
            if (update_reg) begin
                x <= x_new;
                u <= u_new;
                y <= y_new;
            end
        end
    end

endmodule
