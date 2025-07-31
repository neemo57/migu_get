; ------------------------------------------
; ----- ASM routine to fetch a webpage -----
; -----------------------------------------

header1 DB "GET /", 0
header2 DB " HTTP/1.1", 0
header3 DB "Host: ", 0
newline DB 0xD, 0xA
errormsg DB "Failed: Connection Error !", 0xA, 0x0

; Usage: fetch_webpage(char* url_pointer, int ip_address)
fetch_webpage:
	PUSH ebp
	MOV ebp, esp

	; Clear 4 bytes for the file descriptor
	SUB esp, 0x4

	; Clear a good chunk of space in the stack
	SUB esp, 1024d

	; Get the stack pointer in edi
	LEA edi, [esp]

	; Get header 1 into the stack
	MOV ecx, 5
	MOV esi, header1
	REP MOVSB

	; Get the post / part
	MOV esi, [ebp + 0x8]
	ADD esi, 7 
	XOR edx, edx ;Edx records the offest to /

.find_backslash:
	LODSB
	INC edx

	CMP al, 0x2f
	JZ .found

	CMP al, 0xA
	JZ .nobackslash

	CMP al, 0x0
	JZ .nobackslash

	JMP .find_backslash

.found:
	LODSB
	CMP al, 0x0
	JZ .header_one_done
	STOSB
	JMP .found

.nobackslash:
	XOR edx, edx

.header_one_done:
	MOV esi, header2
	MOV ecx, 9
	REP MOVSB

	MOV esi, newline
	MOV ecx, 0x2
	REP MOVSB

.header_two:
	MOV esi, header3
	MOV ecx, 6
	REP MOVSB

	MOV esi, [ebp + 0x8]
	ADD esi, 7d

	MOV ecx, edx
	CMP ecx, 0x2
	JL .nobackslash_header_two

	DEC ecx
	REP MOVSB
	JMP .header_two_done

.nobackslash_header_two:
	LODSB
	CMP al, 0x0
	JZ .header_two_done

	STOSB
	JMP .nobackslash_header_two

.header_two_done:
	MOV esi, newline
	MOV ecx, 0x2
	REP MOVSB

	MOV esi, newline
	MOV ecx, 0x2
	REP MOVSB

	XOR eax, eax
	STOSB

.connect_to_server:

	; Create a new socket
	CALL createtcpsocket

	; Store the fd
	LEA ebx, [ebp - 0x4]
	MOV [ebx], eax

	; Connect to the ip address and port 80
	PUSH 0x50
	PUSH dword [ebp+0xC]
	PUSH eax
	CALL connectsocket
	ADD esp, 0xC

	; Check the return code
	CMP eax, 0x0
	JNZ .connection_error


.send_headers:

	;Calculate headers length

	PUSH esp
	CALL strlen
	ADD esp, 0x4

	MOV edx, eax
	MOV ecx, esp
	MOV ebx, [ebp - 0x4]
	MOV eax, 4
	INT 0x80

.read_whats_sent_back:
	
	PUSH 0x1
	PUSH dword [ebp - 0x4]
	CALL read_all
	ADD esp, 0x8

.its_over:

	; Clear the stack
	ADD esp, 0x400
	ADD esp, 0x4

	MOV esp, ebp
	POP ebp
	RET

.connection_error:
	PUSH errormsg
	CALL strprint
	ADD esp, 0x4

	MOV eax, 1
	MOV ebx, 1
	INT 0x80