;**************************************************************************************************
;*
;*  NAME
;*	String.inc
;*
;*  DESCRIPTION
;*	Header file for string functions.
;*
;*  AUTHOR
;*	Christian Vigh, 11/2012.
;*
;*  HISTORY
;*  [Version : 1.0]		[Author : CV]		[Date : 2012/11/11]
;*	Initial version.
;*
;******************************************************************************************************


;==============================================================================================================
;=
;=  Constants.
;=
;==============================================================================================================*/

;
; Misc constants
;
STRING_BUFFER_SIZE		EQU		1024						; String buffer used by some string functions
BASE64_PADDING			EQU		'='						; Padding char for base64 encoding

;
; Constants for numeric conversions
;
MAX_INT64_BASE10_DIGITS		EQU		20						; Maximum digits in decimal base for a 64-bits unsigned value
MAX_INT32_BASE10_DIGITS		EQU		10						; Same, for 32 bits
MAX_INT16_BASE10_DIGITS		EQU		5						; Same, for 16 bits
MAX_INT8_BASE10_DIGITS		EQU		3						; Same, for 8 bits

;
; CTYPE constants
;
CTYPE_UPPER			EQU		00001H						; Upper case letter
CTYPE_LOWER			EQU		00002H						; Lower case letter
CTYPE_DIGIT			EQU		00004H						; Digit [0-9]
CTYPE_SPACE			EQU		00008H						; Space (TAB, CR, LF, VT or FF)
CTYPE_PUNCTUATION		EQU		00010H						; Punctuation character
CTYPE_CONTROL			EQU		00020H						; Control character
CTYPE_BLANK			EQU		00040H						; Space character
CTYPE_HEX			EQU		00080H						; Hexadecimal digit


;==============================================================================================================
;=
;=  CTYPE classification macros -
;=	Each macro uses the RSI register.
;=
;==============================================================================================================*/

; The String@Is macro is the macro used by all the character classification macros.
; On output ZF is set to 1 if the character does not belong to the specified classification.
; Modifies the RAX register if <SrcReg> is not AL.
String@Is	MACRO	Flags : REQ, SrcReg : REQ,  LoadRSI : REQ
	;; The specified register must be 8-bits long
	IF  $IsRegister8 ( SrcReg )  EQ  0
		.ERR  <The $StringIs macro must be used with an 8-bit register.>
	ENDIF

	;; Load RAX with the specified 8-bit register
	MOVZX		RAX, SrcReg

	;; The first call to a String$Isxxx macro must set the LoadRSI parameter to 1 (the default)
	;; Subsequent calls to any other String$Isxxx macros can omit this parameter.
	IF  LoadRSI  NE  0
		PUSH		RSI
		LEA		RSI, ASCII@CTYPE
	ENDIF

	;; Get the entry from the ctype table
	MOV		AH, [ RSI + RAX ]
	AND		AH, Flags
	OR		AH, AH

	;; Pop RSI if previously pushed
	IF  LoadRSI  NE  0
		POP		RSI
	ENDIF
ENDM


; String$IsSpace -
;	Checks if the character in the specified 8-bits register is a space, tabulation or CR/LF.
String$IsSpace		MACRO		SrcReg := <AL>, LoadRSI := <1>
	String@Is	CTYPE_SPACE, SrcReg, LoadRSI
ENDM

; String$IsLower -
;	Checks if the character in the specified 8-bits register is a lowercase letter.
String$IsLower		MACRO		SrcReg := <AL>, LoadRSI := <1>
	String@Is	CTYPE_LOWER, SrcReg, LoadRSI
ENDM

; String$IsUpper -
;	Checks if the character in the specified 8-bits register is an upprcase letter.
String$IsUpper		MACRO		SrcReg := <AL>, LoadRSI := <1>
	String@Is	CTYPE_UPPER, SrcReg, LoadRSI
ENDM

; String$IsLetter -
;	Checks if the character in the specified 8-bits register is a letter.
String$IsLetter		MACRO		SrcReg := <AL>, LoadRSI := <1>
	String@Is	CTYPE_LOWER OR CTYPE_UPPER, SrcReg, LoadRSI
ENDM

; String$IsDigit -
;	Checks if the character in the specified 8-bits register is a decimal digit.
String$IsDigit		MACRO		SrcReg := <AL>, LoadRSI := <1>
	String@Is	CTYPE_DIGIT, SrcReg, LoadRSI
ENDM

; String$IsHexDigit -
;	Checks if the character in the specified 8-bits register is an hexadecimal digit.
String$IsHexDigit	MACRO		SrcReg := <AL>, LoadRSI := <1>
	String@Is	CTYPE_HEX, SrcReg, LoadRSI
