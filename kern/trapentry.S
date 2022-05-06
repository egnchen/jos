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

// refer to https://wiki.osdev.org/Exception for whether EC is present or notTRAPHANDLER_NOEC(trap_handle_divide, 0)
TRAPHANDLER_NOEC(trap_handle_divide, 0)
TRAPHANDLER_NOEC(trap_handle_debug, 1)
TRAPHANDLER_NOEC(trap_handle_nmi, 2)
TRAPHANDLER_NOEC(trap_handle_brkpt, 3)
TRAPHANDLER_NOEC(trap_handle_oflow, 4)
TRAPHANDLER_NOEC(trap_handle_bound, 5)
TRAPHANDLER_NOEC(trap_handle_illop, 6)
TRAPHANDLER_NOEC(trap_handle_device, 7)
TRAPHANDLER(trap_handle_dblflt, 8)
// TRAPHANDLER_NOEC(trap_handle_coproc, 9)		// not defined
TRAPHANDLER(trap_handle_tss, 10)
TRAPHANDLER(trap_handle_segnp, 11)
TRAPHANDLER(trap_handle_stack, 12)
TRAPHANDLER(trap_handle_gpflt, 13)
TRAPHANDLER(trap_handle_pgflt, 14)
// TRAPHANDLER_NOEC(trap_handle_res, 15)			// not defined
TRAPHANDLER_NOEC(trap_handle_fperr, 16)
TRAPHANDLER(trap_handle_align, 17)
TRAPHANDLER_NOEC(trap_handle_mchk, 18)
TRAPHANDLER_NOEC(trap_handle_simderr, 19)

TRAPHANDLER_NOEC(trap_handle_syscall, 48)

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