############################################################################################################################################
## DESCRIPTION:																  ##
## 	Program is using functions for converting numerals in input and output data.							  ##
## 	Program should decode ascii string into numeral, and than convert it back to ascii string and print at standard output.		  ##
## INPUT:																  ##
## 	Number in ascii.														  ##
## OUTPUT:																  ##
## 	Number in ascii.														  ##
############################################################################################################################################

	.equ	INT_LINUX,	0x80

	.equ	SYS_EXIT,	1
	.equ	SYS_READ,	2
	.equ	SYS_WRITE,	4


	.equ	STDIN,	0
	.equ	STDOUT,	1
	.equ	STDERR,	2

	.equ	ARGN,	0
	.equ	ARG_0,	4
	.equ	ARG_1,	8
	.equ	ARG_2,	12
	.equ	ARG_3,	16

	.equ	F_ERR,	0xFFFFFFFF
	
	.section .text

	.equ	ASCII_MINUS, $'-'
	.equ	ASCII_0, $'0'
	.equ	ASCII_MISS, 255
	
	.global	_start
_start:
	movl	%esp,%ebp
	movl	ARGN(%ebp),%eax
	cmp	$3,%eax
	jne	_exit
	movl	ARG_2(%ebp),%eax
	call	_atoi
	cmp	$F_ERR,%eax
	je	_exit
1:	
	subl	$100,%esp
	movl	%esp,%ebx
	movl	$100,%ecx

	movl	%eax,%edx
	andl	$0x7FFFFFFF,%edx
	cmp	%eax,%edx
	je	1f
	neg	%eax
	movl	$'-',%edx
	pushl	%edx
1:	
	xor	%ecx,%ecx
	movl	ARG_1(%ebp),%ebx
	movb	(%ebx),%cl
	
	cmp	$'b',%ecx
	jne	2f
	call	_uint_toa2
	jmp	1f
2:
	cmp	$'o',%ecx
	jne	2f
	call	_uint_toa8
	jmp	1f
2:
	cmp	$'d',%ecx
	jne	2f
	call	_uint_toa10
	jmp	1f
2:
	cmp	$'x',%ecx
	jne	2f
	call	_uint_toa16
	jmp	1f
1:
	cmp	$0,%eax
	je	_exit
	popl	%ecx
	cmpl	$'-',%ecx
	jne	1f
	decl	%eax
	incl	%ebx
	movb	%cl,(%eax)
1:	
	movl	%eax,%ecx
	movl	%ebx,%edx
	movl	$STDOUT,%ebx
	movl	$SYS_WRITE,%eax
	int	$INT_LINUX
_exit:	
	movl	$SYS_EXIT,%eax
	movl	$0,%ebx
	int	$INT_LINUX

##########################################################################################
## DESCRIPTION:									        ##
## 	Function converts NULL terminated char string representing binary number	##
## 	into unsigned integer.								##
## 	Function defines the end of a number as any character outside the range.	##
## INPUT:									        ##
## 	%eax		(C String) Pointer to the ascii coded number.		        ##
## OUTPUT:									        ##
## 	%eax		(signed big number) The number				        ##
##########################################################################################

_a2to_uint:
	movl	%eax,%ebx
	xor	%eax,%eax	 # %eax = 0
	jmp	2f
	## %eax - the number - return value
	## %ebx - pointer to next char
	## %ecx - next number to be converted
1:	shl	%eax
	jo	_a2to_uint_err
	orl	%ecx,%eax

2:	xor	%ecx,%ecx
	movb	(%ebx),%cl
	incl	%ebx
	subl	$'0',%ecx
	andl	$0x7FFFFFFF,%ecx
	cmpl	$2,%ecx
	jl	1b
_a2to_uint_end:
	ret
_a2to_uint_err:
	movl	$F_ERR,%eax
	ret

##########################################################################################
## DESCRIPTION:									        ##
## 	Function converts NULL terminated char string representing octal number		##
## 	into unsigned integer.								##
## 	Function defines the end of a number as any character outside the range.	##
## INPUT:									        ##
## 	%eax		(C String) Pointer to the ascii coded number.		        ##
## OUTPUT:									        ##
## 	%eax		(signed big number) The number				        ##
##########################################################################################

_a8to_uint:
	movl	%eax,%ebx
	xor	%eax,%eax  	# %eax = 0 
	jmp	2f
	## %eax - the number - return value
	## %ebx - pointer to next char
	## %ecx - next number to be converted
1:	shl	$3,%eax
	jo	_a8to_uint_err
	orl	%ecx,%eax
	
2:	xor	%ecx,%ecx
	movb	(%ebx),%cl
	incl	%ebx
	subl	$'0',%ecx
	andl	$0x7FFFFFFF,%ecx
	cmpl	$8,%ecx
	jl	1b
