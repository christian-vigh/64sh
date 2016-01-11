;**************************************************************************************************************
;*
;*  NAME
;*	RepeatChar.asm
;*
;*   DESCRIPTION
;*	Repeats a character n times.
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
;=	RepeatChar - Repeats a character n times.
;=
;=   DESCRIPTION
;=	Repeats in the buffer pointed to by RCX the character provided in DL. The number of repetions is given
;=	by R8.
;=
;=   INPUT
;=	RCX -
;=		Pointer to the buffer which will receive the repetitions of the specified character.
;=
;=	DL -
;=		Character to be repeated.
;=
;=	R8 -
;=		Repetition count.
;=
;=   OUTPUT
;=	RAX -
;=		Pointer to the next position after the last repeated character in the supplied input buffer.
;=
;=   REGISTERS USED
;=	None.
;=
;=   NOTES
;=	RepeatChar does not put a final null at the end of the string.
;=
;===============================================================================================================*/
String$RepeatChar	PROC
	PUSHREGS	RCX, RDX, RDI

	; Initializations
	MOVZX		EAX, DL				; Move character to write into AL
	MOV		RDI, RCX			; Make RDI point to destination buffer
	MOV		RCX, R8				; And byte count into RCX

	CMP		RCX, 16				; If less than 16 characters to repeat...
	JL		CopyRemaining			; ... then use the LODSB instruction

	; The repeat count is greater than 16 : we will use SS2 instructions for that
	MOVD		XMM0, EAX			; Move the character to repeat into XMM0
	XORPD		XMM1, XMM1			; Shuffle mask : each corresponding position in destination register will hold the byte value in position 0
	PSHUFB		XMM0, XMM1			; Shuffle : now, XMM is all filled with the byte value specified in DL

	; Initialize by 128-bits chunks
	ALIGN ( 8 )
VectorCopy :
	MOVDQU		[RDI], XMM0			; Store next 128-bits value containing bytes that are all equal to DL
	LEA		RDI, [ RDI + 16 ]		; Move 16 bytes forward
	SUB		RCX, 16				; Check if at least 16 bytes remain to be initialized
	CMP		RCX, 16
	JGE		VectorCopy			; If yes, shoot again

	; We finish the copy using LODSBs when less than 16 bytes remain
CopyRemaining :
	REP		STOSB

	MOV		RAX, RDI			; Set return value to point after the last byte initialized

	POPREGS
	RET
String$RepeatChar	ENDP

END