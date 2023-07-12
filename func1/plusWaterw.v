`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/26 22:14:23
// Design Name: 
// Module Name: plusWaterw
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


module plusWaterw(
    input [31:0] plusA,
    input [31:0] plusB,
    input clk,
    input [3:0] reset,
    input [3:0] stop,
    output [31:0] out,
    output c
    );
    reg c1;
    reg c2;
    reg c3;
    reg c4;
    reg [7:0] plus1;
    reg [15:0] plus2;
    reg [23:0] plus3;
    reg [31:0] plus4;
    
    reg [31:0] plusA2; 
    reg [31:0] plusA3;  
    reg [31:0] plusA4;   
    reg [31:0] plusB2;  
    reg [31:0] plusB3;  
    reg [31:0] plusB4;     
    

    
    always@(posedge clk)begin
        if(stop!=4'b0001 && stop!=4'b0010 && stop!= 4'b0100 && stop!=4'b1000)begin
            if(reset==4'b0001)begin
                plus1<=8'b00000000;
                c1<=1'b0;
            end else begin
                {c1,plus1}<={1'b0,plusA[7:0]} + {1'b0,plusB[7:0]};
                plusA2<=plusA;
                plusB2<=plusB;
            end    
        end else begin
              plus1<=plus1;
              c1<=c1;
        end   
    end
    
    always@(posedge clk)begin
        if(stop!=4'b0010 && stop!= 4'b0100 && stop!=4'b1000)begin
            if(reset==4'b0010)begin
                plus2<=8'b00000000;
                c2<=1'b0;
                plusA2<=32'h00;
                plusB2<=32'h00;
            end else begin 
                {c2,plus2}<={{1'b0,plusA2[15:8]} + {1'b0,plusB2[15:8]} + c1 , plus1};
                plusA3<=plusA2;
                plusB3<=plusB2;
            end
        end else begin
           plus2<=plus2;
           c2<=c2;
        end          
    end
    
    always@(posedge clk)begin
        if(stop!= 4'b0100 && stop!=4'b1000)begin
            if(reset==4'b0100)begin
                plus3<=8'b00000000;
                c3<=1'b0;
                plusA3<=32'h00;
                plusB3<=32'h00;
            end else begin
                {c3,plus3}<= {{1'b0,plusA3[23:16]} + {1'b0,plusB3[23:16]} + c2, plus2};
                plusA4<=plusA3;
                plusB4<=plusB3;
            end 
        end else begin
            plus3<=plus3;
            c3<=c3;
       end         
    end
    
    always@(posedge clk)begin
        if(stop!=4'b1000)begin
            if(reset==4'b1000)begin
                plus4<=8'b00000000;
                c4<=1'b0;
                plusA4<=32'h00;
                plusB4<=32'h00;
            end else begin
                {c4,plus4}<= {{1'b0,plusA4[31:24]} + {1'b0,plusB4[31:24]} + c3, plus3};
            end
        end else begin
            plus4<=plus4;
            c4<=c4;
        end         
    end
    
    assign out = plus4;
    assign c = c4;
    
endmodule
