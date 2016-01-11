;**************************************************************************************************
;*
;*  NAME
;*	Length.asm
;*
;*  DESCRIPTION
;*	Returns the length of a string.
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
; String$Length -
;	Returns The length of a string, not including the trailing zero.
;
; INPUT :
;	RCX -
;		Pointer to the string.
;
; OUTPUT :
;	RAX -
;		String length.
;
;==================================================================================================
String$Length		PROC
	CALL		String@FindEOS
	SUB		RAX, RCX
	RET
String$Length		ENDP


END