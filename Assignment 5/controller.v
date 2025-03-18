// controller.v
module control_path(
    input clk,
    input rst,
    input ready,          // External signal to start computation
    input s1, s2, s3, s4,  // Signals for sequentially loading inputs
    input done,           // From datapath: indicates when x_new >= a
    input init_done,      // True if initial x >= a
    output reg load_x,
    output reg load_dx,
    output reg load_u,
    output reg load_a,
    output reg load_in,   // To initialize y once
    output reg stage1,    // Control signal for Stage 1
    output reg stage2,    // Control signal for Stage 2
    output reg stage3,    // Control signal for Stage 3
    output reg update_reg,// Control signal to update registers
    output reg valid     // Asserted when final output is ready
);

    // FSM states
    localparam IDLE       = 4'd0,
               READ_X     = 4'd1,
               READ_DX    = 4'd2,
               READ_U     = 4'd3,
               READ_A     = 4'd4,
               WAIT_READY = 4'd5,
               S1         = 4'd6,
               S2         = 4'd7,
               S3         = 4'd8,
               UPDATE     = 4'd9,
               CHECK      = 4'd10,
               DONE       = 4'd11;
               
    reg [3:0] state;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            load_x      <= 0;
            load_dx     <= 0;
            load_u      <= 0;
            load_a      <= 0;
            load_in     <= 0;
            stage1      <= 0;
            stage2      <= 0;
            stage3      <= 0;
            update_reg  <= 0;
            valid       <= 0;
        end else begin
            // Deassert all control signals by default.
            load_x     <= 0;
            load_dx    <= 0;
            load_u     <= 0;
            load_a     <= 0;
            load_in    <= 0;
            stage1     <= 0;
            stage2     <= 0;
            stage3     <= 0;
            update_reg <= 0;
            valid      <= 0;
            
            case (state)
                IDLE: begin
                    if (s1) begin
                        load_x <= 1;
                        state  <= READ_DX;
                    end
                end
                
                READ_DX: begin
                    if (s2) begin
                        load_dx <= 1;
                        state   <= READ_U;
                    end
                end
                
                READ_U: begin
                    if (s3) begin
                        load_u <= 1;
                        state  <= READ_A;
                    end
                end
                
                READ_A: begin
                    if (s4) begin
                        load_a <= 1;
                        state  <= WAIT_READY;
                    end
                end
                
                WAIT_READY: begin
                    load_in <= 1;  // Initialize y to 0
                    if (ready) begin
                        // If the initial condition is already met (x >= a), skip iterations.
                        if (init_done == 1)
                            state <= DONE;
                        else
                            state <= S1;
                    end
                end
                
                S1: begin
                    stage1 <= 1;  // Execute Stage 1 operations
                    state  <= S2;
                end
                
                S2: begin
                    stage2 <= 1;  // Execute Stage 2 operations
                    state  <= S3;
                end
                
                S3: begin
                    stage3 <= 1;  // Execute Stage 3 operations
                    state  <= UPDATE;
                end
                
                UPDATE: begin
                    update_reg <= 1;  // Update registers (x, u, y)
                    state      <= CHECK;
                end
                
                CHECK: begin
                    if (done)
                        state <= DONE;
                    else
                        state <= S1;
                end
                
                DONE: begin
                    valid <= 1;  // Final result is ready; if x >= a initially, y remains 0.
                    // Remain in DONE state.
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule
