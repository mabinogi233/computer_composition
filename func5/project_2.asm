        .data
msg0:   .asciiz "\n"
msg1:   .asciiz "input first float\n"
msg2:   .asciiz "input second float\n"
msg3:	 .asciiz "sum is:\n "
msg4:	 .asciiz "up overflow\n"
msg5:	 .asciiz "down overflow\n"
msg6:	 .asciiz "sub is:\n "
         .text
#��ʼ         
li    $v0   4
la    $a0    msg0
syscall
#������������$s0,$s1
#�����һ����
li	$v0,	4
la	$a0,	msg1
syscall
li    	$v0,	6			
syscall
mfc1 	$s0,	$f0	              
#����ڶ�����   
li	$v0,	4
la	$a0,	msg2
syscall
li    	$v0,	6			
syscall
mfc1 	$s1,	$f0                    

#׼��������
li	$v0,	4
la	$a0,	msg3
syscall
jal mysum

li	$v0,	4
la	$a0,	msg0
syscall
#������
jal binary

li	$v0,	4
la	$a0,	msg0
syscall
#16����			
jal hexadecimal
#������з�
li	$v0,	4
la	$a0,	msg0
syscall
#�������,�ڶ���������λȡ��
xori	$s1,	$s1,	0x80000000
#׼��������
li	$v0,	4
la	$a0,	msg6
syscall
jal mysum

li	$v0,	4
la	$a0,	msg0
syscall
#������
jal binary

li	$v0,	4
la	$a0,	msg0
syscall
#16����			
jal hexadecimal
#����
j back


mysum:
#���
#s0��s1�ķ���λ
srl 	$s2,	$s0,	31              
srl 	$s5,	$s1,	31              
#s0��s1�Ľ���,����ֱ������23λ
sll 	$s3,	$s0,	1
srl 	$s3,	$s3,	24  		
sll 	$s6,	$s1,	1
srl 	$s6,	$s6,	24  		
#s0��β��λ
sll	$s4,	$s0,	9
srl 	$s4,	$s4,	9
#��ȫ����λ
ori 	$s4,	$s4,	0x00800000     
#s1��β��λ
sll 	$s7,	$s1,	9
srl 	$s7,	$s7,	9
#��ȫ����λ
ori 	$s7,	$s7,	0x00800000

#�Խ�
sub	$t0,	$s3,	$s6
# С��0,��һ�����Խ�
bltz	$t0,		duijie1          
# ����0,��һ�����Խ�
bgtz	$t0,		duijie2	    
#����0����ת����
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

#����β���ӷ�
sumx:
xor	$t3,	$s2,	$s5
#ͬ�żӷ�
beq	$t3,	0,	sum1
#��żӷ�		
beq	$t3,	1,	sum2
		
#ͬ�żӷ�
sum1:
add 	$t1,	$s4,	$s7
#�ж�����
sge 	$t2,	$t1,	0x01000000 
#������β������             
beq 	$t2,	1,     youyi
#��ת�����		     
j	sumResult				
#��żӷ�
sum2:
sub 	$t1,	$s4,	$s7
# s0>s1(����ֵ)
bgt	$t1,	0,	sum11	
# s0<s1(����ֵ)      
blt	$t1,	0,	sum12
#�������0	       
j	sumResult1                     

sum11:
#β����С(����)
blt 	$t1,	0x00800000,	sum111      
#��������
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
  
#β�����ƣ�ָ����һ
youyi:                                 	
srl	$t1,	$t1,	1
addi	$s3,	$s3,	1
j	sumResult				
  	
#���		
sumResult:	
#���
blt 	$s3,	0,	xiayi        
bgt 	$s3,	255,	shangyi
#�����ת��ΪIEEE754������
sll	$s2,	$s2,	31            
sll	$s3,	$s3,	23
sll	$t1,	$t1,	9
srl 	$t1,	$t1,	9
add	$s3,	$s3,	$t1
add	$s2,	$s2,	$s3
mtc1    $s2,	$f12			
#���	
li 	$v0,	2									
syscall 

j           end

#����	
shangyi:
la 	$a0,	msg4
li	$v0,	4
syscall
j           end   
#����
xiayi:
la 	$a0,	msg5
li	$v0,	4
syscall
 j       end
#���0
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



#���������
binary: 
	#ȡ��IEEE754����
  	addu   $t2,$s2,$0   
   	#����$t9��    
  	add  $t9, $t2,$0 
  	li   $t7,0	 
  	#����
  	addi 	$t4,$0,32        
  	addi 	$t8,$0,0x80000000  	
binaryLoop:  
   	addi $t4,$t4,-1     
   	and  $t7,$t8,$t9          
   	srl  $t8,$t8,1       
   	srlv  $t7,$t7,$t4     
   	add  $a0,$t7,$zero  
   	#ѭ��һ�����һλ        
   	li $v0,1	         
   	syscall
   	beq 	$t4,$0,Exist           
   	j 	binaryLoop
Exist: 
	jr $ra 


#hexadeccimal  ʮ������  
hexadecimal: 
  	li   $t0,0		
   	addu   $t5,$s2,$0		
srloop:	
   	bge  $t0,8,hexadecimalend  #ѭ��8��
  	addi $t0,$t0,1      
  	 #һ��ȡ��λ     
  	srl  $t1,$t5,28 
   	#������λ           
  	sll  $t5,$t5,4     
  	 #����9ʱ����ĸ���        
   	bgt $t1,9,outchar  
   	#ѭ��һ�����һ��ʮ��������        
   	li $v0,1                   
   	add $a0,$t1,$zero
   	syscall
   	j	srloop
outchar:
	# ASCZII	���
  	addi $t1,$t1,55	       
  	li 	$v0,11
  	add	$a0,$t1,$zero
  	syscall
  	j	srloop
hexadecimalend:                
	#�������
  	jr $ra


back:
li	$v0,	10
syscall

                                                                                                                                     
                                                                                                                                                                                                                                                                                                                                                                                                                                    