;**************************************************************************************************************
;*
;*  NAME
;*	CopyFixed.asm
;*
;*   DESCRIPTION
;*	Copies a string to another, for a specified number of characters.
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
;=	CopyFixed - Copies a string up to the specified number of characters.
;=
;=   DESCRIPTION
;=	Copies a string to another destination, up to the specified number of characters.
;=
;=   INPUT
;=	RCX -
;=		Address of string to be copied.
;=
;=	RDX -
;=		Destination address.
;=
;=	R8D -
;=		Maximum number of characters to be copied. If this value exceeds the actual string length, then
;=		the copy will stop.
;=
;=
;=   OUTPUT
;=	RAX -
;=		Set to point the the first character after the characters copied.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$CopyFixed	PROC
	PUSHES		RSI, RDI, R8

	MOV		RSI, RCX			; Set pointers to origin & destination data
	MOV		RDI, RDX

CopyLoop :
	OR		R8D, R8D			; Did we copy the specified number of characters ?
	JZ		TheEnd

	LODSB						; Copy next character from input string
	STOSB

	OR		AL, AL				; If end of string, we can terminate
	JZ		TheEnd

	DEC		R8D				; Count one character to copy less
	JMP		CopyLoop			; Then process next character

TheEnd :
	MOV		RAX, RDI			; Pointer to end of string

	POPS		RSI, RDI, R8
	RET
String$CopyFixed	ENDP

END