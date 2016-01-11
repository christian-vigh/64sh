;**************************************************************************************************************
;*
;*  NAME
;*	ReplaceString.asm
;*
;*   DESCRIPTION
;*	Replaces a string by another in a STRING.
;*
;*  AUTHOR
;* 	Christian Vigh, 12/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/12/08]     [Author : CV]
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
;=	ReplaceString - Replaces a string by another.
;=
;=   DESCRIPTION
;=	Replaces the string pointed to by RDX with the string pointed to by R8, in the STRING pointed to by
;=	RCX.
;=
;=   INPUT
;=	RCX -
;=		Pointer to the string where the searched string is to be replaced.
;=
;=	RDX -
;=		Pointer to the string to be searched.
;=
;=	R8 -
;=		Pointer to the replacement string.
;=
;=   OUTPUT
;=	RAX -
;=		Pointer to the end of the input string.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$ReplaceString	PROC
	;--------------------------------------------------------------------------------------------------------------
	;-
	;- Preliminary checks : input string and searched string must be non null.
	;-
	;--------------------------------------------------------------------------------------------------------------
	MOV		AL, [ RCX ]				; Get first character of input string
	OR		AL, AH					; Check if empty string
	JZ		Empty

	MOV		AL, [ RDX ]				; Get first character of searched string
	OR		AL, AL					; Check if empty string
	JZ		Empty

	JMP		ReplaceStart

	; Either input or searched string is empty, simply return a pointer to the end of the input string
	ALIGN ( 8 )
Empty :
	CALL		String$Length
	RET


	;--------------------------------------------------------------------------------------------------------------
	;-
	;- For readability reasons, we use aliases for saved registers
	;-
	;--------------------------------------------------------------------------------------------------------------
	SEARCHPTR	EQU	R9				; Searched string pointer & length
	SEARCHLEN	EQU	R10
	REPLACEPTR	EQU	R11				; Replacement string pointer & length
	REPLACELEN	EQU	R12
	STRPTR		EQU	R13				; Input string pointer and length
	STRLEN		EQU	R14

	ALIGN ( 8 )
ReplaceStart :
	PUSHES		RBX, RCX, RDX, RDI, RSI, R8, R9, R10, R11, R12, R13, R14

	MOV		RDI, RCX				; RDI will point to input string, since we will use SCASB to locate the first character from the searched string
	MOV		STRPTR, RCX				; Save input string pointer
	MOV		SEARCHPTR, RDX

	CALL		String$Length				; Get length of input string
	MOV		STRLEN, RAX				; And save it

	MOV		RCX, SEARCHPTR				; Get length of searched string
	CALL		String$Length
	MOV		SEARCHLEN, RAX

	MOV		REPLACEPTR, R8				; Get length of replacement string
	MOV		RCX, REPLACEPTR
	CALL		String$Length
	MOV		REPLACELEN, RAX

	CMP		REPLACELEN, SEARCHLEN			; Compare lengths of searched and replacement strings
	JL		ReplacementShorter			; Replacement string is shorter : this will be an easier in-place replacement
	JG		ReplacementGreater			; Replacement string is longer : it will be a little bit trickier...


	;--------------------------------------------------------------------------------------------------------------
	;-
	;- Case #1 : Both searched and replacement strings have the same length
	;-
	;--------------------------------------------------------------------------------------------------------------
	ALIGN ( 8 )
ReplacementEqual :
	MOV		RCX, STRLEN				; Get remaining number of bytes to be scanned

	MOV		AL, [ SEARCHPTR ]			; AL = first character from the searched string
	REPNE		SCASB					; Locate the next occurrence
	JNE		NotFound				; If not found, we have finished searching the input string

	MOV		STRLEN, RCX				; Save the number of bytes which remain to be scanned

	LEA		RCX, [ RDI - 1 ]				; Compare current substring in the input string with the searched string
	MOV		RDX, SEARCHPTR
	MOV		R8, SEARCHLEN
	CALL		String$CompareFixed

	JNZ		ReplacementEqual			; If not equal on SEARCHLEN characters, then proceed with next input character

	MOV		RDX, RCX				; RDX = destination pointer
	MOV		RCX, REPLACEPTR				; to copy the replacement string...
	CALL		String$CopyFixed

	MOV		RDI, RAX				; Make RDI point to the first character after the copy
	INC		STRLEN					; Adjust by 1 after the REPNE SCASB, which decremented RCX one byte too much
	SUB		STRLEN, REPLACELEN			; Subtract replacement string length from remaining bytes to be scanned
	JBE		NotFound

	JMP		ReplacementEqual			; And shoot again...


	;--------------------------------------------------------------------------------------------------------------
	;-
	;- Case #2 : The replacement string is shorter than the searched string.
	;-
	;--------------------------------------------------------------------------------------------------------------

	; We first make sure that the input string does not contain the searched string ; this will allow for faster search failure...
	ALIGN ( 8 )
ReplacementShorter :
	MOV		RCX, STRLEN				; Search the input string for an occurrence of the 1st character of the searched string

	ALIGN ( 8 )
