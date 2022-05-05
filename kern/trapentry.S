/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

// refer to https://wiki.osdev.org/Exception for whether EC is present or not
TRAPHANDLER_NOEC(TH_DIVIDE, 0)
TRAPHANDLER_NOEC(TH_DEBUG, 1)
TRAPHANDLER_NOEC(TH_NMI, 2)
TRAPHANDLER_NOEC(TH_BRKPT, 3)
TRAPHANDLER_NOEC(TH_OFLOW, 4)
TRAPHANDLER_NOEC(TH_BOUND, 5)
TRAPHANDLER_NOEC(TH_ILLOP, 6)
TRAPHANDLER_NOEC(TH_DEVICE, 7)
TRAPHANDLER(TH_DBLFLT, 8)
// TRAPHANDLER_NOEC(TH_COPROC, 9)		// not defined
TRAPHANDLER(TH_TSS, 10)
TRAPHANDLER(TH_SEGNP, 11)
TRAPHANDLER(TH_STACK, 12)
TRAPHANDLER(TH_GPFLT, 13)
TRAPHANDLER(TH_PGFLT, 14)
// TRAPHANDLER_NOEC(TH_RES, 15)			// not defined
TRAPHANDLER_NOEC(TH_FPERR, 16)
TRAPHANDLER(TH_ALIGN, 17)
TRAPHANDLER_NOEC(TH_MCHK, 18)
TRAPHANDLER_NOEC(TH_SIMDERR, 19)


/*
 * Lab 3: Your code here for _alltraps
 */

filename:
	.asciz	"trapentry.S"
panic_msg:
	.asciz	"should never be here!"

// definition for generic trap handler
.align 2
_alltraps:
	// construct the rest of TrapFrame
	pushl	%ds
	pushl	%es
	// push all general-purpose registers
	pushal
	// set kernel data segment
	movl	$GD_KD, %eax
	mov		%eax, %ds
	mov		%eax, %es
	// push TrapFrame pointer
	push	%esp
	call	trap
	
	// should never return from here
	// print message & panic
	pushl	panic_msg
	pushl	$0
	pushl	filename
	call	_panic