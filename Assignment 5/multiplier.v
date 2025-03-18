// multiplier.v
module multiplier(
    input signed [14:0] a,
    input signed [14:0] b,
    output signed [14:0] product
);
    // Multiply two 15-bit numbers; the natural product is 30 bits.
    // We then take the lower 15 bits.
    wire signed [29:0] temp;
    assign temp = a * b;
    assign product = temp[14:0];  
endmodule
