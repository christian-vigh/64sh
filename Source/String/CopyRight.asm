;**************************************************************************************************************
;*
;*  NAME
;*	CopyRight.asm
;*
;*   DESCRIPTION
;*	Copies the specified number of characters from the right of a string.
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
;=	CopyRight - Copies the right part of a string up to the specified number of characters.
;=
;=   DESCRIPTION
;=	Copies n characters from the right of a string to another destination.
;=
;=   INPUT
;=	RCX -
;=		Address of string to be copied.
;=
;=	RDX -
;=		Destination address.
;=
;=	R8D -
;=		Maximum number of characters to be copied from the right of the string. 
;=		If this value exceeds the actual string length, then the whole string will be copied.
;=
;=
;=   OUTPUT
;=	RAX -
;=		Pointer to the end of the copied string.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$CopyRight	PROC
	PUSHES		RSI, RDI, R8

	CALL		String@FindEOS				; Find the end of string
	MOV		RSI, RAX				; ... into RSI
	SUB		RSI, R8					; Subtract from end of string pointer the number of bytes to be copied

	MOV		RDI, RDX				; RDI <- Destination pointer

	CMP		RCX, RSI				; Check if EOS - Number of bytes to copy does not go before the start of the input string
	JL		CopyLoop

	MOV		RSI, RCX				; If yes, assume that we must start from the beginning of the input string

	; Copy loop, starting from EOS - byte cont
CopyLoop :
	LODSB							; Copy next character
	STOSB

	OR		AL, AL					; If EOS reached, whatever the number of characters to copy, we must stop
	JZ		TheEnd

	JMP		CopyLoop				; Shoot again

	; End of copy loop ; we reached the EOS character
TheEnd :
	MOV		RAX, RDI				; Set return value to point to this trailing zero
	DEC		RAX

	POPS		RSI, RDI, R8
	RET
String$CopyRight	ENDP

END