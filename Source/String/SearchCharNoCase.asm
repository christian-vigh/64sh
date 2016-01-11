;**************************************************************************************************************
;*
;*  NAME
;*	SearchCharNoCase.asm
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
;=	SearchCharNoCase@ - Searches a character in a string and returns a pointer to it.
;=
;=   DESCRIPTION
;=	Searches for the specified char in AL. The search is case-insensitive.
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
;=		Pointer to the character if found in the string, or zero if not found.
;=
;=	ZF -
;=		ZF will be set to 1 if the character is not found.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$SearchCharNoCase 	PROC
	PUSHES		RBX, RSI

	CMP		AL, 'a'					; Check if searched character is a lowercase letter
	JL		NotConvertible
	CMP		AL, 'z'
	JG		NotConvertible

	AND		AL, 0DFH				; If yes, convert it to uppercase
	
NotConvertible :	
	MOV		BL, AL					; BL = Character to search
	MOV		RSI, RCX				; RSI = pointer to string to be searched

	; Search loop : get characters from string, one at a time, until a terminating null is found
	; or current character is equal to the searched one
SearchLoop :
	LODSB							; Get next character
	OR		AL, AL					; If zero, then we arrived to the end of string
	JZ		NotFound

	CMP		AL, 'a'					; Check if current character is a lowercase letter
	JL		NotConvertible2
	CMP		AL, 'z'
	JG		NotConvertible2

	AND		AL, 0DFH				; If not, convert it to uppercase

NotConvertible2 :
	CMP		AL, BL					; Compare current character with the searched one
	JNE		SearchLoop				; If different, process next character

	; Exit point 1 : We found a matching character
	MOV		RAX, RSI				; Set the function return value, a pointer to the character found
	DEC		RAX					; But don't forget that the last LODSB moved us past it

	POPS		RBX, RSI
	RET

	; Exit point 2 : No match
NotFound :
	XOR		RAX, RAX				; Set return value to NULL, ZF will be 1
	
	POPS		RBX, RSI
	RET
String$SearchCharNoCase 	ENDP

END