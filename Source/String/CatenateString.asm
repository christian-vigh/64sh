;**************************************************************************************************
;*
;*  NAME
;*	CatenateString.asm
;*
;*  DESCRIPTION
;*	Catenates a string to an existing one.
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
; String$CatenateString -
;	Catenates a string to another one.
;
; INPUT :
;	RCX -
;		Pointer to the destination string.
;
;	RDX -
;		Pointer to the string to be catenated.
;
; OUTPUT :
;	RAX -
;		Pointer to the last character of the destination string.
;
;==================================================================================================
String$CatenateString	PROC
	PUSHES		RCX, RDX, RSI, RDI

	CALL		String@FindEOS			; Get a pointer to the terminating null of the destination string
	MOV		RDI, RAX			; RDI will point to the destination string terminating zero
	MOV		RSI, RDX			; RDI = string to copy

	; Copy all characters from RDX (now RSI) to RCX (now RDI)
CopyLoop :
	LODSB						; Get next char
	OR		AL, AL				; Break loop if terminating zero has been found
	JZ		TheEnd

	STOSB						; End of string no found yet : copy next character
	JMP		CopyLoop			; And shoot again

TheEnd :
	MOV		BYTE PTR [ RDI ], 0		; Don't forget the trailing zero

	POPS		RCX, RDX, RSI, RDI
	RET
String$CatenateString	ENDP

END