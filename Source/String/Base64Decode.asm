;**************************************************************************************************************
;*
;*  NAME
;*	Base64Decode.asm
;*
;*   DESCRIPTION
;*	Decodes a string encoded into base 64.
;*
;*  AUTHOR
;* 	Christian Vigh, 12/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/12/16]     [Author : CV]
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
;=	Base64Decode - decodes a string encoded into base 64.
;=
;=   DESCRIPTION
;=	Decodes the specified string from base 64. The results are placed into the buffer specified by the
;=	caller.
;=
;=   INPUT
;=
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
;=	ZF -
;=		Set to 1 if invalid characters have been found in the input string, or if the encoding was
;=		inconsistent (for example, the input string does on end on a 4-byte boundary, or is not padded
;=		with the correct character).
;=
;=   REGISTERS USED
;=	None.
;=
;=   NOTES
;=	Spaces, tabs and line breaks are ignored in the input stream.
;=
;===============================================================================================================*/
String$Base64Decode	PROC
	PUSHES		RBX, RCX, RDX, RSI, RDI

	BYTE1		EQU	CH
	BYTE2		EQU	CL
	BYTE3		EQU	DH
	BYTE4		EQU	DL

	MOV		RSI, RCX				; This will be our source buffer
	MOV		RDI, RDX				; RDI now points to the destination buffer
	LEA		RBX, ASCII@REVERSE_BASE64		; Address of base 64 decoding table

	; Main conversion loop
ConversionLoop :

	; Get the 1st byte out of four
GetByte1 :
	LODSB

	OR		AL, AL					; If we find the end of string, then we're over
	JZ		EndOfString

	String$IsSpace						; Skip spaces
	JNZ		GetByte1

	CMP		AL, BASE64_PADDING			; Check for padding character
	JE		BadString				; This is too early so stop scanning

	XLATB							; Check that this is a valid base64 character
	TEST		AL, 080H
	JNZ		BadString
	
	MOV		BYTE1, AL				; Backup this character

	; Get the second byte out of four
GetByte2 :
	LODSB

	OR		AL, AL					; if we find the end of string, then we have met bad encoding
	JZ		BadString

	String$IsSpace						; Skip spaces
	JNZ		GetByte2

	CMP		AL, BASE64_PADDING			; Check for padding character
	JE		BadString				; This is too early so stop scanning

	XLATB							; Check that this is a valid base64 character
	TEST		AL, 080H
	JNZ		BadString
	
	MOV		BYTE2, AL				; Backup this second character

	; Get the third byte out of four
GetByte3 :
	LODSB

	OR		AL, AL					; if we find the end of string, then we have met bad encoding
	JZ		BadString

	String$IsSpace						; Skip spaces
	JNZ		GetByte3

	CMP		AL, BASE64_PADDING			; If padding character
	JE		Byte3Padding				; then check that we have a second padding character, followed by the end of string

	XLATB							; Check that this is a valid base64 character
	TEST		AL, 080H
	JNZ		BadString
	
	MOV		BYTE3, AL				; Backup this third character

	; Get the fourth byte out of four
GetByte4 :
	LODSB

	OR		AL, AL					; if we find the end of string, then we have met bad encoding
	JZ		BadString

	String$IsSpace						; Skip spaces
	JNZ		GetByte4

	CMP		AL, BASE64_PADDING			; If padding character
	JE		Byte4Padding				; then check that the last character is the end of string

	XLATB							; Check that this is a valid base64 character
	TEST		AL, 080H
	JNZ		BadString
	
	MOV		BYTE4, AL				; Backup this fourth character

	; We have collected four base64-encoded bytes so far (four 6-bits values)
	; Convert them to three 8-bytes values
	MOV		AL, BYTE1				; Build first original byte
	SHL		AL, 2					; Shift 6 bits from 1st byte to the upper positions					
	MOV		AH, BYTE2				; Then keep bits 4..5 from second byte
	SHR		AH, 4					; Put them in positions 0..1
	OR		AL, AH					; Adn rebuild the original 1st byte
	STOSB

	MOV		AL, BYTE2				; Build 2nd original byte
	SHL		AL, 4					; Shift bits 0..3 from encoded byte 2 to 4..7
	MOV		AH, BYTE3				; Get encoded byte 3
	SHR		AH, 2					; Get 4 bits from positions 2..5 to positions 0..3
	OR		AL, AH					; And rebuild the original second byte
	STOSB

	MOV		AL, BYTE3				; Build 3rd original byte
	SHL		AL, 6					; Move bits 0..1 to 6..7
	OR		AL, BYTE4				; And add the remaining bits 0..5
	STOSB

	JMP		ConversionLoop				; All done for this pack of 4 bytes, process next

	; We arrive here when the third character out of four is a padding character
	; We just need two check that the two subsequent characters are a padding character followed by the end of string
Byte3Padding :
	LODSB
	CMP		AL, BASE64_PADDING			; Check that next character is also a padding character
	JNE		BadString

	MOV		AL, BYTE1				; Build first original byte
	SHL		AL, 2					; Shift 6 bits from 1st byte to the upper positions					
	MOV		AH, BYTE2				; Then keep bits 4..5 from second byte
	SHR		AH, 4					; Put them in positions 0..1
	OR		AL, AH					; Adn rebuild the original 1st byte
	STOSB

	JMP		ZeroAfterPad				; We must ensure that the encoded string is correctly terminated

	; We arrive here when the fourth character out of four is a padding character
	; We just need two check that the two subsequent characters are a padding character followed by the end of string
Byte4Padding :
	MOV		AL, BYTE1				; Build first original byte
	SHL		AL, 2					; Shift 6 bits from 1st byte to the upper positions					
	MOV		AH, BYTE2				; Then keep bits 4..5 from second byte
	SHR		AH, 4					; Put them in positions 0..1
	OR		AL, AH					; Adn rebuild the original 1st byte
	STOSB

	MOV		AL, BYTE2				; Build 2nd original byte
	SHL		AL, 4					; Shift bits 0..3 from encoded byte 2 to 4..7
	MOV		AH, BYTE3				; Get encoded byte 3
	SHR		AH, 2					; Get 4 bits from positions 2..5 to positions 0..3
	OR		AL, AH					; And rebuild the original second byte
	STOSB

	; We arrive here when a padding character has been found either on the third or fourth position
	; We need to check that the string is correctly terminated
ZeroAfterPad :
	LODSB			

	String$IsSpace						; Allow for trailing spaces
	JNZ		ZeroAfterPad

	OR		AL, AL					; Then check that the next character is the end of string
	JNZ		BadString
	
	; When we arrive here, we have decoded a correctly encoded string whose length is a multiple of 4 bytes
EndOfString :
	XOR		AL, AL					; Put the trailing end of string character
	STOSB
	MOV		RAX, RDI				; And return a pointer to that position
	DEC		RAX

	POPS		RBX, RCX, RDX, RSI, RDI
	RET


	; We arrive here when the submitted string contains improper data
BadString :
	XOR		AL, AL					; Put a trailing end of string character
	STOSB		
	MOV		RAX, RDI				; Return a pointer to that position
	DEC		RAX
	XOR		DL, DL					; Set the ZF flag to indicate an error has occurred

	POPS		RBX, RCX, RDX, RSI, RDI
	RET

String$Base64Decode	ENDP

END