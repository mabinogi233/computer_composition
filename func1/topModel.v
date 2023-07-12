`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/26 21:39:27
// Design Name: 
// Module Name: topModel
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


module topModel(
    input wire [7:0] ins,
    input wire [2:0] op,
    input wire clk,reset,
    output wire [6:0]seg,
    output [7:0] ans
    );
    
    reg [31:0] num2 = 32'h01;
    wire [31:0] num1 = {24'b0,ins[7:0]};
    wire [31:0] result;
    Myalu myalu(num1,num2,op,result);
    display mydis(clk,reset,result,seg,ans);
endmodule
