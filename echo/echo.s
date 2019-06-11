#################################################################
### DESCRIPTION:
### 	Program writes passed arguments to the standard output,
### INPUT:
### 	(string) String to be printed.
### OUTPUT:
### 	(string) String passed in input
#################################################################


	## System interrupts
	.equ	LIN_INT,	0x80
	.equ	SYS_EXIT,	1
	.equ 	SYS_WRITE,	4
	
	## IO
	.equ	STDOUT,	1
	.equ	STDERR,	2

	## Arguments mng
	.equ	ARGN,	0
	.equ	ARG_0,	4
	.equ	ARG_1,	8
	
	.section .text
	
	.globl _start
_start:
 	movl	ARGN(%esp),%eax
	cmpl	$1,%eax
	je	_exit
	movl	ARG_1(%esp),%ebx
_get_length:
	incl	%ebx
	movl	(%ebx),%eax
	cmpb	$0,%al
	jne	_get_length
	movb	$' ',(%ebx)
	
	movl	ARGN(%esp),%eax
	movl	$4,%edx
	mul	%edx
	addl	%esp,%eax
	movl	(%eax),%eax
	cmpl	%eax,%ebx
	jle	_get_length

	movb	$'\n',(%ebx)
	incl	%ebx
	
	movl	ARG_1(%esp),%ecx
	movl	%ebx,%edx
	subl	%ecx,%edx
_write:
	movl	$SYS_WRITE,%eax
	movl	$STDOUT,%ebx
	int	$LIN_INT
_exit:
	movl	%eax,%ebx
	movl	$SYS_EXIT,%eax
	int	$LIN_INT