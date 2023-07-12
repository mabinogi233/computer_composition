`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/26 21:15:45
// Design Name: 
// Module Name: Myalu
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


module Myalu(
    input [31:0] A,
    input [31:0] B,
    input [2:0] op,
    output [31:0] C
    );
    reg [31:0] x;
        always @(*) begin
            case(op)
                3'b000:x<=A+B; 
                3'b001:x<=A-B;
                3'b010:x<=A&B;
                3'b011:x<=A|B;
                3'b100:x<=~A;
                3'b101:x<=(A<B?32'b00000000000000000000000000000001:32'b00000000000000000000000000000000);
                3'b110:;
                3'b111:;
                default:;
            endcase
        end 
        assign C = x;
    
endmodule
