;**************************************************************************************************************
;*
;*  NAME
;*	DuplicateString.asm
;*
;*   DESCRIPTION
;*	Duplicates a string.
;*
;*  AUTHOR
;* 	Christian Vigh, 11/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/11/18]     [Author : CV]
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
;=	DuplicateString - Duplicates a string.
;=
;=   DESCRIPTION
;=	Duplicates a string into the destination string.
;=
;=   INPUT
;=	RCX -
;=		Address of the resulting string.
;=
;=	RDX -
;=		Address of string to be duplicated.
;=
;=	R8 -
;=		Copy count.
;=
;=   OUTPUT
;=	RAX -
;=		Points to the end of the concatenated string.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$DuplicateString	PROC
	PUSHES		RCX, RSI, RDI

	MOV		RDI, RCX				; RDX <- Destination address

	; Main copy loop : each iteration copies the string from RDX to current RDI value
CopyLoop :
	OR		R8, R8					; Stop if we met the copy count
	JZ		TheEnd

	MOV		RSI, RDX				; Get source string address

	; Individual copies of the string pointed to by RDX
CopyStringLoop :
	LODSB							; Get next character

	OR		AL, AL					; Stop if we found the end of string
	JZ		EndOfCopyString

	STOSB							; Otherwise copy the character
	JMP		CopyStringLoop				; And shoot again

EndOfCopyString :
	DEC		R8					; String copied ; count one occurrence less
	JMP		CopyLoop

	; End of string copy loop
TheEnd :
	MOV		RCX, RDI				; RDI points to the end of string : save it into RCX			
	STOSB							; Store a zero value for the end of the string
	MOV		RAX, RCX				; Return a pointer to the end of the string

	POPS		RCX, RSI, RDI
	RET
String$DuplicateString	ENDP

END