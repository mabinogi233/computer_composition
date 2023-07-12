`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/31 20:13:50
// Design Name: 
// Module Name: myCpu
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

module MainDecoder(
	input [31:0] instr,
	output reg regwrite,
	output reg  regdst,
	output reg  alusrc,
	output reg branch,
	output reg memWrite,
	output reg memtoReg,
	output reg [1:0] aluop,
	output reg jump
);
    wire [5:0] op;
    assign op = instr[31:26];
    always @(*)begin
        
        case(op)
            6'b000000:begin
				regwrite<=1'b1;
				regdst<=1'b1;
				alusrc<=1'b0;
				branch<=1'b0;
				memWrite<=1'b0;
				memtoReg<=1'b0;
				aluop<=2'b10;
				jump<=1'b0;	
			end	
			6'b100011:begin
				regwrite<=1'b1;
				regdst<=1'b0;
				alusrc<=1'b1;
				branch<=1'b0;
				memWrite<=1'b0;
				memtoReg<=1'b1;
				aluop<=2'b00;
				jump<=1'b0;		
			end				
			6'b101011:begin
				regwrite<=1'b0;
				regdst<=1'b0;
				alusrc<=1'b1;
				branch<=1'b0;
				memWrite<=1'b1;
				memtoReg<=1'b0;
				aluop<=2'b00;
				jump<=1'b0;		
			end			
			6'b000100:begin
				regwrite<=1'b0;
				regdst<=1'b0;
				alusrc<=1'b0;
				branch<=1'b1;
				memWrite<=1'b0;
				memtoReg<=1'b0;
				aluop<=2'b01;
				jump<=1'b0;	
			end				
			6'b001000:begin
				regwrite<=1'b1;
				regdst<=1'b0;
				alusrc<=1'b1;
				branch<=1'b0;
				memWrite<=1'b0;
				memtoReg<=1'b0;
				aluop<=2'b00;
				jump<=1'b0;	
			end					
			6'b000010:begin
				regwrite<=1'b0;
				regdst<=1'b0;
				alusrc<=1'b0;
				branch<=1'b0;
				memWrite<=1'b0;
				memtoReg<=1'b0;
				aluop<=2'b00;
				jump<=1'b1;	
			end	
			default:begin
			    regwrite<=1'b0;
				regdst<=1'b0;
				alusrc<=1'b0;
				branch<=1'b0;
				memWrite<=1'b0;
				memtoReg<=1'b0;
				aluop<=2'b00;
				jump<=1'b0;
			end	
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

//控制器核心
module Controller(
	input [31:0] instr,
	input zero,
	output memtoReg,
	output memWrite,
	output pcsrc,
	output alusrc,
	output regdst,
	output regwrite,
	output jump,
	output [2:0] alucontroll
);
	wire [1:0] aluop;
	wire branch;
	MainDecoder mydecoder(instr,regwrite,regdst,alusrc,branch,memWrite,memtoReg,aluop,jump);
	aluController myalucontroller(aluop,instr[5:0],alucontroll);
	assign pcsrc = branch & zero;	
endmodule 

module PCmodule(
	input clk,
	input rst,
	input en,
	input [31:0] pcin,
	output reg [31:0] pc
);
	always @(posedge clk,posedge rst)begin
		if(rst)begin
			pc<=32'b00000000000000000000000000000000;
		end else if(en) begin
			pc<=pcin;
		end
	end
endmodule

//加法器
module addmodule(
	input [31:0] pcin,
	input [31:0] jumpnum,
	output [31:0] pcout
);
	assign pcout = pcin + jumpnum;
endmodule


//ALU模块
module Myalu(
    input [31:0] A,
    input [31:0] B,
    input [2:0] op,
    output [31:0] C
    );
    reg [31:0] x;
        always @(*) begin
            case(op)
                3'b000:x<=A&B;
                3'b001:x<=A|B;
                3'b010:x<=A+B; 
                3'b011:;
                3'b100:x<=~A;
                3'b101:;
                3'b110:x<=A-B;
                3'b111:x<=(A<B?32'b00000000000000000000000000000001:32'b00000000000000000000000000000000);
                default:;
            endcase
        end 
        assign C = x;
endmodule

//有符号扩展16-32
module signext(
	input wire[15:0] a,
	output wire[31:0] y
    );
	assign y = {{16{a[15]}},a};
endmodule

//左移位模块
module sl2(
    input wire[31:0] a,
	output wire[31:0] y
    );
	assign y = {a[29:0],2'b00};
endmodule


//寄存器堆
module regfile(
	input wire clk,
	input wire we3,
	input wire[4:0] ra1,ra2,wa3,
	input wire[31:0] wd3,
	output wire[31:0] rd1,rd2
    );
	reg [31:0] rf[31:0];
	always @(posedge clk) begin
		if(we3) begin
			 rf[wa3] <= wd3;
		end
	end
	assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
	assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule

//二选一选择器
module mux2 #(parameter WIDTH = 8)(
	input wire[WIDTH-1:0] x1,x2,
	input wire a,
	output wire[WIDTH-1:0] y
    );
	assign y = a ? x2 : x1;
endmodule


module top(
	input wire clk,rst,
	output wire[31:0] writedata,dataadr,
	output wire memwrite
    );
	wire[31:0] pc,instr,readdata;
	mips mymips(clk,rst,pc,instr,memwrite,dataadr,writedata,readdata);
	inst_mem inst_ram (
        .clka(~clk),    // input wire clka
        .ena(1'b1),      // input wire ena
        .wea(4'b0000),      // input wire [3 : 0] wea
        .addra(pc[9:2]),  // input wire [7 : 0] addra
        .dina(32'b0),    // input wire [31 : 0] dina
        .douta(instr)  // output wire [31 : 0] douta
    );

	data_mem data_ram (
        .clka(~clk),    // input wire clka
        .ena(1'b1),      // input wire ena
        .wea({4{memwrite}}),      // input wire [3 : 0] wea
        .addra(dataadr[9:0]),  // input wire [9 : 0] addra
        .dina(writedata),    // input wire [31 : 0] dina
        .douta(readdata)  // output wire [31 : 0] douta
);
endmodule



module mips(
	input wire clk,rst,
	output wire[31:0] pc,
	input wire[31:0] instr,
	output wire memwrite,
	output wire[31:0] aluout,writedata,
	input wire[31:0] readdata 
    );
	wire memtoreg,alusrc,regdst,regwrite,jump,pcsrc,zero;
	wire[2:0] alucontrol;
	/*
	input [31:0] instr,
	input zero,
	output memtoReg,
	output memWrite,
	output pcsrc,
	output alusrc,
	output regdst,
	output regwrite,
	output jump,
	output [2:0] alucontroll
	*/
	Controller c(instr,zero,memtoreg,
		memwrite,pcsrc,alusrc,regdst,regwrite,jump,alucontrol);
	datapath dp(clk,rst,memtoreg,pcsrc,alusrc,
		regdst,regwrite,jump,alucontrol,zero,pc,instr,aluout,writedata,readdata);
endmodule

module datapath(
	input wire clk,rst,
	input wire memtoreg,pcsrc,
	input wire alusrc,regdst,
	input wire regwrite,jump,
	input wire[2:0] alucontrol,
	output wire zero,
	output wire[31:0] pc,
	input wire[31:0] instr,
	output wire[31:0] aluout,writedata,
	input wire[31:0] readdata
    );	
	
	/*
	module PCmodule
	input clk,
	input rst,
	input en,
	input [31:0] pcin,
	output reg [31:0] pc
	*/
	wire [31:0] pcpie;
	wire [31:0] pcnextpie;
	//PC计数器
	PCmodule mypc(clk,rst,1'b1,pcpie,pc);
	
	wire [31:0] pcplus4,pcbranch;
	wire [31:0] signimm,signimm2;
	
	mux2 #(32) mymux1(pcnextpie,{pcplus4[31:28],instr[25:0],2'b00},jump,pcpie);
	
	addmodule myadd1(pc,32'b100,pcplus4);
	
	sl2 mysl(signimm,signimm2);
	
	mux2 #(32) mymux2(pcplus4,pcbranch,pcsrc,pcnextpie);
	
	addmodule myadd2(pcplus4,signimm2,pcbranch);
		
	//寄存器堆
	wire [31:0] ra,rb;
	wire [4:0] writereg;
	wire [31:0] aluresult;
	regfile myregfile(clk,regwrite,instr[25:21],instr[20:16],writereg,aluresult,ra,writedata);
	//ALU模块
	mux2 #(32) mymux3(writedata,signimm,alusrc,rb);
	/*
	Myalu
    input [31:0] A,
    input [31:0] B,
    input [2:0] op,
    output [31:0] C
    */
	Myalu myalu(ra,rb,alucontrol,aluout);
	
	assign zero = (ra==rb)?1'b1:1'b0;
	
	signext mysign(instr[15:0],signimm);
	
	mux2 #(5) mymux4(instr[20:16],instr[15:11],regdst,writereg);
	
	mux2 #(32) mymux5(aluout,readdata,memtoreg,aluresult);	
endmodule