_a8to_uint_end:
	ret
_a8to_uint_err:
	movl	$F_ERR,%eax
	ret

##########################################################################################
## DESCRIPTION:									        ##
## 	Function converts NULL terminated char string representing decimal number	##
## 	into unsigned integer.								##
## 	Function defines the end of a number as any character outside the range.	##
## INPUT:									        ##
## 	%eax		(C String) Pointer to the ascii coded number.		        ##
## OUTPUT:									        ##
## 	%eax		(signed big number) The number				        ##
##########################################################################################

_a10to_uint:
	movl	%eax,%ebx
	xor	%eax,%eax  	# %eax = 0 
	jmp	2f
	## %eax - the number - return value
	## %ebx - pointer to next char
	## %ecx - next number to be converted
1:	mull	%edx
	jo	_a10to_uint_err
	addl	%ecx,%eax

2:	xor	%ecx,%ecx
	movl	$10,%edx
	movb	(%ebx),%cl
	incl	%ebx
	subl	$'0',%ecx
	andl	$0x7FFFFFFF,%ecx
	cmpl	$10,%ecx
	jl	1b
_a10to_uint_end:
	ret
_a10to_uint_err:
	movl	$F_ERR,%eax
	ret


##########################################################################################
## DESCRIPTION:									        ##
## 	Function converts NULL terminated char string representing hexadecimal number	##
## 	into unsigned integer.								##
## 	Function defines the end of a number as any character outside the range.	##
## INPUT:									        ##
## 	%eax		(C String) Pointer to the ascii coded number.		        ##
## OUTPUT:									        ##
## 	%eax		(signed big number) The number				        ##
##########################################################################################

_a16to_uint:
	movl	%eax,%ebx
	xor	%eax,%eax  	# %eax = 0 
	jmp	2f
	## %eax - the number - return value
	## %ebx - pointer to next char
	## %ecx - next number to be converted
1:	shl	$4,%eax
	jo	_a16to_uint_err
	orl	%ecx,%eax

2:	xor	%ecx,%ecx
	movb	(%ebx),%cl
	incl	%ebx
	subl	$'0',%ecx
 	andl	$0x7FFFFFFF,%ecx
	cmpl	$10,%ecx
	jl	1b
	movl	%ecx,%edx
	subl	$7,%ecx 	# A = 10
	andl	$0x7FFFFFFF,%ecx
	subl	$39,%edx	# a = 10
	andl	$0x7FFFFFFF,%edx
	cmpl	$16,%ecx
	jl	1b
	movl	%edx,%ecx
	cmpl	$16,%ecx
	jl	1b
_a16to_uint_end:
	ret
_a16to_uint_err:
	movl	$F_ERR,%eax
	ret

##########################################################################################
## DESCRIPTION:									        ##
## 	Function converts NULL terminated char string representing hexadecimal number	##
## 	into unsigned integer.								##
## 	Function defines the end of a number as any character outside the range.	##
##	This function uses character map.						##
## INPUT:									        ##
## 	%eax		(C String) Pointer to the ascii coded number.		        ##
## OUTPUT:									        ##
## 	%eax		(signed big number) The number				        ##
##########################################################################################

NUMBER_BUFF:
	.byte	0,1,2,3,4,5,6,7,8,9 # ASCII [0,9]
	.space	7, ASCII_MISS
	.byte	10,11,12,13,14,15 # ASCII A-F
	.space	26, ASCII_MISS
	.byte	10,11,12,13,14,15 # ASCII a-f
NUMBER_BUFF_END:
	
_a16to_uint2:
	movl	%eax,%ebx
	xor	%eax,%eax  	# %eax = 0 
	jmp	2f
	## %eax - the number - return value
	## %ebx - pointer to next char
	## %ecx - next number to be converted
1:	shl	$4,%eax
	jo	_a16to_uint_err2
	orl	%ecx,%eax

2:	xor	%ecx,%ecx
	movb	(%ebx),%cl
	incl	%ebx
	subl	$'0',%ecx
 	andl	$0x7FFFFFFF,%ecx
	cmpl	$(NUMBER_BUFF_END-NUMBER_BUFF),%ecx
	jge	_a16to_uint_end2
	movb	NUMBER_BUFF(%ecx),%cl
	cmpl	$ASCII_MISS,%ecx
	jne	1b
_a16to_uint_end2:
	ret
_a16to_uint_err2:
	movl	$F_ERR,%eax
	ret

