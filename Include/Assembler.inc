;**************************************************************************************************
;*
;*  NAME
;*	Assembler.inc
;*
;*  DESCRIPTION
;*	General macros for the assembly language.
;*
;*  AUTHOR
;*	Christian Vigh, 11/2012.
;*
;*  HISTORY
;*  [Version : 1.0]		[Author : CV]		[Date : 2012/11/05]
;*	Initial version.
;*
;**************************************************************************************************


;==================================================================================================
;=
;=  Constants.
;=
;==================================================================================================

;
; EFLAGS register
;
EFLAGS_CF		EQU		000000001H		; Carry flag : Set if an arithmetic operation generates a carry or a borrow out of the most-significant bit 
								; of the result ; cleared othrwise.
EFLAGS_PF		EQU		000000004H		; Parity flag — Set if the least-significant byte of the result contains an even number of 1 bits; cleared otherwise.
EFLAGS_AF		EQU		000000010H		; Auxiliary carry flag : Adjust flag — Set if an arithmetic operation generates a carry or a borrow out of bit 3 of 
								; the result ; cleared otherwise. This flag is used in binary-coded decimal (BCD) arithmetic.
EFLAGS_ZF		EQU		000000040H		; Zero flag — Set if the result is zero ; cleared otherwise.
EFLAGS_SF		EQU		000000080H		; Sign flag — Set equal to the most-significant bit of the result, which is the sign bit of a signed integer. 
								; (0 indicates a positive value and 1 indicates a negative value.)
EFLAGS_TF		EQU		000000100H		; Trap flag — Set to enable single-step mode for debugging ; clear to disable single-step mode.
EFLAGS_IF		EQU		000000200H		; Interrupt enable flag — Controls the response of the processor to maskable interrupt requests. Set to respond to
								; maskable interrupts; cleared to inhibit maskable interrupts.
EFLAGS_DF		EQU		000000400H		; The direction flag (DF, located in bit 10 of the EFLAGS register) controls string instructions 
								; (MOVS, CMPS, SCAS, LODS, and STOS).
EFLAGS_OF		EQU		000000800H		; Overflow flag — Set if the integer result is too large a positive number or too small a negative number 
								; (excluding the sign-bit) to fit in the destination operand; cleared otherwise. This flag indicates an overflow 
								; condition for signed-integer (two’s complement) arithmetic.
EFLAGS_IOPL		EQU		000003000H		; I/O privilege level field — Indicates the I/O privilege level of the currently running program or task. 
								; The current privilege level (CPL) of the currently running program or task must be less than or equal to the 
								; I/O privilege level to access the I/O address space. This field can only be modified by the POPF and IRET instructions 
								; when operating at a CPL of 0.
EFLAGS_NT		EQU		000004000H		; Nested task flag — Controls the chaining of interrupted and called tasks. Set when the current task is linked to 
								; the previously executed task; cleared when the current task is not linked to another task.
EFLAGS_RF		EQU		000010000H		; Resume flag — Controls the processor’s response to debug exceptions.
EFLAGS_VM		EQU		000020000H		; Virtual-8086 mode flag — Set to enable virtual-8086 mode ; clear to return to protected mode without virtual-8086 
								; mode semantics.
EFLAGS_AC		EQU		000040000H		; Alignment check flag — Set this flag and the AM bit in the CR0 register to enable alignment checking of memory 
								; references ; clear the AC flag and/or the AM bit to disable alignment checking.
EFLAGS_VIF		EQU		000080000H		; Virtual interrupt flag — Virtual image of the IF flag. Used in conjunction with the VIP flag. (To use this flag and 
								; the VIP flag the virtual mode extensions are enabled by setting the VME flag in control register CR4.)
EFLAGS_VIP		EQU		000100000H		; Virtual interrupt pending flag — Set to indicate that an interrupt is pending ; clear when no interrupt is pending. 
								; (Software sets and clears this flag; the processor only reads it.) Used in conjunction with the VIF flag.
EFLAGS_ID		EQU		000200000H		; Identification flag — The ability of a program to set or clear this flag indicates support for the CPUID instruction.


;
; Miscellaneous constants
;
CODE_ALIGNMENT		EQU		8			; Optimal code alignment



