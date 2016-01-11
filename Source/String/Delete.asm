;**************************************************************************************************************
;*
;*  NAME
;*	Delete.asm
;*
;*   DESCRIPTION
;*	Delete characters in a string.
;*
;*  AUTHOR
;* 	Christian Vigh, 11/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/11/21]     [Author : CV]
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
;=	Delete - delete characters from a string at the specified position.
;=
;=   DESCRIPTION
;=	Deletes the specified number of characters from a string, starting at the specified position.
;=
;=   INPUT
;=	RCX -
;=		Pointer to the string.
;=
;=	EDX -
;=		Position where characters are to be deleted. If start position + number of characters to
;=		delete ( RCX + EDX ) goes beyond the end of the string, nothing happens.
;=	
;=	R8D -
;=		Number of characters to delete. If start of string + start position + number of characters to
;=		delete ( RCX + EDX + R8D ) goes beyond the end of the string, a trailing zero will be put at
;=		the position specified by EDX, with no error.
;=
;=   OUTPUT
;=	RAX -
;=		Points to the end of the string.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$Delete	PROC
	PUSHES		RCX, RDX, RSI, RDI, R8

	CALL		String@FindEOS			; Find end of string

	OR		R8D, R8D			; If number of characters to delete is zero, then we have nothing to do
	JZ		ReallyExit

	; Compute the destination address of the characters to be copied for deletion
	MOV		RDI, RCX			; Set RDI to point to start of string + index (RCX + EDX)
	ADD		RDI, RDX

	CMP		RDI, RAX			; If past end of string, then we have nothing to do
	JG		Exit

	; Compute the start address of the characters to be copied for deletion
	MOV		RSI, RDI			; RSI = Start address (RDI)
	ADD		RSI, R8				; RSI = Start address + number of characters to delete

	; If source address is past the end of string, then adjust it to point to the end of the string
	CMP		RSI, RAX
	JLE		ComputeCharacterCount

	MOV		R8, RAX				; Adjuste the number of characters to delete
	SUB		R8, RDI


	; Compute the number of characters to copy
ComputeCharacterCount :
	MOV		RCX, RAX			; Get pointer to end of string
	SUB		RCX, RDI			; Subtract pointer to destination address : this gives us an offset...
	SUB		RCX, R8				; from which we subtract the index of the character where the deletion starts : 
							; this gives us the exact number of characters to be copied
	REP		MOVSB				; Copy the characters

Zero :
	XOR		BL, BL				; Store a final trailing zero
	MOV		[ RDI ], BL

	; We arrive here when either ( string address + index ) or ( start address of characters to be copied ) is past the EOS (RAX)
	; (or simply from the code above, where the copy has been performed)
Exit :
	MOV		RAX, RDI			; Set the return value to point to the end of string

ReallyExit :
	POPS		RCX, RDX, RSI, RDI, R8
	RET
String$Delete	ENDP


END