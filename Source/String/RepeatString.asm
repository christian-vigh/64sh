;**************************************************************************************************************
;*
;*  NAME
;*	RepeatString.asm
;*
;*   DESCRIPTION
;*	Repeats a string n times.
;*
;*  AUTHOR
;* 	Christian Vigh, 12/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/12/07]     [Author : CV]
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
;=	RepeatString - Repeats a string n times.
;=
;=   DESCRIPTION
;=	Repeats in the buffer pointed to by RCX the string provided in RDX. The number of repetions is given
;=	by R8.
;=
;=   INPUT
;=	RCX -
;=		Pointer to the buffer which will receive the repetitions of the specified string.
;=
;=	RDX -
;=		Zero-terminated string to be repeated.
;=
;=	R8 -
;=		Repetition count.
;=
;=   OUTPUT
;=	RAX -
;=		Pointer to the next position after the last repeated string in the supplied input buffer.
;=
;=   REGISTERS USED
;=	None.
;=
;=   NOTES
;=	RepeatString puts a final null at the end of the string.
;=
;===============================================================================================================*/
String$RepeatString	PROC
	PUSHREGS	RCX, RDX, RSI, RDI, R8, R9

	MOV		RDI, RCX			; RDI points to the destination buffer

	MOV		RCX, RDX			; Get end of string address
	CALL		String@FindEOS

	MOV		R9, RAX				; Compute number of characters in the string to be repeated
	SUB		R9, RDX

	OR		R8, R8				; Make sure occurrence count is non-zero
	JZ		Copied				; If not, we're over

	; Main copy loop
CopyLoop :	
	MOV		RSI, RDX			; RSI points the the string to be repeated
	MOV		RCX, R9				; Number of bytes to be copied
	REP		MOVSB				; Copy the bytes

	DEC		R8				; Count one repetition less
	JNZ		CopyLoop			; And shoot again

	; When we arrive here, the copy is over
Copied :
	XOR		AL, AL				; Store a trailing null into the destination buffer
	MOV		[ RDI ], AL
	MOV		RAX, RDI			; Set the return value to point there...

	POPREGS
	RET
String$RepeatString	ENDP

END