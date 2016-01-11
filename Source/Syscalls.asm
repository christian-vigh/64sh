;**************************************************************************************************
;*
;*  NAME
;*	Syscalls-Windows7-x64.asm
;*
;*  DESCRIPTION
;*	Implements the syscalls needed to run the interpreter in the Windows 7/x64 environment.
;*
;*  AUTHOR
;*	Christian Vigh, 11/2012.
;*
;*  HISTORY
;*  [Version : 1.0]		[Author : CV]		[Date : 2012/11/03]
;*	Initial version.
;*
;**************************************************************************************************

.NOLIST
INCLUDE		64sh.inc
.LIST


;
; Standard file descriptors
;
STD_INPUT_HANDLE	EQU	-10				; Handle constants for GetStdHandle
STD_OUTPUT_HANDLE	EQU	-11		
STD_ERROR_HANDLE	EQU	-12

;
; Console mode flags - used for character-at-a-time input using ReadChar.
;
ENABLE_ECHO_INPUT	EQU	00004H				; Characters are echoed while they are typed (active only for the ENABLE_LINE_INPUT mode)
ENABLE_EXTENDED_FLAGS	EQU	00080H				; Required to enable or disable extended flags. See ENABLE_INSERT_MODE and ENABLE_QUICK_EDIT_MODE.
ENABLE_INSERT_MODE	EQU	00020H				; Activates the insert mode
ENABLE_LINE_INPUT	EQU	00002H				; ReadFile will return if a carriage return is read. When disabled, the function returns when characters 
								; are available
ENABLE_MOUSE_INPUT	EQU	00010H				; Handles mouse movements
ENABLE_PROCESSED_INPUT	EQU	00001H				; CTRL+C is processed by the system and is not placed in the input buffer. 
								; If the input buffer is being read by ReadFile or ReadConsole, other control keys are processed 
								; by the system and are not returned in the ReadFile or ReadConsole buffer. 
								; If the ENABLE_LINE_INPUT mode is also enabled, backspace, carriage return, and line feed characters 
								; are handled by the system.
ENABLE_QUICK_EDIT_MODE	EQU	00040H				; This flag enables the user to use the mouse to select and edit text. 
ENABLE_WINDOW_INPUT	EQU	00008H				; User interactions that change the size of the console screen buffer are reported in the console's input buffer.


;
; Virtual memory allocation flags
;
MEM_COMMIT		EQU	000001000H			; Allocates memory charges (from the overall size of memory and the paging files on disk) for the specified
								; reserved memory pages. 
								; The function also guarantees that when the caller later initially accesses the memory, the contents will 
								; be zero. Actual physical pages are not allocated unless/until the virtual addresses are actually accessed.
MEM_RESERVE		EQU	000002000H			; Reserves a range of the process's virtual address space without allocating any actual physical storage 
								; in memory or in the paging file on disk.
MEM_DECOMMIT		EQU	000004000H			; Decommits the specified region of committed pages. After the operation, the pages are in the reserved state. 
MEM_RELEASE		EQU	000008000H			; Releases the specified region of pages.
MEM_RESET		EQU	000080000H			; Indicates that data in the memory range specified by lpAddress and dwSize is no longer of interest. 
MEM_RESET_UNDO		EQU	001000000H			; Tries to undo the effects of a MEM_RESET operation.
MEM_LARGE_PAGES		EQU	020000000H			; Allocates memory using large page support.
MEM_PHYSICAL		EQU	000400000H			; Reserves an address range that can be used to map Address Windowing Extensions (AWE) pages.
MEM_TOP_DOWN		EQU	000100000H			; Allocates memory at the highest possible address.
MEM_WRITE_WATCH		EQU	000200000H			; Causes the system to track pages that are written to in the allocated region.

;
; Virtual memory protection flags
;
PAGE_EXECUTE			EQU	00010H			; Enables execute access to the committed region of pages. 
								; An attempt to read from or write to the committed region results in an access violation.
PAGE_EXECUTE_READ		EQU	00020H			; Enables execute or read-only access to the committed region of pages. 
								; An attempt to write to the committed region results in an access violation.
PAGE_EXECUTE_READWRITE		EQU	00040H			; Enables execute, read-only, or read/write access to the committed region of pages.
PAGE_EXECUTE_WRITECOPY		EQU	00080H			; Enables execute, read-only, or copy-on-write access to a mapped view of a file mapping object.
PAGE_NOACCESS			EQU	00001H			; Disables all access to the committed region of pages. An attempt to read from, write to, 
								; or execute the committed region results in an access violation.
