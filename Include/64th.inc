;**************************************************************************************************
;*
;*  NAME
;*	64th.inc
;*
;*  DESCRIPTION
;*	Definitions and macros for the 64th engine.
;*
;*  AUTHOR
;*	Christian Vigh, 11/2012.
;*
;*  HISTORY
;*  [Version : 1.0]		[Author : CV]		[Date : 2012/11/05]
;*	Initial version.
;*
;**************************************************************************************************


;==================================================================================================
;
;  Register allocation.
;
;==================================================================================================
@WS					TEXTEQU		<R15>


;==================================================================================================
;
;  Default values for Forth workspace sizes.
;
;==================================================================================================
WORKSPACE_HEADER_SIZE			EQU	256			; Unused data at the head of the workspace
TIB_DEFAULT_BUFFER_SIZE			EQU	1024			; Terminal input buffer size
TIB_DEFAULT_MAX_WORD_SIZE		EQU	128			; Maximum word size
DEFAULT_STACK_SIZE			EQU	010000H			; Stack size 
DEFAULT_RETURN_STACK_SIZE		EQU	01000H			; Return stack size
DEFAULT_DICTIONARY_SIZE			EQU	010000H			; Dictionary size

PRIMITIVE_ALIGNMENT			EQU	16			; Alignment value for primitives
ADDRESS_ALIGNMENT			EQU	8			; Alignment value for instructions
@CS					EQU	8			; Default cell size, in bytes
@CS_SHIFT				EQU	3			; Linked to @CS : number of shifts to be performed to multiply/divide a value per @CS


;==================================================================================================
;
;  Forth workspace definition structure :
;	Defines the sizes of the variable workspace items, such as input buffer or stack.	
;
;==================================================================================================
WORKSPACE_DEFINITION	STRUCT
	TIB_BUFFER_SIZE			DD	TIB_DEFAULT_BUFFER_SIZE			; Size of terminal input buffer
	TIB_WORD_BUFFER_SIZE		DD	TIB_DEFAULT_MAX_WORD_SIZE		; Max size of a TIB word
	STACK_SIZE			DD	DEFAULT_STACK_SIZE			; 64th stack size
	RETURN_STACK_SIZE		DD	DEFAULT_RETURN_STACK_SIZE		; Return stack size
	DICTIONARY_SIZE			DD	DEFAULT_DICTIONARY_SIZE			; Dictionary size
WORKSPACE_DEFINITION	ENDS


;==================================================================================================
;
;  Forth workspace relocation structure :
;	Since the Forth workspace can be relocated anywhere, this structure holds pointers to the
;	corresponding real field address. Real data is immediately after.
;
;==================================================================================================
WORKSPACE_STRUCTURE	STRUCT 
	RESERVED		DB	WORKSPACE_HEADER_SIZE DUP (?)		; Reserved area

	ALIGN ( 16 )
	WORKSPACE_DEFINITIONS	WORKSPACE_DEFINITION	<>			; Workspace definitions

	ALIGN ( 16 )
	$R0			DQ	?					; Experimental 

	TIB_BUFFER_START	DQ	?					; Current character in TIB
	TIB_BUFFER_END		DQ	?					; Last character in input buffer
	TIB_WORD_BUFFER_END	DQ	?					; Last character of current word + 1

	TIB_BUFFER		DQ	?					; Address of terminal input buffer
	TIB_WORD_BUFFER		DQ	?					; Address of current word buffer

	STACK_START		DQ	?					; Address of 64th start of stack
	STACK_TOP		DQ	?					; Address of top of stack (the stack grows downwards)
	RETURN_STACK_START	DQ	?					; Address of return stack
	RETURN_STACK_TOP	DQ	?					; Address of top of return stack (the stack grows downwards)
	DICTIONARY		DQ	?					; Address of dictionary
	DICTIONARY_END		DQ	?					; End of dictionary

	ALIGN ( 16 )
WORKSPACE_STRUCTURE	ENDS


;==================================================================================================
;
;  64th word-related definitions.
;
;==================================================================================================

;
; Word flags.
;
WORD64TH_NFA_BIT		EQU		080H		; Set in the first byte of a word definition ; signals the start of the NFA
WORD64TH_SMUDGE			EQU		001H		; If set, the word is defined
WORD64TH_IMMEDIATE		EQU		002H		; If set, the word is immediate at compile time
WORD64TH_INLINE			EQU		004H		; If set, any reference to the word will be replaced with its PFA contents


;==================================================================================================
;
;  Vocabulary and word definitions.
;
;==================================================================================================

; VOCABULARY_BEGIN -
;	Defines the start of  vocabulary.
VOCABULARY  MACRO  Name : REQ
	;; Check that no other vocabulary definition is running
	IFDEF  @@CURRENT_VOCABULARY
		IFNB  @@CURRENT_VOCABULARY
			.ERR <Vocabulary definitions cannot be nested.>
		ENDIF
	ENDIF

	;; Build the vocabulary definition
	@@CURRENT_VOCABULARY	EQU	 <Name>

	;; We have to keep the alignment
	ALIGN ( PRIMITIVE_ALIGNMENT )

	;; @@CURRENT_VOCABULARY_HERE points to the CFA of the last defined primitive
	@@CURRENT_VOCABULARY_HERE		=  0			;; The very first primitive has a backpointer set to zero

	;; @@CURRENT_VOCABULARY_WORDS holds the number of primitives defined in the current vocabulary
	@@CURRENT_VOCABULARY_WORDS		=  0

