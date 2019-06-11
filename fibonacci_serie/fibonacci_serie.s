################################################################
### DESC:
### 	Program writing N'th element of the fibonacci sequence
### INPUT:
### 	(uint)N	number of the element in sequence
### OUTPUT:
### 	(uint)	Value of the element.
################################################################

	## Program Arguments
	.equ ARGN,	0
	.equ ARGV_0,	4
	.equ ARGV_1,	8
	
	## IO Buffers
	.equ STDIN,	0
	.equ STDOUT,	1
	.equ STDERR,	2

	
	## Interrupts
	.equ SYS_INT,	0x80

	## Syscalls
	.equ SYS_EXIT,	1
	.equ SYS_READ,	3
	.equ SYS_WRITE,	4

	## External Entrypoints
	.globl _start

	.section .text
MSG_BAD_ARG:
	.ascii "Only 1 positive integer argument accepted.\n"
MSG_BAD_ARG_END:
	
_start:
	movl	%esp,%ebp
	movl	ARGN(%ebp),%ebx
	cmpl	$2,%ebx
	jne	_print_err_arg	# Exit with error when
	movl	ARGV_1(%ebp),%edi
	movl	$0,%eax		# Erase decoded number accumulator
 	movl	$10,%ecx
	
_decode_string:
	movb	(%edi),%bl
	incl	%edi
	cmpb	$0,%bl
	je	_fibonacci	# End of a string goto fibonacci
	cmpb	$'0',%bl
	jl	_print_err_arg	# Element is not a number print error
	cmpl	$'9',%ebx
	jg	_print_err_arg
	subl	$'0',%ebx
	mull	%ecx		# Magnify the previous result (eax) by 10
	addl	%ebx,%eax
	jmp	_decode_string
	
_fibonacci:
	cmpl	$0,%eax
	je	_print_err_arg
	movl	$1,%ebx
	movl	$1,%ecx
_fibonacci_loop:
	cmpl	$1,%eax
	je	_fibonacci_end_1
	cmpl	$2,%eax
	je	_fibonacci_end_2
	subl	$2,%eax
	addl	%ecx,%ebx
	addl	%ebx,%ecx
	jmp	_fibonacci_loop
_fibonacci_end_1:
	movl	%ebx,%eax
	jmp	_encode_string
_fibonacci_end_2:
	movl	%ecx,%eax
	## 	jmp	_encode_string
_encode_string:
	## 	pushl	%ebp		# Zapamiętujemy początek stosu
	movl	%esp,%ebp	#
	movl	$10,%ebx
	movl	$0,%ecx
	decl	%esp		# Add newline at the end
	movb	$'\n',(%esp)	#
	
_encode_string_loop:
	movl	$0,%edx
	divl	%ebx
	addl	$'0',%edx
	decl	%esp
	movb	%dl,(%esp)
	cmp	$0,%eax
	jne	_encode_string_loop
	## 	jmp	_print_good_arg
	
_print_good_arg:
	movl	%ebp,%edx
	subl	%esp,%edx
	movl	%esp,%ecx
	jmp	_print
	
_print_err_arg:
	movl	$MSG_BAD_ARG_END,%edx
	subl	$MSG_BAD_ARG,%edx
	movl	$MSG_BAD_ARG,%ecx
	## 	jmp	_print_err
	
_print:
	movl	$STDOUT,%ebx
	movl	$SYS_WRITE,%eax
	int	$SYS_INT
	## 	jmp	_exit
	
_exit:
	movl	$SYS_EXIT,%eax
	int	$SYS_INT
	