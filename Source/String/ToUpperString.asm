;**************************************************************************************************
;*
;*  NAME
;*	ToUpperString.asm
;*
;*  DESCRIPTION
;*	Translates a string to all uppercase.
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
; String$ToUpperString -
;	Converts a string to uppercase.
;
; INPUT :
;	RCX -
;		Pointer to the first string.
;
; OUTPUT :
;	None.
;
;==================================================================================================
String$ToUpperString	PROC
	PUSHREGS	RAX, RSI, RDI

	MOV		RSI, RCX			; RDI and RSI will point to the string
	MOV		RDI, RCX

	; Conversion loop
ConvertLoop :
	LODSB						; Get next character

	OR		AL, AL				; If null, this means the end of the string
	JZ		Return

	; Process only the characters that fall into a letter range
	CMP		AL, 'a'
	JL		Next
	CMP		AL, 'z'
	JG		Next

	AND		AL, 0DFH			; Cancel the bit that transforms a lowercase letter to its uppercase equivalent
	STOSB						; ... and store the result
	JMP		ConvertLoop

	; Other cases, no conversion needed
Next :
	INC		RDI				; Make RDI point to the next character in the string, like RSI
	JMP		ConvertLoop			; and shoot again

Return :
	POPREGS
	RET
String$ToUpperString	ENDP

END