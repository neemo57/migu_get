; Contains input output subroutines
; for main.asm file


; Return the length of the string via eax 
strlen:
	PUSH ebp
	MOV ebp, esp

	MOV edi, [ebp + 0x8] 
	; Scan the string in edi until a zero is found
	XOR eax, eax
	MOV ecx, -1
	REPNE SCASB

	MOV eax, -1
	SUB eax, ecx
	DEC eax

	MOV esp, ebp
	POP ebp
	RET

; Print a string pushed into the register
strprint:
	PUSH ebp
	MOV ebp, esp

	MOV ecx, [ebp + 0x8]
	PUSH ecx
	CALL strlen
	POP ecx

	MOV edx, eax
	MOV ebx, 1
	MOV eax, 4
	INT 0x80

	MOV esp, ebp
	POP ebp
	RET

; Ask for a string input from the user and place the string into the buffer
; Calling format:
; strinput(int buffer_size, void* buffer)
strinput:
	PUSH ebp
	MOV ebp, esp

	MOV edx, [ebp + 0x8] ; The buffer size
	MOV ecx, [ebp + 0xC] ; The buffer pointer

	; Call the sread function
	MOV ebx, 0x0
	MOV eax, 0x3
	INT 0x80

	MOV esp, ebp
	POP ebp
	RET

; linefeedprint
; print a string and an additional newline
linefeedprint:
	PUSH ebp
	MOV ebp, esp

	; Print the argument first
	MOV eax, [ebp + 0x8]
	PUSH eax
	CALL strprint

	; Print 0xA (linefeed)
	MOV eax, 0xA
	PUSH eax
	PUSH esp
	CALL strprint

	MOV esp, ebp
	POP ebp
	RET

; str to int
; Convert a string into an integer representation
strtoint:
	PUSH ebp
	MOV ebp, esp

	; Fetch the argument
	MOV esi, [ebp + 0x8]

	; Clear ebx for the final integer
	XOR ebx, ebx

	; Clear ecx for the sign
	MOV ecx, 0x1

.signupdate:
	MOV al, byte [esi]
	CMP al, 45d
	JNZ .strtointloop

.negativenumber:
	MOV ecx, -1

.strtointloop:
	; Calculate the byte value
	XOR eax, eax
	LODSB
	
	; Check if its the end of the number
	CMP al, 0x0
	JZ .loopdone

	CMP al, 0xA
	JZ .loopdone

	; Update the value again
	IMUL ebx, 10d
	SUB al, 0x30
	ADD ebx, eax

	JMP .strtointloop

.loopdone:
	MOV eax, ebx
	IMUL eax, ecx

	MOV esp, ebp
	POP ebp
	RET

; int to str
; convert an int and place it into the buffer

; void* inttostr(void* buffer, int n)
; The length of the buffer must be exactly 22 bytes

;Returns start of the string in eax

inttostr:
	PUSH ebp
	MOV ebp, esp

	; Set the direction flag to decrement mode
	STD

	; Get the buffer
	MOV edi, [ebp + 0x8]
	
	;Move the buffer 21 bytes forward and end a zero
	ADD edi, 21d
	XOR eax, eax
	STOSB

	;Get the integer
	MOV ebx, [ebp + 0xC]
	; ecx remembers the sign
	MOV ecx, 0x0
	
	; Move 10 to esi for division
	MOV esi, 0xA

.signcheck:
	ADD ebx, 0
	JS .negative
	JMP .inttostrloop

.negative:
	MOV ecx, 0x2d
	MOV ebx, 0x0
	SUB ebx, [ebp+0xC]

.inttostrloop:
	XOR edx, edx
	MOV eax, ebx

	IDIV esi

	PUSH eax
	MOV eax, edx
	ADD eax, 0x30
	STOSB
	POP eax

	CMP eax, 0x0
	JZ .done

	MOV ebx, eax
	JMP .inttostrloop


.done:
	;Add the sign on front
	CMP ecx, 0x0
	JZ .over 
	MOV al, cl
	STOSB

.over:
	MOV eax, edi
	ADD eax, 1

	; Reset dir flag
	CLD

	MOV esp, ebp
	POP ebp
	RET

; newline to nullbyte
; convert newline terminated string to null terminated string
; usage: newline_to_nullbyte(void* buffer)

newline_to_nullbyte:
	 PUSH ebp
	 MOV ebp, esp

	 ; Get the buffer
	 MOV esi, [ebp + 0x8]

	 XOR al, al

;Loop and update the first newline found
.newline_to_nullbyte_loop:
	LODSB
	CMP al, 0xA
	JZ .newline_found

	CMP al, 0x0
	JZ .newline_to_nullbyte.done

	JMP .newline_to_nullbyte_loop

.newline_found:
	MOV byte [esi-1], 0x0

.newline_to_nullbyte.done:
	 MOV esp, ebp
	 POP ebp
	 RET