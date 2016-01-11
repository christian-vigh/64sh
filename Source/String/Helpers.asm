;**************************************************************************************************
;*
;*  NAME
;*	Helpers.asm
;*
;*  DESCRIPTION
;*	Helper functions for the String package.
;*
;*  AUTHOR
;*	Christian Vigh, 11/2012.
;*
;*  HISTORY
;*  [Version : 1.0]		[Author : CV]		[Date : 2012/11/17]
;*	Initial version.
;*
;******************************************************************************************************

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

;==================================================================================================
;
; String@FindEOS -
;	Returns a pointer to the end of the string (locates the null terminator).
;
; INPUT :
;	RCX -
;		Pointer to the string.
;
; OUTPUT :
;	RAX -
;		Pointer to the end of the string (the trailing zero).
;
;==================================================================================================
String@FindEOS		PROC
	PUSHREGS	RCX, RDI

	MOV		RDI, RCX			; RDI <- Pointer to string
	XOR		RCX, RCX			; Search for at most 0xFFF....FFFF bytes
	DEC		RCX
	XOR		AL, AL				; Search for a byte having the value 0
	REPNE		SCASB				; perform the search

	MOV		RAX, RDI			; Move pointer to the trailing zero into RAX
	DEC		RAX				; Adjust to point to the trailing zero

	POPREGS	
	RET
String@FindEOS		ENDP

END
