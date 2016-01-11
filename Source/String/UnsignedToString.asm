;**************************************************************************************************************
;*
;*  NAME
;*	UnsignedToString.asm
;*
;*   DESCRIPTION
;*	Converts an unsigned integer to a string.
;*
;*  AUTHOR
;* 	Christian Vigh, 11/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/11/29]     [Author : CV]
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
;=	UnsignedToString@ - Converts an unsigned integer to a string.
;=
;=   DESCRIPTION
;=	Converts an unsigned integer to a string. The result is placed into a buffer whose address is given by
;=	the caller.
;=
;=   INPUT
;=	RCX -
;=		Signed integer value to convert.
;=
;=	RDX -
;=		Address of the destination buffer.
;=
;=   OUTPUT
;=	RAX -
;=		Pointer to the start of the converted string into the supplied destination buffer.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$UnsignedToString  PROC
	PUSHES		RCX, RDX, R8, R9, R10, R11

	; Since we know the maximum length of an integer number into base 10, and the algorithm produces
	; the characters from the conversion into the reverse order, we will start conversion from the
	; end and move the buffer pointer downwards for each new digit.
	MOV		R10, RDX
	ADD		R10, MAX_INT64_BASE10_DIGITS + 2	; "+2" stands for : "room for potential negative sign and trailing zero"
	MOV		BYTE PTR [ R10 ], 0			; Terminate the string

	MOV		R11, 0CCCCCCCCCCCCCCCDH			; Magic value

	ALIGNCODE
ConversionLoop :
	MOV		RAX, R11				; Move the magic value into RAX
	DEC		R10					; Move downwards one character for the next digit
	MUL		RCX					; Multiply the value to convert by the magic value
	SHR		RDX, 3					; The rest of the conversion algorithm is provided by the Microsoft C Compiler
	MOVZX		R8D, DL
	SHL		R8B, 2
	LEA		R9D, DWORD PTR[ R8 + RDX ]
	ADD		R9B, R9B
	SUB		CL, R9B

	ADD		CL, '0'					; Convert digit value to ascii
	MOV		BYTE PTR [ R10 ], CL			; Save it 

	MOV		RCX, RDX				; Divide value to convert by 10

	TEST		RDX, RDX				; Is remainder non-zero ?
	JNE		ConversionLoop				; Yes, continue
	MOV		RAX, R10				; No, return the pointer to the converted value

	POPS		RCX, RDX, R8, R9, R10, R11
	RET
String$UnsignedToString  ENDP

END