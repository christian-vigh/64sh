;**************************************************************************************************
;*
;*  NAME
;*	CommandLine.inc
;*
;*  DESCRIPTION
;*	Header file for command-line argument parsing.
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
; Constants
;
MAX_ARGC					EQU	256		; Max number of command-line arguments
MAX_ARGV					EQU	1024		; Max command line length


;
; CMDLINE structure -
;	Defines the ARGC and ARGV variables.
;
CMDLINE		STRUCT
	ARGV		DQ	MAX_ARGC DUP (0)			; Pointers to individual command line arguments
	ARGPTR		DQ	?					; Pointer to the real command line
	ARGC		DW	0					; Argument count
	ARGVDATA	DB	MAX_ARGV DUP (?)			; Command line buffer
CMDLINE		ENDS


;
; Entry points
;
EXTERNDEF		ScanCommandLine		: PROC


;==================================================================================================
;=
;=  Macros.
;=
;==================================================================================================

; PARAMDEF -
;	Starts an IFPARAM/ENDIFPARAM sequence.
PARAMDEF	MACRO
	NEXT_PARAM_LABEL_INDEX		=  0
ENDM


; IFNPARAM Address, Label, Names -
;	Checks if the command-line parameter pointed to by <Address> is one of the names specified in
;	the <Names> parameter. If not, jumps to <Label>.
IFPARAM	MACRO	Address : REQ, Names : VARARG
	LOCAL	IsRegister, CompareSuccess, Label

	Label		CATSTR	<IF_PARAM_>, %NEXT_PARAM_LABEL_INDEX
	Label :

	IF  $IsRegister ( <Address> )  EQ  1
		IsRegister	=  1 
	ELSE
		IsRegister	=  0
	ENDIF

	FOR  Name, <Names>
		LOCAL	StringStart, StringEnd, StringValue

		IF  IsRegister
			PUSH		Address
		ENDIF
			
		MOV		RCX, Address
		LEA		RDX, [ StringStart ]
		CALL		String$CompareNoCase
		JMP SHORT	StringEnd

StringStart :
		StringValue	TEXTEQU  <DB ">, <Name>, <", 0>
		StringValue
StringEnd :
		AND		EAX, EAX

		IF  IsRegister
			POP		Address
		ENDIF

		JZ		CompareSuccess
	ENDM

	Label		CATSTR	<ENDIF_PARAM_>, %NEXT_PARAM_LABEL_INDEX
	JMP		Label

CompareSuccess :
ENDM


; ENDIFPARAM -
;	Closes an IFPARAM construct.
ENDIFPARAM	MACRO
	LOCAL		Label

	Label		CATSTR	<ENDIF_PARAM_>, %NEXT_PARAM_LABEL_INDEX
	Label :

	NEXT_PARAM_LABEL_INDEX	=  NEXT_PARAM_LABEL_INDEX + 1
ENDM


; BADPARAM args -
;	Displays an error message when an invalid parameter has been found and exits.
BADPARAM	MACRO  Args : VARARG
	SYSWRITE	Args
	EXIT		EXITCODE_INVALID_ARGUMENT
ENDM