;==================================================================================================
;=
;=  PUSHREGS  Regs : VARARGS 
;=  POPREGS
;=	PUSHes or POPs the specified registers. 
;=	POPREGS has no arguments and pops all the registers that have been pushed by PUSHREGS.
;=	Multiple PUSHREGS/POPREGS instructions can be nested.
;=
;==================================================================================================
PUSHREGS  MACRO  Regs : VARARG
	LOCAL	Registers

	;; "Create" a stack to be able to handle nested PUSHREGS/POPREGS combinations
	STACK$CREATE  PushedRegisters

	Registers	EQU  <>
	@PUSHEDREGS	=    0

	;; For POPREGS to be able to pop the registers pushed by PUSHREGS in reverse order, we build a string
	;; (Registers) where the register names appear in reverse order, separated by a '#' sign
	FOR Reg, <Regs>
		Registers	CATSTR <Reg>, <#>, Registers		;; Add current register name to the "list"
		PUSH	Reg						;; Push it
		@PUSHEDREGS	=  @PUSHEDREGS + 1
	ENDM

	;; Push this new register list onto the stack
	STACK$PUSH PushedRegisters, Registers
ENDM

POPREGS  MACRO
	LOCAL	Pos, Pos2, Len, Reg, Registers

	;; Note : use TEXTEQU instead of EQU, because the former forces the evaluation of the call
	;;        to the STACK$POP macro function, whereas the latter creates an equate whose value
	;;	  (the call to the STACK$POP macro) is evaluated each time the equate is referenced,
	;;	 thus calling STACK$POP upon each equate reference.
	Registers	TEXTEQU  STACK$POP  ( PushedRegisters )
	Pos		=		1
	Len		SIZESTR		Registers

	;; The string is composed of register names followed by "#", such as :
	;;	EAX#EBX#
	;; The last character is always "#". We need now to retrieve inidividual register names.
	WHILE Pos  LE  Len
		Pos2	INSTR	Pos, Registers, <#>		;; Get position of next "#" character

		IF  Pos2  LT  Pos				;; Paranoia : string is not terminated by "#"
			EXITM
		ENDIF

		Reg	SUBSTR  Registers, Pos, Pos2 - Pos	;; Get register name
		Pos	=  Pos2 + 1				;; New current position is after the last "#" encountered so far

		POP	Reg					;; Issue the POP instruction
	ENDM
ENDM


;==================================================================================================
;=
;=  PUSHES  Regs : VARARGS 
;=  POPS
;=	A version of PUSREGS and POPREGS which does not "remember" the registers you have pushed.
;=	You thus can use multiple POPS instructions for one PUSHES.
;=	Specify for POPS the registers you specified for PUSHES, in the reverse order.
;=
;==================================================================================================
PUSHES  MACRO	Regs : VARARG
	FOR  Reg, <Regs>
		PUSH		Reg
	ENDM
ENDM


POPS	MACRO	Regs : VARARG
	LOCAL		Registers, Pos, Len, Pos2, PopReg

	Registers		TEXTEQU		<>

	;; Reverse the <Regs> parameter list
	FOR  Reg, <Regs>
		Registers	CATSTR	<Reg>, <#>, Registers
	ENDM

	Pos		=		1
	Len		SIZESTR		Registers

	;; The string is composed of register names followed by "#", such as :
	;;	EAX#EBX#
	;; The last character is always "#". We need now to retrieve inidividual register names.
	WHILE Pos  LE  Len
		Pos2	INSTR	Pos, Registers, <#>		;; Get position of next "#" character

		IF  Pos2  LT  Pos				;; Paranoia : string is not terminated by "#"
			EXITM
		ENDIF

		Reg	SUBSTR  Registers, Pos, Pos2 - Pos	;; Get register name
		Pos	=  Pos2 + 1				;; New current position is after the last "#" encountered so far

		POP	Reg					;; Issue the POP instruction
	ENDM
ENDM


;==================================================================================================
;=
;=  Simple assembly macros.
;=
;==================================================================================================

; MOVMM -
;	Moves Mem2 to Mem1 using the specified register. 
MOVMM	MACRO	Mem1 : REQ, Mem2 : REQ, Reg : REQ
	MOV	Reg, Mem2
	MOV	Mem1, Reg