PAGE_READONLY			EQU	00002H			; Enables read-only access to the committed region of pages.
PAGE_READWRITE			EQU	00004H			; Enables read-only or read/write access to the committed region of pages.
PAGE_WRITECOPY			EQU	00008H			; Enables read-only or copy-on-write access to a mapped view of a file mapping object. 
PAGE_GUARD			EQU	00100H			; Pages in the region become guard pages.
PAGE_NOCACHE			EQU	00200H			; Sets all pages to be non-cachable.
PAGE_WRITECOMBINE		EQU	00400H			; Sets all pages to be write-combined. 

;
; MEMORY_BASIC_INFORMATION structure -
;	Contains information about the memory used by the current process. This will be useful for calling the VirtualProtect function,
;	in order to allow for writing to code segments.
;
MEMORY_BASIC_INFORMATION	STRUCT
	BaseAddress		DQ	?			; Base address of the region pages
	AllocationBase		DQ	?			; Pointer to the base address returned by VirtualAlloc() ; contains BaseAddress
	AllocationProtect	DD	?			; Memory protection options.
	Reserved1		DD	?
	RegionSize		DQ	?			; Size of the region
	State			DD	?			; State of pages in the region (MEM_COMMIT, MEM_FREE, MEM_RESERVE)
	Protect			DD	?			; Access protection for pages in the region ; subset of AllocationProtect
	PageType		DD	?			; Types of pages in the region (MEM_IMAGE, MEM_MAPPED, MEM_PRIVATE)
	Reserved2		DD	?
MEMORY_BASIC_INFORMATION	ENDS	


;
; Syscall information for this driver.
;
FORTH64$DATA		SEGMENT	 ALIGN ( 16 )	'DATA'
	STDIN			DD ?				; Standard streams
	STDOUT			DD ?
	STDERR			DD ?

	PROCESSID		DQ ?				; Current process handle
	MODULEID		DQ ?				; Current module handle

	ALIGN ( 16 )
	MEMINFO			MEMORY_BASIC_INFORMATION <>	; Process memory information
FORTH64$DATA		ENDS



.CODE 

;==================================================================================================
;
;  Syscall$Initialize -
;	Initializes this syscall handler.
;
;==================================================================================================
Syscall$Initialize	PROC
	;
	;  Get the values of the standard file descriptors
	;
	MOV		ECX, STD_INPUT_HANDLE		; Stdin
	CALL		GetStdHandle
	MOV		[ STDIN ], EAX

	MOV		ECX, STD_OUTPUT_HANDLE		; Stdout
	CALL		GetStdHandle
	MOV		[ STDOUT ], EAX

	MOV		ECX, STD_ERROR_HANDLE		; Stderr
	CALL		GetStdHandle
	MOV		[ STDERR ], EAX

	; Get current process and module
	CALL		GetCurrentProcessId
	MOV		[ PROCESSID ], RAX

	XOR		ECX, ECX
	CALL		GetModuleHandle
	MOV		[ MODULEID ], RAX

	; Get memory information ; this will allow us to obtain a base address and executable size for 
	; calling the VirtualProtect() function in order to allow for writing in the code segment
	MOV		RCX, Syscall$Initialize
	LEA		RDX, MEMINFO
	MOV		R8D, SIZE MEMORY_BASIC_INFORMATION
	CALL		VirtualQuery

	; Use VirtualProtect() to enable data modification in the whole code segment
	MOV		RCX, MEMINFO. AllocationBase		; Executable file base address in memory
	MOV		RDX, MEMINFO. RegionSize		; Size to be protected
	MOV		R8D, PAGE_EXECUTE_READWRITE		; Allow read/write/execute for the allocated block.
	LEA		R9, MEMINFO. AllocationProtect

	CALL		VirtualProtect

	RET
Syscall$Initialize	ENDP


;==================================================================================================
;
; Syscall$Terminate -
;	Terminates the syscall handler.
;
;==================================================================================================
Syscall$Terminate	PROC
	RET					; Nothing much to do so far...
Syscall$Terminate	ENDP




;**************************************************************************************************
;**************************************************************************************************
;**************************************************************************************************
;******                                                                                      ******
;******                        INTERFACES TO WINAPI FUNCTIONS                                ******
;******                                                                                      ******
;**************************************************************************************************
;**************************************************************************************************
;**************************************************************************************************


;==================================================================================================
;
;  Syscall$ExitProcess -
;	Exits the current process.
;
;  INPUT
;	ECX :
;		Exit code.
;
;  OUTPUT
;	This call never returns and terminates the program.
;
;==================================================================================================
Syscall$ExitProcess	PROC
	CALL	ExitProcess			; We never return from that...
