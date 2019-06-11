########################################################################
## DESCRIPTION:							      ##
## 	Program reverts the line order of the input string.	      ##
## ARGS:							      ##
## 	(none)							      ##
## INPUT:							      ##
## 	(C string) Any.						      ##
## OUTPUT:							      ##
## 	(C string) String with lines reversed.			      ##
########################################################################
	
	.macro	m_blckDef name, startp, var0, rest:vararg
	.equ \var0, \startp
	.ifnb \rest
	m_blckDef \name, (\startp+4),\rest
	.else
	.equ \name\()_SIZE, \startp
	.endif
	.endm


	.macro primitive_type name, size
	.ifdef \name
	.error "Type \"\name\" already defined"
	.else
	.equ \name, 0
	.equ \name\()_size, \size
	.endif
	.endm
	
	.macro	struct name:req, varName:req, varType:req, rest:vararg
	.ifnotdef \name\()_size
	.equ \name\()_size, 0
	.endif
	.ifdef \name
	.error "Type \"\name\" already defined"
	.else
	.ifnotdef \varType
	.error "Type \"\varType\" not defined"
	.else
	.equ \name\()__\()\varName, \name\()_size
	.equ \name\()_size, \name\()_size + \varType\()_size
	.ifnb \rest
	struct \name, \rest
	.endif
	.endif
	.endif
	.equ \name, 0
	.endm

	primitive_type POINTER,	4
	primitive_type UINT,	4
	primitive_type STRING,	0
	
	.equ LIN_INT,	0x80

	.equ SYS_EXIT,	1
	.equ SYS_READ,	3
	.equ SYS_WRITE,	4
	.equ SYS_BRK,	45

	.equ SIG_SEGV,	11

	.equ ALLOC_FAIL,0
	
	.equ STDIN,	0
	.equ STDOUT,	1
	.equ STDERR,	2

	## stack
	struct StackFrame, pHeapPtr,POINTER,pHeapBegin,POINTER,pHeapEnd,POINTER,lAllocSize,UINT,pLinePtr,POINTER
	## line structure
	struct Line, pPrevLine,POINTER,pNextLine,POINTER,
	
	.equ ARGN,	(4+StackFrame_size)
	.equ ARG_0,	(8+StackFrame_size)
	
	.section .text
	.global _start
	
_start:
	subl $StackFrame_size,%esp	# allocate VARIABLES
	movl %esp,%ebp			# save stack ptr
_start_heap_init:			# get heap end
	movl $SYS_BRK,%eax	
	xor %ebx,%ebx			# movl $0,%ebx
	int $LIN_INT
	incl %eax
	movl %eax,StackFrame__pHeapBegin(%ebp) # The first byte after the last stack element is a continous heap area.
	movl %eax,StackFrame__pHeapPtr(%ebp)   # The pointer we will use
	movl %eax,StackFrame__pHeapEnd(%ebp)   # The end of a current heap area
	movl $512,StackFrame__lAllocSize(%ebp) # Set 512 as starting allocate size
_start_allocate_mem:
	movl $SYS_BRK,%eax
	movl StackFrame__lAllocSize(%ebp),%ecx	# set next alloc size as 2x of previous
	shl %ecx				# -
	movl %ecx,StackFrame__lAllocSize(%ebp)	# -
	movl StackFrame__pHeapEnd(%ebp),%ebx	# and set new boundary
	addl %ecx,%ebx				# -
	int $LIN_INT
	cmpl $ALLOC_FAIL,%eax	# If alloc failed throw error
	je _start_error		# -
	movl %eax,StackFrame__pHeapEnd(%ebp) # Else set new heap end

_start_read_lines:			     # Read as many chars as it is possible
	movl $SYS_READ,%eax		     # sys_read(
	movl $STDIN,%ebx		     #		STDIN,
	movl StackFrame__pHeapPtr(%ebp),%ecx #		pHeapPtr,
	movl StackFrame__pHeapEnd(%ebp),%edx #
	subl %ecx,%edx			     #		pHeapEnd - pHeapPtr
	int $LIN_INT			     #		)
	cmp $-1,%eax
	je _start_error
	movl StackFrame__pHeapPtr(%ebp),%ecx	# Actualize heap data
	movl StackFrame__pHeapEnd(%ebp),%edx	#
	addl %eax,%ecx				#
	movl %ecx,StackFrame__pHeapPtr(%ebp)	#
	cmpl $0,%eax				# Check if end of input data
	je _start_write_line_init
	cmpl %ecx,%edx				# Check if end of buffer
	je _start_allocate_mem
	jmp _start_read_lines	# Wait for more data
_start_write_line_init:
	decl %ecx
	movl %ecx,StackFrame__pHeapEnd(%ebp)	# Setting end of a buffer
	decl %ecx
	movl %ecx,StackFrame__pHeapPtr(%ebp)
_start_write_line:
	movl StackFrame__pHeapBegin(%ebp),%ebx # Buffer start
	movl StackFrame__pHeapPtr(%ebp),%ecx   # Line current possition
	movl StackFrame__pHeapEnd(%ebp),%edx   # Line end
	incl %ecx
	xor %eax,%eax
	cmpl %edx,%ebx		# Check if no elements in buffer left
	jge _start_quit
_start_write_line_search:
	decl %ecx
	movb (%ecx),%al
	cmpb $'\n',%al
	je _start_write_line_flush_init
	cmpb $'\f',%al
	je _start_write_line_flush_init
	cmpl %ebx,%ecx
	jne _start_write_line_search
	jmp _start_write_line_flush_init_first_elem

_start_write_line_flush_init_first_elem:
	decl %ecx
_start_write_line_flush_init:
	movl %ecx,StackFrame__pHeapPtr(%ebp)
	movb $'\n',(%ecx)
	incl %ecx
	movl %ecx,StackFrame__pLinePtr(%ebp)
	movl StackFrame__pHeapEnd(%ebp),%edx
_start_write_line_flush:
	movl $SYS_WRITE,%eax
	movl $STDOUT,%ebx
	## 	movl StackFrame__pLinePtr(%ebp),%ecx -- %ecx already loaded
	subl %ecx,%edx 		# Set line size
	incl %edx
	int $LIN_INT
	cmp $-1,%eax
	je _start_error
	movl StackFrame__pLinePtr(%ebp),%ecx
	movl StackFrame__pHeapEnd(%ebp),%edx
	incl %edx
	addl %eax,%ecx
	movl %ecx,StackFrame__pLinePtr(%ebp)
	cmpl %ecx,%edx		# Check if the whole line written
	jne _start_write_line_flush
_start_write_line_flush_end:
	movl StackFrame__pHeapPtr(%ebp),%ecx
	movl %ecx,StackFrame__pHeapEnd(%ebp)
	decl %ecx
	movl %ecx,StackFrame__pHeapPtr(%ebp)
	jmp _start_write_line
	
_start_error:
	movl $SIG_SEGV,%ebx
	jmp _end
_start_quit:
	movl $0,%ebx
_end:
	movl $SYS_EXIT,%eax
	int $LIN_INT
	