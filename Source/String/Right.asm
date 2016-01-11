;**************************************************************************************************************
;*
;*  NAME
;*	Left.asm
;*
;*   DESCRIPTION
;*	Extracts the right portion of a string.
;*
;*  AUTHOR
;* 	Christian Vigh, 11/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/11/23]     [Author : CV]
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
;=	Right - Extracts the right portion of a string.
;=
;=   DESCRIPTION
;=	Extracts the right portion of a string, up to the specified number of characters. If the specified
;=	number is greater than the string length, the whole string will be extracted.
;=
;=   INPUT
;=	RCX -
;=		Pointer to the source string.
;=
;=	EDX -
;=		Number of characters to be extracted.
;=
;=	R8 -
;=		Pointer to the destination string.
;=
;=   OUTPUT
;=	RAX -
;=		Pointer to the end of the destination string.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$Right	PROC
	PUSHES		RCX, RSI, RDI

	CALL		String@FindEOS			; Find end of string

	MOV		RDI, R8				; RDI <- Destination string
	MOV		RSI, RCX			; RSI <- Source string
	SUB		RAX, RDX			; Subtract number of bytes to take from the end of the source string
	CMP		RAX, RSI			; Before start of string ?
	CMOVG		RSI, RAX			; No, the pointer will be ( EOS - Start of string + number of bytes )

	MOV		RCX, RDI			; Count the (potentially) new number of bytes to copy
	SUB		RCX, RSI
	REP		MOVSB				; And perform the copy

	XOR		AL, AL				; Don't forget the trailing zero
	STOSB		

	MOV		RAX, RDI			; Set return value to point to the end of destination string
	DEC		RAX

	POPS		RCX, RSI, RDI
	RET
String$Right	ENDP

END