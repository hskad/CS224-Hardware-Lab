module tb_CSA_32bit();
  reg  [31:0] x, y, z;
  wire [32:0] s;
  wire        cout;
  
  CSA_32bit uut (
      .x(x),
      .y(y),
      .z(z),
      .s(s),
      .cout(cout)
  );
  
  initial begin
      x = 32'h2;  y = 32'h3;       z = 32'ha;       #10;
      $display("Test1: Sum = %h, Cout = %h", s, cout);
      x = 32'hFFFFFFFF; y = 32'h1;  z = 32'h0;       #10;
      $display("Test2: Sum = %h, Cout = %h", s, cout);
      x = 32'hAAAA5555; y = 32'h5555AAAA; z = 32'hF0F0F0F0; #10;
      $display("Test3: Sum = %h, Cout = %h", s, cout);
      x = 32'h12345678; y = 32'h87654321; z = 32'hFEDCBA98; #10;
      $display("Test4: Sum = %h, Cout = %h", s, cout);
      x = 32'h0; y = 32'h0;         z = 32'h0;       #10;
      $display("Test5: Sum = %h, Cout = %h", s, cout);
      $finish;
  end
endmodule
