;**************************************************************************************************************
;*
;*  NAME
;*	Left.asm
;*
;*   DESCRIPTION
;*	Extracts the left portion of a string.
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
;=	Left - Extracts the left portion of a string.
;=
;=   DESCRIPTION
;=	Extracts the left portion of a string, up to the specified number of characters. If the specified
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
String$Left	PROC
	PUSHES		RCX, RSI, RDI

	CALL		String@FindEOS			; Find end of string

	MOV		RDI, R8				; RDI <- Destination string
	MOV		RSI, RCX			; RSI <- Source string
	ADD		RCX, RDX			; Add number of bytes to take
	CMP		RCX, RAX			; Past beyond EOS ?
	CMOVG		RCX, RAX			; Yes, the end pointer will be the end of the string

	SUB		RCX, RSI			; Subtract source pointer to get the number of bytes to copy
	REP		MOVSB				; And perform the copy

	XOR		AL, AL				; Don't forget the trailing zero
	STOSB		

	MOV		RAX, RDI			; Set return value to point to the end of destination string
	DEC		RAX

	POPS		RCX, RSI, RDI
	RET
String$Left	ENDP

END