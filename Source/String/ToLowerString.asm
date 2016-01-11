;**************************************************************************************************
;*
;*  NAME
;*	ToLowerString.asm
;*
;*  DESCRIPTION
;*	Converts a string to all lowercase.
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
; String$ToLowerString -
;	Converts a string to all lowercase.
;
; INPUT :
;	RCX -
;		Pointer to the first string.
;
; OUTPUT :
;	None.
;
;==================================================================================================
String$ToLowerString	PROC
	PUSHREGS	RAX, RSI, RDI

	MOV		RSI, RCX			; RDI and RSI will point to the string
	MOV		RDI, RCX

	; Conversion loop
ConvertLoop :
	LODSB						; Get next character

	OR		AL, AL				; If null, this means the end of the string
	JZ		Return

	; Process only the characters that fall into a letter range
	CMP		AL, 'A'
	JL		Next
	CMP		AL, 'Z'
	JG		Next

	OR		AL, 020H			; Set the bit that transforms a lowercase letter to its uppercase equivalent
	STOSB						; ... and store the result
	JMP		ConvertLoop

	; Other cases, no conversion needed
Next :
	INC		RDI				; Make RDI point to the next character in the string, like RSI
	JMP		ConvertLoop			; and shoot again

Return :
	POPREGS
	RET
String$ToLowerString	ENDP


END