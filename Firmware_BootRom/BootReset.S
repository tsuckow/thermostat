/******************************************************************************/
/*                                                                            */
/*                           D E S C R I P T I O N                            */
/*                                                                            */
/******************************************************************************/

/******************************************************************************/
/*                                                                            */
/*                         C H A N G E  H I S T O R Y                         */
/*                                                                            */
/******************************************************************************/
/*

Date       Version Description                 Author
20080701   1.0     First version               marcus
20110331   1.1     Heavily Modified & Extended Thomas Suckow

*/
/******************************************************************************/

#include "spr_defs.h"

/******************************************************************************/
/*        L O A D   3 2  B I T   C O N S T A N T  I N T O   R E G I S T E R   */
/******************************************************************************/

.macro  load32i reg const
        l.movhi \reg,hi(\const)
        l.ori   \reg,\reg,lo(\const)
.endm

/******************************************************************************/
/*                   S E T U P   E X C E P T I O N   V E C T O R              */
/******************************************************************************/

.macro  exception_vector name org
        .org \org
        .p2align 8

        l.addi r1,r1,-4
        l.sw 0x00(r1),r9

        l.jal (save_state)
        l.nop

        l.jal (exception_\name)
        l.nop

        l.jal (restore_state)
        l.nop

        l.lwz r9 ,0x00(r1)
        l.addi r1,r1,4

        //Return from exception
        l.rfe

         /* By default we loop forever, but this can be overridden */
        .weak exception_\name
exception_\name:
        l.j exception_\name
        l.nop
.endm

/******************************************************************************/
/*                         B R A N C H   T O   N A M E                        */
/******************************************************************************/


.macro  BSR name
        l.j    \name
        l.nop
ret_\name:  
.endm


/*$$RESET START*/
/******************************************************************************/
/*                                                                            */
/*                          R E S E T   S T A R T                             */
/*                                                                            */
/******************************************************************************/

.section .vectors, "ax"

.org 0x100 - 0x100 		// Sector .vectors start at 0x100


_reset:

// Set stack pointer (r1) to 00003560
// Clear all other registers

	.equ sp,__STACK_BOTTOM	;
	l.movhi r0,0x0000	; #r0 = 0
	l.ori r0,r0,0x0000	; 
	l.movhi r1,hi(sp)	; #r1 = sp
	l.ori r1,r1,lo(sp)	;
	l.or r2,r0,r0		; #clear r2
	l.or r3,r0,r0		; #clear r3
	l.or r4,r0,r0		; #clear r4
	l.or r5,r0,r0		; #clear r5
	l.or r6,r0,r0		; #clear r6
	l.or r7,r0,r0		; #clear r7
	l.or r8,r0,r0		; #clear r8
	l.or r9,r0,r0		; #clear r9
	l.or r10,r0,r0		; #clear r10
	l.or r11,r0,r0		; #clear r11
	l.or r12,r0,r0		; #clear r12
	l.or r13,r0,r0		; #clear r13
	l.or r14,r0,r0		; #clear r14
	l.or r15,r0,r0		; #clear r15
	l.or r16,r0,r0		; #clear r16
	l.or r17,r0,r0		; #clear r17
	l.or r18,r0,r0		; #clear r18
	l.or r19,r0,r0		; #clear r19
	l.or r20,r0,r0		; #clear r20
	l.or r21,r0,r0		; #clear r21
	l.or r22,r0,r0		; #clear r22
	l.or r23,r0,r0		; #clear r23
	l.or r24,r0,r0		; #clear r24
	l.or r25,r0,r0		; #clear r25
	l.or r26,r0,r0		; #clear r26
	l.or r27,r0,r0		; #clear r27
	l.or r28,r0,r0		; #clear r28
	l.or r29,r0,r0		; #clear r29
	l.or r30,r0,r0		; #clear r30
   l.or r31,r0,r0		; #clear r31		

// Jump to start of program

   load32i r2, (Start)
   l.jr    r2
   l.nop

/*
 * Exceptions
 */
exception_vector        bus_error               0x200 - 0x100 // Sector .vectors start at 0x100
exception_vector        data_page_fault         0x300 - 0x100 // Sector .vectors start at 0x100
exception_vector        instruction_page_fault  0x400 - 0x100 // Sector .vectors start at 0x100
exception_vector        tick_timer              0x500 - 0x100 // Sector .vectors start at 0x100 //Low PRIO Interrupt?
exception_vector        unaligned_access        0x600 - 0x100 // Sector .vectors start at 0x100
exception_vector        illegal_instruction     0x700 - 0x100 // Sector .vectors start at 0x100


