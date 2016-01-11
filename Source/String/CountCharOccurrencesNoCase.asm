;**************************************************************************************************************
;*
;*  NAME
;*	CountCharOccurrencesNoCase.asm
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
;=	String$CountCharOccurrencesNoCase - Counts the number of character occurrences in a string.
;=
;=   DESCRIPTION
;=	Counts the number of character occurrences specified by CL in the string whose address is given by
;=	RDX.
;=	The comparison is case insensitive.
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
String$CountCharOccurrencesNoCase	PROC
	String$IsLetter		AL					; If the searched character is a letter then...
	JNZ			CaseInsensitiveCompare			; ... perform case-insensitive compare
	JMP			String$CountCharOccurrences		; Otherwise, use the standard comparison function

CaseInsensitiveCompare :
	PUSHREGS		RBX, RCX, RDX, RSI

	XOR			EBX, EBX				; RBX = occurrence counter
	MOV			RSI, RCX				; RSI points to the input string buffer
	MOV			DL, AL					; Get searched character into DL
	AND			DL, 0DFH				; And convert it to uppercase

	; Main search loop
ScanLoop :		
	LODSB								; Get next character
	OR			AL, AL					; If end of string, we're over
	JZ			ScanEnd

	String$IsLetter		AL					; If the current character is not a letter, then we ca safely
	JZ			ScanLoop				; process the next one

	AND			AL, 0DFH				; Current character is a letter : convert it to uppercase
	CMP			AL, DL					; If current character is not equal to the searched one then...
	JNE			ScanLoop				; ... process next character

	INC			RBX					; Character found : increment occurrence count...
	JMP			ScanLoop				; And shoot again

	; End of search loop
ScanEnd :
	MOV			RAX, RBX				; Set return value (number of occurrences of the searched character)
	OR			RAX, RAX				; Set ZF if no occurrence found

	POPREGS
	RET
String$CountCharOccurrencesNoCase	ENDP

END