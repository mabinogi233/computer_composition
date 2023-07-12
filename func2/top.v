`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/31 21:55:33
// Design Name: 
// Module Name: top
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
module fenpin(
    input clk,
    output newclk
);
reg oldclk = 1'b1;
reg [31:0] jishu = 32'b0;
always @(posedge clk)begin
    if(jishu == 100000000)begin
        oldclk <= ~oldclk;
        jishu <= 32'b0;
    end else begin
        jishu = jishu + 1;
    end
end  
assign newclk = oldclk;
endmodule

module topX(
    input reset,
	input clk,
	output [6:0]seg,
    output [7:0]ans,
    output [8:0]con
    );   
	wire regwrite;
	wire regdst;
	wire alusrc;
	wire branch;
	wire memWrite;
	wire memtoReg;
	wire [2:0] alucontroll;
	wire [31:0] opInct;	
	wire newclk;
	
	//fenpin fp(clk,newclk);
	
	//仿真不用分频，应该
	assign newclk = clk;
    controllX mycont(reset,newclk,regwrite,regdst,alusrc,branch,memWrite,memtoReg,alucontroll,opInct);
    
    assign con = {regwrite,regdst,alusrc,branch,memWrite,memtoReg,alucontroll};
    
    display mydis(clk,reset,opInct,seg,ans);
    
    
endmodule
