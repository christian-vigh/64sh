;**************************************************************************************************************
;*
;*  NAME
;*	ReplaceCharNoCase.asm
;*
;*   DESCRIPTION
;*	Replaces a char in a string with the specified one.
;*
;*  AUTHOR
;* 	Christian Vigh, 11/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/11/22]     [Author : CV]
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
;=	ReplaceCharNoCase - Replaces a character in a string.
;=
;=   DESCRIPTION
;=	Replaces all occurrences of a character in a string with the specified character. The comparison is
;=	case-insensitive.
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
String$ReplaceCharNoCase	PROC
	PUSHES		RBX, RSI, RDI

	MOV		RSI, RCX			; Both RSI and RDI will point to the same address
	MOV		RDI, RCX
	MOV		BX, AX				; Keep a copy of character to be replaced (AL) and character to search (AH)

	CMP		BH, 'a'				; Check if the character to search is a lowercase letter
	JL		ReplaceLoop
	CMP		BH, 'z'
	JG		ReplaceLoop

	AND		BH, 0DFH			; If yes, convert it to an uppercase letter

	; Replacement loop
ReplaceLoop :
	LODSB						; Get next character
	OR		AL, AL				; Exit loop if end of string
	JZ		TheEnd

	MOV		AH, AL				; Check if current character from input string is a lowercase letter
	CMP		AH, 'a'
	JL		NotLowercase
	CMP		AH, 'z'
	JG		NotLowercase

	AND		AH, 0DFH			; If yes, convert it to an uppercase letter

NotLowercase :
	CMP		AH, BH				; Compare the uppercase version of the current character with the uppercase version of the character to be searched
	CMOVE		AX, BX				; If equal, move the character to be replaced (in BL) to AL...
	STOSB						; ... which will be written back here
	JMP		ReplaceLoop			; And shoot again

TheEnd :
	MOV		RAX, RDI			; Return a pointer to the end of the string

	POPS		RBX, RSI, RDI
	RET
String$ReplaceCharNoCase	ENDP

END