// Defines what will happen when an external interrupt occurs

.org 0x800 - 0x100

        .global  __external_IRQ

__external_IRQ:
   /*
   Redzone: We are not allowed to touch 128 bytes past stack pointer.
   We could also use gcc flag -mredzone=0
   */
   l.addi r1,r1,-128

   //Reserve Return Address
   l.addi r1,r1,-4
   l.sw 0x00(r1),r9

   l.jal (save_state)
   l.nop

   /*
   If we nested exceptions, we would need to save this (SR's previous state)
   l.mfspr r3,r0,SPR_ESR_BASE
   */

   l.jal (external_exception)
   l.nop

   l.jal (restore_state)
   l.nop

   l.lwz r9 ,0x00(r1)
   l.addi r1,r1,4

   /*Restore Redzone*/
   l.addi r1,r1,128

   //Return from exception
   l.rfe

/* Exceptions Cont. */
exception_vector        data_tlb_miss           0x900 - 0x100 // Sector .vectors start at 0x100
exception_vector        instruction_tlb_miss    0xA00 - 0x100 // Sector .vectors start at 0x100
exception_vector        range                   0xB00 - 0x100 // Sector .vectors start at 0x100
exception_vector        system_call             0xC00 - 0x100 // Sector .vectors start at 0x100
exception_vector        floating_point          0xD00 - 0x100 // Sector .vectors start at 0x100
exception_vector        trap                    0xE00 - 0x100 // Sector .vectors start at 0x100
exception_vector        unknown                 0x1F00 - 0x100 // Sector .vectors start at 0x100

//
//
//

.section .text, "ax"
// Save current state (all general purpose registers)
save_state:
   //Reserve Stack Space
   l.addi r1,r1, -29*4
   l.sw 0x0(r1),r2
   l.sw 0x4(r1),r3
   l.sw 0x8(r1),r4
   l.sw 0xc(r1),r5
   l.sw 0x10(r1),r6
   l.sw 0x14(r1),r7
   l.sw 0x18(r1),r8
   l.sw 0x20(r1),r10
   l.sw 0x24(r1),r11
   l.sw 0x28(r1),r12
   l.sw 0x2c(r1),r13
   l.sw 0x30(r1),r14
   l.sw 0x34(r1),r15
   l.sw 0x38(r1),r16
   l.sw 0x3c(r1),r17
   l.sw 0x40(r1),r18
   l.sw 0x44(r1),r19
   l.sw 0x48(r1),r20
   l.sw 0x4c(r1),r21
   l.sw 0x50(r1),r22
   l.sw 0x54(r1),r23
   l.sw 0x58(r1),r24
   l.sw 0x5c(r1),r25
   l.sw 0x60(r1),r26
   l.sw 0x64(r1),r27
   l.sw 0x68(r1),r28
   l.sw 0x6c(r1),r29
   l.sw 0x70(r1),r30
   l.sw 0x1C(r1),r31
   l.jr r9
   l.nop

// Restore current state
restore_state:
   l.lwz r2  ,0x0(r1)
   l.lwz r3  ,0x4(r1)
   l.lwz r4  ,0x8(r1)
   l.lwz r5  ,0xc(r1)
   l.lwz r6 ,0x10(r1)
   l.lwz r7 ,0x14(r1)
   l.lwz r8 ,0x18(r1)
   l.lwz r10,0x20(r1)
   l.lwz r11,0x24(r1)
   l.lwz r12,0x28(r1)
   l.lwz r13,0x2c(r1)
   l.lwz r14,0x30(r1)
   l.lwz r15,0x34(r1)
   l.lwz r16,0x38(r1)
   l.lwz r17,0x3c(r1)
   l.lwz r18,0x40(r1)
   l.lwz r19,0x44(r1)
   l.lwz r20,0x48(r1)
   l.lwz r21,0x4c(r1)
   l.lwz r22,0x50(r1)
   l.lwz r23,0x54(r1)
   l.lwz r24,0x58(r1)
   l.lwz r25,0x5c(r1)
   l.lwz r26,0x60(r1)
   l.lwz r27,0x64(r1)
   l.lwz r28,0x68(r1)
   l.lwz r29,0x6c(r1)
   l.lwz r30,0x70(r1)
   l.lwz r31,0x1C(r1)
   //Restore Stack
   l.addi r1,r1,29*4
   l.jr r9
   l.nop