#########################################################################################
## DESCRIPTION:									       ##
## 	Function egzamines the given C string and returns coresponding value	       ##
## 										       ##
## INPUT:									       ##
##	(C STRING) - %eax ASCII number representation in standard form:		       ##
## 	BASE  2 - 0b101011011101						       ##
## 	BASE  8 - 0o213455061311						       ##
## 	BASE 10 - 0d112013241311 or 21444101					       ##
## 	BASE 16 - 0x120aaeACD401						       ##
## 	All numbers can be prepended '+'/'-' signs.				       ##
## OUTPUT:									       ##
## 	signed int - %eax							       ##
#########################################################################################

_atoi:
	xor	%ecx,%ecx
	pushl	%eax
	## Check for sign marks
	movb	(%eax),%cl
	incl	%eax
	cmpb	$0,%cl
	je	_atoi_err
	## Check for sign
	cmpb	$'-',%cl
	je	1f
	cmpb	$'+',%cl
	je	1f
	jmp	2f
1:	# Read nex char
	movb	(%eax),%cl
	incl	%eax
	cmpb	$0,%cl
	je	_atoi_err
2:	# Check if contain prefix
	cmpb	$'0',%cl
	je	1f
	## Check if decimal with propriate format
	subl	$'0',%ecx
 	andl	$0x7FFFFFFF,%ecx
	cmp	$10,%ecx
	jge	_atoi_err	# Not apropriate string format
	## We deal with decimal number without prefix
	movl	(%esp),%eax
	call	_a10to_uint
	jmp	_atoi_exit
1:
	movb	(%eax),%cl
	incl	%eax
	cmpb	$0,%cl
	je	_atoi_err	
_atoi_call_a2to_uint:	
	cmpb	$'b',%cl
	jne	_atoi_call_a8to_uint
	call	_a2to_uint
	jmp	_atoi_exit
_atoi_call_a8to_uint:	
	cmpb	$'o',%cl
	jne	_atoi_call_a10to_uint
	call	_a8to_uint
	jmp	_atoi_exit
_atoi_call_a10to_uint:	
	cmpb	$'d',%cl
	jne	_atoi_call_a16to_uint
	call	_a10to_uint
	jmp	_atoi_exit
_atoi_call_a16to_uint:	
	cmpb	$'x',%cl
	jne	_atoi_err
	call	_a16to_uint2
	jmp	_atoi_exit
_atoi_exit:
	cmpl	$F_ERR,%eax
	je	_atoi_err
	popl	%ebx
	xor	%ecx,%ecx
	movb	(%ebx),%cl
	cmpb	$'-',%cl
	jne	1f
	neg	%eax
1:
	ret
_atoi_err:
	popl	%ebx
	movl	$F_ERR,%eax
	ret


##################################################################################
## DESCRIPTION:								        ##
## 	Convert number into String representation of base 2		        ##
## INPUT:								        ##
## 	%eax - Number							        ##
## 	%ebx - Buffer								##
## 	%ecx - Buffer size							##
## OUTPUT:								        ##
## 	%eax - pointer to the string						##
##	%ebx - size of a string							##
##################################################################################

_uint_toa2:
	addl	%ebx,%ecx	# set buffer end pointer
	movl	%ecx,%edi	# momorize the end of the string
	decl	%ecx		# add \0 at the end
	movl	$0,(%ecx)
	## %eax - Number
	## %ebx - Beginning of a buffer
	## %ecx - Buffer index
	## %edx	- Work variable
	## %edi	- End of a buffer
1:
	cmpl	%ecx,%ebx	# Check if not exceeding the buffer
	je	_uint_toa2_err
	movl	%eax,%edx	# compute the reminder
	andl	$0x00000001,%edx
	addl	$'0',%edx	# convert reminder into ASCII
	decl	%ecx		# Write reminder as the next digit
	movb	%dl,(%ecx)	
	shr	%eax		# Divide number by 2
	cmpl	$0,%eax
	jne	1b
### _uint_toa2_end:
	decl	%ecx		# Add '0b' base mark
	movb	$'b',(%ecx)
	decl	%ecx
	movb	$'0',(%ecx)
	movl	%edi,%ebx	# compute the string size
	subl	%ecx,%ebx
	decl	%ebx
	movl	%ecx,%eax	# pass the string pointer
	ret
_uint_toa2_err:
	xor	%eax,%eax
	xor	%ebx,%ebx
	ret

##################################################################################
## DESCRIPTION:								        ##
## 	Convert number into String representation of base 8		        ##
## INPUT:								        ##
## 	%eax - Number							        ##
## 	%ebx - Buffer								##
## 	%ecx - Buffer size							##
## OUTPUT:								        ##
## 	%eax - pointer to the string						##
##	%ebx - size of a string							##
##################################################################################

