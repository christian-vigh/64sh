;**************************************************************************************************
;*
;*  NAME
;*	ToLowerChar.asm
;*
;*  DESCRIPTION
;*	Translates a character to lowercase.
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
; String$ToLowerChar -
;	Converts a character to lowercase.
;
; INPUT :
;	AL -
;		Character to be translated.
;
; OUTPUT :
;	AL -
;		Translated character.
;
;==================================================================================================
String$ToLowerChar	PROC
	; Process only the characters that fall into a letter range
	CMP		AL, 'A'
	JL		Next
	CMP		AL, 'Z'
	JG		Next

	OR		AL, 020H			; Cancel the bit that transforms a lowercase letter to its Lowercase equivalent

Next :
	RET
String$ToLowerChar	ENDP

END