;**************************************************************************************************
;*
;*  NAME
;*	Tables.asm
;*
;*  DESCRIPTION
;*	Tables used by string functions.
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


;
; A segment used to store misc data for string functions.
;
STRING$DATA		SEGMENT ALIGN(16) 	'DATA'

	; The following table is an ascii table, where all entries for lowercase characters hold the value of their
	; corresponding uppercase equivalent. It is used by String$ICompare for case-insensitive comparisons.
	ASCII@UPPERCASE		DB	000H, 001H, 002H, 003H, 004H, 005H, 006H, 007H, 008H, 009H, 00AH, 00BH, 00CH, 00DH, 00EH, 00FH
				DB	010H, 011H, 012H, 013H, 014H, 015H, 016H, 017H, 018H, 019H, 01AH, 01BH, 01CH, 01DH, 01EH, 01FH
				DB	020H, 021H, 022H, 023H, 024H, 025H, 026H, 027H, 028H, 029H, 02AH, 02BH, 02CH, 02DH, 02EH, 02FH
				DB	030H, 031H, 032H, 033H, 034H, 035H, 036H, 037H, 038H, 039H, 03AH, 03BH, 03CH, 03DH, 03EH, 03FH
				DB	040H, 041H, 042H, 043H, 044H, 045H, 046H, 047H, 048H, 049H, 04AH, 04BH, 04CH, 04DH, 04EH, 04FH
				DB	050H, 051H, 052H, 053H, 054H, 055H, 056H, 057H, 058H, 059H, 05AH, 05BH, 05CH, 05DH, 05EH, 05FH
				DB	060H, 041H, 042H, 043H, 044H, 045H, 046H, 047H, 048H, 049H, 04AH, 04BH, 04CH, 04DH, 04EH, 04FH
				DB	050H, 051H, 052H, 053H, 054H, 055H, 056H, 057H, 058H, 059H, 05AH, 07BH, 07CH, 07DH, 07EH, 07FH
				DB	080H, 081H, 082H, 083H, 084H, 085H, 086H, 087H, 088H, 089H, 08AH, 08BH, 08CH, 08DH, 08EH, 08FH
				DB	090H, 091H, 092H, 093H, 094H, 095H, 096H, 097H, 098H, 099H, 09AH, 09BH, 09CH, 09DH, 09EH, 09FH
				DB	0A0H, 0A1H, 0A2H, 0A3H, 0A4H, 0A5H, 0A6H, 0A7H, 0A8H, 0A9H, 0AAH, 0ABH, 0ACH, 0ADH, 0AEH, 0AFH
				DB	0B0H, 0B1H, 0B2H, 0B3H, 0B4H, 0B5H, 0B6H, 0B7H, 0B8H, 0B9H, 0BAH, 0BBH, 0BCH, 0BDH, 0BEH, 0BFH
				DB	0C0H, 0C1H, 0C2H, 0C3H, 0C4H, 0C5H, 0C6H, 0C7H, 0C8H, 0C9H, 0CAH, 0CBH, 0CCH, 0CDH, 0CEH, 0CFH
				DB	0D0H, 0D1H, 0D2H, 0D3H, 0D4H, 0D5H, 0D6H, 0D7H, 0D8H, 0D9H, 0DAH, 0DBH, 0DCH, 0DDH, 0DEH, 0DFH
				DB	0E0H, 0E1H, 0E2H, 0E3H, 0E4H, 0E5H, 0E6H, 0E7H, 0E8H, 0E9H, 0EAH, 0EBH, 0ECH, 0EDH, 0EEH, 0EFH
				DB	0F0H, 0F1H, 0F2H, 0F3H, 0F4H, 0F5H, 0F6H, 0F7H, 0F8H, 0F9H, 0FAH, 0FBH, 0FCH, 0FDH, 0FEH, 0FFH

	; Same table, for lowercase conversions
	ASCII@LOWERCASE		DB	000H, 001H, 002H, 003H, 004H, 005H, 006H, 007H, 008H, 009H, 00AH, 00BH, 00CH, 00DH, 00EH, 00FH
				DB	010H, 011H, 012H, 013H, 014H, 015H, 016H, 017H, 018H, 019H, 01AH, 01BH, 01CH, 01DH, 01EH, 01FH
				DB	020H, 021H, 022H, 023H, 024H, 025H, 026H, 027H, 028H, 029H, 02AH, 02BH, 02CH, 02DH, 02EH, 02FH
				DB	030H, 031H, 032H, 033H, 034H, 035H, 036H, 037H, 038H, 039H, 03AH, 03BH, 03CH, 03DH, 03EH, 03FH
				DB	040H, 061H, 062H, 063H, 064H, 065H, 066H, 067H, 068H, 069H, 06AH, 06BH, 06CH, 06DH, 06EH, 06FH
				DB	070H, 071H, 072H, 073H, 074H, 075H, 076H, 077H, 078H, 079H, 07AH, 05BH, 05CH, 05DH, 05EH, 05FH
				DB	060H, 061H, 062H, 063H, 064H, 065H, 066H, 067H, 068H, 069H, 06AH, 06BH, 06CH, 06DH, 06EH, 06FH
				DB	070H, 071H, 072H, 073H, 074H, 075H, 076H, 077H, 078H, 079H, 07AH, 07BH, 07CH, 07DH, 07EH, 07FH
				DB	080H, 081H, 082H, 083H, 084H, 085H, 086H, 087H, 088H, 089H, 08AH, 08BH, 08CH, 08DH, 08EH, 08FH
				DB	090H, 091H, 092H, 093H, 094H, 095H, 096H, 097H, 098H, 099H, 09AH, 09BH, 09CH, 09DH, 09EH, 09FH
				DB	0A0H, 0A1H, 0A2H, 0A3H, 0A4H, 0A5H, 0A6H, 0A7H, 0A8H, 0A9H, 0AAH, 0ABH, 0ACH, 0ADH, 0AEH, 0AFH
				DB	0B0H, 0B1H, 0B2H, 0B3H, 0B4H, 0B5H, 0B6H, 0B7H, 0B8H, 0B9H, 0BAH, 0BBH, 0BCH, 0BDH, 0BEH, 0BFH
				DB	0C0H, 0C1H, 0C2H, 0C3H, 0C4H, 0C5H, 0C6H, 0C7H, 0C8H, 0C9H, 0CAH, 0CBH, 0CCH, 0CDH, 0CEH, 0CFH
				DB	0D0H, 0D1H, 0D2H, 0D3H, 0D4H, 0D5H, 0D6H, 0D7H, 0D8H, 0D9H, 0DAH, 0DBH, 0DCH, 0DDH, 0DEH, 0DFH
				DB	0E0H, 0E1H, 0E2H, 0E3H, 0E4H, 0E5H, 0E6H, 0E7H, 0E8H, 0E9H, 0EAH, 0EBH, 0ECH, 0EDH, 0EEH, 0EFH
				DB	0F0H, 0F1H, 0F2H, 0F3H, 0F4H, 0F5H, 0F6H, 0F7H, 0F8H, 0F9H, 0FAH, 0FBH, 0FCH, 0FDH, 0FEH, 0FFH

	; Table for character type classification
	ASCII@CTYPE		DB	CTYPE_CONTROL						; 00 (NUL)
				DB	CTYPE_CONTROL                				; 01 (SOH)
				DB	CTYPE_CONTROL                				; 02 (STX)
				DB	CTYPE_CONTROL                				; 03 (ETX)
				DB	CTYPE_CONTROL                				; 04 (EOT)
				DB	CTYPE_CONTROL                				; 05 (ENQ)
				DB	CTYPE_CONTROL                				; 06 (ACK)
				DB	CTYPE_CONTROL                				; 07 (BEL)
				DB	CTYPE_CONTROL                				; 08 (BS)
				DB	CTYPE_SPACE + CTYPE_CONTROL         			; 09 (HT)
				DB	CTYPE_SPACE + CTYPE_CONTROL         			; 0A (LF)
				DB	CTYPE_SPACE + CTYPE_CONTROL         			; 0B (VT)
				DB	CTYPE_SPACE + CTYPE_CONTROL         			; 0C (FF)
				DB	CTYPE_SPACE + CTYPE_CONTROL         			; 0D (CR)
				DB	CTYPE_CONTROL                				; 0E (SI)
				DB	CTYPE_CONTROL                				; 0F (SO)
				DB	CTYPE_CONTROL                				; 10 (DLE)
				DB	CTYPE_CONTROL                				; 11 (DC1)
				DB	CTYPE_CONTROL                				; 12 (DC2)
				DB	CTYPE_CONTROL                				; 13 (DC3)
				DB	CTYPE_CONTROL                				; 14 (DC4)
				DB	CTYPE_CONTROL                				; 15 (NAK)
				DB	CTYPE_CONTROL                				; 16 (SYN)
				DB	CTYPE_CONTROL                				; 17 (ETB)
				DB	CTYPE_CONTROL                				; 18 (CAN)
				DB	CTYPE_CONTROL                				; 19 (EM)
				DB	CTYPE_CONTROL                				; 1A (SUB)
				DB	CTYPE_CONTROL                				; 1B (ESC)
				DB	CTYPE_CONTROL                				; 1C (FS)
				DB	CTYPE_CONTROL                				; 1D (GS)
				DB	CTYPE_CONTROL                				; 1E (RS)
				DB	CTYPE_CONTROL                				; 1F (US)
				DB	CTYPE_SPACE + CTYPE_BLANK           			; 20 SPACE
				DB	CTYPE_PUNCTUATION                  			; 21 !
				DB	CTYPE_PUNCTUATION                  			; 22 "
				DB	CTYPE_PUNCTUATION                  			; 23 #
				DB	CTYPE_PUNCTUATION                  			; 24 $
				DB	CTYPE_PUNCTUATION                  			; 25 %
				DB	CTYPE_PUNCTUATION                  			; 26 &
				DB	CTYPE_PUNCTUATION                  			; 27 '
				DB	CTYPE_PUNCTUATION                  			; 28 (
				DB	CTYPE_PUNCTUATION                  			; 29 )
				DB	CTYPE_PUNCTUATION                  			; 2A *
				DB	CTYPE_PUNCTUATION                  			; 2B +
				DB	CTYPE_PUNCTUATION                  			; 2C  
				DB	CTYPE_PUNCTUATION                  			; 2D -
				DB	CTYPE_PUNCTUATION                  			; 2E .
				DB	CTYPE_PUNCTUATION                  			; 2F /
				DB	CTYPE_DIGIT + CTYPE_HEX             			; 30 0
				DB	CTYPE_DIGIT + CTYPE_HEX             			; 31 1
				DB	CTYPE_DIGIT + CTYPE_HEX             			; 32 2
				DB	CTYPE_DIGIT + CTYPE_HEX             			; 33 3
				DB	CTYPE_DIGIT + CTYPE_HEX             			; 34 4
				DB	CTYPE_DIGIT + CTYPE_HEX             			; 35 5
				DB	CTYPE_DIGIT + CTYPE_HEX             			; 36 6
				DB	CTYPE_DIGIT + CTYPE_HEX             			; 37 7
				DB	CTYPE_DIGIT + CTYPE_HEX             			; 38 8
				DB	CTYPE_DIGIT + CTYPE_HEX             			; 39 9
				DB	CTYPE_PUNCTUATION                  			; 3A :
				DB	CTYPE_PUNCTUATION                  			; 3B 			;
				DB	CTYPE_PUNCTUATION                  			; 3C <
				DB	CTYPE_PUNCTUATION                  			; 3D =
				DB	CTYPE_PUNCTUATION                  			; 3E >
				DB	CTYPE_PUNCTUATION                  			; 3F ?
				DB	CTYPE_PUNCTUATION                  			; 40 @
				DB	CTYPE_UPPER + CTYPE_HEX             			; 41 A
				DB	CTYPE_UPPER + CTYPE_HEX             			; 42 B
				DB	CTYPE_UPPER + CTYPE_HEX             			; 43 C
				DB	CTYPE_UPPER + CTYPE_HEX             			; 44 D
				DB	CTYPE_UPPER + CTYPE_HEX             			; 45 E
				DB	CTYPE_UPPER + CTYPE_HEX             			; 46 F
				DB	CTYPE_UPPER                  				; 47 G
				DB	CTYPE_UPPER                  				; 48 H
				DB	CTYPE_UPPER                  				; 49 I
				DB	CTYPE_UPPER                  				; 4A J
				DB	CTYPE_UPPER                  				; 4B K
				DB	CTYPE_UPPER                  				; 4C L
				DB	CTYPE_UPPER                  				; 4D M
				DB	CTYPE_UPPER                  				; 4E N
				DB	CTYPE_UPPER                  				; 4F O
				DB	CTYPE_UPPER                  				; 50 P
				DB	CTYPE_UPPER                  				; 51 Q
				DB	CTYPE_UPPER                  				; 52 R
				DB	CTYPE_UPPER                  				; 53 S
				DB	CTYPE_UPPER                  				; 54 T
				DB	CTYPE_UPPER                  				; 55 U
				DB	CTYPE_UPPER                  				; 56 V
				DB	CTYPE_UPPER                  				; 57 W
				DB	CTYPE_UPPER                  				; 58 X
				DB	CTYPE_UPPER                  				; 59 Y
				DB	CTYPE_UPPER                  				; 5A Z
				DB	CTYPE_PUNCTUATION                  			; 5B [
				DB	CTYPE_PUNCTUATION                  			; 5C \ 
				DB	CTYPE_PUNCTUATION                  			; 5D ]
				DB	CTYPE_PUNCTUATION                  			; 5E ^
				DB	CTYPE_PUNCTUATION                  			; 5F _
				DB	CTYPE_PUNCTUATION                  			; 60 `
				DB	CTYPE_LOWER + CTYPE_HEX             			; 61 a
				DB	CTYPE_LOWER + CTYPE_HEX             			; 62 b
				DB	CTYPE_LOWER + CTYPE_HEX             			; 63 c
				DB	CTYPE_LOWER + CTYPE_HEX             			; 64 d
				DB	CTYPE_LOWER + CTYPE_HEX             			; 65 e
				DB	CTYPE_LOWER + CTYPE_HEX             			; 66 f
				DB	CTYPE_LOWER                  				; 67 g
				DB	CTYPE_LOWER                  				; 68 h
				DB	CTYPE_LOWER                  				; 69 i
				DB	CTYPE_LOWER                  				; 6A j
				DB	CTYPE_LOWER                  				; 6B k
				DB	CTYPE_LOWER                  				; 6C l
				DB	CTYPE_LOWER                  				; 6D m
				DB	CTYPE_LOWER                  				; 6E n
				DB	CTYPE_LOWER                  				; 6F o
				DB	CTYPE_LOWER                  				; 70 p
				DB	CTYPE_LOWER                  				; 71 q
				DB	CTYPE_LOWER                  				; 72 r
				DB	CTYPE_LOWER                  				; 73 s
				DB	CTYPE_LOWER                  				; 74 t
				DB	CTYPE_LOWER                  				; 75 u
				DB	CTYPE_LOWER                  				; 76 v
				DB	CTYPE_LOWER                  				; 77 w
				DB	CTYPE_LOWER                  				; 78 x
				DB	CTYPE_LOWER                  				; 79 y
				DB	CTYPE_LOWER                  				; 7A z
				DB	CTYPE_PUNCTUATION                  			; 7B {
				DB	CTYPE_PUNCTUATION                  			; 7C |
				DB	CTYPE_PUNCTUATION                  			; 7D }
				DB	CTYPE_PUNCTUATION                  			; 7E ~
				DB	CTYPE_CONTROL                				; 7F (DEL)
				DB	128 DUP (?)						; Rest of the ASCII table...

	; Base 64 encoding table
	ALIGN ( 16 )
	ASCII@BASE64		DB	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M'
				DB	'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
				DB	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm' 
				DB	'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
				DB	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/', 0

	; Base 64 decoding table
	; Entries with -2 represent invalid characters ; Entries with -1 stand for space characters, which can be ignored if desired
	ALIGN ( 16 )
	ASCII@REVERSE_BASE64	DB	-2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -2, -1, -2, -2
				DB	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
				DB	-1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63
				DB	52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2
				DB	-2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14
				DB	15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2
				DB	-2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40
				DB	41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2
				DB	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
				DB	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
				DB	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
				DB	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
				DB	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
				DB	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
				DB	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
				DB	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2


	; Hex digits
	ALIGN ( 16 )
	ASCII@HEXDIGITS		DB	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'

	; Buffers
	ALIGN ( 16 )
	STRING_BUFFER		DB		STRING_BUFFER_SIZE DUP (?)			; String buffer used for misc operations


STRING$DATA		ENDS

END
