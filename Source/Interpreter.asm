;**************************************************************************************************
;*
;*  NAME
;*	Interpreter.asm
;*
;*  DESCRIPTION
;*	Main program for the 64th version of Forth.
;*
;*  AUTHOR
;*	Christian Vigh, 11/2012.
;*
;*  HISTORY
;*  [Version : 1.0]		[Author : CV]		[Date : 2012/11/02]
;*	Initial version.
;*
;**************************************************************************************************

.NOLIST
INCLUDE		64sh.inc
.LIST


.CODE

;==================================================================================================
;
;  Interpreter -
;	Outer Forth interpreter loop.
;
;==================================================================================================

Interpreter	PROC
	;
	; Display welcome header
	;
	LEA		RCX, Msg$Header				; Generic bla-bla to display upon startup
	CALL		Syscall$WriteString

	LEA		RCX, Msg$Version			; Version number
	CALL		Syscall$WriteString

	LEA		RCX, Msg$CRLF				; One more CR/LF for the road...
	CALL		Syscall$WriteString

	;
	; Get the address of the interpreter worksapce
	;
	MOV		@WS, [ InterpreterWorkspace ]

	;
	; Outer interpreter loop ; performs the following steps :
	; 1) Get a word
	; 2) Interpret it 
	;
InterpreterLoop :
	; Step 1) : get a word
	CALL		NextWord				; Read next word from input
	JZ		ExitInterpreter				; ZF = 1 means we had EOF

	JMP		InterpreterLoop

	;
	; End of interpreter loop : we received an End-of-file.
	; Output a brief message then return to the caller.
	;
ExitInterpreter :
	LEA		RCX, Msg$Bye
	CALL		Syscall$WriteString

	RET
Interpreter	ENDP


;==================================================================================================
;
;  NextWord -
;	Gets the next word from input.
;
;==================================================================================================
NextWord	PROC
	PUSHREGS	RBX, RCX, RDI

	; Initializations :
	; - ECX is the number of characters for the word currently being read
	; - RDI is the current pointer to the word buffer 
	XOR		ECX, ECX				; Character counter
	MOV		RBX, [ InterpreterWorkspace ]		; Workspace data pointer into RBX
								; Address of word buffer start -> RDI
	MOV		RDI, WSPTR ( RBX, TIB_WORD_BUFFER )
	MOV		WSPTR ( RBX, TIB_WORD_BUFFER_END ), RDI

	;
	; Main read loop : read until EOF is reached or a space character has been met
	;
CharLoop :
	CALL		NextChar				; Get next char
	JZ		EOF					; EOF reached ?

	CMP		AL, ' '					; Check current character for space, tab, cr or lf
	JE		IsSpace
	CMP		AL, 7
	JE		IsSpace
	CMP		AL, 13
	JE		IsSpace
	CMP		AL, 10
	JE		IsEOLSpace

	; Character is not a space : we simply have to store it in current word buffer then get next character
	STOSB							; Store
	INC		ECX					; Count one more character
	JMP SHORT	CharLoop				; And shoot again

	; Special case for line feed : display the "OK" prompt
IsEOLSpace :
	LEA		RCX, Msg$Prompt
	CALL		Syscall$WriteString


	; A space character has been met. If characters have been read so far, then this means the end of the
	; current word ; otherwise, simply discard the character
IsSpace :
	AND		ECX, ECX				; Did we got characters so far ?
	JZ		CharLoop				; No, discard this space character
	XOR		AL, AL					; Store a final zero character at the end of the word
	STOSB									
	MOV		WSPTR ( RBX, TIB_WORD_BUFFER_END ), RDI ; Save end of word pointer
	AND		ECX, ECX				; Set ZF = 0

EOF :
	POPREGS
	RET
NextWord	ENDP


;==================================================================================================
;
;  NextChar -
;	Gets the next character from input.
;
;==================================================================================================
NextChar	PROC
	PUSHREGS	RBX, RCX, RDX, RSI

	;
	; First, check if our TIB contains data (RBX points to workspace data) by comparing the TIB
	; buffer start to TIB buffer end.
	;
	MOV	RSI, WSPTR ( RBX, TIB_BUFFER_START )
	CMP	RSI, WSPTR ( RBX, TIB_BUFFER_END )
	JL	NotEmpty					; If current position is < end of TIB then we have buffered character(s)

	;
	; TIB does not contain any more data. Read a string from the terminal.
	;
								; TIB is the destination address where to put the characters
	MOV	RCX, WSPTR ( RBX, TIB_BUFFER )
	MOV	RSI, RCX					; Next char is no more at [ TIB_BUFFER_START ], but at [ TIB_BUFFER ]
	MOV	EDX, WSPTR ( RBX, WORKSPACE_DEFINITIONS. TIB_BUFFER_SIZE ); Don't read more than TIB_SIZE characters.
	CALL	Syscall$ReadString 				; Call the ReadString syscall
	JZ	EOF						; There was no character to read : this is end of file

	;
	; After reading, update the TIB pointers
	;
								; Current character in TIB now points to the start of the buffer
	MOV	WSPTR ( RBX, TIB_BUFFER_START ), RSI
	ADD	RAX, RSI					; End of data that has just been read
								
	MOV	WSPTR ( RBX, TIB_BUFFER_END ), RAX		; and update the buffer end pointer

	;
	; When we arrive here, either a character was already available in the TIB, or we had to call ReadString
	; to get more characters.
	;
NotEmpty:
	LODSB							; Get next character from TIB ; RSI
	INC	WSPTR ( RBX, TIB_BUFFER_START )			; Increment the pointer to the next character to be read

	CMP	AL, 26						; Set ZF if we met the EOF character

EOF :
	; All done, return...
	POPREGS
	RET
NextChar	ENDP


END