`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.02.2024 11:47:28
// Design Name: 
// Module Name: upDownCounter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

 
module mux(
    input a,
    input b,
    input select,
    output y
);
    assign y = (select == 0) ? a : b;
endmodule

module jkFF(j,k,clk,Q,Q_bar);
    input j,k,clk;
    output reg Q,Q_bar;
    
        always@(posedge clk)
              begin
                case({j,k})
                2'b00:{Q,Q_bar}<={Q,Q_bar};
                2'b01:{Q,Q_bar}<={1'b0,1'b1};
                2'b10:{Q,Q_bar}<={1'b1,1'b0};
                2'b11:{Q,Q_bar}<={~Q,Q};
                default:begin end
                endcase
             end          
endmodule
    
module upDownCounter(
    input clk,
    input reset,
    input set,
    input up,
    input [3:0] value,
    output [3:0] counter
    );

    wire reset_bar=~reset;
    
    wire w1,w2;
    mux m1(1,value[0], set,w1);
    mux m2(1,~value[0], set,w2);
    
    wire w3,w4;
    assign w3=(reset_bar&w1);
    assign w4=(reset|w2);
    
    wire Q0, Q0_bar;
    jkFF FF1(w3,w4,clk, counter[0], Q0_bar);
    
    wire w5,w6,w7;
    mux m3(Q0_bar, counter[0], up,w5);
    mux m4(w5, value[1], set, w6);
    mux m5(w5, ~value[1], set, w7);
    
    wire w22,w8;
    assign w22=(w6&reset_bar);
    assign w8=(w7|reset);
    
    wire Q1,Q1_bar;
    jkFF FF2(w22,w8,clk,counter[1],Q1_bar);
    wire w9,w10,w11,w12;
    mux m6(Q1_bar, counter[1], up, w9);
    assign w10=(w9&w5);
    
    mux m7(w10,value[2],set, w11);
    mux m8(w10, ~value[2], set, w12);
    
    wire w13,w14;
    wire Q2, Q2_bar;
    assign w13=(w11&reset_bar);
    assign w14=(w12|reset);
   
   jkFF FF3(w13,w14,clk,counter[2],Q2_bar);
   
   wire w15,w16,w17,w18;
   
   mux m9(Q2_bar, counter[2], up, w15);
   assign w16=(w15&w10);
   mux m10(w16, value[3],set,w17);
   mux m11(w16, ~value[3], set, w18);
   
   wire w19,w20;
   wire Q3,Q3_bar;
   assign w19=(w17&reset_bar);
   assign w20=(w18|reset);
   
   jkFF FF4(w19,w20,clk,counter[3],Q3_bar);
    
endmodule
