;**************************************************************************************************************
;*
;*  NAME
;*	Reverse.asm
;*
;*   DESCRIPTION
;*	Reverses a string.
;*
;*  AUTHOR
;* 	Christian Vigh, 12/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/12/06]     [Author : CV]
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
;=	Reverse - reverses a string.
;=
;=   DESCRIPTION
;=	Reverses the string pointed to by RCX.
;=
;=   INPUT
;=	RCX -
;=		Pointer to the string to be reversed.
;=
;=   OUTPUT
;=	RAX -
;=		Pointer to the end of the string.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$Reverse	PROC
	PUSHREGS	RCX, RDX, RSI, RDI

	CALL		String@FindEOS				; Find last character before the end of string		
	MOV		RDX, RAX
	DEC		RAX

	CMP		RAX, RCX				; If the string is empty or contains only one character, then we have nothing to do
	JLE		Reversed	

	; String is neither empty nor one-character long 
	MOV		RSI, RCX				; RSI will point to the first character of the string
	MOV		RDI, RAX				; And RDI to the last character

	; Now reverse the characters in the string
ReverseLoop : 
	LODSB							; Get next character from start
	MOV		AH, [ RDI ]				; Then next character (downwards) from end
	MOV		[ RDI ], AL				; Then swap both characters
	MOV		[ RSI - 1 ], AH
	DEC		RDI					; Move pointer to last character go downwards

	CMP		RSI, RDI				; Compare pointers to current start character and current end character
	JL		ReverseLoop				; Shoot again if character remains

	; The whole string has been reversed : return a pointer to the end of the string
Reversed :
	MOV		RAX, RDX
	
	POPREGS
	RET
String$Reverse	ENDP

END