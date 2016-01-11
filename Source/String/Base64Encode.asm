;**************************************************************************************************************
;*
;*  NAME
;*	Base64Encode.asm
;*
;*   DESCRIPTION
;*	Encodes a string into base 64.
;*
;*  AUTHOR
;* 	Christian Vigh, 12/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/12/10]     [Author : CV]
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
;=	Base64Encode - Encodes a string into base 64.
;=
;=   DESCRIPTION
;=	Encodes the specified string into base 64. The results are placed into the buffer specified by the
;=	caller.
;=
;=   INPUT
;=	RCX -
;=		Pointer to the input string.
;=
;=	RDX -
;=		Pointer to the output string.
;=
;=   OUTPUT
;=	RAX -
;=		Pointer to the end of the encoded string.
;=
;=   REGISTERS USED
;=	None.
;=
;=   NOTES
;=	This version does NOT cut the output result into fixed lines of 64 or 76 characters followed by
;=	a CR/LF sequence.
;=
;===============================================================================================================*/
String$Base64Encode	PROC
	PUSHES		RBX, RCX, RSI, RDI

	MOV		RSI, RCX				; This will be our source buffer
	MOV		RDI, RDX				; RDI now points to the destination buffer
	LEA		RBX, ASCII@BASE64			; Address of base 64 encoding table

	; 
	; The base-64 algorithm is the following :
	; - Take a chunk of 3 bytes (24 bits)
	; - Consider that those 3 bytes hold 4 6-bits items :
	;
	;	Byte 1 (B1) :				Byte 2 (B2) :				Byte 3 (B3) :
	;	7   6   5   4   3   2   1   0		7   6   5   4   3   2   1   0		7   6   5   4   3   2   1   0
	;	+-------------------------------+	+-------------------------------+	+-------------------------------+
	;	| S1                    | S2(1) |	| S2(2)         | S3(1)         |	| S3(2) | S4                    |
	;       +-------------------------------+	+-------------------------------+	+-------------------------------+
	; 
	; The output is made of the following 4 bytes :
	; - OB1 = BASE64 [ B1 >> 2 ]
	; - OB2 = BASE64 [ (B1 << 4) | (B2 >> 4) ]
	; - OB3 = BASE64 [ ( (B2 & 0xF)  <<  2) | (B3 >> 6) ]
	; - OB4 = BASE64 [ (B3 & 0x3F) ]
	;
	; where "BASE64" is the address of the base-64 translation table (ASCII@BASE64).
	;
	ALIGN ( 8 )

ConversionLoop :
	; Test if we're in the case where at least three characters remain
	CMP		BYTE PTR [ RSI ], 0			; End of string : we're over
	JZ		Remains0
	CMP		BYTE PTR [ RSI + 1 ], 0			; Only one character remains
	JZ		Remains1
	CMP		BYTE PTR [ RSI + 2 ], 0			; Only two characters remain
	JZ		Remains2

	; Handle a series of 3 bytes
	LODSB							; Get B1
	MOV		AH, AL					; AH = B1 ( S1 + S2.1 )
	SHR		AL, 2					; AL = S1
	XLATB							; Get base64 character equivalent of S1
	STOSB							; Store OB1
	
	LODSB							; Get B2 (AH is still (S1 + S2.1)
	MOV		CL, AL					; CL = B2
	SHR		AL, 4					; AL = S2.2	
	AND		AH, 03H					; Isolate S2.1 in B1
	SHL		AH, 4					; Make it bits 4 and 5
	OR		AL, AH					; OB2 = (B1 << 4) | (B2 >> 4)
	XLATB							; Get base64 character equivalent of S2
	STOSB							; Store OB2

	LODSB							; Get B3
	MOV		AH, AL					; AH = (S3.2 + S4) ; CL is still B2
	SHR		AL, 6					; Get S3 in least significant positions
	SHL		CL, 2					; Move S3.1 to positions 2..5
	AND		CL, 03FH				; Mask bits 6 & 7
	OR		AL, CL					; AL = S3.2 + S3.1
	XLATB							; Get base64 character equivalent of S3
	STOSB							; Store OB3

	MOV		AL, AH					; AH = (S3.2 + S4)
	AND		AL, 03FH				; Zero out bits 6 & 7
	XLATB							; Get base64 character equivalent of S4
	STOSB							; Store OB4

	JMP		ConversionLoop				; And shoot again

	; No more byte remains to convert : we'reover
	ALIGN ( 8 )
Remains0 :
	XOR		AL, AL					; Store a trailing zero
	STOSB
	MOV		RAX, RDI				; Make RAX point to this trailing zero
	DEC		RAX

	POPS		RBX, RCX, RSI, RDI
	RET

	; Only one byte remains in the input stream
	ALIGN ( 8 )
Remains1 :
	LODSB							; Get B1
	MOV		AH, AL					; Save B1
	SHR		AL, 2					; Get S1
	XLATB							; Get base64 character equivalent of S1
	STOSB							; Store OB1

	MOV		AL, AH					; Get B1
	AND		AL, 03H					; Isolate S2.1
	SHL		AL, 4					; Don't forget that S2.1 are bits 4 & 5
	XLATB							; Get base64 character equivalent of S2.1
	STOSB							; Store OB2

	MOV		AL, BASE64_PADDING			; Store 2 padding characters
	STOSB
	STOSB

	JMP		Remains0				; We're over

	; Only two bytes remain in the input stream
	ALIGN ( 8 )
Remains2 :
	LODSB							; Get B1
	MOV		AH, AL					; AH = B1 ( S1 + S2.1 )
	SHR		AL, 2					; AL = S1
	XLATB							; Get base64 character equivalent of S1
	STOSB							; Store OB1
	
	LODSB							; Get B2 (AH is still (S1 + S2.1)
	MOV		CL, AL					; CL = B2
	SHR		AL, 4					; AL = S2.2	
	AND		AH, 03H					; Isolate S2.1 in B1
	SHL		AH, 4					; Make it bits 4 and 5
	OR		AL, AH					; OB2 = (B1 << 4) | (B2 >> 4)
	XLATB							; Get base64 character equivalent of S2
	STOSB							; Store OB2

	MOV		AL, CL					; AL = B2
	AND		AL, 0FH					; Isolate S3
	SHL		AL, 2					; Don't forget that S3.1 bits are in position 2 through 5
	XLATB							; Get base64 character equivalent of S3
	STOSB							; Store OB3

	MOV		AL, BASE64_PADDING			; Store one padding character
	STOSB

	JMP		Remains0				; We're over

String$Base64Encode	ENDP

END