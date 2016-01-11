;**************************************************************************************************
;*
;*  NAME
;*	Primitives.asm
;*
;*  DESCRIPTION
;*	64th primitives.
;*
;*  AUTHOR
;*	Christian Vigh, 11/2012.
;*
;*  HISTORY
;*  [Version : 1.0]		[Author : CV]		[Date : 2012/11/11]
;*	Initial version.
;*
;******************************************************************************************************

.NOLIST
INCLUDE		64sh.inc
.LIST

.CODE

VOCABULARY 	PRIMITIVES

	;==============================================================================================
	; Primitive	:  "+"
	; Stack 	:  ( a b  --  a+b )
	; Return stack	:  N/A
	; Description	:  Adds "a" to "b" and leaves the result on the stack.
	; Usage		:  a b +
	;==============================================================================================
	PRIMITIVE	<+>
		@POP		RAX
		ADD		[ RSP ], RAX
	END_PRIMITIVE


	;==============================================================================================
	; Primitive	:  "++"
	; Stack 	:  ( a  --  a+1 )
	; Return stack	:  N/A
	; Description	:  Adds 1 to "a" and leaves the result on top of the stack.
	; Usage		:  a ++
	;==============================================================================================
	PRIMITIVE	<++>
		INC		QWORD PTR [ RSP ]
	END_PRIMITIVE

	; Usage		:  a ++1
	PRIMITIVE	<++1>				; Alias
		INC		QWORD PTR [ RSP ]
	END_PRIMITIVE

	; Usage		:  a ++2
	PRIMITIVE	<++2>				; Adds "2" instead of "1"
		INC		QWORD PTR [ RSP ]
		INC		QWORD PTR [ RSP ]
	END_PRIMITIVE



	;==============================================================================================
	; Primitive	:  "-"
	; Stack 	:  ( a b  --  a-b )
	; Return stack	:  N/A
	; Description	:  Subtracts "b" from "a" and leaves the result on top of the stack.
	; Usage		: a b - 
	;==============================================================================================
	PRIMITIVE	<->
		@POP		RAX
		SUB		[ RSP ], RAX
	END_PRIMITIVE


	;==============================================================================================
	; Primitive	:  "--"
	; Stack 	:  ( a  --  a-1 )
	; Return stack	:  N/A
	; Description	:  Subtracts 1 from "a" and leaves the result on top of the stack.
	; Usage		:  a --
	;==============================================================================================
	PRIMITIVE	<-->
		DEC		QWORD PTR [ RSP ]
	END_PRIMITIVE

	; Usage		: a --1
	PRIMITIVE	<--1>				; Alias
		DEC		QWORD PTR [ RSP ]
	END_PRIMITIVE

	; Usage		: a --2
	PRIMITIVE	<--2>				; Subtracts "2" instead of "1"
		DEC		QWORD PTR [ RSP ]
		DEC		QWORD PTR [ RSP ]
	END_PRIMITIVE


	;==============================================================================================
	; Primitive	:  "DROP"
	; Stack 	:  ( a  -- )
	; Return stack	:  N/A
	; Description	:  Drops the last value from the stack
	; Usage		:  DROP
	;==============================================================================================
	PRIMITIVE	<DROP>
		@DESTROYS		1
		@POP		RAX
	END_PRIMITIVE


	;==============================================================================================
	; Primitive	:  "DROP2"
	; Stack 	:  ( a a -- )
	; Return stack	:  N/A
	; Description	:  Drops the two last values from the stack
	; Usage		:  DROP2
	;==============================================================================================
	PRIMITIVE	<DROP2>
		@DESTROYS	2
		@POP		RAX
		@POP		RAX
	END_PRIMITIVE


	;==============================================================================================
	; Primitive	:  "DROPn"
	; Stack 	:  ( a ... a n --   ) ( "n" times "a" )
	; Return stack	:  N/A
	; Description	:  Drops the "n" last values from the stack
	; Usage		:  n DROP
	;==============================================================================================
	PRIMITIVE	<DROPn>
		@POP		RAX
		SHL		RAX, @CS_SHIFT
		@DESTROYS	RAX
		SUB		RSP, RAX
	END_PRIMITIVE


	;==============================================================================================
	; Primitive	:  "DUP2"
	; Stack 	:  ( a  --  a a a )
	; Return stack	:  N/A
	; Description	:  Duplicates two times the value on top of the stack
	; Usage		:  a DUP2
	;==============================================================================================
	PRIMITIVE	<DUP2>
		@NEEDS		2
		MOV		RAX, [RSP]
		@PUSH		RAX
		@PUSH		RAX
	END_PRIMITIVE


	;==============================================================================================
	; Primitive	:  "DUPn"
	; Stack 	:  ( a n --  a a ... a )  "n" times
	; Return stack	:  N/A
	; Description	:  Duplicates "n" times the value "a".
	; Usage		:  n DUPn
	;==============================================================================================
	PRIMITIVE	<DUPn>
		@POP		RCX				; Get duplication count
		@POP		RAX				; Get value to duplicate
		@NEEDS		RCX
		STD						; We will duplicate the value downwards the stack
		MOV		RDI, RSP			; Destination pointer is top of stack
		REP		STOSQ				; Perform the duplication
		CLD						; Restore the direction flag
		ADD		RDI, 8				; Along with the real top of stack (the last STOSQ led us 8 bytes after the last value copied)
		MOV		RSP, RDI
	END_PRIMITIVE


	;==============================================================================================
	; Primitive	:  "SWAP"
	; Stack 	:  ( a b --  b a )
	; Return stack	:  N/A
	; Description	:  Swaps the two last values from the stack.
	; Usage		:  SWAP
	;==============================================================================================
	PRIMITIVE	<SWAP>
		@NEEDS		2
		MOV		RAX, [ RSP ]
		XCHG		[ RSP - @CS ], RAX
		MOV		[ RSP ], RAX
	END_PRIMITIVE
VOCABULARY_END		PRIMITIVES

END