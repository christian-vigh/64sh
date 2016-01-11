;**************************************************************************************************
;*
;*  NAME
;*	VM.asm
;*
;*  DESCRIPTION
;*	Forth VM-related functions.
;*
;*  AUTHOR
;*	Christian Vigh, 11/2012.
;*
;*  HISTORY
;*  [Version : 1.0]		[Author : CV]		[Date : 2012/11/10]
;*	Initial version.
;*
;**************************************************************************************************

.NOLIST
INCLUDE		64sh.inc
.LIST

.CODE

;==================================================================================================
;
;  VM$CreateWorkspace -
;	Creates a Forth VM workspace in a separate memory block.
;
;  INPUT
;	RCX :
;		Pointer to a WORKSPACE_DEFINITION structure, which defines the various sizes of
;		64th buffers.
;
;  OUTPUT
;	RAX -
;		Address of allocated memory, or zero if allocation failed.
;
;	ZF = 0 :
;		The workspace could not be created due to a memory allocation problem.
;
;==================================================================================================
VM$CreateWorkspace	PROC
	PUSHREGS	RBX, RCX, RDX, R8, R9, R10, R11, R12, R13, R14, R15

	;
	; Compute the total size of the workspace
	;
	MOV		EDX, WORKSPACE_HEADER_SIZE
	ADD		EDX, SIZE ( WORKSPACE_STRUCTURE )				; First, it contains a WORKSPACE_STRUCTURE
	ADD		EDX, SFPTR ( RCX, WORKSPACE_DEFINITION. TIB_BUFFER_SIZE )	; Add size of TIB
	ADD		EDX, SFPTR ( RCX, WORKSPACE_DEFINITION. TIB_WORD_BUFFER_SIZE )	; Add size of TIB buffer for the current word
	ADD		EDX, SFPTR ( RCX, WORKSPACE_DEFINITION. STACK_SIZE )		; + stack size
	ADD		EDX, SFPTR ( RCX, WORKSPACE_DEFINITION. RETURN_STACK_SIZE )	; + return stack size
	ADD		EDX, SFPTR ( RCX, WORKSPACE_DEFINITION. DICTIONARY_SIZE )	; + dictionary size
	ADD		EDX, 256							; Some extra space, for proper alignment
	ALIGNPTR	EDX, PRIMITIVE_ALIGNMENT

	;
	; Allocate the memory
	;
	MOV		RBX, RCX							; Save the pointer to the workspace definition structure & structure size
	MOV		ECX, EDX							; Memory size
	CALL		Syscall$VirtualAlloc	
	OR		RAX, RAX							; RAX = 0 means allocation failed
	JZ		AllocationFailed
	MOV		RCX, RBX							; Restore pointer to the workspace definition structure

	;
	; Copy the WORKSPACE_DEFINITION structure to the WORKSPACE_STRUCTURE.
	; At this point, RAX holds a pointer to the newly allocated workspace.
	;
	MOV		RSI, RCX
	MOV		ECX, SIZE WORKSPACE_DEFINITION
	LEA		RDI, WSPTR ( RAX, WORKSPACE_DEFINITIONS )
	REP		MOVSB
	MOV		RDI, RAX							; RDI now points to the start of the workspace

	;
	; Compute the first address after the end of the workspace structure
	; Later on in this routine, RDX will always point to the current end of the 64th workspace
	;
	MOV		RDX, RAX							
	ADD		RDX, WORKSPACE_HEADER_SIZE
	ADD		RDX, SIZE WORKSPACE_STRUCTURE
	ALIGNPTR	RDX, 16
	MOV		[ RDI + WORKSPACE_STRUCTURE. TIB_BUFFER_END ], RDX
	
	;
	; Compute the offset of the TIB buffer
	;
	MOV		[ RDI + WORKSPACE_STRUCTURE. TIB_BUFFER ], RDX
	MOV		[ RDI + WORKSPACE_STRUCTURE. TIB_BUFFER_START ], RDX

	; 
	; Address of the word buffer, which is immediately after the TIB buffer
	;
	MOV		EBX, [ RDI + WORKSPACE_DEFINITION. TIB_BUFFER_SIZE ]
	MOV		[ RDI + WORKSPACE_STRUCTURE. TIB_WORD_BUFFER ], RDX
	ADD		RDX, RBX
	ALIGNPTR	RDX, 16
	MOV		[ RDI + WORKSPACE_STRUCTURE. TIB_WORD_BUFFER_END ], RDX

	;
	; Address of the stack & return stack
	;
	MOV		EBX, [ RDI + WORKSPACE_DEFINITION. STACK_SIZE ]
	ADD		RDX, RBX
	ALIGNPTR	RDX, 16
	MOV		[ RDI + WORKSPACE_STRUCTURE. STACK_START ], RDX
	MOV		[ RDI + WORKSPACE_STRUCTURE. STACK_TOP ], RDX

	MOV		EBX, [ RDI + WORKSPACE_DEFINITION. RETURN_STACK_SIZE ]
	ADD		RDX, RBX
	ALIGNPTR	RDX, 16
	MOV		[ RDI + WORKSPACE_STRUCTURE. RETURN_STACK_START ], RDX
	MOV		[ RDI + WORKSPACE_STRUCTURE. RETURN_STACK_TOP ], RDX

	;
	; Address of the dictionary
	;
	MOV		EBX, [ RDI + WORKSPACE_DEFINITION. DICTIONARY_SIZE ]
	MOV		[ RDI + WORKSPACE_STRUCTURE. DICTIONARY ], RDX
	ADD		RDX, RBX
	ALIGNPTR	RDX, 16
	MOV		[ RDI + WORKSPACE_STRUCTURE. DICTIONARY_END ], RDX

	;
	; Copy the built-in primitives
	;
	MOV		RCX, VOCABULARY_SIZE( <PRIMITIVES> )
	PUSH		RDI
	MOV		RSI, VOCABULARY_PRIMITIVES					; Perform the dictionary copy
	MOV		RDI, [ RDI + WORKSPACE_STRUCTURE. DICTIONARY ]
	REP		MOVSB
	POP		RDI

	;
	; End of subroutine. We arrive here if allocation failed or was successful.
	;
AllocationFailed :
	POPREGS
	RET
VM$CreateWorkspace	ENDP


;==================================================================================================
;
;  VM$DestroyWorkspace -
;	Destroys a Forth VM workspace previously allocated by VM$CreateWorkspace.
;
;  INPUT
;	RCX :
;		Pointer to the workspace address.
;
;==================================================================================================
VM$DestroyWorkspace	PROC
	PUSHREGS	RBX, RCX, RDX, R8, R9, R10, R11, R12, R13, R14, R15

	CALL		Syscall$VirtualFree

	POPREGS
	RET
VM$DestroyWorkspace	ENDP

END