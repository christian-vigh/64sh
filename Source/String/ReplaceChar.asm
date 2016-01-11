;**************************************************************************************************************
;*
;*  NAME
;*	ReplaceChar.asm
;*
;*   DESCRIPTION
;*	Replaces a char in a string with the specified one.
;*
;*  AUTHOR
;* 	Christian Vigh, 11/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/11/21]     [Author : CV]
;*	Initial version.
;*
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

;==============================================================================================================
;=
;=   NAME
;=	ReplaceChar - Replaces a character in a string.
;=
;=   DESCRIPTION
;=	Replaces all occurrences of a character in a string with the specified character.
;=
;=   INPUT
;=	AL -
;=		Character to be replaced.
;=
;=	AH -
;=		Replacement character.
;=
;=	RCX -
;=		Address of the string where the replacement has to take place.
;=
;=   OUTPUT
;=	RAX -
;=		Pointer to the end of the string.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$ReplaceChar	PROC
	PUSHES		RBX, RSI, RDI

	MOV		RSI, RCX			; Both RSI and RDI will point to the same address
	MOV		RDI, RCX
	MOV		BX, AX				; Keep a copy of character to be replaced (AL) and character to search (AH)

	; Replacement loop
ReplaceLoop :
	LODSB						; Get next character
	OR		AL, AL				; Exit loop if end of string
	JZ		TheEnd

	CMP		AL, BH				; Compare current character with the character to be searched
	CMOVE		AX, BX				; If equal, move the character to be replaced (in BL) to AL...
	STOSB						; ... which will be written back here
	JMP		ReplaceLoop			; And shoot again

TheEnd :
	MOV		RAX, RDI			; Return a pointer to the end of the string

	POPS		RBX, RSI, RDI
	RET
String$ReplaceChar	ENDP

END