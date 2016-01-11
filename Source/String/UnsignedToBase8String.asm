;**************************************************************************************************************
;*
;*  NAME
;*	UnsignedToBase8String.asm
;*
;*   DESCRIPTION
;*	Converts an unsigned integer to a string in base 8.
;*
;*  AUTHOR
;* 	Christian Vigh, 11/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/11/30]     [Author : CV]
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
;=	UnsignedToBase8String@ - Converts an unsigned integer to a base-8 string.
;=
;=   DESCRIPTION
;=	Converts an unsigned integer to a string in the specified base. The result is placed into the buffer
;=	supplied by the caller.
;=
;=   INPUT
;=	RCX -
;=		Value to convert.
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
String$UnsignedToBase8String  PROC
	PUSHES		RDX

	LEA		RDX, STRING_BUFFER				; get pointer to our internal buffer
	OR		RCX, RCX					; Special case when the value is zero
	JNZ		NotZero

	MOV		BYTE PTR [ RDX ], '0'				; We must return a pointer to "0\0"
	MOV		BYTE PTR [ RDX + 1 ], 0

	POPS		RDX
	RET

	; Non-zero value : the digits are processed in reversed order and start from the end of the string.
NotZero :
	PUSHES		RBX, RCX

	LEA		RBX, ASCII@HEXDIGITS				; Get address of digit conversion table
	ADD		RDX, 22						; We will have at most 22 digits
	MOV		BYTE PTR [ RDX ], 0				; Put the trailing zero

	; During the conversion loop, we will put the digits downwards
ConversionLoop :
	DEC		RDX						; Move to next digit
	MOV		AL, CL						; Get next nibble
	AND		AL, 07H
	XLATB								; Translate to its ascii value
	MOV		BYTE PTR [ RDX ], AL				; And store it
	SHR		RCX, 3						; Get read from that nibble

	OR		RCX, RCX					; We're finished when the value to convert is zero
	JNZ		ConversionLoop

	MOV		RAX, RDX					; All done, return a pointer to the converted value

	POPS		RDX, RBX, RCX
	RET
String$UnsignedToBase8String  ENDP

END