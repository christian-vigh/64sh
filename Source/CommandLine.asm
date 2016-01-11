;**************************************************************************************************
;*
;*  NAME
;*	CommandLine.asm
;*
;*  DESCRIPTION
;*	Command-line parsing functions.
;*
;*  AUTHOR
;*	Christian Vigh, 11/2012.
;*
;*  HISTORY
;*  [Version : 1.0]		[Author : CV]		[Date : 2012/11/11]
;*	Initial version.
;*
;******************************************************************************************************

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
	INCLUDE		CommandLine.inc
.LIST

.CODE

;==================================================================================================
;
;  ScanCommandLine -
;	Scans the command line arguments.
;
;  INPUT
;	RCX :
;		Pointer to a CMDLINE structure that will receive the command-line arguments.
;
;  OUTPUT
;	EAX -
;		Number of command-line arguments.
;
;==================================================================================================
ScanCommandLine	PROC
	PUSHREGS	RBX, RCX, RDX, R8, R9, R10, R11, R12, R13, R14, R15, RSI, RDI

	; Get the command-line string
	PUSH		RCX
	CALL		GetCommandLine
	POP		RCX

	; Prepare for exploding the command line into individual zero-terminated string arguments.
	; The ARGVDATA will hold the zero-terminated strings in sequence, while ARGV will
	; be set to point to each command-line argument.
	MOV		RSI, RAX					; Source pointer (command line)
	LEA		RDI, [ RCX + CMDLINE. ARGVDATA ]		; Destination pointer (sequence of zero-terminated arguments)
	MOV		[ RCX + CMDLINE. ARGPTR ], RAX			; Save pointer to real command line
	LEA		R8, [ RCX + CMDLINE. ARGV ]			; R8 will point to the current item in the ARGV array
	MOV		R9, RDI						; R9 points to the start of the current command-line argument, in ARGVDATA
	XOR		DX, DX						; DX holds ARGC and is saved at the end of this procedure
	XOR		BL, BL						; BL is non-zero if the current argument is enclosed between quotes

	; Main copy loop
CopyCmdLine :
	LODSB								; Get next character from command line	
	
	CMP		AL, '"'						; If the argument does not start with a quote, then process it normally
	JNE		Continue

	OR		BL, BL						; Otherwise, check if this is the closing or opening quote
	JNZ		StringEnd					; Closing quote found

	INC		BL						; Opening quote found : say we met a quoted argument by incrementing BL...
	MOV		AH, AL

	JMP SHORT	CopyCmdLine					; ... discard the character and process next one

StringEnd :								; We found a closing quote...
	DEC		BL						; Reset our "found quote" flag
	MOV		AH, ' '						; Say the previous character was a space : this is how we know how to delimit argument
	XOR		AL, AL						; Terminate the current argument with a zero
	STOSB
	INC		DX						; Count one more argument
	MOV		[ R8 ], R9					; Save into ARGV  [ ARGC ] the pointer to the start of the current argument
	ADD		R8, 8						; Position ARGV to ARGV + 1
	MOV		R9, RDI						; Start of next argument is now the current ARGVDATA pointer
	JMP SHORT	CopyCmdLine					; And process next character
			
Continue :								; We arrive here when the current character is not a quote
	OR		BL, BL						; but if a quote was encountered...
	JZ		Continue2
	JMP SHORT	NonSpace					; ... we just have to collect characters until a terminating quote has been found

Continue2 :
	OR		AL, AL						; If we find a trailing zero, then this is the end of our loop.
	JNZ		Continue3

	CMP		R9, RDI						; If we didn't collect a nonspace character, then finish
	JE		CopyCmdLineEnd

	INC		DX						; Increment ARGC
	MOV		[ R8 ], R9					; Save pointer to this argument
	JMP SHORT	CopyCmdLineEnd					; And that's all

Continue3 :
	CMP		AL, ' '						; If the current character is not a space, then collect it...
	JNE		NonSpace

	CMP		AL, AH						; Current character is a space ; if the previous one was also a space...
	JE		CopyCmdLine					; ... then ignore it

	MOV		AH, AL						; Otherwise, this is time to say : "end of current argument"
	XOR		AL, AL						; So, store a trailing zero to the current argument
	STOSB

	INC		DX						; Count one more argument
	MOV		[ R8 ], R9					; Save into ARGV  [ ARGC ] the pointer to the start of the current argument
	ADD		R8, 8						; Position ARGV to ARGV + 1
	MOV		R9, RDI						; Start of next argument is now the current ARGVDATA pointer
	
	JMP SHORT	CopyCmdLine					; Space processed, get next character

NonSpace :								; If the current character is neither a space, a zero nor a quote then...
	STOSB								; ... store it
	MOV		AH, AL						; And save it as the previous character
	JMP SHORT	CopyCmdLine					; And process next character

CopyCmdLineEnd :							; We arrive here when current character is a zero so...
	STOSB								; ... Store it
	MOV		[ RCX + CMDLINE. ARGC ], DX			; And save ARGC

	POPREGS
	RET
ScanCommandLine	ENDP

END