Syscall$ExitProcess	ENDP


;==================================================================================================
;
;  Syscall$ReadChar -
;	Reads a character from the standard input.
;
;  INPUT
;	AL -
;		When AL <> 0, the character is not echoed on the terminal.
;
;  OUTPUT
;	AL -
;		The character that have been read.
;
;	ZF :
;		Set to 1 if EOF has been encountered.
;
;==================================================================================================
Syscall$ReadChar		PROC
	PUSH	RCX				;  Save used registers
	PUSH	RDX
	PUSH	R8
	PUSH	R9
	PUSH	RBX

	SUB	RSP, 12				; Reserve space for : console input mode, number of characters read, character read
	MOV	[ RSP + 5 ], AL			; Store the ECHO flag just after the byte where the character that has been read will be placed

	;
	; Input one character at a time is a little bit more complicated than inputting an entire line :
	; for that, we first need to change then input mode from line to character
	;
	MOV	ECX, [ STDIN ]			; Get console mode
	LEA	RDX, [ RSP + 8 ]		; Points to a value that will receive the current console mode
	CALL	GetConsoleMode

	MOV	ECX, [ STDIN ]			; Set console mode
	MOV	EDX, DWORD PTR [ RSP + 8 ]	; Retrieve current console mode
	MOV	EBX, EDX			; Save original console mode
	AND	EDX, NOT ENABLE_LINE_INPUT	; Set input mode to character
	CALL	SetConsoleMode

	;
	;  Prepare to call ReadFile
	;
	MOV	ECX, [ STDIN ]			; Input file handle
	LEA	RDX, [ ESP + 4 ]		; Output buffer (1 DWORD to store one character)
	MOV	R8D, 1				; Number of bytes to read
	MOV	R9, RSP				; Variable that will receive the number of bytes read

	CALL	ReadFile			; Call the API function

	;
	; Now we have to restore the original console mode. At that point, the character has been read but not yet echoed
	;
	MOV	ECX, [ STDIN ]
	MOV	EDX, EBX			; It was in EBX...
	CALL	SetConsoleMode

	;
	; Now it's time to echo the character that has been read
	;
	MOV	AL, [ RSP + 5 ]			; Get the ECHO flag
	OR	AL, AL				; Is it zero ?
	JNZ	NoEcho				; No, we won't echo it

	MOV	ECX, [  RSP + 4 ]		; Get the character that has been read
	CALL	Syscall$WriteChar
	
	;
	; Finally retrieve the character read and the read count
	;
