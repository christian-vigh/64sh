;**************************************************************************************************************
;*
;*  NAME
;*	SearchChar.asm
;*
;*   DESCRIPTION
;*	Searches a character in a string and returns a pointer to it.
;*
;*  AUTHOR
;* 	Christian Vigh, 11/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/11/19]     [Author : CV]
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
;=	SearchChar@ - Searches a character in a string and returns a pointer to it.
;=
;=   DESCRIPTION
;=	Searches for the specified char in AL.
;=
;=   INPUT
;=	AL -
;=		Character to be searched.
;=
;=	RCX -
;=		Pointer to the string to be searched.
;=
;=   OUTPUT
;=	RAX -
;=		Pointer to the found character in the string, or zero if not found.
;=
;=	ZF -
;=		ZF will be set to 1 if the character is not found.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$SearchChar	PROC
	PUSHES		RBX, RCX, RSI, RDI

	MOV		BL, AL				; Save character to be searched
	CALL		String@FindEOS			; Find the end of the string

	MOV		RDI, RCX			; Destination pointer for the search
	MOV		RCX, RAX			; Compute the maximum number of characters to be scanned
	SUB		RCX, RDI			; ... which is eos (RAX) - bos (RCX)
	MOV		AL, BL				; Restore the character to be searched
	REPNE		SCASB				; And scan the string
	JZ		Found				; If found, ZF will be set to 0

	; Character not found
	XOR		RAX, RAX			; Return null pointer
	POPS		RBX, RCX, RSI, RDI
	RET

	; Character found
Found :
	MOV		RAX, RDI			; Return the character pointer
	DEC		RAX				; But don't forget that we moved past the character found
	POPS		RBX, RCX, RSI, RDI
	RET
String$SearchChar	ENDP

END