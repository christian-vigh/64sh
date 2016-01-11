;**************************************************************************************************************
;*
;*  NAME
;*	CopyLeft.asm
;*
;*   DESCRIPTION
;*	Copies the left part of a string up to the specified number of characters.
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
;=	CopyLeft - Copies the left part of a string up to the specified number of characters.
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
;=   OUTPUT
;=	RAX -
;=		Points to the end of the string (the trailing zero).
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$CopyLeft	PROC
	PUSHES		RSI, RDI, R8

	MOV		RSI, RCX			; Set pointers to origin & destination data
	MOV		RDI, RDX

CopyLoop :
	OR		R8D, R8D			; Did we copy the specified number of characters ?
	JZ		CountReached

	LODSB						; Copy next character from input string
	STOSB

	OR		AL, AL				; If end of string, we can terminate
	JZ		EOSReached

	DEC		R8D				; Count one character to copy less
	JMP		CopyLoop			; Then process next character

	; We arrive here if we stopped copying before we met the string terminator character before the specified number of characters to be copied
EOSReached :
	MOV		RAX, RDI			; RDI points to the character after the terminating zero
	DEC		RAX				; So decrement the return value
	POPS		RSI, RDI, R8
	RET

	; We arrive here when the specified number of characters have been copied
CountReached :
	MOV		BYTE PTR [RDI], 0		; Terminate the output string
	MOV		RAX, RDI			; RDI points to the trailing zero
	POPS		RSI, RDI, R8
	RET
String$CopyLeft		ENDP

END