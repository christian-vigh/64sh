;**************************************************************************************************************
;*
;*  NAME
;*	DuplicateChar.asm
;*
;*   DESCRIPTION
;*	Duplicates a character.
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
;=	DuplicateChar - Duplicates a character.
;=
;=   DESCRIPTION
;=	Duplicates a char into the destination string.
;=
;=   INPUT
;=	RCX -
;=		Address of the resulting string.
;=
;=	DL -
;=		Char to be duplicated.
;=
;=	R8 -
;=		Copy count.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$DuplicateChar	PROC
	PUSHES		RCX, RDI

	MOV		RDI, RCX			; Destination pointer
	MOV		AL, DL				; AL  <-  character to duplicate
	MOV		RCX, R8				; RCX <-  number of duplications
	REP		STOSB				; Perform duplication

	XOR		AL, AL				; And terminate with a trailing zero
	STOSB

	MOV		RAX, RDI			; Return value is a pointer to the trailing zero
	DEC		RAX				; But adjust the value because we point past this character

	POPS		RCX, RDI
	RET
String$DuplicateChar	ENDP

END