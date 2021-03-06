;**************************************************************************************************
;*
;*  NAME
;*	Compare.asm
;*
;*  DESCRIPTION
;*	String comparison function.
;*
;*  AUTHOR
;*	Christian Vigh, 11/2012.
;*
;*  HISTORY
;*  [Version : 1.0]		[Author : CV]		[Date : 2012/11/11]
;*	Initial version.
;*
;******************************************************************************************************

;
; Masm32 include files.
;
.NOCREF
	INCLUDE		Kernel32.inc
	INCLUDE		User32.inc
.CREF

;
; Generic include files
;
.NOLIST
	INCLUDE		Macros.inc
	INCLUDE		Assembler.inc
	INCLUDE		String.inc
.LIST


.CODE

;==================================================================================================
;
; String$Compare -
;	Compares two zero-terminated strings. The comparison is case-sensitive.
;
; INPUT :
;	RCX -
;		Pointer to the first string.
;
;	RDX -
;		Pointer to the second string.
;
; OUTPUT :
;	EAX -
;		-1 if RCX < RDX, +1 if RCX > RDX, 0 if RCX == RDX.
;
;	ZF -
;		ZF will be set to 1 if both strings are identical.
;
;==================================================================================================
String$Compare	PROC
	PUSHES		RBX, RDX, RSI

	MOV		RSI, RCX			; RSI = String A, RDX = String B

	; The main comparison loop
CompareLoop :
	LODSB						; Get next char from string A
	MOV		BL, [ RDX ]			; then from string B

	; Simple case : test if both characters are unequal
	CMP		BL, AL				; Compare both characters
	JL		Less				; Character from string A is less than character from string B
	JG		Greater				; Or character from string A is greater than character from string B

	; Characters are equal : check if both are zero
	OR		AL, AL
	JZ		Zero

	; Characters are equal ; process next ones
	INC		RDX
	JMP		CompareLoop

	; We arrive here when one character from string A is less than the corresponding one in string B
Less :
	XOR		RAX, RAX			; Return 1
	INC		RAX
	POPS		RBX, RDX, RSI	
	RET

	; Save case, but character from A is greater than character from B
Greater :
	XOR		RAX, RAX			; Return -1
	DEC		RAX
	POPS		RBX, RDX, RSI	
	RET

	; Special case : both strings have the same length
Zero :
	XOR		RAX, RAX			; Return 0, which incidentally sets ZF to 1
	POPS		RBX, RDX, RSI	
	RET
String$Compare	ENDP

END