VOCABULARY_&Name& :
ENDM


; VOCABULARY_END -
;	Ends a vocabulary definition.
VOCABULARY_END  MACRO  Name : REQ
	LOCAL		VocSize

	;; Check that the VOCABULARY_END directive has a matching VOCABULARY one.
	IFB	@@CURRENT_VOCABULARY
		.ERR  <VOCABULARY_END directive found, but there is no matching VOCABULARY directive.>
	ENDIF

	;; Also check that the name specified with the closing VOCABULARY_END directive matches the name specified in the VOCABULARY one.
	IFIDNI  @@CURRENT_VOCABULARY, <Name>
	ELSE
		.ERR  <Vocabulary name mismatch (Name) between the VOCABULARY and VOCABULARY_END directives.>
	ENDIF

	;; Declare the end of the vocabulary segment
	ALIGN ( PRIMITIVE_ALIGNMENT )
VOCABULARY_&Name&_END :
	VocSize		=  $ - VOCABULARY_&Name&

	;; Various vocabulary data will be defined in the DATA segment
	.DATA
	VOCABULARY_&Name&_SIZE :
		DQ	VocSize
	VOCABULARY_&Name&_WORDS	:
		DQ	@@CURRENT_VOCABULARY_WORDS
	.CODE
ENDM


; VOCABULARY_SIZE -
;	Returns the size of the specified vocabulary.
VOCABULARY_SIZE	 MACRO  Name : REQ
	LOCAL	Result

	Result		CATSTR   <QWORD PTR [ VOCABULARY_>, <Name>, <_SIZE ]>
	EXITM Result
ENDM


; VOCABULARY_WORDS -
;	Returns the number of primitives defined for this vocabulary.
VOCABULARY_WORDS  MACRO
	LOCAL	Result

	Result		CATSTR   <QWORD PTR [ VOCABULARY_>, <Name>, <_WORDS ]>
	EXITM Result
ENDM


; VOCABULARY_DECLARE -
;	For use in include files ; declares a vocabulary start and stop addresses.
VOCABULARY_DECLARE  MACRO  Name : REQ
	EXTERNDEF	VOCABULARY_&Name&		:  PROC
	EXTERNDEF	VOCABULARY_&Name&_END		:  PROC
	EXTERNDEF	VOCABULARY_&Name&_SIZE		:  PROC
	EXTERNDEF	VOCABULARY_&Name&_WORDS		:  PROC
ENDM


; PRIMITIVE -
;	Defines a 64th word as a primitive (ie, already embedded in the system).
PRIMITIVE  MACRO  Name : REQ, Flags := <WORD64TH_SMUDGE>
	LOCAL		NFA, LFA, CFA, NameDef, NameLength

	;; Check that we are in a vocabulary definition
	IFNDEF  @@CURRENT_VOCABULARY
		.ERR <PRIMITIVE directive used outside a vocabulary.>
	ENDIF

	IFB  @@CURRENT_VOCABULARY
		.ERR <PRIMITIVE directive used outside a vocabulary.>
	ENDIF

	;; Define @@CURRENT_PRIMITIVE so that PRIMITIVE_END will be able to match the specified name
	@@CURRENT_PRIMITIVE	TEXTEQU		<Name>

	;; Make sure we keep aligned
	ALIGN ( PRIMITIVE_ALIGNMENT )

	;; First, define the word flags
NFA :
	DB		Flags OR WORD64TH_NFA_BIT

	;; Then the word name length
	NameLength	SIZESTR	<Name>
	DB		NameLength
	
	;; Then the word name itself
	NameDef		CATSTR		<DB ">, <Name>, <">
	NameDef

	;; Align to the proper alignment value before introducing the LFA
	ALIGN ( ADDRESS_ALIGNMENT )

	;; LFA points to last word LFA
LFA :
	DQ		@@CURRENT_VOCABULARY_HERE
	@@CURRENT_VOCABULARY_HERE	=	$ 

	;; CFA
CFA :
	XCHG		RSP, RBP
	
ENDM


; END_PRIMITIVE -
;	Ends a primitive.
END_PRIMITIVE  MACRO
	LOCAL		PrimitiveEnd

	XCHG		RSP, RBP
	RET
	ALIGN ( PRIMITIVE_ALIGNMENT )
PrimitiveEnd :

	@@CURRENT_VOCABULARY_WORDS	=  @@CURRENT_VOCABULARY_WORDS + 1
ENDM


;==================================================================================================
;
;  Macros for the debug/release environments.
;
;==================================================================================================


;==================================================================================================
;
;  Built-in vocabulary definitions.
;
;==================================================================================================
VOCABULARY_DECLARE  PRIMITIVES