;**************************************************************************************************
;*
;*  NAME
;*	ToUpperChar.asm
;*
;*  DESCRIPTION
;*	Translates a character to uppercase.
;*
;*  AUTHOR
;*	Christian Vigh, 11/2012.
;*
;*  HISTORY
;*  [Version : 1.0]		[Author : CV]		[Date : 2012/11/11]
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
; String$ToUpperChar -
;	Converts a character to uppercase.
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
String$ToUpperChar	PROC
	; Process only the characters that fall into a letter range
	CMP		AL, 'a'
	JL		Next
	CMP		AL, 'z'
	JG		Next

	AND		AL, 0DFH			; Cancel the bit that transforms a lowercase letter to its uppercase equivalent

Next :
	RET
String$ToUpperChar	ENDP

END