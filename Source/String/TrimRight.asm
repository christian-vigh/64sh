;**************************************************************************************************************
;
;   NAME
;	TrimRight.asm
;
;   DESCRIPTION
;	Trims a string to the right.
;
;   AUTHOR
; 	Christian Vigh, 11/2012.
;
;   HISTORY
;   [Version : 1.0]    [Date : 2012/11/18]     [Author : CV]
;	Initial version.
;
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
;=	String$TrimRight - Trims a string right.
;=
;=   DESCRIPTION
;=	Trims all space characters right from a string.
;=
;=   INPUT
;=	RCX -
;=		Pointer to the string to be trimmed.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$TrimRight	PROC
	PUSHES			RAX, RSI

	CALL			String@FindEOS			; Find the end of string
	STD							; Reverse direction flag : we start from the end of the string to its beginning
	DEC			RAX				; Point to the character before the trailing zero
	MOV			RSI, RAX
	
TrimLoop :
	CMP			RSI, RCX			; First, check that we did not go before the start of the string
	JL			TheEnd				; In that case we're over : the string is either empty or contains only spaces

	LODSB							; Get next character

	CMP			AL, ' '				; If space, ignore it
	JE			TrimLoop
	CMP			AL, 9				;  From 9 to 13, we have TAB, NL, VTAB, FF and CR : ignore them
	JL			TheEnd
	CMP			AL, 13
	JLE			TrimLoop

	INC			RSI				; Current character is not a space ; RSI now points to the character before this one so adjust it

TheEnd :
	INC			RSI				; Move past the last non-space character
	MOV			BYTE PTR [RSI], 0		; And terminate the string with a trailing zero

	CLD							; Restore direction flag to go forward
	POPS			RAX, RSI		
	RET
String$TrimRight	ENDP

END