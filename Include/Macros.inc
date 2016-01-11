;**************************************************************************************************
;*
;*  NAME
;*	Macros.inc
;*
;*  DESCRIPTION
;*	General macros.
;*
;*  AUTHOR
;*	Christian Vigh, 11/2012.
;*
;*  HISTORY
;*  [Version : 1.0]		[Author : CV]		[Date : 2012/11/02]
;*	Initial version.
;*
;**************************************************************************************************


;==================================================================================================
;=
;=  Macro BUFFER Lbl, Size
;=	Defines an uninitialized buffer.
;=
;==================================================================================================
BUFFER	MACRO	Lbl : REQ, Size : REQ, Alignment := <16>
	ALIGN( Alignment )
	Lbl:
		DB	Size DUP (?)
	ALIGN( Alignment )
ENDM


;==================================================================================================
;=
;=  Macro STRING Lbl, Args :
;=	Defines a string having the specified label in the englobing segment.
;=	The string will be null=terminated.
;=
;==================================================================================================
STRING	MACRO	Lbl, Args : VARARG
	Lbl:
	FOR  Arg, <Args>
		DB	Arg
	ENDM
		DB	0
ENDM


;==================================================================================================
;=
;=  String manipulation macros.
;=
;==================================================================================================

; ORD -
;	Returns the ordinal value of a character.
ORD	MACRO	Ch : REQ
	LOCAL	Characters, Index

	Characters	EQU  < !"#$%&'()*+,-./0123456789:;!<=!>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~>
	Index	INSTR  Characters, <Ch>

	IF  Index  LT  1 
		EXITM %0
	ELSE
		EXITM %( Index + 32 )
	ENDIF
ENDM


; CHR -
;	Returns the character corresponding to an integer value.
CHR	MACRO  Ich : REQ
	LOCAL	Characters, Index, Strlen, Ch

	Characters	EQU  < !"#$%&'()*+,-./0123456789:;!<=!>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~>
	Strlen	SIZESTR  Characters
	Index	=  Ich - 32

	IF  Index  LT  1  OR  Index  GT  126
		EXITM < >
	ELSE
		Ch  SUBSTR Characters, Index, 1
		EXITM Ch
	ENDIF
ENDM  


; CHR$ -
;	Returns the Ascii character corresponding to an integer value, enclosed in quotes.
CHR$	MACRO  Ich : REQ
	LOCAL  Result

	Result   EQU  CHR ( Ich )
	Result   CATSTR  <">, Result, <">
	EXITM    Result
ENDM


; STRING$ -
;	Converts its arguments to a double-quoted string.
STRING$  MACRO  Args : VARARG
	LOCAL	Result


	ToString	MACRO  Value
		LOCAL  ArgLen, ArgFirst, ArgLast, ToResult, Bracketed, Escape, Ch

		ArgLen		SIZESTR <Value>
	
		IF  ArgLen  EQ  0
			EXITM  <>
		ENDIF
	
		ArgFirst	SUBSTR <Value>, 1, 1
		ArgLast		SUBSTR <Value>, ArgLen, 1
		Bracketed	=  0

		IFIDN  ArgFirst, <!<>
			IFIDN  ArgLast, <!>>
				Bracketed = 1
			ENDIF
		ENDIF

		IFIDN  ArgFirst, <">
			IFIDN  ArgLast, <">
				Bracketed = 1
			ENDIF
		ENDIF

		IF  Bracketed  NE  0
			Value	SUBSTR  <Value>, 2, ArgLen - 2 
		ELSE
			EXITM <Value>
		ENDIF

		Escape	=  0
		ToResult EQU <>

		FORC  Ch, Value
			IFIDN  Ch, <!!>  AND  NOT Escape
				Escape = 1
			ELSEIFIDN  Ch, <">
				ToResult  CATSTR  ToResult, <"">
			ELSE
				ToResult  CATSTR  ToResult, Ch
			ENDIF
		ENDM

		ToResult	CATSTR  <">, ToResult, <">

		EXITM <ToResult>
	ENDM

	Result	EQU  <>

	FOR  Value, <Args>
		Result  CATSTR  Result, ToString ( Value )
	ENDM

	IFIDN  Result, <>
		Result = <0>
	ELSE
		Result CATSTR <">, Result, <">, <, 0>
	ENDIF

	EXITM  Result
