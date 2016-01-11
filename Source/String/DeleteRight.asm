;**************************************************************************************************************
;*
;*  NAME
;*	DeleteRight.asm
;*
;*   DESCRIPTION
;*	Deletes n characters of a string from the right.
;*
;*  AUTHOR
;* 	Christian Vigh, 11/2012.
;*
;*   HISTORY
;*   [Version : 1.0]    [Date : 2012/11/18]     [Author : CV]
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
;=	DeleteRight - Deletes n characters of a string from the right.
;=
;=   DESCRIPTION
;=	Deletes n characters from the right of the specified string.
;=
;=   INPUT
;=	RCX -
;=		Address of the string in which characters are to be deleted.
;=
;=	RDX -
;=		Number of characters to delete. If the specified number of characters is greater than the string
;=		length, then the string will be zeroed.
;=
;=   OUTPUT
;=	RAX -
;=		Points to the end of the string.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$DeleteRight	PROC
	CALL		String@FindEOS				; Find the end of the string

	SUB		RAX, RDX				; Subtract the number of characters to copy from the EOS address
	CMP		RCX, RAX				; If this address is greater than or equal to the start of the string, we can continue
	JL		DoDelete

	MOV		RAX, RCX				; Otherwise, say that we will zero the string

DoDelete :
	MOV		BYTE PTR [RAX], 0			; Set the end of string

	RET
String$DeleteRight	ENDP

END