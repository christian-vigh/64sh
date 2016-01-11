;**************************************************************************************************************
;
;   NAME
;	CompareFixed.asm
;
;   DESCRIPTION
;	Compares two string on a fixed length.
;
;   AUTHOR
; 	Christian Vigh, 11/2012.
;
;   HISTORY
;   [Version : 1.0]    [Date : 2012/11/18]     [Author : CV]
;	Initial version.
;
;**************************************************************************************************************/

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
; String$CompareFixed -
;	Compares two zero-terminated strings for the specified length. The comparison is 
;	case-sensitive. No more than R8 characters will be compared.
;
; INPUT :
;	RCX -
;		Pointer to the first string.
;
;	RDX -
;		Pointer to the second string.
;
;	R8D -
;		Max string length.
;
; OUTPUT :
;	EAX -
;		-1 if RCX < RDX, +1 if RCX > RDX, 0 if RCX == RDX.
;
;	ZF -
;		ZF will be set to 1 if both strings are identical.
;
;==================================================================================================
String$CompareFixed	PROC
	PUSHES		RBX, RDX, RSI, R8

	MOV		RSI, RCX			; RSI = String A, RDX = String B

	; The main comparison loop
CompareLoop :
	OR		R8D, R8D			; Exit if we reached the maximum number of characters to compare
	JZ		Zero

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
	DEC		R8D				; Count one character less
	JMP		CompareLoop

	; We arrive here when one character from string A is less than the corresponding one in string B
Less :
	XOR		RAX, RAX			; Return 1
	INC		RAX
	POPS		RBX, RDX, RSI, R8
	RET

	; Save case, but character from A is greater than character from B
Greater :
	XOR		RAX, RAX			; Return -1
	DEC		RAX
	POPS		RBX, RDX, RSI, R8	
	RET

	; Special case : both strings have the same length
Zero :
	XOR		RAX, RAX			; Return 0, which incidentally sets ZF to 1
	POPS		RBX, RDX, RSI, R8	
	RET
String$CompareFixed	ENDP

END
