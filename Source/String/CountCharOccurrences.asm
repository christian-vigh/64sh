;**************************************************************************************************************
;*
;*  NAME
;*	CountCharOccurrences.asm
;*
;*   DESCRIPTION
;*	Counts the number of occurrences of the same character in a string.
;*
;*  AUTHOR
;* 	Christian Vigh, 12/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/12/16]     [Author : CV]
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
;=	String$CountCharOccurrences - Counts the number of character occurrences in a string.
;=
;=   DESCRIPTION
;=	Counts the number of character occurrences specified by CL in the string whose address is given by
;=	RDX.
;=
;=   INPUT
;=	AL -
;=		Character to be searched.
;=
;=	RCX -
;=		Address of a zero-terminated string to be searched for.
;=
;=   OUTPUT
;=	RAX -
;=		Number of character occurrences found.
;=
;=	ZF -
;=		Set to 1 if no occurrence found.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$CountCharOccurrences	PROC
	PUSHREGS	RBX, RCX, RDX, RDI

	MOV		DL, AL					; Save character to be counted into DL
	CALL		String@FindEOS				; Find end of string
	XOR		EBX, EBX				; EBX = occurrence count

	CMP		RAX, RCX				; If empty string, nothing to count
	JE		Over

	MOV		RDI, RCX				; RDI = pointer to string buffer
	MOV		RCX, RAX				; Compute string length
	SUB		RCX, RDI
	MOV		AL, DL					; Restore back character to be searched

	; Main scan loop
ScanLoop :
	REPNE		SCASB					; Find next character occurrence
	JNZ		Over					; ZF = 0 if character not found so we're over
	INC		RBX					; ZF = 1 : count one more occurrence
	JMP		ScanLoop				; And shoot again

	; Termination point : RBX contains the number of character occurrences found
Over :
	MOV		RAX, RBX				; Set return value
	OR		RAX, RAX				; Set ZF if no occurrence found

	POPREGS
	RET
String$CountCharOccurrences	ENDP

END