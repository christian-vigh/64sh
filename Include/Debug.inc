;**************************************************************************************************
;*
;*  NAME
;*	Debug.inc
;*
;*  DESCRIPTION
;*	Main include file for Forth64 debugging help. Most of those macros are active only if the
;*	DEBUG constant is set to a non-zero value.
;*
;*  AUTHOR
;*	Christian Vigh, 11/2012.
;*
;*  HISTORY
;*  [Version : 1.0]		[Author : CV]		[Date : 2012/11/09]
;*	Initial version.
;*
;******************************************************************************************************

; Make sure there will always be a DEBUG constant
IFNDEF  DEBUG
	DEBUG	EQU  0
ENDIF


;==================================================================================================
;=
;=  Debug$PrintLine, Debug$Print -
;=	Outputs a debugging message to the console. Debug$PrintLine adds an ending CR/LF if none
;=	present.
;=
;==================================================================================================
Debug$PrintLine  MACRO  Args : VARARG
	IF DEBUG  NE  0
		__Debug$PrintLine__  Args
	ENDIF
ENDM

Debug$Print	MACRO  Args : VARARG
	IF  DEBUG  NE  0
		__Debug$Print__  Args
	ENDIF
ENDM

__Debug$PrintLine__  MACRO  Args : VARARG
	LOCAL	StringStart, StringEnd, CRLF, DbDir

	CRLF	=  0

	LEA		RCX, StringStart
	CALL		Syscall$WriteString
	JMP SHORT	StringEnd

StringStart :
	FOR  Arg, <Args>
		IFIDN  <Arg>, <13>
			CRLF	=  CRLF + 1
		ELSE
			IFIDN <Arg>, <10>
				CRLF	=  CRLF + 1
			ELSE
				CRLF	=  0
			ENDIF
		ENDIF

		DbDir	TEXTEQU	<DB ">, <Arg>, <">
		DbDir
	ENDM

	IF  CRLF  EQ  0
		DB 13, 10
	ENDIF

	DB 0		
StringEnd :
ENDM


__Debug$Print__	MACRO  Args : VARARG
	LOCAL	StringStart, StringEnd

	LEA		RCX, StringStart
	CALL		Syscall$WriteString
	JMP SHORT	StringEnd

StringStart :
	FOR  Arg, <Args>
		DB  Arg
	ENDM
StringEnd :
ENDM

;==================================================================================================
;=
;= Debug macros used when writing built-in primitives.
;=
;==================================================================================================

; @@STACK_UNDERFLOW -
;	Checks for a stack underflow condition.
@@STACK_UNDERFLOW  MACRO  Value : REQ
ENDM

; @@STACK_UNDERFLOW_COUNT -
;	Checks for a stack underflow condition, for the number of cells specified in Reg.
@@STACK_UNDERFLOW_COUNT  MACRO  Reg : REQ
ENDM

; @@STACK_OVERFLOW -
;	Checks for a stack overflow condition.
@@STACK_OVERFLOW  MACRO  Value : REQ

ENDM


; @@STACK_OVERFLOW_COUNT -
;	Checks for a stack overflow condition, for the number of cells specified in Reg.
@@STACK_OVERFLOW_COUNT  MACRO  Reg : REQ
ENDM


; @POP -
;	Pops a value from the data stack, with debug controls if enabled.
@POP	MACRO  Value : REQ
	IFDEF  DEBUG
		@@STACK_UNDERFLOW	Value
		POP			Value
	ELSE
		POP			Value
	ENDIF
ENDM


; @PUSH -
;	Pushes a value from the data stack, with debug controls if enabled.
@PUSH	MACRO  Value : REQ
	IFDEF	DEBUG
		@@STACK_OVERFLOW	Value
		PUSH			Value
	ELSE
		PUSH			Value
	ENDIF
ENDM


; @NEEDS -
;	Checks if the stack has sufficient space to hold <Reg> cells.
@NEEDS   MACRO  Value : REQ
	@@STACK_OVERFLOW_COUNT		Value
ENDM

; @DESTROYS -
;	Checks if the stack can pop <reg> cells.
@DESTROYS   MACRO  Value : REQ
	@@STACK_UNDERFLOW_COUNT		Value
ENDM