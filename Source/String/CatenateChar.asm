;**************************************************************************************************
;*
;*  NAME
;*	CatenateChar.asm
;*
;*  DESCRIPTION
;*	Catenates a char to a string.
;*
;*  AUTHOR
;*	Christian Vigh, 11/2012.
;*
;*  HISTORY
;*  [Version : 1.0]		[Author : CV]		[Date : 2012/11/20]
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
; String$CatenateChar -
;	Catenates a character to the specified zero-length string.
;
; INPUT :
;	AL -
;		Character to be catenated.
;
;	RCX -
;		Pointer to the string.
;
; OUTPUT :
;	RAX -
;		Pointer to the last character of the string.
;
;==================================================================================================
String$CatenateChar	PROC
	PUSH		RBX

	MOV		BL, AL				; Save character to be catenated
	CALL		String@FindEOS			; Get a pointer to the terminating null

	MOV		[ RAX ], BL			; Save the character
	INC		RAX				; Add 1 to end of string pointer
	XOR		BL, BL
	MOV		[ RAX ], BL			; And store a new zero

	POP		RBX
	RET
String$CatenateChar	ENDP

END