;------------------------------------------------------------------
;--- Library used by webpage downloader for file read / write------
;------------------------------------------------------------------


; create a file using the create system call
; Usage create_file(void* filename)

create_file:
	PUSH ebp
	MOV ebp, esp

	; Create the file with rwx permissions
	MOV ecx, 0o660
	MOV ebx, [ebp + 0x8]
	MOV eax, 0x8
	INT 0x80 

	MOV esp, ebp
	POP ebp
	RET

; Open File
; opens a file for reading or writing idk
; Usage open_file(void* filename)
open_file:
	PUSH ebp
	MOV ebp, esp

	MOV eax, 5
	MOV ebx, [ebp + 0x8]
	MOV ecx, 66d
	MOV edx, 0o660
	INT 0x80

	MOV esp, ebp
	POP ebp
	RET

; Read file
; Usage read_file(int file_descriptor, int buffer_size, void* buffer)
; Returns byte read in eax

read_file:

	PUSH ebp
	MOV ebp, esp

	MOV ebx, [ebp + 0x8] ;File descriptor
	MOV edx, [ebp + 0xC] ; bytes to read // buffer size
	MOV ecx, [ebp + 0x10] ; buffer
	
	MOV eax, 3
	INT 0x80

	MOV esp, ebp
	POP ebp
	RET

; Write to a file
; Usage write_file(int file_descriptor, void* buffer)

write_file:

	PUSH ebp
	MOV ebp, esp

	MOV ecx, [ebp + 0xC] ; The buffer to write to file from
	PUSH ecx
	CALL strlen
	POP ecx

	MOV edx, eax
	
	MOV ebx, [ebp + 0x8] ; The file descriptor
	MOV eax, 4
	INT 0x80

	MOV esp, ebp
	POP ebp
	RET

; Close a file
; Usage close(int file_descriptor)

close_file:
	PUSH ebp
	MOV ebp, esp

	MOV eax, 0x6 ;File descriptor
	MOV ebx, [ebp + 0x8]
	INT 0x80

	MOV esp, ebp
	POP ebp
	RET


; Read everything
; Usage read_all(int input_file_descriptor, int output_file_descriptor)

end_of_headers_marker DD 0x0a0d0a0d

read_all:

	PUSH ebp
	MOV ebp, esp

	; Headers found ? variable. 0 for not found, 1 for found
	SUB esp, 4
	MOV dword [ebp - 0x4], 0x0

	; Create a big enough buffer
	SUB esp, 8192

	; Start reading and writing at the same time
.read_loop:	

	MOV eax, 3
	MOV ebx, [ebp + 0x8]
	MOV ecx, esp
	MOV edx, 8192
	INT 0x80

	CMP eax, 0x0
	JE .done

	MOV ebx, [ebp - 0x4]
	CMP ebx, 0x0
	JZ .find_end_of_headers

.print_allowed:
	MOV edx, eax
	MOV ecx, esp
	MOV ebx, [ebp + 0xC]
	MOV eax, 4
	INT 0x80

	SUB edx, 4
	ADD edx, esp
	MOV eax, dword [edx]
	CMP eax, [end_of_headers_marker]
	JZ .done
	
	JMP .read_loop

.find_end_of_headers:
	MOV edi, esp
	
	; ecx contains the stop point
	XOR ecx, ecx
	ADD ecx, esp
	ADD ecx, eax

.find_end_of_headers_loop:
	MOV eax, dword [edi]
	CMP eax, [end_of_headers_marker]
	JZ .end_of_headers_found

	INC edi
	CMP ecx, edi
	JLE .read_loop

	JMP .find_end_of_headers_loop

.end_of_headers_found:
	; Move edi 4 bytes ahead
	ADD edi, 4
	
	; Fill edx with the lenght of post header content
	MOV edx, ecx
	SUB edx, edi

	; Get the edi pointer in ecx
	MOV ecx, edi

	MOV ebx, [ebp + 0xC]
	MOV eax, 4
	INT 0x80

	MOV dword [ebp - 0x4], 1
	JMP .read_loop

.done:
	; Reset stack
	ADD esp, 8192
	ADD esp, 0x4

	MOV esp, ebp
	POP ebp
	RET