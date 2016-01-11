;**************************************************************************************************
;*
;*  NAME
;*	64sh.asm
;*
;*  DESCRIPTION
;*	Main program for the command-line version of 64th.
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



; 
; The FORTH64$DATA segment contains all the necessary information for the outer Forth interpreter.
;
FORTH64$DATA		SEGMENT ALIGN(16) 	'DATA'
	ALIGN ( 16 ) 

	; Strings
	STRING		Forth64$Version			,  VERSION$()
	STRING		Msg$Header			,  "64th Shell Interpreter - Copyright Christian Vigh, 2012.", 13, 10
	STRING		Msg$Version			,  "Version ", VERSION$(), " (", DATE$(), ")", 13, 10
	STRING		Msg$Prompt			,  "OK", 13, 10
	STRING		Msg$CRLF			,  13, 10
	STRING		Msg$Bye				,  "Bye.", 13, 10

	; Command-line related strings
	Help$Usage		DB			"Usage : 64sh", 13, 10
				DB			9, "Runs a 64th command-line shell.", 13, 10, 0
	Help$Extra		DB			"Type ""64sh -help"" for more information.", 13, 10, 0
	Help$Params		DB			13, 10, "params...", 13, 10
				DB			0

	; Error messages
	STRING		Err$Header			,  "*** Error *** "
	STRING		Err$WorkspaceCreationFailed	,  "Workspace creation failed.", 13, 10
	STRING		Err$InvalidOptionStart		,  """"
	STRING		Err$InvalidOptionEnd		,  """ is not a valid command-line agument.", 13, 10

	; Command-line arguments
	ALIGN ( 16 )
	CommandLine		CMDLINE			<>

	; Default workspace definitions
	ALIGN ( 16 )
	WorkspaceDefinitions	WORKSPACE_DEFINITION	<>

	; Pointer to the interpreter workspace
	ALIGN ( 16 )
	InterpreterWorkspace	DQ			?

FORTH64$DATA		ENDS

.DATA


.CODE

;==================================================================================================
;
;  Main -
;	Program entry point.
;
;==================================================================================================
PUBLIC		Main

Main		PROC

	; 
	; Give any chance to the syscall handler to perform initializations
	;
	

	CALL		Syscall$Initialize

.DATA
tst	db "abxxz12x3xx000", 0, 256 dup (0FFH)
a	db "x", 0
b	db "XYZ", 0
.CODE


LEA RCX, tst
LEA RDX, a
LEA R8, b
CALL String$ReplaceString


	;
	; Get command-line arguments
	;
	CALL		ScanParameterList

	;
	; Allocate a workspace for this interactive instance
	;
	LEA		RCX, [ WorkspaceDefinitions ]
	CALL		VM$CreateWorkspace

	JNZ		WorkspaceCreated			; Check error condition
	EXIT		EXITCODE_MEMORY_ALLOCATION_FAILED, Err$WorkspaceCreationFailed

WorkspaceCreated :
	MOV		[ InterpreterWorkspace ], RAX		; Save workspace address

	;
	; Run the outer interpreter loop
	;
	CALL		Interpreter

	;
	; Give a chance to the syscall handler to terminate gracefully.
	;
	CALL		Syscall$Terminate

	;
	; Delete the workspace created to run the Forth interpreter
	;
	MOV		RCX, [ InterpreterWorkspace ]
	CALL		VM$DestroyWorkspace

	;
	; All done, exit process
	;
	EXIT
Main		ENDP


;==================================================================================================
;
;  ScanParameterList -
;	Scans the command-line parameters.
;
;==================================================================================================
ScanParameterList	PROC
	PUSHREGS	RBX, RCX, RDX, R8, RSI

	;
	; Get command line arguments
	;
	LEA		RCX, [ CommandLine ]
	CALL		ScanCommandLine

	MOVZX		ECX, [ CommandLine. ARGC ]			; ECX <- Number of command line arguments
	DEC		ECX						; Ignore the first argument, which is the command name
	LEA		RSI, [ CommandLine. ARGV + 8 ]			; RSI <- Pointer to the first ARGV after the command name

	;
	; Loop through parameters
	;
ScanLoop :
	LODSQ								; Get next parameter address
	OR		RAX, RAX					; If no more arguments, then return
	JZ		TheEnd

	MOV		R8, RAX						; Backup copy

	PARAMDEF

	; -usage :
	;	Displays command line usage then exits.
	IFPARAM		RAX, <-usage>, <-u>
		SYSWRITE	Help$Usage, Help$Extra
		EXIT
	ENDIFPARAM

	; -help :
	;	Displays command line help.
	IFPARAM		RAX, <-help>, <-?>
		SYSWRITE	Help$Usage, Help$Params
		EXIT
	ENDIFPARAM

	; Not a valid parameter
	BADPARAM	Err$Header, Err$InvalidOptionStart, R8, Err$InvalidOptionEnd

	DEC		ECX						; End of loop
	JZ		TheEnd
	JMP		ScanLoop

TheEnd :
	POPREGS
	RET
ScanParameterList	ENDP

END