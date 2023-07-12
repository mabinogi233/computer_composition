`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/27 18:05:55
// Design Name: 
// Module Name: controllX
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


module controllX(
    input reset,
	input clk,
	output regwrite,
	output regdst,
	output alusrc,
	output branch,
	output memWrite,
	output memtoReg,
	output [2:0] alucontroll,
	output [31:0] opInct
    );
    //

	wire [31:0] pcin;
	wire [31:0] pc;
	wire inst_ce;
	//PC计数器
    PCmodule mypcmodule(clk,reset,pcin,pc,inst_ce);
    
    //计数器加法
    addmodule myadd(pc,32'h4,pcin);
    
    //指令ROM
    blk_mem_gen_0 your_instance_name (
    .clka(clk),    // input wire clka
    .ena(inst_ce),      // input wire ena
    .addra(pc[9:2]),  // input wire [7 : 0] addra
    .douta(opInct)  // output wire [31 : 0] douta
    );
    //控制器
    Controller mycontrollerx(opInct[31:26],opInct[5:0],regwrite,regdst,alusrc,branch,memWrite,memtoReg,alucontroll);
    
    
endmodule


module MainDecoder(
	input [5:0] op,
	output reg regwrite,
	output reg  regdst,
	output reg  alusrc,
	output reg branch,
	output reg memWrite,
	output reg memtoReg,
	output reg [1:0] aluop
);
    always @(*)begin
        casex(op)
            6'b000000:begin
				regwrite<=1'b1;
				regdst<=1'b1;
				alusrc<=1'b0;
				branch<=1'b0;
				memWrite<=1'b0;
				memtoReg<=1'b0;
				aluop<=2'b10;	
			end	
			6'b100011:begin
				regwrite<=1'b1;
				regdst<=1'b0;
				alusrc<=1'b1;
				branch<=1'b0;
				memWrite<=1'b0;
				memtoReg<=1'b1;
				aluop<=2'b00;	
			end				
			6'b101011:begin
				regwrite<=1'b0;
				regdst<=1'b0;
				alusrc<=1'b1;
				branch<=1'b0;
				memWrite<=1'b1;
				memtoReg<=1'b0;
				aluop<=2'b00;	
			end			
			6'b000100:begin
				regwrite<=1'b0;
				regdst<=1'b0;
				alusrc<=1'b0;
				branch<=1'b1;
				memWrite<=1'b0;
				memtoReg<=1'b0;
				aluop<=2'b01;
			end				
			6'b001000:begin
				regwrite<=1'b1;
				regdst<=1'b0;
				alusrc<=1'b1;
				branch<=1'b0;
				memWrite<=1'b0;
				memtoReg<=1'b0;
				aluop<=2'b00;
			end					
			6'b000010:begin
				regwrite<=1'b0;
				regdst<=1'b0;
				alusrc<=1'b0;
				branch<=1'b0;
				memWrite<=1'b0;
				memtoReg<=1'b0;
				aluop<=2'b00;
			end	
			default:;	
		endcase
	end
endmodule


module aluController(
	input [1:0] aluop,
	input [5:0] op,
	output reg [2:0] alucontroll
);
	always @(*)begin
		casex({aluop,op})
			8'b10100000: alucontroll<=3'b010;
			8'b10100010:alucontroll<=3'b110;
			8'b10100100:alucontroll<=3'b000;
			8'b10100101:alucontroll<=3'b001;
			8'b10101010:alucontroll<=3'b111;
			8'b00xxxxxx:alucontroll<=3'b010;
			8'b01xxxxxx:alucontroll<=3'b110;
		endcase;
	end
endmodule


module Controller(
	input [5:0] op,
	input [5:0] funct,
	output regwrite,
	output regdst,
	output alusrc,
	output branch,
	output memWrite,
	output memtoReg,
	output [2:0] alucontroll
);
	wire [1:0] aluop;
	MainDecoder mydecoder(op,regwrite,regdst,alusrc,branch,memWrite,memtoReg,aluop);
	aluController myalucontroller(aluop,funct,alucontroll);
endmodule 




module PCmodule(
	input clk,
	input rst,
	input [31:0] pcin,
	output [31:0] pc,
	output inst_ce
);
	reg [31:0] pc;
	reg inst_ce;
	always @(posedge clk)begin
		if(rst)begin
			pc<=32'b00000000000000000000000000000000;
			inst_ce<=1'b0;
		end else begin
			pc<=pcin;
			inst_ce<=1'b1;
		end
	end
endmodule


module addmodule(
	input [31:0] pcin,
	input [31:0] jumpnum,
	output [31:0] pcout
);
	assign pcout = pcin + jumpnum;
endmodule
