;**************************************************************************************************************
;
;   NAME
;	Trim.asm
;
;   DESCRIPTION
;	Trims a string right and left.
;
;   AUTHOR
; 	Christian Vigh, 11/2012.
;
;   HISTORY
;   [Version : 1.0]    [Date : 2012/11/18]     [Author : CV]
;	Initial version.
;
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
;=	String$Trim - Trims a string left and right.
;=
;=   DESCRIPTION
;=	Trims all space characters left and right to a string.
;=
;=   INPUT
;=	RCX -
;=		Pointer to the string to be trimmed.
;=
;=   REGISTERS USED
;=	None.
;=
;===============================================================================================================*/
String$Trim	PROC
	MOV		AL, [RCX]
	JZ		TheEnd

	CALL		String$TrimRight

	MOV		AL, [RCX]
	JZ		TheEnd

	CALL		String$TrimLeft

TheEnd :
	RET
String$Trim	ENDP

END