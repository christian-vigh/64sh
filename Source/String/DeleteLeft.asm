;**************************************************************************************************************
;*
;*  NAME
;*	DeleteLeft.asm
;*
;*   DESCRIPTION
;*	Deletes n characters of a string from the left.
;*
;*  AUTHOR
;* 	Christian Vigh, 11/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/11/18]     [Author : CV]
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
;=	DeleteLeft - Deletes n characters of a string from the left.
;=
;=   DESCRIPTION
;=	Deletes n characters from the left of the specified string.
;=
;=   INPUT
;=	RCX -
;=		Address of the string in which the characters are to be deleted.
;=
;=	EDX -
;=		Number of characters to delete. If the specified number of characters is greater than the string
;=		length, then the string will be zeroed.
;=
;=   OUTPUT
;=	RAX -
;=		Points to the end of the string.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$DeleteLeft	PROC
	; If the string is empty or we received an empty count, then there is nothing to do
	OR		EDX, EDX			; Check that the count is not zero
	JZ		IsZero

	MOV		AL, [ RCX ]			; Also check that the first character of the string is not zero
	OR		AL, AL
	JNZ		NotEmpty 

IsZero :
	MOV		RAX, RCX			; Either empty string or count (EDX) = 0 : return
	RET


NotEmpty :
	CALL		String@FindEOS			; Find the end of the string into RAX
	SUB		RAX, RDX			; Subtract the number of characters to delete
	CMP		RAX, RCX			; If the pointer in RAX is still greater than start of the string (RCX) then...
	JG		Continue			; ... we can continue

	MOV		RAX, RCX			; Set the return value to point to the first byte of the string
	MOV		BYTE PTR [ RCX ], 0		; Don't forget to put the trailing zero
	RET

Continue :
	PUSHES		RCX, RDI, RSI

	MOV		RDI, RCX			; Destination pointer (RCX) = start of string
	MOV		RSI, RCX			; Source pointer = start of string + char count (EDX)
	ADD		RSI, RDX			
	SUB		RAX, RCX			; Compute offset between start and end of string
	MOV		RCX, RAX			; Byte counter
	REP		MOVSB				; Perform copy

	MOV		RAX, RDI			; Move pointer to end of string into RAX
	MOV		BYTE PTR [ RAX ], 0		; Don't forget the trailing zero

	POPS		RCX, RDI, RSI
	RET		
String$DeleteLeft	ENDP

END