ENDM


; SWAPMM -
;	Moves Mem2 to Mem1 using the specified register. 
SWAPMM	MACRO	Mem1 : REQ, Mem2 : REQ, Reg : REQ
	MOV	Reg, Mem2
	XCHG	Reg, Mem1
	MOV	Mem2, Reg
ENDM


; SFPTR -
;	Casts the specified register to a pointer to a field of a structure.
;	Usage : 
;		MOV   RSI, SFPTR ( RBX, StructureName.FieldName )
SFPTR	MACRO  Register : REQ, QualifiedField : REQ
	LOCAL	DotPos, StructureName, FieldName, Result

	DotPos		INSTR	<QualifiedField>, <.>
	StructureName	SUBSTR  <QualifiedField>, 1, DotPos - 1
	FieldName	SUBSTR	<QualifiedField>, DotPos + 1
	Result		CATSTR  <( >, StructureName, < PTR [>, <Register>, <] ). >, FieldName

	EXITM	Result
ENDM


;==================================================================================================
;=
;=  Padding and alignement.
;=
;==================================================================================================

; NPAD -
;	Pads code with NOP forms.
NPAD	MACRO  Value : REQ
	LOCAL		PadMacroName, PadValue

	IF   Value  GE  1
		IF  Value  LE  9
			PadMacroName	CATSTR  <NPAD>, <Value>
			PadMacroName
		ELSE
			PadValue	= Value - 9
			NPAD9
			NPAD PadValue
		ENDIF
	ENDIF
ENDM


; NPADx macros -
;	Those macros insert NOP instructions in the way recommended by Intel.
NPAD1	MACRO
	DB	90H
ENDM

NPAD2	MACRO
	DB	66H, 90H
ENDM

NPAD3	MACRO
	DB	0FH, 1FH, 00H
ENDM

NPAD4	MACRO
	DB	0FH, 1FH, 40H, 00H
ENDM

NPAD5	MACRO
	DB	0FH, 1FH, 44H, 00H, 00H
ENDM

NPAD6	MACRO
	DB	66H, 0FH, 1FH, 44H, 00H, 00H
ENDM

NPAD7	MACRO
	DB	0FH, 1FH, 80H, 00H, 00H, 00H, 00H
ENDM

NPAD8	MACRO
	DB	0FH, 1FH, 84H, 00H, 00H, 00H, 00H 00H
ENDM

NPAD9	MACRO
	DB	66H, 0FH, 1FH, 84H, 00H, 00H 00H 00H, 00H
ENDM

; ALIGNCODE -
;	Aligns the code to the CODE_ALIGNMENT constant.
ALIGNCODE	MACRO
	ALIGN ( CODE_ALIGNMENT )
ENDM


; ALIGNPTR -
;	Aligns a pointer held in a register to the specified value.
ALIGNPTR	MACRO	Reg : REQ, Alignment : REQ
	LOCAL		IsValid, AlignmentOffset

	IsValid		=  0

	IF  $IsRegister ( Reg )  EQ  0
		.ERR <ALIGNPTR : The first parameter should be a register. Reg was specified.>
	ENDIF

	IF  Alignment  EQ  2 
		IsValid = 1
	ENDIF

	IF  Alignment  EQ  4
		IsValid = 1
	ENDIF

	IF  Alignment  EQ  8
		IsValid = 1
	ENDIF

	IF  Alignment  EQ  16
		IsValid = 1
	ENDIF

	IF  Alignment  EQ  32
		IsValid = 1
	ENDIF

	IF  Alignment  EQ  64
		IsValid = 1
	ENDIF

	IF  Alignment  EQ  128
		IsValid = 1
	ENDIF

	IF  Alignment  EQ  256
		IsValid = 1
	ENDIF

	IF  IsValid  EQ  0
		.ERR <ALIGNPTR : The !alignment value should be a power of two, between 2 and 256. Alignment was specified.>
	ENDIF

	AlignmentOffset		=  Alignment - 1
	ADD		Reg, AlignmentOffset
	AND		Reg, NOT AlignmentOffset
ENDM