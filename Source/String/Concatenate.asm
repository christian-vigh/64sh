;**************************************************************************************************************
;*
;*  NAME
;*	Concatenate.asm
;*
;*   DESCRIPTION
;*	Concatenates a string to another.
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
;=	Concatenate - Concatenates two strings.
;=
;=   DESCRIPTION
;=	Concatenates the string pointed to by RDX to the one pointed to by RCX.
;=
;=   INPUT
;=	RCX -
;=		Address of the resulting string.
;=
;=	RDX -
;=		String to be concatenated.
;=
;=   OUTPUT
;=	EAX -
;=		Pointer to the end of the resulting string.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$Concatenate	PROC
	CALL		String@FindEOS			; Find the end of string

	; Prepare for copy
	MOV		RCX, RDX			; Origin address is the string to concatenate
	MOV		RDX, RAX			; Destination address points to the end of the source string
	CALL		String$Copy			; Copy the string to concatenate

	RET
String$Concatenate	ENDP

END