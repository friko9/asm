#######################################################################################################
## DESCRIPTION:											     ##
## 	Program takes output from the standard input and writes it to the standard output.	     ##
## INPUT:											     ##
##	(none)                                                                                       ##
## OUTPUT:											     ##
## 	(string) Data from the standard input.							     ##
#######################################################################################################

	.equ LIN_INT,	0x80

	.equ SYS_EXIT,	1
	.equ SYS_READ,	3
	.equ SYS_WRITE,	4

	.equ STDIN,	0
	.equ STDOUT,	1
	.equ STDERR,	2

	.equ BUFF_SIZE,	512
	
	.globl _start

	.section .text

_start:
	movl %esp,%ebp
	addl $BUFF_SIZE,%esp

	## Writing unchanged elements
	movl %ebp,%ecx
	movl $BUFF_SIZE,%edx
_read:
	movl $SYS_READ,%eax
	movl $STDIN,%ebx
	int  $LIN_INT
	movl %eax,%edx
_write:
	movl $SYS_WRITE,%eax
	movl $STDOUT,%ebx
	int  $LIN_INT
	cmpl $BUFF_SIZE,%eax
	je   _read
_exit:
	movl $SYS_EXIT,%eax
	movl $0,%ebx
	int  $LIN_INT