ENDM


;==================================================================================================
;=
;=  Macro VERSION  major, minor, release
;=	Defines the following constants : VERSION_MAJOR, VERSION_MINOR and VERSION_RELEASE.
;=
;==================================================================================================
VERSION	 MACRO  Major, Minor, Release
	VERSION_MAJOR		EQU	Major
	VERSION_MINOR		EQU	Minor
	VERSION_RELEASE		EQU	Release
ENDM


; VERSION$ -
;	Returns the version as a string.
VERSION$  MACRO
	LOCAL	@dir

	@dir	CATSTR  <">, %VERSION_MAJOR, <.>, %VERSION_MINOR, <.>, %VERSION_RELEASE, <">
	EXITM @dir
ENDM


;==================================================================================================
;=
;=  Predefined macros aliases. This allows the macro functions to be used within a DB directive.
;=  So, for example, instead of writing :
;=	DB %@DATE
;=  ("@DATE" is a predefined symbol, and the "%" sign forces it to be evaluated as a string), you
;=  can write :
;=	DB $DATE()
;=
;==================================================================================================
DATE$  MACRO
	LOCAL	dat$month, dat$day, dat$year, $result

	dat$month	SUBSTR @DATE, 1, 2
	dat$day		SUBSTR @DATE, 4, 2
	dat$year	SUBSTR @DATE, 7, 2
	$result		CATSTR  <">, <20>, dat$year, </>, dat$month, </>, dat$day, <">
	EXITM $result
ENDM

; YEAR$ -
;	Returns the current year.
YEAR$  MACRO
	LOCAL  year
	
	year	SUBSTR @DATE, 7, 2
	year	CATSTR  <20>, year
	EXITM year
ENDM

; MONTH$ -
;	Returns the current month.
MONTH$  MACRO
	LOCAL  month

	month	SUBSTR @DATE, 1, 2
	EXITM month
ENDM


; DAY$ -
;	Returns the current day.
DAY$  MACRO
	LOCAL  day

	day	SUBSTR @DATE, 4, 2
	EXITM day
ENDM

; HOUR$ -
;	Returns the current hour.
HOUR$  MACRO
	LOCAL  hour

	hour	SUBSTR @TIME, 1, 2
	EXITM  hour
ENDM

; MINUTE$ -
;	Returns the current minute.
MINUTE$  MACRO
	LOCAL  minute

	minute	SUBSTR @TIME, 4, 2
	EXITM minute
ENDM

; SECOND$ -
;	Returns the current second.
SECOND$  MACRO
	LOCAL  second

	second  SUBSTR @TIME, 7, 2
	EXITM second
ENDM


;==================================================================================================
;=
;=  Stack manipulation macros :
;=	STACK$CREATE Name
;=	STACK$PUSH   Name, Value
;=      Value TEXTEQU  STACK$POP ( Name )
;=
;=  These macros allow to simulate a stack by creating equates for referencing its elements.
;=  One equate is defined to hold the stack size, then one additional equate is created each time
;=  a value is pushed onto the stack.
;=
;=  The equate holding the stack size has the following form :
;=	$Stack$stackname$Size
;=  where "stackname" is the name of the stack. Similarly, equates holding a stack entry have the
;=  following form :
;=	$Stack$stackname$x
;=  where "x" is the entry number, starting from zero.
;=
;=  STACK$CREATE name creates a stack of the given name.
;=  STACK$PUSH name, value pushes the specified value onto the stack named "name".
;=  STACK$POP ( name ) allows to retrieve the latest entry pushed onto the stack. Note that if you
;=  use the following syntax :
;=
;=	LastEntry  EQU STACK$POP ( MyStack )
;=
;=  then the STACK$POP function will be called each time you reference "LastEntry" in your macro
;=  or assembly source. To force the evaluation of the STACK$POP function result, you must either :
;=  1) Call a macro, giving the equate as a parameter (LastEntry in our above example). In this
;=     case, the call to STACK$POP is evaluated and the macro will receive the evaluated value.
;=  2) Define the equate using the TEXTEQU directive :
;=		LastEntry  TEXTEQU  STACK$POP ( MyStack )
;=     In this case, the LastEntry equate will receive the result of the call to STACK$POP.
;=
;==================================================================================================

