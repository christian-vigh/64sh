;**************************************************************************************************
;*
;*  NAME
;*	ToInteger.asm
;*
;*  DESCRIPTION
;*	String to integer conversion.
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
.LIST


.CODE

;==================================================================================================
;
; String$ToInteger -
;	Converts a string to an integer value.
;
; INPUT :
;	RCX -
;		Pointer to the first string.
;
; OUTPUT :
;	RAX -
;		Converted number.
;
;	ZF -
;		ZF will be set to 1 if the input string isa zero value.
;
;	CF -
;		CF will be set to 1 if the input string contains an invalid integer value.
;
; NOTES
;	. Integer values can have the following forms :
;		- [+-]? [0-9]+		for signed/unsigned decimal integer values
;		- 0x [0-9A-Fa-f]+	for unsigned hexadecimal values
;		- 0d [0-9]+		for unsigned decimal integer values
;		- 0o [0-7]+		for unsigned octal values
;		- 0b [0-1]+		for unsigned binary values
;	
;	. The caller must test the carry flag for potential error before checking the zero flag :
;	  when an error occurs, the zero flag is always set to 1.
;	. The strings literals '0b', '0o', '0d' and '0x' are interpreted as zero.
;
;==================================================================================================
String$ToInteger	PROC
	PUSHES		RBX, RCX, RDX, RSI, R8, R9

	MOV		RSI, RCX			; Input string characters will be loaded with LODSB

	MOV		RBX, 10				; Current base
	XOR		R8, R8				; Current conversion result
	XOR		CH, CH				; CH will be set to 1 on negative number

	; Check if the first character is a positive or negative sign
	LODSB	
	CMP		AL, '-'
	JE		NegativeSign
	CMP		AL, '+'
	JE		PositiveSign

	; The first character can also be a zero followed by 'x', 'o', 'd' or 'b'
	CMP		AL, '0'
	JNE		Base10				; First character was not a zero
	LODSB						; Get next byte : may be a character specifying the base

	CMP		AL, 'x'				; Check for '0x' : base 16
	JE		SetBase16
	CMP		AL, 'X'
	JE		SetBase16

	CMP		AL, 'o'				; Check for '0o' : base 8
	JE		SetBase8
	CMP		AL, 'O'
	JE		SetBase8

	CMP		AL, 'b'				; Check for '0b' : base 2
	JE		SetBase2
	CMP		AL, 'B'
	JE		SetBase2

	CMP		AL, 'd'				; Check for '0d' : base 10
	JE		SetBase10
	CMP		AL, 'D'
	JE		SetBase10

	; Character is not a sign : then it must be a sequence of digits
	JMP		Base10

	; The string is prefixed by '0b' : base 2
SetBase2 :
	LODSB						; Get next char
	JMP		Base2

	; The string is prefixed by '0o' : base 8
SetBase8 :
	LODSB						; Get next char
	MOV		CL, 3
	JMP		Base8

	; The string is prefixed by '0x' : base 16
SetBase16 :
	LODSB						; Get next char
	MOV		CL, 4
	JMP		Base16

	; Base 10 : When a negative sign is encountered, keep a flag indicating that we need to negate the result
NegativeSign :
	INC		CH

	; Base 10 : Otherwise don't keep anything
PositiveSign :

	; The string is prefixed by '0d' : base 10
SetBase10 :
	LODSB						; Get next char

	; Conversion loop for the decimal base
Base10 :
	OR		AL, AL				; Current character is zero : we have finished to parse the string
	JZ		AlmostTheEnd

	CMP		AL, '0'				; Characters must be between 0 and 9
	JL		BadChar
	CMP		AL, '9'
	JG		BadChar

	SUB		AL, '0'				; Convert character to byte value

	MOVZX		R9, AL				; R9 corresponds to AL and will hold a value between 0 and 9
	MOV		RAX, R8				; RAX <- Current conversion result
	MUL		RBX				; Multiply current conversion result by the number base
	ADD		RAX, R9				; Add the character we just converted
	MOV		R8, RAX				; And save the result back to R8

	LODSB						; Next loop iteration : load next character...
	JMP		Base10				; ... and jump !

	; Conversion loop for base 2
Base2 :
	OR		AL, AL				; Current character is zero : we have finished to parse the string
	JZ		AlmostTheEnd

	CMP		AL, '0'				; Characters must be between 0 and 1
	JL		BadChar
	CMP		AL, '1'
	JG		BadChar

	SUB		AL, '0'				; Convert character to byte value

	SHL		R8, 1				; Multiply by 2
	MOVZX		R9, AL
	ADD		R8, R9				; Add current digit

	LODSB						; Next loop iteration : load next character...
	JMP		Base2				; ... and jump !

	; Conversion loop for base 8
Base8 :
	OR		AL, AL				; Current character is zero : we have finished to parse the string
	JZ		AlmostTheEnd

	CMP		AL, '0'				; Characters must be between 0 and 7
	JL		BadChar
	CMP		AL, '7'
	JG		BadChar

	SUB		AL, '0'				; Convert character to byte value

	SHL		R8, CL				; Multiply by 8 (CL = 3)
	MOVZX		R9, AL
	ADD		R8, R9				; Add current digit

	LODSB						; Next loop iteration : load next character...
	JMP		Base8				; ... and jump !

	; Conversion loop for base 16
Base16 :
	OR		AL, AL				; Current character is zero : we have finished to parse the string
	JZ		AlmostTheEnd

	CMP		AL, '0'				; Characters must be between 0 and 9, or A and F
	JL		BadChar
	CMP		AL, '9'
	JG		MaybeHex

	SUB		AL, '0'				; Convert decimal character to byte value
	JMP		DoBase16Operation

MaybeHex :
	AND		AL, 0DFH			; Mask the bit that makes the letter an uppercase letter
	CMP		AL, 'A'
	JL		BadChar
	CMP		AL, 'F'
	JG		BadChar

	SUB		AL, 'A' - 10			; Convert hex character to byte value

DoBase16Operation :
	SHL		R8, CL				; Multiply by 8 (CL = 4)
	MOVZX		R9, AL
	ADD		R8, R9				; Add current digit

	LODSB						; Next loop iteration : load next character...
	JMP		Base16				; ... and jump !


	; We arrive here when we met a decimal number of the form [+-]? [0-9]+
	; At that point, we need to check if the number will be negative or positive
AlmostTheEnd :
	OR		CH, CH				; Negative flag is held in CH
	JZ		TheEnd

	NEG		R8				; Negative flag was set

	; The whole string has been scanned, everything is ok
TheEnd :
	MOV		RAX, R8				; Move into RAX the final conversion result
	OR		RAX, RAX			; Just to set ZF in case the result is zero
	CLC						; Cancel carry flag to indicate to the caller that everything is ok

	POPS		RBX, RCX, RDX, RSI, R8, R9
	RET


BadChar :
	XOR		RAX, RAX			; Return zero in case of error
	STC						; And set the carry flag

	POPS		RBX, RCX, RDX, RSI, R8, R9
	RET

String$ToInteger	ENDP

END