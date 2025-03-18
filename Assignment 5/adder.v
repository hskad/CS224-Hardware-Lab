// adder.v
module adder(
    input signed [14:0] a,
    input signed [14:0] b,
    output signed [14:0] sum
);
    assign sum = a + b;
endmodule
