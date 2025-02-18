module fulladder
    ( input  a,
      input  b,
      input  cin,
      output sum,
      output carry
    );  
  
  assign sum   = a ^ b ^ cin;
  assign carry = (a & b) | (b & cin) | (a & cin);

endmodule


module CSA_32bit(
    input  [31:0] x,
    input  [31:0] y,
    input  [31:0] z,
    output [32:0] s,
    output        cout
);
  wire [31:0] s1;
  wire [31:0] c1;
  
  genvar i;
  generate
    for(i = 0; i < 32; i = i + 1) begin: stage1
      fulladder FA_stage1 (
         .a(x[i]),
         .b(y[i]),
         .cin(z[i]),
         .sum(s1[i]),
         .carry(c1[i])
      );
    end
  endgenerate

  wire [31:1] c2;
  
  fulladder FA_stage2_1 (
      .a(s1[1]),
      .b(c1[0]),
      .cin(1'b0),
      .sum(s[1]),
      .carry(c2[1])
  );
  
  generate
    for(i = 2; i < 32; i = i + 1) begin: stage2
      fulladder FA_stage2 (
         .a(s1[i]),
         .b(c1[i-1]),
         .cin(c2[i-1]),
         .sum(s[i]),
         .carry(c2[i])
      );
    end
  endgenerate

  fulladder FA_final (
      .a(1'b0),
      .b(c1[31]),
      .cin(c2[31]),
      .sum(s[32]),
      .carry(cout)
  );

  assign s[0] = s1[0];
endmodule