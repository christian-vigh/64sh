;**************************************************************************************************
;*
;*  NAME
;*	Forth64.inc
;*
;*  DESCRIPTION
;*	Main include file for Forth64.
;*
;*  AUTHOR
;*	Christian Vigh, 11/2012.
;*
;*  HISTORY
;*  [Version : 1.0]		[Author : CV]		[Date : 2012/11/02]
;*	Initial version.
;*
;*  NOTES
;*	To create a 64 bits MASM project :
;*	1) Create an empty solution
;*	2) Create an empty C++ project
;*	3) Right-click on the project, select "Build customization" and tick the MASM32 checkbox.
;*	4) The "Microsoft Macro Assembler" entry should now appear in project properties
;*	5) In "Project properties" :
;*		a) Link/System : Choose the CONSOLE subsystem
;*		b) Link/General : Specify the path where the 64-bits version of the Kernel32.lib
;*		   file can be found, along with the Lib directory of MASM32 :
;*			C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Lib\x64;C:\Masm32\Lib
;*		c) Link/Input : Add "Masm32.lib" to the list of additional dependencies
;*		d) Link/Advanced : Specify the program entry point name (which must be declared as
;*		   PUBLIC)
;*		e) Microsoft Macro Assembler/General : Add the following include paths (and whatever
;*		   include paths that may fit the needs of your project) :
;*			C:\Masm32\Lib;C:\Masm32\Macros
;*    6) Set your target platform to X64
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
; Forth64 include files.
;
INCLUDE		Macros.inc
INCLUDE		Assembler.inc
INCLUDE		Debug.inc
INCLUDE		String.inc
INCLUDE		CommandLine.inc
INCLUDE		64th.inc


;
; Program exit codes
;
EXITCODE_OK					EQU	0		; Everything is ok
EXITCODE_MEMORY_ALLOCATION_FAILED		EQU	-1		; Failed to allocate memory
EXITCODE_INVALID_ARGUMENT			EQU	-2		; Invaid command-line argument

;
;  Forth64 characteristics
;
VERSION			1, 0, 0


;
; Strings
;
EXTERNDEF	Forth64$Version				:  PROC
EXTERNDEF	Msg$Header				:  PROC
EXTERNDEF	Msg$Prompt				:  PROC
EXTERNDEF	Msg$Version				:  PROC
EXTERNDEF	Msg$CRLF				:  PROC
EXTERNDEF	Msg$Bye					:  PROC

; Errors
EXTERNDEF	Err$Header				:  PROC
EXTERNDEF	Err$WorkspaceCreationFailed		:  PROC

;
; Variables & structures
;
EXTERNDEF	CommandLine				:  CMDLINE
EXTERNDEF	WorkspaceDefinitions			:  PROC
EXTERNDEF	InterpreterWorkspace			:  QWORD

; 
; WinAPI function wrappers
;
EXTERNDEF	Syscall$Initialize			:  PROC			; "System" calls
EXTERNDEF	Syscall$Terminate			:  PROC
EXTERNDEF	Syscall$ExitProcess			:  PROC
EXTERNDEF	Syscall$WriteString			:  PROC
EXTERNDEF	Syscall$WriteChar			:  PROC
EXTERNDEF	Syscall$ReadChar			:  PROC
EXTERNDEF	Syscall$ReadString			:  PROC
EXTERNDEF	Syscall$VirtualAlloc			:  PROC
EXTERNDEF	Syscall$VirtualFree			:  PROC

;
; 64th functions
EXTERNDEF	Interpreter				:  PROC			; Main interpreter loop
EXTERNDEF	VM$CreateWorkspace			:  PROC
EXTERNDEF	VM$DestroyWorkspace			:  PROC


;==================================================================================================
;
; Macros
;
;==================================================================================================

; EXIT -
;	Exits the current process with the specified status (default : 0). If a message is specified,
;	it is displayed before exiting.
;	The message can either be a label, register or a list of constant strings and byte constants.
EXIT	MACRO	Status, Message : VARARG
	LOCAL	Count, Argv1, StringStart, StringEnd, DBDir

	;; No exit code specified : exit code will be zero
	IFB  <Status>
		XOR	ECX, ECX
		CALL	Syscall$ExitProcess
	;; An exit code has been specified
	ELSE
		Count	=  MACRO_ARGC ( Message )

		;; Check if additional arguments are present (label address, register, or list of strings)
		IF  Count  EQ  1
			;; Get first argument 
			Argv1	EQU  MACRO_ARGV ( 1, Message )

			;; Write the prefix string of the error message
			LEA		RCX, [ Err$Header ]
			CALL		Syscall$WriteString

			;; If message argument is a data or label address pointer, then display the message pointed to
			IF  $IsData ( Argv1 )  OR  $IsLabel ( Argv1 )
				IF  Count  GT  1 
					.ERR  <The EXIT macro cannot have multiple arguments when the first one is a label.>
				ENDIF

				LEA		RCX, [ Message ]
				CALL		Syscall$WriteString
			;; The same case applies to a register
			ELSEIF  $IsRegister ( Argv1 )
				IF  Count  GT  1 
					.ERR  <The EXIT macro cannot have multiple arguments when the first one is a register.>
				ENDIF

				;; Avoid an extra MOV instruction if the specified register is RCX
				IFIDNI  <Message>,  <RCX>
				ELSE
					MOV	RCX, Message
				ENDIF

				CALL	Syscall$WriteString
			ENDIF
		;; Otherwise, <Message> is one or more values for the DB directive
		ELSEIF  Count  GT  1 
			LEA		RCX, [ StringStart ]
			CALL		Syscall$WriteString
			JMP SHORT	StringEnd

			StringStart :

			FOR  Arg, <Message>
				IF  $IsLiteral ( Arg )
					DbDir	TEXTEQU		<DB >, <Arg>
				ELSE
					DbDir  TEXTEQU  <DB ">, <Arg>, <">
				ENDIF

				DbDir
			ENDM

			DB 0

			StringEnd :
		ENDIF

		;; Now the string is displayed, exit current process
		IF  Status  EQ  0
			XOR	ECX, ECX
		ELSE
			MOV	ECX, Status
		ENDIF

		CALL	Syscall$ExitProcess
	ENDIF
ENDM


; WSPTR -
;	Casts a pointer to a WORKSPACE_STRUCTURE structure.
WSPTR	MACRO  Register : REQ, Field : REQ
	LOCAL	Result

	Result	TEXTEQU	 SFPTR ( Register, WORKSPACE_STRUCTURE. Field )
	EXITM	Result
ENDM


; SYSWRITE -
;	Writes the specified arguments to the standard output.
SYSWRITE	MACRO  Args : VARARG
	FOR  Arg, <Args>
		LOCAL		DoPush

		IsRegister	=  $IsRegister ( Arg )
		DoPush		=  IsRegister

		IF  ( IsRegister )
			IFIDN  <Arg>, <RAX>
				DoPush = 1
			ELSE
				DoPush = 0
			ENDIF
		ENDIF

		IF  DoPush  EQ  1
			PUSH	Arg
		ENDIF

		IF  IsRegister  EQ  1
			MOV	RCX, Arg
		ELSE
			LEA	RCX, Arg
		ENDIF

		CALL	Syscall$WriteString

		IF  DoPush  EQ  1
			POP	Arg
		ENDIF
	ENDM
ENDM