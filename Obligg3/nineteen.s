#Navn Oblig4
#
#
#
#Registre: 
#				%ECX - Antall Bytes skrevet
#				%EDX
#				
	.globl nineteen
	.globl incr
	.globl stringcpy



nineteen:
	movl	$19, %eax
	ret

incr: 
	movl 4(%esp),%eax
	addl $5,%eax
	ret

stringcpy:
	pushl 	%ebp
	movl 	%esp,%ebp

	movl 	8(%ebp),%ecx
	
s_loop: 
	cmpb	$0,(%ecx)
	jz		s_ret
	incl	%ecx
	jmp		s_loop

s_ret
	movl	12(%ebp),%eax
	movl	12(%ebp),%eax
	movb	%al,(%ecx)
	movb	$0,1