;
; STACK$CREATE  Name -
;	Creates a stack of the specified name.
;
STACK$CREATE  MACRO  Name : REQ
	IFNDEF $Stack$&Name&$Size 
		$Stack$&Name&$Size	=  0
	ENDIF
ENDM

;
; STACK$PUSH  Name, Value -
;	Pushes the specified value onto the stack having the specified name.
;
STACK$PUSH  MACRO  Name : REQ, Value : REQ
	LOCAL	CurrentIndex, CurrentName

	;; Macro EMIT -
	;;	A replacement to the following instructions :
	;;		CurrentName		CATSTR	<$Stack$>, <Name>, <$>, %CurrentIndex, < EQU >, <!<>, Value, <!>>
	;;		CurrentName
	;;	The STACK$PUSH macro is called by PUSHREGS. Once the pushed register stack has been emptied by POPREGS, 
	;;	a subsequent PUSHREGS generated a "bad character in file" error, as if the local label "CurrentName" (??xxxx)
	;;	was empty.
	;;	A macro such as EMIT allows to overcome what seems to be a bug.
	EMIT  MACRO	Name, Value, Index
		$Stack$&Name&$&Index&  EQU  <Value>
	ENDM


	STACK$CREATE		Name

	CurrentIndex		=  $Stack$&Name&$Size
	EMIT  Name, Value, %CurrentIndex
	$Stack$&Name&$Size	=  $Stack$&Name&$Size + 1
ENDM

;
; STACK$POP  Name -
;	Returns the latest pushed value from the stack (well, in fact it returns the name of the equate
;	that contains the value).
;
STACK$POP  MACRO  Name : REQ
	LOCAL	CurrentIndex, CurrentName

	CurrentIndex		=  $Stack$&Name&$Size

	IF  CurrentIndex  EQ  0
		.ERR <Stack "&Name&" empty.>
	ENDIF

	CurrentIndex		=  CurrentIndex - 1 

	CurrentName		CATSTR	<$Stack$>, <Name>, <$>, %CurrentIndex
	$Stack$&Name&$Size	=  CurrentIndex

	EXITM CurrentName
ENDM


;==================================================================================================
;=
;=  Miscellaneous macros.
;=
;==================================================================================================

;
; ORIGIN -
;	Sets the segment origin.
;
ORIGIN	MACRO  Address
	ORG	Address
ENDM


;==================================================================================================
;=
;=  Macros related to macro arguments checkings.
;=
;==================================================================================================

; $IsRegister - 
;	Returns 1 if the specified argument is a register, 0 otherwise.
$IsRegister	MACRO  Arg : REQ
	LOCAL		ArgType

	ArgType		=  OPATTR ( Arg )

	IF  ArgType  EQ  030H
		EXITM %1
	ELSE
		EXITM %0
	ENDIF
ENDM


; $IsLiteral -
;	Returns 1 if the specified argument is a literal, 0 otherwise.
$IsLiteral	MACRO  Arg : REQ
	LOCAL		ArgType, ArgType2

	ArgType		=  OPATTR ( Arg )
	ArgType2	=  TYPE ( Arg ) 

	;; Structs have an OPATTR of 0x24 and TYPE return their size,
	;; while true literals have a size of 0.
	IF  ArgType  EQ  024H  AND  ArgType2  EQ  0
		EXITM %1
	ELSE
		EXITM %0
	ENDIF
ENDM


; $IsStructure -
;	Returns 1 if the specified argument is a structure, 0 otherwise.
$IsStructure	MACRO  Arg : REQ
	LOCAL		ArgType, ArgType2

	ArgType		=  OPATTR ( Arg )
	ArgType2	=  TYPE ( Arg ) 

	;; Structs have an OPATTR of 0x24 and TYPE return their size,
	;; while true literals have a size of 0.
	IF  ArgType  EQ  024H  AND  ArgType2  NE  0
		EXITM %1
	ELSE
		EXITM %0
	ENDIF
ENDM


; $IsData -
;	Returns 1 if the specified argument is a label associated with data (through
;	the DB, DW, DD, STRUCT, etc. keywords) or 0 if not.
$IsData		MACRO  Arg : REQ
	LOCAL	Value

	;; Mask bit 15, which signals an external symbol
	Value	=  OPATTR ( Arg )
	Value	=  Value AND  07FH

	IF  Value  EQ  02AH 
		EXITM %1
	ELSE
		EXITM %0
	ENDIF
