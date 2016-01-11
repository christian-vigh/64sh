;**************************************************************************************************************
;*
;*  NAME
;*	IntegerToString.asm
;*
;*   DESCRIPTION
;*	Converts a signed integer to a string.
;*
;*  AUTHOR
;* 	Christian Vigh, 11/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/11/28]     [Author : CV]
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
;=	IntegerToString@ - Converts an integer to a string.
;=
;=   DESCRIPTION
;=	Converts a signed integer to a string.
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
String$IntegerToString  PROC
	PUSHES		RCX, RDX, R8, R9, R10, R11
	MOV		R10, RCX				; R10 will hold the number to convert

	; Since we know the maximum length of an integer number into base 10, and the algorithm produces
	; the characters from the conversion into the reverse order, we will start conversion from the
	; end and move the buffer pointer downwards for each new digit.
	MOV		R9, RDX	
	ADD		R9, MAX_INT64_BASE10_DIGITS + 2		; "+2" stands for : "room for potential negative sign and trailing zero"
	MOV		BYTE PTR [R9], 0			; Terminate the string

	MOV		R11, 06666666666666667H

	TEST		RCX, RCX
	JS		Negative
	ALIGNCODE

	; Conversion of positive integers
Positive :
	MOV		RAX, R11				; Move the magic value into RAX
	DEC		R9					; Move downwards one character for the next digit
	IMUL		R10					; Multiply the value to convert by the magic value
	SAR		RDX, 2					; The rest of the conversion algorithm is provided by the Microsoft C Compiler
	MOV		RAX, RDX				; with all optimizations activated
	SHR		RDX, 63
	ADD		RDX, RAX
	MOVZX		ECX, DL
	SHL		CL, 2
	LEA		R8D, DWORD PTR [ RCX + RDX ]
	ADD		R8B, R8B
	SUB		R10B, R8B

	ADD		R10B, '0'				; Convert digit value to ascii
	MOV		BYTE PTR [R9], R10B			; Save it 

	MOV		R10, RDX				; Divide value to convert by 10

	TEST		RDX, RDX				; Is remainder non-zero ?
	JNE		Positive				; Yes, continue
	MOV		RAX, R9					; No, return the pointer to the converted value

	POPS		RCX, RDX, R8, R9, R10, R11
	RET

	; Conversion of negative integers
	ALIGNCODE
Negative :
	MOV		RAX, R11				; Move the magic value into RAX
	DEC		R9					; Move downwards one character for the next digit
	IMUL		R10					; Multiply the value to convert by the magic value
	SAR		RDX, 2					; The rest of the conversion algorithm is provided by the Microsoft C Compiler
	MOV		RAX, RDX				; with all optimizations activated
	SHR		RDX, 63
	ADD		RDX, RAX
	MOVZX		RAX, DL
	SHL		AL, 2
	LEA		ECX, DWORD PTR [ RAX + RDX ]
	ADD		CL, CL
	SUB		CL, R10B

	MOV		R10, RDX				; Divide value to convert by 10
	ADD		CL, '0'					; Convert digit value to 0
	MOV		BYTE PTR [ R9 ], CL			; And store it

	TEST		RDX, RDX				; Is remainder non-zero ?
	JNE		Negative				; Yes, continue

	MOV		RAX, R9					; No, return the pointer to the converted value
	DEC		RAX					; Don't forget the leading sign
	MOV		BYTE PTR [ RAX ], '-'			

	POPS		RCX, RDX, R8, R9, R10, R11
	RET
String$IntegerToString  ENDP

END