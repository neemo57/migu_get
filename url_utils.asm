; --------------------------------------------------
; ---- Assembly routines to work with strings ----
; --------------------------------------------------


; Get hostname
; Usage get_ip_address(char* url)

invalid_scheme_error DB 0xA, "The scheme you supplied is not supported. We only support http://", 0xA, 0

get_ip_address:
	PUSH ebp
	MOV ebp, esp

	; Get the url in esi
	MOV esi, [ebp + 0x8]

	; Match the scheme
	PUSH esi
	CALL match_scheme
	POP esi

	; Check validity
	CMP eax, 0x0
	JZ .bad_scheme_error

	;Push the esi 7 bytes ahead
	ADD esi, 7

	; Use ecx to store the offset
	XOR ecx, ecx

	; Create a buffer for the new string
	SUB esp, 1024d
	LEA edi, [esp]

.find_backslash:
	LODSB

	CMP al, 0x2f
	JZ .found

	CMP al, 0xA
	JZ .found

	CMP al, 0x0
	JZ .found

	; If its not the end then store the character in stack
	STOSB	
	INC ecx

	JMP .find_backslash

.found:
	; Store a zero at the end
	XOR eax, eax
	STOSB

	; Now, push it and get the IP address
	LEA eax, [esp]
	PUSH eax
	CALL dns_query
	ADD esp, 0x4

	; Clear the stack will you ?
	ADD esp, 1024d

	MOV esp, ebp
	POP ebp
	RET

.bad_scheme_error:
	PUSH invalid_scheme_error
	CALL strprint

	MOV eax, 1
	MOV ebx, 1
	INT 0x80

; Sees if the scheme matches http://
; Returns 0 on eax if not matching, 1 if matching
; Usage: int match_scheme(char* url)

scheme_to_match DB "http://", 0

match_scheme:
	PUSH ebp
	MOV ebp, esp

	; Hardcoded size of 'scheme_to_match'
	MOV ecx, 7

	;Set up the source and destination
	MOV esi, scheme_to_match
	MOV edi, [ebp + 0x8]

	; Match the bytes
	REPE CMPSB

	; Check the ecx
	CMP ecx, 0x0
	JZ .found

	JMP .notfound

.found:
	MOV eax, 0x1
	JMP .match_scheme_done

.notfound:
	XOR eax, eax

.match_scheme_done:
	MOV esp, ebp
	POP ebp
	RET