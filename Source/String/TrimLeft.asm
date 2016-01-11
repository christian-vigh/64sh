;**************************************************************************************************************
;
;   NAME
;	TrimLeft.asm
;
;   DESCRIPTION
;	Trims a string to the left.
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

;==============================================================================================================
;=
;=   NAME
;=	String$TrimLeft - Trims a string left.
;=
;=   DESCRIPTION
;=	Trims all space characters left to a string.
;=
;=   INPUT
;=	RCX -
;=		Pointer to the string to be trimmed.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$TrimLeft	PROC
	PUSHES		RAX, RSI, RDI
	MOV		RSI, RCX				; Point to the start of the string

TrimLoop :
	LODSB							; get next character
		
	OR		AL, AL					; If end of string reach, then it contains only spaces
	JZ		OnlySpaces

	CMP		AL, ' '					; Ignore spaces
	JE		TrimLoop
	CMP		AL, 9					; And characters from 9 to 13 (TAB, LF, VTAB, FF, CR)
	JL		Copy
	CMP		AL, 13
	JLE		TrimLoop

	; We arrive here when all the space characters from the start of the string have been processed
Copy :
	DEC		RSI					; Adjust RSI since it points to the character after the first non-space character

	CMP		RSI, RCX				; Don't do anything if the string does not contain leading spaces
	JNE		Copy2

	POPS		RAX, RSI, RDI				; And return
	RET

Copy2 :
	MOV		RDI, RCX				; RDI now points to the start of the string

	; We found leading spaces ; we now have to copy the string starting from the first non-space character to the start of the string
CopyLoop :
	LODSB							; Get next character
	STOSB							; Store it
	OR		AL, AL					; If zero, then the copy is over
	JZ		TheEnd
	JMP		CopyLoop				; Otherwise, process next character

	; We arrive here when all characters have been processed and copied
TheEnd :
	POPS		RAX, RSI, RDI
	RET

	; Arriving here means that the string contains only spaces
OnlySpaces :
	MOV		BYTE PTR [RCX], 0			; The string becomes an empty string
	POPS		RAX, RSI, RDI
	RET
String$TrimLeft	ENDP

END