RS$ScanForNoOccurrence :
	MOV		AL, [ SEARCHPTR ]
	REPNE		SCASB

	JNE		NoOccurrence				; When not found, we're over
	
	LEA		RCX, [ RDI - 1 ]				; Compare current substring in the input string with the searched string
	MOV		RDX, SEARCHPTR
	MOV		R8, SEARCHLEN
	CALL		String$CompareFixed

	JNZ		RS$ScanForNoOccurrence			; If not equal on SEARCHLEN characters, then proceed with next input character (pointed to by RDI)
	DEC		RDI
	MOV		RSI, RDI				; From now on, RSI may differ from RDI

	; We have found an occurrence, loop through the input string until all occurrences have been processed
	ALIGN ( 8 )
RS$Loop :
	MOV		RCX, REPLACEPTR				; Replace the found occurrence with the replacement string
	MOV		RDX, RDI
	MOV		R8, REPLACELEN
	CALL		String$CopyFixed

	LEA		RSI, [ RSI + SEARCHLEN ]		; Adjust RSI to point past the search (and found) string
	LEA		RDI, [ RDI + REPLACELEN ]		; And RDI past the replacement string

	; Within the RS$Loop loop, we need to scan for the next character that matches the first character from the input string
	; and stop if we find the EOS
	ALIGN ( 8 )
RS$NextCharacter :
	LODSB							; From now on, we have no other choice than using LODSB/STOSB
	OR		AL, AL					; End of string ?
	JZ		NotFound				; Yes, we're over

	CMP		AL, [ SEARCHPTR ]			; Is the current character the same as the first one from the searched string ?
	JE		RS$PartialMatch				; Yes, try if substring matches the searched string

	STOSB							; No, store the current character
	JMP		RS$NextCharacter			; and proceed with next character

	; We may have found a match ; check if the current substring is equal to the searched one
	ALIGN ( 8 )
RS$PartialMatch :
	DEC		RSI					; The LODSB instruction at RS$NextCharacter made RSI point one character too far : adjust
	MOV		RCX, RSI				; Compare current substring in the input string with the searched string
	MOV		RDX, SEARCHPTR
	MOV		R8, SEARCHLEN
	CALL		String$CompareFixed

	JZ		RS$Loop					; Substring is equal to searched string : we have to perform the copy

	LODSB							; Not equal : save the current character
	STOSB		
	JMP		RS$NextCharacter


	
	;--------------------------------------------------------------------------------------------------------------
	;-
	;- Case #3 : The replacement string is longer than the searched string.
	;-	     We will first count the number of occurrences of the searched string, compute the new string
	;-	     length, then perform a backward copy.
	;-
	;--------------------------------------------------------------------------------------------------------------
	ALIGN ( 8 )
ReplacementGreater :
	XOR		RBX, RBX				; Occurrence counter
	MOV		RCX, STRLEN				; Search the input string for an occurrence of the 1st character of the searched string

	ALIGN ( 8 )
RG$ScanForNoOccurrence :
	MOV		AL, [ SEARCHPTR ]
	REPNE		SCASB

	JNE		RG$NoOccurrenceEnd			; When not found, we're over for counting
	
	LEA		RCX, [ RDI - 1 ]				; Compare current substring in the input string with the searched string
	MOV		RDX, SEARCHPTR
	MOV		R8, SEARCHLEN
	CALL		String$CompareFixed

	JNZ		RG$ScanForNoOccurrence			; If not equal on SEARCHLEN characters, then proceed with next input character (pointed to by RDI)
	INC		RBX					; If equal, count one occurrence more
	LEA		RDI, [ RDI + SEARCHLEN ]		; Make RDI point to the character next after this occurrence
	JMP		RG$ScanForNoOccurrence			; And shoot again

RG$NoOccurrenceEnd :
	OR		RBX, RBX				; Any occurrence found ?
	JZ		NotFound				; No, we're over

	LEA		RAX, [ REPLACELEN - SEARCHLEN ]		; Compute the number of extra bytes to add
	MUL		RBX
	ADD		RAX, STRLEN
	MOV		RCX, RAX				; RCX will hold the new string length


	;--------------------------------------------------------------------------------------------------------------
	;-
	;- We fall here when the input string does not contain any occurrence of the searched string.
	;-
	;--------------------------------------------------------------------------------------------------------------
	ALIGN ( 8 )
NoOccurrence :
	LEA		RAX, [ STRPTR + STRLEN ]		; Return in RAX the pointer to the last character of the string (zero)

	POPS		RBX, RCX, RDX, RDI, RSI, R8, R9, R10, R11, R12, R13, R14
	RET


	;--------------------------------------------------------------------------------------------------------------
	;-
	;- We fall here whenever there is no more occurrence of the searched string or of its first character.
	;-
	;--------------------------------------------------------------------------------------------------------------
	ALIGN ( 8 )
NotFound :
	XOR		AL, AL					; Don't forget the trailing zero
	MOV		[ RDI ], AL

	LEA		RAX, [ RDI - 1 ]				; Return in RAX the pointer to the last character of the string (zero)

	POPS		RBX, RCX, RDX, RDI, RSI, R8, R9, R10, R11, R12, R13, R14
	RET

String$ReplaceString	ENDP

END