_uint_toa8:
	addl	%ebx,%ecx	# set buffer end pointer
	movl	%ecx,%edi	# momorize the end of the string
	decl	%ecx		# add \0 at the end
	movl	$0,(%ecx)
	## %eax - Number
	## %ebx - Beginning of a buffer
	## %ecx - Buffer index
	## %edx	- Work variable
	## %edi	- End of a buffer
1:
	cmpl	%ecx,%ebx	# Check if not exceeding the buffer
	je	_uint_toa8_err
	movl	%eax,%edx	# compute the reminder
	andl	$0x00000007,%edx
	addl	$'0',%edx	# convert reminder into ASCII
	decl	%ecx		# Write reminder as the next digit
	movb	%dl,(%ecx)	
	shr	$3,%eax		# Divide number by 8
	cmpl	$0,%eax
	jne	1b
### _uint_toa8_end:
	decl	%ecx		# Add '0b' base mark
	movb	$'o',(%ecx)
	decl	%ecx
	movb	$'0',(%ecx)
	movl	%edi,%ebx	# compute the string size
	subl	%ecx,%ebx
	decl	%ebx
	movl	%ecx,%eax	# pass the string pointer
	ret
_uint_toa8_err:
	xor	%eax,%eax
	xor	%ebx,%ebx
	ret

##################################################################################
## DESCRIPTION:								        ##
## 	Convert number into String representation of base 10		        ##
## INPUT:								        ##
## 	%eax - Number							        ##
## 	%ebx - Buffer								##
## 	%ecx - Buffer size							##
## OUTPUT:								        ##
## 	%eax - pointer to the string						##
##	%ebx - size of a string							##
##################################################################################

_uint_toa10:
	addl	%ebx,%ecx	# set buffer end pointer
	movl	%ecx,%edi	# momorize the end of the string
	decl	%ecx		# add \0 at the end
	movl	$0,(%ecx)
	movl	$10,%esi
	## %eax - Number
	## %ebx - Beginning of a buffer
	## %ecx - Buffer index
	## %edx	- Work variable
	## %edi	- End of a buffer
	## %esi - hold 10 as base for division operation
1:
	xor	%edx,%edx
	cmpl	%ecx,%ebx	# Check if not exceeding the buffer
	je	_uint_toa16_err
	divl	%esi		# compute the reminder
	addl	$'0',%edx	# convert reminder into ASCII
	decl	%ecx		# Write reminder as the next digit
	movb	%dl,(%ecx)
	cmpl	$0,%eax
	jne	1b
### _uint_toa10_end:
	decl	%ecx		# Add '0b' base mark
	movb	$'d',(%ecx)
	decl	%ecx
	movb	$'0',(%ecx)
	movl	%edi,%ebx	# compute the string size
	subl	%ecx,%ebx
	decl	%ebx
	movl	%ecx,%eax	# pass the string pointer
	ret
_uint_toa10_err:
	xor	%eax,%eax
	xor	%ebx,%ebx
	ret
	
##################################################################################
## DESCRIPTION:								        ##
## 	Convert number into String representation of base 16		        ##
## INPUT:								        ##
## 	%eax - Number							        ##
## 	%ebx - Buffer								##
## 	%ecx - Buffer size							##
## OUTPUT:								        ##
## 	%eax - pointer to the string						##
##	%ebx - size of a string							##
##################################################################################
XDIG_CHAR_BUFF:
	.ascii	"0123456789ABCDEF"
XDIG_CHAR_BUFF_END:
	
_uint_toa16:
	addl	%ebx,%ecx	# set buffer end pointer
	movl	%ecx,%edi	# momorize the end of the string
	decl	%ecx		# add \0 at the end
	movl	$0,(%ecx)
	## %eax - Number
	## %ebx - Beginning of a buffer
	## %ecx - Buffer index
	## %edx	- Work variable
	## %edi	- End of a buffer
1:
	cmpl	%ecx,%ebx	# Check if not exceeding the buffer
	je	_uint_toa16_err
	movl	%eax,%edx	# compute the reminder
	andl	$0x0000000F,%edx
	movl	XDIG_CHAR_BUFF(%edx),%edx	# convert reminder into ASCII
	decl	%ecx		# Write reminder as the next digit
	movb	%dl,(%ecx)	
	shr	$4,%eax		# Divide number by 8
	cmpl	$0,%eax
	jne	1b
### _uint_toa16_end:
	decl	%ecx		# Add '0b' base mark
	movb	$'x',(%ecx)
	decl	%ecx
	movb	$'0',(%ecx)
	movl	%edi,%ebx	# compute the string size
	subl	%ecx,%ebx
	decl	%ebx
	movl	%ecx,%eax	# pass the string pointer
	ret
_uint_toa16_err:
	xor	%eax,%eax
	xor	%ebx,%ebx
	ret
	