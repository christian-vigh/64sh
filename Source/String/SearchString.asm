;**************************************************************************************************************
;*
;*  NAME
;*	SearchString.asm
;*
;*   DESCRIPTION
;*	Searches a substring in a string and returns a pointer to it.
;*
;*  AUTHOR
;* 	Christian Vigh, 11/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/11/23]     [Author : CV]
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
;=	SearchString@ - Searches a substring in a string and returns a pointer to it.
;=
;=   DESCRIPTION
;=	Searches the first occurrence of the specified substring.
;=
;=   INPUT
;=	RCX -
;=		Pointer to the string to be searched.
;=
;=	RDX -
;=		Pointer to the string to search.
;=
;=   OUTPUT
;=	RAX -
;=		Pointer to the found substring in the string, or zero if not found.
;=
;=	RBX -
;=		Pointer to the end of the found substring in the string, or zero if not found.
;=
;=	ZF -
;=		ZF will be set to 1 if the substring is not found.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$SearchString	PROC
	PUSHES		RCX, RDX, RDI, R8, R10

	MOV		RDI, RCX				; Source string in RDI because this is what SCASB needs
	CALL		String@FindEOS				; Find end of string
	MOV		RCX, RAX				; And compute max number of characters to be searched
	SUB		RCX, RDI

	XCHG		RCX, RDX				; Compute the length of the string to search
	CALL		String@FindEOS
	MOV		R10, RAX
	SUB		R10, RCX
	XCHG		RCX, RDX

	; Main loop : loop for the position in searched string that starts with the first character of the string to search
FindLoop :
	MOV		AL, [ RDX ]				; Get first character of string to search
	REPNE		SCASB					; Try to find it in the searched string
	JNZ		NotFound				; Character not found means string not found

	; Call the String$CompareFixed function, starting from current position in searched string
	PUSH		RCX					; Save the length of the string to be searched
	MOV		RCX, RDI				; RDI points after the character in searched string that is equal to the
	DEC		RCX					; 1st character in string to search, so decrement it (comparing the same character - the first -
								; two times avoids handling of the special case where the searched string is empty)
	MOV		R8D, R10D				; Searched string length
	CALL		String$CompareFixed
	POP		RCX					; Restore the length of the string to be searched
	JNZ		FindLoop				; And search for the next occurrence of the string to be searched

	; We arrive here when the substring has been found
Found :
	MOV		RAX, RDI				; We return into RAX a pointer in the source string to the first occurrence of the searched string
	DEC		RAX					; Don't forget that SCASB led us one byte past the start of this occurrence
	MOV		RBX, RAX				; And we return into RBX a pointer to the first byte after the matched string
	ADD		RBX, R10
	
	POPS		RCX, RDX, RDI, R8, R10
	RET

	; Substring not found in searched string
NotFound :
	XOR		RAX, RAX				; Set RAX and RBX to zero
	XOR		RBX, RBX

	POPS		RCX, RDX, RDI, R8, R10
	RET
String$SearchString	ENDP

END