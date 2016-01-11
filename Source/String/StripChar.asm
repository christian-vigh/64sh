;**************************************************************************************************************
;*
;*  NAME
;*	StripChar.asm
;*
;*   DESCRIPTION
;*	Strips all occurrences of the specified char from a string.
;*
;*  AUTHOR
;* 	Christian Vigh, 12/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/12/04]     [Author : CV]
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
;=	StripChar - Strips all occurrences of a character from a string.
;=
;=   DESCRIPTION
;=	Removes all occurrences of the specified character from the supplied input string.
;=
;=   INPUT
;=	RCX -
;=		Pointer to the string to be searched.
;=
;=	DL -
;=		Character to be removed.
;=
;=   OUTPUT
;=	RAX -
;=		Pointer to the end of the supplied input string, with all occurrences of the specified character
;=		being stripped.
;=
;=	RBX -
;=		Number of characters stripped.
;=
;=	ZF -
;=		ZF will be set to 1 if the character is not found.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$StripChar	PROC
	PUSHREGS	RSI, RDI

	MOV		RSI, RCX			; Both RSI and RDI will point to the start of the supplied
	MOV		RDI, RCX
	XOR		EBX, EBX			; Occurrence count

	; Character stripping loop
StripLoop :
	LODSB						; Get next character
	OR		AL, AL				; We're over when we encounter the trailing zero
	JZ		Stripped

	CMP		AL, DL				; If current character isn't the character to be stripped...
	JNE		NotStripped			; ... then store it
	INC		EBX				; Otherwise, count one more occurrence
	JMP		StripLoop			; And shoot again

NotStripped :
	STOSB						; Current character must not be stripped so store it
	JMP		StripLoop			; And shoot again

Stripped :
	MOV		BYTE PTR [ RDI ], AL		; Don't forget to store the last character (the trailing zero)

	MOV		RAX, RDI			; RAX points to the end of the string
	OR		EBX, EBX			; Set ZF if no occurrence found

	POPREGS
	RET
String$StripChar	ENDP

END