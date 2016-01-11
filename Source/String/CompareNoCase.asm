;**************************************************************************************************
;*
;*  NAME
;*	CompareNoCase.asm
;*
;*  DESCRIPTION
;*	Case-insensitive string comparison.
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
; String$CompareNoCase -
;	Compares two zero-terminated strings. Comparison is case-insensitive.
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
String$CompareNoCase	PROC
	PUSHES		RBX, RCX, RDX, RSI

	MOV		RSI, RCX			; RSI = String A, RDX = String B
	LEA		RBX, ASCII@UPPERCASE		; We use a translation table to promote lowercase letters to uppercase

	; The main comparison loop
CompareLoop :
	LODSB						; Get next char from string A
	MOV		CL, [ RDX ]			; then from string B

	; Translate lowercase to uppercase
	XCHG		AL, CL
	XLAT
	XCHG		CL, AL
	XLAT

	; Simple case : test if both characters are unequal
	CMP		CL, AL				; Compare both characters
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
	POPS		RBX, RCX, RDX, RSI	
	RET

	; Save case, but character from A is greater than character from B
Greater :
	XOR		RAX, RAX			; Return -1
	DEC		RAX
	POPS		RBX, RCX, RDX, RSI	
	RET

	; Special case : both strings have the same length
Zero :
	XOR		RAX, RAX			; Return 0, which incidentally sets ZF to 1
	POPS		RBX, RCX, RDX, RSI	
	RET
String$CompareNoCase	ENDP

END