ENDM

; String$IsPunctuation -
;	Checks if the character in the specified 8-bits register is a punctuation character.
String$IsPunctuation	MACRO		SrcReg := <AL>, LoadRSI := <1>
	String@Is	CTYPE_PUNCTUATION, SrcReg, LoadRSI
ENDM

; String$IsControl -
;	Checks if the character in the specified 8-bits register is a control character.
String$IsControl	MACRO		SrcReg := <AL>, LoadRSI := <1>
	String@Is	CTYPE_CONTROL, SrcReg, LoadRSI
ENDM


;==============================================================================================================
;=
;=  Entry points.
;=
;==============================================================================================================*/

;
; String functions 
;
EXTERNDEF	String$Base64Decode			:  PROC
EXTERNDEF	String$Base64Encode			:  PROC
EXTERNDEF	String$CatenateChar			:  PROC
EXTERNDEF	String$CatenateString			:  PROC
EXTERNDEF	String$Compare				:  PROC
EXTERNDEF	String$CompareFixed			:  PROC
EXTERNDEF	String$CompareFixedNoCase		:  PROC
EXTERNDEF	String$CompareNoCase			:  PROC
EXTERNDEF	String$Concatenate			:  PROC
EXTERNDEF	String$Copy				:  PROC
EXTERNDEF	String$CopyFixed			:  PROC
EXTERNDEF	String$CopyLeft				:  PROC
EXTERNDEF	String$CopyRight			:  PROC
EXTERNDEF	String$CountCharOccurrences		:  PROC
EXTERNDEF	String$CountCharOccurrencesNoCase	:  PROC
EXTERNDEF	String$Delete				:  PROC
EXTERNDEF	String$DeleteLeft			:  PROC
EXTERNDEF	String$DeleteRight			:  PROC
EXTERNDEF	String$DuplicateChar			:  PROC
EXTERNDEF	String$DuplicateString			:  PROC
EXTERNDEF	String$FormatString			:  PROC
EXTERNDEF	String$IntegerToString			:  PROC
EXTERNDEF	String$Left				:  PROC
EXTERNDEF	String$Length				:  PROC
EXTERNDEF	String$RepeatChar			:  PROC
EXTERNDEF	String$RepeatString			:  PROC
EXTERNDEF	String$ReplaceChar			:  PROC
EXTERNDEF	String$ReplaceCharNoCase		:  PROC
EXTERNDEF	String$ReplaceString			:  PROC
EXTERNDEF	String$ReplaceStringNoCase		:  PROC
EXTERNDEF	String$Reverse				:  PROC
EXTERNDEF	String$Right				:  PROC
EXTERNDEF	String$SearchChar			:  PROC
EXTERNDEF	String$SearchCharNoCase			:  PROC
EXTERNDEF	String$SearchString			:  PROC
EXTERNDEF	String$SearchStringNoCase		:  PROC
EXTERNDEF	String$StripChar			:  PROC
EXTERNDEF	String$ToFloat				:  PROC
EXTERNDEF	String$ToInteger			:  PROC
EXTERNDEF	String$ToUpperChar			:  PROC
EXTERNDEF	String$ToLowerString			:  PROC
EXTERNDEF	String$ToUpperString			:  PROC
EXTERNDEF	String$ToUpperString			:  PROC
EXTERNDEF	String$Trim				:  PROC
EXTERNDEF	String$TrimLeft				:  PROC
EXTERNDEF	String$TrimRight			:  PROC
EXTERNDEF	String$UnsignedToString			:  PROC
EXTERNDEF	String$UnsignedToBase16String		:  PROC
EXTERNDEF	String$UnsignedToBase8String		:  PROC
EXTERNDEF	String$UnsignedToBase2String		:  PROC

;
; Various tables
;
EXTERNDEF	ASCII@UPPERCASE				:  BYTE			; Conversion to uppercase
EXTERNDEF	ASCII@LOWERCASE				:  BYTE			; Conversion to lowercase
EXTERNDEF	ASCII@CTYPE				:  BYTE			; Character type classification
EXTERNDEF	ASCII@HEXDIGITS				:  BYTE			; Correspondance for hex digits
EXTERNDEF	ASCII@BASE64				:  BYTE			; Base 64 conversion table
EXTERNDEF	ASCII@REVERSE_BASE64			:  BYTE			; Reversed base 64 conversion table; We're over
EXTERNDEF	STRING_BUFFER				:  BYTE			; Temporary string buffer used by some string functions

;
; Entry points for internal functions
;
EXTERNDEF	String@FindEOS				:  PROC