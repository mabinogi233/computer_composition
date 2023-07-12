`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/27 19:36:56
// Design Name: 
// Module Name: myCPU
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
	output [2:0] alucontroll,
	output branch
);
	wire [1:0] aluop;
	//wire branch;
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
	always @(negedge clk) begin
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


//三选一选择器
module mux3 #(parameter WIDTH = 8)(
	input wire[WIDTH-1:0] x1,x2,x3,
	input wire [1:0] a,
	output reg [WIDTH-1:0] y
    );
	always @(*) begin
	   case(a)
	       2'b00:y<=x1;
	       2'b01:y<=x2;
	       2'b10:y<=x3;
	   endcase    
	end
endmodule


//寄存器
module flopr #(parameter WIDTH = 8)(
	input wire clk,rst,
	input wire [WIDTH-1:0] in,
	output reg [WIDTH-1:0] out
    );
	always @(posedge clk,posedge rst) begin
	   if(rst)begin
	       out<=0; 
	   end else begin
	       out<=in;
	   end
	end
endmodule

module floprc #(parameter WIDTH = 8)(
	input wire clk,rst,clear,
	input wire [WIDTH-1:0] in,
	output reg [WIDTH-1:0] out
    );
	always @(posedge clk,posedge rst) begin
	   if(rst)begin
	       out<=0; 
	   end else if(clear) begin
	       out<=0; 
	   end else begin
	       out<=in;
	   end
	end
endmodule

module flopenrc #(parameter WIDTH = 8)(
	input wire clk,rst,en,clear,
	input wire [WIDTH-1:0] in,
	output reg [WIDTH-1:0] out
    );
	always @(posedge clk,posedge rst) begin
	   if(rst)begin
	       out<=0; 
	   end else if(clear) begin
	       out<=0; 
	   end else if(en) begin
	       out<=in;
	   end
	end
endmodule

module flopenr #(parameter WIDTH = 8)(
	input wire clk,rst,en,
	input wire [WIDTH-1:0] in,
	output reg [WIDTH-1:0] out
    );
	always @(posedge clk,posedge rst) begin
	   if(rst)begin
	       out<=0; 
	   end else if(en) begin
	       out<=in;
	   end
	end
endmodule


module mips(
	input wire clk,rst,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire memwriteM,
	output wire[31:0] aluout,writedata,
	input wire[31:0] readdata
    );

	wire memtoregD,alusrcD,regdstD,regwriteD,pcsrcD,zeroD,memwriteD;
	wire[2:0] alucontrolD;
	wire [31:0] instrD;
	wire jumpD;
	wire branchD;
    //控制器


	Controller c(instrD,zeroD,memtoregD,
		memwriteD,pcsrcD,alusrcD,regdstD,regwriteD,jumpD,alucontrolD,branchD);
    //数据链路
	datapath dp(    
	.clk(clk),
	.rst(rst),
    .instrF(instrF),
    .instrD(instrD),
    .jumpD(jumpD),
    .regwriteD(regwriteD),
    .memtoregD(memtoregD),
    .memwriteD(memwriteD),
    .alucontrollD(alucontrolD),
    .alusrcD(alusrcD),
    .regdstD(regdstD),
    .pcsrcD(pcsrcD),
    .zero(zeroD),
    .pcF(pcF),
    .aluoutM(aluout),
    .writedataM(writedata),
    .readdataM(readdata),
    .branchD(branchD),
    .memwriteM(memwriteM)
    );
endmodule

//顶层
module top(
	input wire clk,rst,
	output wire[31:0] writedata,dataadr,
	output wire memwrite,
	output [31:0] instr
    );
	wire[31:0] pc,readdata;
	//CPU核心
	mips mips(clk,rst,pc,instr,memwrite,dataadr,writedata,readdata);
	//存储层
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







//数据链路
module datapath(
    input wire clk,rst,
    input wire [31:0] instrF,
    output wire [31:0] instrD,
    input wire jumpD,
    input wire regwriteD,memtoregD,memwriteD,
    input wire [2:0] alucontrollD,
    input wire alusrcD,regdstD,
    input wire branchD,
    input wire pcsrcD,
    output wire zero,
    output wire[31:0] pcF,
    output wire [31:0] aluoutM,writedataM,
    input wire [31:0] readdataM,
    output wire memwriteM
    );
    //第一级
    wire [31:0] pcpie;
    wire startIF; //链接冒险模块
    wire [31:0] pcplus4F;
    wire [31:0] pcbranchD;
    wire startID;//链接冒险模块
    wire [31:0] pcplus4D;
    wire [31:0] resultW;
    wire regwriteW;//第五级
    wire [4:0] writeregW;//第五级
    wire [31:0] rd1D;
    wire [31:0] rd2D;
    wire [31:0] newrd1D,newrd2D;
    wire [31:0] signlmmD;
    wire [31:0] signlmmD2;
    wire startIE;
    wire [4:0] rsE,rtE,rdE;
    wire regwriteE,memtoregE,memwriteE,alusrcE,regdstE;
    wire [2:0] alucontrollE;
    wire [31:0] rd1E;
    wire [31:0] rd2E;
    wire [31:0] signlmmE;
    wire [31:0] srcAE;
    wire [1:0] forwardAE;
    wire [1:0] forwardBE;
    wire [31:0] writedataE;
    wire regwriteM,memtoregM;
    wire [4:0] writeregE,writeregM;
    wire [31:0] aluoutE;
    wire [31:0] srcBE;
    wire [31:0] readdataW,aluoutW;
    wire forwardAD,forwardBD;
    wire memtoregW;
    wire [31:0] pcnextbrFD;
    
    PCmodule mypcmodule(.clk(clk),.rst(rst),.en(~startIF),.pcin(pcpie),.pc(pcF));
    
    mux2 #(32) numux1(.x1(pcplus4F),.x2(pcbranchD),.a(pcsrcD),.y(pcnextbrFD));
    
    mux2 #(32) numux2(pcnextbrFD,{pcplus4D[31:28],instrD[25:0],2'b00},jumpD,pcpie);
    
    addmodule myadd1(.pcin(pcF),.jumpnum(32'h4),.pcout(pcplus4F));
    //第一级门

    flopenrc #(32) flopenrc_1(clk,rst,~startID,pcsrcD,pcplus4F,pcplus4D);
	flopenrc #(32) flopenrc_2(clk,rst,~startID,pcsrcD,instrF,instrD);

    regfile myregfile(.clk(clk),.we3(regwriteW),.ra1(instrD[25:21]),.ra2(instrD[20:16]),.wa3(writeregW),.wd3(resultW),.rd1(rd1D),.rd2(rd2D));
    
    signext mysignnext(.a(instrD[15:0]),.y(signlmmD));

    sl2 mysl2_1(.a(signlmmD),.y(signlmmD2));
    
    addmodule myadd2(.pcin(signlmmD2),.jumpnum(pcplus4D),.pcout(pcbranchD));
    
    mux2 #(32) numux3(rd1D,aluoutM,forwardAD,newrd1D);

	mux2 #(32) numux4(rd2D,aluoutM,forwardBD,newrd2D);
    
    assign zero = (newrd1D==newrd2D)?1'b1:1'b0;
    
    //第二级门
    floprc #(1) flopenrc_5(clk,rst,startIE,regwriteD,regwriteE);
    floprc #(1) flopenrc_6(clk,rst,startIE,memtoregD,memtoregE);
    floprc #(1) flopenrc_7(clk,rst,startIE,memwriteD,memwriteE);
    floprc #(3) flopenrc_8(clk,rst,startIE,alucontrollD,alucontrollE);
    floprc #(1) flopenrc_9(clk,rst,startIE,alusrcD,alusrcE);
    floprc #(1) flopenrc_10(clk,rst,startIE,regdstD,regdstE);
    floprc #(32) flopenrc_11(clk,rst,startIE,rd1D,rd1E);
    floprc #(32) flopenrc_13(clk,rst,startIE,rd2D,rd2E);
    floprc #(5) flopenrc_14(clk,rst,startIE,instrD[25:21],rsE);
    floprc #(5) flopenrc_15(clk,rst,startIE,instrD[20:16],rtE);
    floprc #(5) flopenrc_16(clk,rst,startIE,instrD[15:11],rdE);
    floprc #(32) flopenrc_17(clk,rst,startIE,signlmmD,signlmmE);
    
    //第三级
    mux3 #(32) mymux3_1(.x1(rd1E),.x2(resultW),.x3(aluoutM),.a(forwardAE),.y(srcAE));
    
    mux3 #(32) mymux3_2(.x1(rd2E),.x2(resultW),.x3(aluoutM),.a(forwardBE),.y(writedataE));   
   
    mux2 #(32) mumux2(.x1(writedataE),.x2(signlmmE),.a(alusrcE),.y(srcBE));
    
    Myalu myalu(.A(srcAE),.B(srcBE),.op(alucontrollE),.C(aluoutE));
    
    mux2 #(5) mumux3(.x1(rtE),.x2(rdE),.a(regdstE),.y(writeregE));
   
    //第三级门
    flopr #(1) flopenrc_18(clk,rst,regwriteE,regwriteM);
    flopr #(1) flopenrc_19(clk,rst,memtoregE,memtoregM);
    flopr #(1) flopenrc_20(clk,rst,memwriteE,memwriteM);
    flopr #(32) flopenrc_21(clk,rst,aluoutE,aluoutM);
    flopr #(32) flopenrc_22(clk,rst,writedataE,writedataM);
    flopr #(5) flopenrc_23(clk,rst,writeregE,writeregM);
    
    //第四级门
    flopr #(1) flopenrc_24(clk,rst,regwriteM,regwriteW);
    flopr #(1) flopenrc_25(clk,rst,memtoregM,memtoregW);
    flopr #(32) flopenrc_26(clk,rst,readdataM,readdataW);
    flopr #(32) flopenrc_27(clk,rst,aluoutM,aluoutW);
    flopr #(5) flopenrc_29(clk,rst,writeregM,writeregW);
    
    //第五级
    mux2 #(32) mumux4(.x1(aluoutW),.x2(readdataW),.a(memtoregW),.y(resultW));
    
    //冒险模块
    hazard myharzard(
    .stallF(startIF),
    .rsD(instrD[25:21]),
	.rtD(instrD[20:16]),
	.branchD(branchD),
	.forwardaD(forwardAD),
	.forwardbD(forwardBD),
	.stallD(startID),
	.rsE(rsE),
	.rtE(rtE),
	.writeregE(writeregE),
	.regwriteE(regwriteE),
	.memtoregE(memtoregE),
	.forwardaE(forwardAE),
	.forwardbE(forwardBE),
	.flushE(startIE),
	.writeregM(writeregM),
	.regwriteM(regwriteM),
	.memtoregM(memtoregM),
	.writeregW(writeregW),
    .regwriteW(regwriteW)
	
    );
    
endmodule    


module hazard(
	output wire stallF,
	input wire[4:0] rsD,rtD,
    input wire branchD,
	output wire forwardaD,forwardbD,
	output wire stallD,
	input wire[4:0] rsE,rtE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	output reg[1:0] forwardaE,forwardbE,
	output wire flushE,
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,
	input wire[4:0] writeregW,
	input wire regwriteW
    );
	wire lwstallD,branchstallD;
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
	always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
			if(rsE == writeregM & regwriteM) begin
				forwardaE = 2'b10;
			end else if(rsE == writeregW & regwriteW) begin
				forwardaE = 2'b01;
			end
		end
		if(rtE != 0) begin
			if(rtE == writeregM & regwriteM) begin
				forwardbE = 2'b10;
			end else if(rtE == writeregW & regwriteW) begin
				forwardbE = 2'b01;
			end
		end
	end
	assign #2 lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	assign #2 branchstallD = branchD &
				(regwriteE & 
				(writeregE == rsD | writeregE == rtD) |
				memtoregM &
				(writeregM == rsD | writeregM == rtD));
	assign #2 stallD = lwstallD | branchstallD;
	assign #2 stallF = stallD;
	assign #2 flushE = stallD;
endmodule


