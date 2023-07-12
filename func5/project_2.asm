        .data
msg0:   .asciiz "\n"
msg1:   .asciiz "input first float\n"
msg2:   .asciiz "input second float\n"
msg3:	 .asciiz "sum is:\n "
msg4:	 .asciiz "up overflow\n"
msg5:	 .asciiz "down overflow\n"
msg6:	 .asciiz "sub is:\n "
         .text
#开始         
li    $v0   4
la    $a0    msg0
syscall
#输入两个数到$s0,$s1
#输入第一个数
li	$v0,	4
la	$a0,	msg1
syscall
li    	$v0,	6			
syscall
mfc1 	$s0,	$f0	              
#输入第二个数   
li	$v0,	4
la	$a0,	msg2
syscall
li    	$v0,	6			
syscall
mfc1 	$s1,	$f0                    

#准备输出结果
li	$v0,	4
la	$a0,	msg3
syscall
jal mysum

li	$v0,	4
la	$a0,	msg0
syscall
#二进制
jal binary

li	$v0,	4
la	$a0,	msg0
syscall
#16进制			
jal hexadecimal
#输出换行符
li	$v0,	4
la	$a0,	msg0
syscall
#计算减法,第二个数符号位取反
xori	$s1,	$s1,	0x80000000
#准备输出结果
li	$v0,	4
la	$a0,	msg6
syscall
jal mysum

li	$v0,	4
la	$a0,	msg0
syscall
#二进制
jal binary

li	$v0,	4
la	$a0,	msg0
syscall
#16进制			
jal hexadecimal
#结束
j back


mysum:
#求和
#s0和s1的符号位
srl 	$s2,	$s0,	31              
srl 	$s5,	$s1,	31              
#s0和s1的阶数,不能直接右移23位
sll 	$s3,	$s0,	1
srl 	$s3,	$s3,	24  		
sll 	$s6,	$s1,	1
srl 	$s6,	$s6,	24  		
#s0的尾数位
sll	$s4,	$s0,	9
srl 	$s4,	$s4,	9
#补全隐藏位
ori 	$s4,	$s4,	0x00800000     
#s1的尾数位
sll 	$s7,	$s1,	9
srl 	$s7,	$s7,	9
#补全隐藏位
ori 	$s7,	$s7,	0x00800000

#对阶
sub	$t0,	$s3,	$s6
# 小于0,第一个数对阶
bltz	$t0,		duijie1          
# 大于0,第一个数对阶
bgtz	$t0,		duijie2	    
#等于0，跳转运算
beqz	$t0,		sumx		
   
duijie1:					
addi	$s3,	$s3	1             
srl	$s4,	$s4,	1
sub	$t0,	$s3,	$s6
bltz	$t0,		duijie1
beqz	$t0,		sumx

duijie2:				
addi	$s6,	$s6,	1              
srl	$s7,	$s7,	1
sub	$t0,	$s3,	$s6
bgtz	$t0,		duijie2
beqz	$t0,		sumx

#计算尾数加法
sumx:
xor	$t3,	$s2,	$s5
#同号加法
beq	$t3,	0,	sum1
#异号加法		
beq	$t3,	1,	sum2
		
#同号加法
sum1:
add 	$t1,	$s4,	$s7
#判断上溢
sge 	$t2,	$t1,	0x01000000 
#上溢则尾数右移             
beq 	$t2,	1,     youyi
#跳转到输出		     
j	sumResult				
#异号加法
sum2:
sub 	$t1,	$s4,	$s7
# s0>s1(绝对值)
bgt	$t1,	0,	sum11	
# s0<s1(绝对值)      
blt	$t1,	0,	sum12
#结果等于0	       
j	sumResult1                     

sum11:
#尾数过小(左移)
blt 	$t1,	0x00800000,	sum111      
#处理上溢
bge 	$t1,	0x01000000,	sum122      
j 	sumResult

sum111:
sll 	$t1,	$t1,	1
subi 	$s3,	$s3,	1
blt 	$t1,	0x00800000,	sum111
j 	sumResult

sum122:
srl 	$t1,	$t1,	1
addi 	$s3,	$s3,	1
bge 	$t8,	0x01000000,	sum122
j 	sumResult

sum12:
sub 	$t1,	$s7,	$s4
xori    $s2     $s2     0x00000001
j     sum11
  
#尾数右移，指数加一
youyi:                                 	
srl	$t1,	$t1,	1
addi	$s3,	$s3,	1
j	sumResult				
  	
#输出		
sumResult:	
#溢出
blt 	$s3,	0,	xiayi        
bgt 	$s3,	255,	shangyi
#将结果转化为IEEE754浮点数
sll	$s2,	$s2,	31            
sll	$s3,	$s3,	23
sll	$t1,	$t1,	9
srl 	$t1,	$t1,	9
add	$s3,	$s3,	$t1
add	$s2,	$s2,	$s3
mtc1    $s2,	$f12			
#输出	
li 	$v0,	2									
syscall 

j           end

#上溢	
shangyi:
la 	$a0,	msg4
li	$v0,	4
syscall
j           end   
#下溢
xiayi:
la 	$a0,	msg5
li	$v0,	4
syscall
 j       end
#输出0
sumResult1:
mtc1    $zero,	$f12	
li 	$v0,	2     
syscall
j       end
				 		 		
end:				
la    	$a0,	msg0		
li    	$v0,	4

syscall
jr $ra



#二进制输出
binary: 
	#取出IEEE754的数
  	addu   $t2,$s2,$0   
   	#存在$t9中    
  	add  $t9, $t2,$0 
  	li   $t7,0	 
  	#计数
  	addi 	$t4,$0,32        
  	addi 	$t8,$0,0x80000000  	
binaryLoop:  
   	addi $t4,$t4,-1     
   	and  $t7,$t8,$t9          
   	srl  $t8,$t8,1       
   	srlv  $t7,$t7,$t4     
   	add  $a0,$t7,$zero  
   	#循环一次输出一位        
   	li $v0,1	         
   	syscall
   	beq 	$t4,$0,Exist           
   	j 	binaryLoop
Exist: 
	jr $ra 


#hexadeccimal  十六进制  
hexadecimal: 
  	li   $t0,0		
   	addu   $t5,$s2,$0		
srloop:	
   	bge  $t0,8,hexadecimalend  #循环8次
  	addi $t0,$t0,1      
  	 #一次取四位     
  	srl  $t1,$t5,28 
   	#左移四位           
  	sll  $t5,$t5,4     
  	 #大于9时用字母输出        
   	bgt $t1,9,outchar  
   	#循环一次输出一个十六进制数        
   	li $v0,1                   
   	add $a0,$t1,$zero
   	syscall
   	j	srloop
outchar:
	# ASCZII	输出
  	addi $t1,$t1,55	       
  	li 	$v0,11
  	add	$a0,$t1,$zero
  	syscall
  	j	srloop
hexadecimalend:                
	#输出结束
  	jr $ra


back:
li	$v0,	10
syscall

                                                                                                                                     
                                                                                                                                                                                                                                                                                                                                                                                                                                    