NoEcho:
	MOV	EAX, [  RSP + 4 ]		; Get the character that has been read (once again...
	MOV	ECX, [ RSP ]			; Get number of bytes read by ReadFile
	ADD	RSP, 12				; Restore stack
	AND	ECX, ECX			; Set ZF if number of bytes read is zero

	POP	RBX				; Restore used registers
	POP	R9				
	POP	R8
	POP	RDX
	POP	RCX
	RET
Syscall$ReadChar		ENDP


;==================================================================================================
;
;  Syscall$ReadString -
;	Reads a string from the standard output.
;
;  INPUT
;	RCX :
;		Pointer to an output buffer that will receive the read data.
;
;	EDX  :
;		Maximum size of the output buffer.
;
;  OUTPUT
;	EAX :
;		Number of characters read.
;
;	ZF :
;		Set to 1 if no character has been read.
;
;==================================================================================================
Syscall$ReadString	PROC
	PUSHREGS	RBX, RCX, RDX, R8, R9, R10, R11, R12, R13, R14, R15

	;
	; Prepare the call to ReadFile
	;
	MOV	R8D, EDX			; R8 = buffer size
	MOV	RDX, RCX			; RDX = buffer pointer
	MOV	ECX, [ STDIN ]			; Output file handle
	SUB	RSP, 024H			; Reserve extra space to store the number of bytes written
	LEA	R9, [ RSP + 020H ]		; Pointer to this extra space

	CALL	ReadFile			; Call the API function

	MOV	EAX, [ RSP + 020H ]		; Retrieve number of bytes written
	ADD	RSP, 024H			; Restore stack pointer
	AND	EAX, EAX			; Set ZF if number of bytes written is zero

	POPREGS
	RET
Syscall$ReadString	ENDP


;==================================================================================================
;
;  Syscall$VirtualAlloc -
;	Allocates a virtual memory block.
;
;  INPUT
;	RCX :
;		Memory block size.
;
;  OUTPUT
;	RAX :
;		Address of the allocated memory block, or 0 if allocation failed.
;
;	ZF :
;		Set to 1 if memory allocation failed.
;
;  NOTES
;	The allocated memory has the READ, WRITE and EXECUTE flags.
;
;==================================================================================================
Syscall$VirtualAlloc	PROC
	PUSHREGS	RBX, RCX, RDX, R8, R9, R10, R11, R12, R13, R14, R15

	MOV		RDX, RCX			; Size of memory to be allocated
	XOR		RCX, RCX			; 0 means VirtualAlloc will determine the region to be allocated
	MOV		R8D, MEM_COMMIT OR MEM_RESERVE	; Allocation options : make sure all pages are reserved and committed
	MOV		R9D, PAGE_EXECUTE_READWRITE	; Allow read/write/execute for the allocated block.

	SUB		RSP, 018H			; Call the VirtualAlloc API
	CALL		VirtualAlloc
	ADD		RSP, 018H

	AND		RAX, RAX			; Set ZF = 1 if allocation failed

	POPREGS
	RET
Syscall$VirtualAlloc	ENDP


;==================================================================================================
;
;  Syscall$VirtualFree -
;	Frees a virtual memory block previously allocated by Syscall$VirtualFree.
;
;  INPUT
;	RCX :
;		Address of allocated memory block.
;
;==================================================================================================
Syscall$VirtualFree	PROC
	PUSHREGS	RBX, RCX, RDX, R8, R9, R10, R11, R12, R13, R14, R15

	XOR		EDX, EDX		; Size of memory to be freed ; Is zero because we use the MEM_RELEASE flag.
	MOV		R8D, MEM_RELEASE

	SUB		RSP, 010H		; Call the VirtualFree API
	CALL		VirtualFree
	ADD		RSP, 010H

	POPREGS
	RET
Syscall$VirtualFree	ENDP


;==================================================================================================
;
;  Syscall$WriteChar -
;	Writes a string to the standard output.
;
;  INPUT
;	CL :
;		Character to write.
;
;  OUTPUT
;	ZF :
;		Set to 1 if no character has been written.
;
;==================================================================================================
Syscall$WriteChar	PROC
	PUSHREGS	RBX, RCX, RDX, R8, R9, R10, R11, R12, R13, R14, R15

	;
	; Prepare the call to WriteFile
	;
	SUB	RSP, 028H			; Reserve extra space to store the number of bytes written and the character to write
	MOV	[ RSP + 024H ], ECX		; The character to be written
	MOV	R8D, 1				; Number of characters to write
	MOV	R9, RSP 			; Pointer to this extra space
	MOV	ECX, [ STDOUT ]			; Output file handle
	LEA	RDX, [ RSP + 024H ]		; Pointer to data

	CALL	WriteFile			; Call the API function

	MOV	ECX, [ RSP + 020H ]		; Retrieve number of bytes written
	ADD	RSP, 020H			; Restore stack pointer
	AND	ECX, ECX			; Set ZF if number of bytes written is zero

	POPREGS
Syscall$WriteChar	ENDP


;==================================================================================================
;
;  Syscall$WriteString -
;	Writes a string to the standard output.
;
;  INPUT
;	RCX :
;		Pointer to a null-terminated string.
;
;  OUTPUT
;	EAX :
;		Number of characters written.
;
;	ZF :
;		Set to 1 if no character has been written.
;
;  REGISTERS USED
;	EAX
;
;==================================================================================================
Syscall$WriteString	PROC
	PUSHREGS	RBX, RCX, RDX, R8, R9, R10, R11, R12, R13, R14, R15

	;
	; First, compute the length of the supplied string
	;
	PUSHREGS	RCX
	SUB		RSP, 8
	CALL		lstrlen				; Get length of string in EAX
	ADD		RSP, 8
	MOV		R8D, EAX			; then as 3rd parameter of WriteFile
	POPREGS

	;
	; Prepare the call to WriteFile
	;
	MOV		RDX, RCX			; EDX = Pointer to input buffer
	MOV		ECX, [ STDOUT ]			; Output file handle
	SUB		RSP, 020H			; Reserve extra space to store the number of bytes written
	MOV		R9, RSP				; Pointer to this extra space
	CALL		WriteFile			; Call the API function
	MOV		EAX, [ ESP ]			; Retrieve number of bytes written
	ADD		RSP, 020H			; Restore stack pointer
	AND		EAX, EAX			; Set ZF if number of bytes written is zero

	POPREGS
	RET
Syscall$WriteString	ENDP

END
