module cla_4bit (
    input  [3:0] A,
    input  [3:0] B,  
    input        Cin,
    output [3:0] Sum,  
    output       Cout  
);
   
    wire [3:0] g = A & B;     
    wire [3:0] p = A ^ B;     

    wire c1, c2, c3;

    assign c1 = g[0] | (p[0] & Cin);

    assign c2 = g[1] | (p[1] & g[0]) | (p[1] & p[0] & Cin);

    assign c3 = g[2] 
              | (p[2] & g[1]) 
              | (p[2] & p[1] & g[0]) 
              | (p[2] & p[1] & p[0] & Cin);

    assign Cout = g[3] 
                | (p[3] & g[2]) 
                | (p[3] & p[2] & g[1]) 
                | (p[3] & p[2] & p[1] & g[0]) 
                | (p[3] & p[2] & p[1] & p[0] & Cin);

    assign Sum[0] = p[0] ^ Cin;
    assign Sum[1] = p[1] ^ c1;
    assign Sum[2] = p[2] ^ c2;
    assign Sum[3] = p[3] ^ c3;

endmodule
