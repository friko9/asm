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

	movl	$4,%ebx
	mul	%ebx
	addl	%esp,%ebx
	addl	%esp,%eax
_get_length:
	addl	$4,%ebx
	movl	(%ebx),%edx
	movb	$' ',-1(%edx)
	cmp	%ebx,%eax
	jne	_get_length
_get_length_end:
	incl	%edx
	movl	(%edx),%eax
	cmpb	$0,%al
	jne	_get_length_end
	movb	$'\n',(%edx)
	incl	%edx
	
	movl	ARG_1(%esp),%ecx
	subl	%ecx,%edx
_write:
	movl	$SYS_WRITE,%eax
	movl	$STDOUT,%ebx
	int	$LIN_INT
_exit:
	movl	$SYS_EXIT,%eax
	movl	$0,%ebx
	int	$LIN_INT