ENDM


; $IsExternal -
;	Returns 1 if the specified argument is an external symbol, 0 otherwise.
$IsExternal	MACRO  Arg : REQ
	Value	=  OPATTR ( Arg )
	Value	=  Value AND  080H

	IF  Value  NE  0
		EXITM %1
	ELSE
		EXITM %0
	ENDIF
ENDM


; $IsLabel -
;	Returns 1 if the specified argument is a label (or proc), 0 otherwise.
$IsLabel	MACRO  Arg : REQ
	Value	=  OPATTR ( Arg )
	Value	=  Value AND  07FH

	IF  Value  EQ  025H
		EXITM %1
	ELSE
		EXITM %0
	ENDIF
ENDM

; $IsAddressing -
;	Returns 1 if the specified argument is an addressing argument enclosed in brackets,
;	or 0 otherwise.
$IsAddressing	MACRO  Arg : REQ
	;; We could use OPATTR() to determine if we have an addressing expression, but here is
	;; what the function returns :
	;; [EBX], [ECX], etc.	: 0x22
	;; [ESP], [EBP], etc.	: 0x62
	;; [EAX]		: 0x2A, same as MyVariable or [MyVariable] !!
	;; Due to this inconsistency, we simply check that the string starts with "["
	LOCAL		Index

	Index		EQU  SUBSTR ( Arg, 1, 1 )

	IFIDN  Index, <[>
		EXITM %1
	ELSE
		EXITM %0
	ENDIF
ENDM

; $Sizeof -
;	Returns the size of its argument.
$Sizeof	MACRO  Arg : REQ
	LOCAL		TheSize

	TheSize		=  TYPE ( Arg )
	EXITM  %TheSize
ENDM

; $IsRegisterx -
;	Checks if the specified register have a size of 'x' bits.
$IsRegister8	MACRO  Arg : REQ
	IF  $IsRegister ( <Arg> )  EQ  1  
		IF  $Sizeof ( <Arg> )  EQ  1
			EXITM %1
		ENDIF
	ENDIF

	EXITM %0
ENDM

$IsRegister16	MACRO  Arg : REQ
	IF  $IsRegister ( Arg )  EQ  1  AND  $Sizeof ( Arg )  EQ  2
		EXITM %1
	ELSE
		EXITM %0
	ENDIF
ENDM

$IsRegister32	MACRO  Arg : REQ
	IF  $IsRegister ( Arg )  EQ  1  AND  $Sizeof ( Arg )  EQ  4
		EXITM %1
	ELSE
		EXITM %0
	ENDIF
ENDM

$IsRegister64	MACRO  Arg : REQ
	IF  $IsRegister ( Arg )  EQ  1  AND  $Sizeof ( Arg )  EQ  8
		EXITM %1
	ELSE
		EXITM %0
	ENDIF
ENDM

$IsRegister128	MACRO  Arg : REQ
	IF  $IsRegister ( Arg )  EQ  1  AND  $Sizeof ( Arg )  EQ  16
		EXITM %1
	ELSE
		EXITM %0
	ENDIF
ENDM



;==================================================================================================
;=
;=  Macros related to macro arguments.
;=
;==================================================================================================

; MACRO_ARGC -
;	Returns the number of elements in a VARARG macro argument.
MACRO_ARGC	MACRO	Args : VARARG
	LOCAL	Count

	Count	=  0

	FOR  Arg, <Args>
		Count = Count + 1
	ENDM

	EXITM  %Count
ENDM


; MACRO_ARGV -
;	Returns the nth element of a VARARG macro argument.
MACRO_ARGV	MACRO	Index, Args : VARARG
	LOCAL	Count, Current, Result

	Count	=  MACRO_ARGC ( Args )

	IF  Index  GT  Count  OR  Index  LT  1
		.ERR <Argument index out of range.>
	ENDIF

	Current		=  0
	Result TEXTEQU	<>

	FOR  Arg, <Args>
		Current = Current + 1
		
		IF  Current  EQ  Index
			Result	TEXTEQU  <Arg>
			EXITM
		ENDIF
	ENDM
	
	EXITM  Result
ENDM