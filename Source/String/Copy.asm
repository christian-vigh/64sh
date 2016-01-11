;**************************************************************************************************************
;*
;*  NAME
;*	Copy.asm
;*
;*   DESCRIPTION
;*	Copies a string to another.
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
;=	Copy - Copies a string.
;=
;=   DESCRIPTION
;=	Copies a string to another destination.
;=
;=   INPUT
;=	RCX -
;=		Address of string to be copied.
;=
;=	RDX -
;=		Destination address.
;=
;=   OUTPUT
;=	RAX -
;=		Pointer to the string end (which contains the trailing zero).
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$Copy	PROC
	PUSHES		RSI, RDI

	MOV		RSI, RCX			; Set pointers to origin & destination data
	MOV		RDI, RDX

CopyLoop :
	LODSB						; Copy next character from input string
	STOSB

	OR		AL, AL				; If end of string, we can terminate
	JZ		TheEnd

	JMP		CopyLoop			; Otherwise, process next character

TheEnd :
	MOV		RAX, RDI			; Compute pointer to end of string
	DEC		RAX

	POPS		RSI, RDI
	RET
String$Copy	ENDP

END