;------------------------------
;---- DNS request library -----
;------------------------------

swap_ax:
	; Sends the value ax to the file descriptor in ebx

	;Swap ax
	XCHG al, ah
	RET


; ---- Label encode a data ----
; Usage: label_encoder( char* input)
label_encoder:
	PUSH ebp
	MOV ebp, esp

	; Get the pointer to the string separated by dots
	MOV esi, [ebp + 0x8]

	; Push the size of the current label into the stack
	PUSH 0

	; ecx stores the current label length
	LEA ecx, [esp]

	;Store the starting of ESP in ebx
	LEA ebx, [esp]

.label_encoder_loop:
	INC edx

	XOR eax, eax
	LODSB
	CMP al, 0x2e
	JZ .reset_label_length

	PUSH eax

	CMP al, 0x0
	JZ .label_encoder_loop_done

	INC dword [ecx]
	JMP .label_encoder_loop

.reset_label_length:
	PUSH 0
	LEA ecx, [esp]
	JMP .label_encoder_loop

.label_encoder_loop_done:
	; Reset the original string
	MOV edi, dword [ebp + 0x8]
	
.restore_loop:
	MOV eax, dword [ebx]
	STOSB
	
	CMP al, 0
	JZ .label_encoder_done

	SUB ebx, 0x4
	JMP .restore_loop

.label_encoder_done:
	MOV esp, ebp
	POP ebp
	RET

; Send DNS request get the IP address in eax
; Usage: dns_query(char* unencoded_website_name)
; -------------------------------------------
erromsg DB "Could not connect to the DNS server. Idk what happened bruh :( ", 0

dns_query:
	PUSH ebp
	MOV ebp, esp

	CALL createudpsocket
	; The fd is in eax now
	MOV esi, eax
	PUSH esi ;Preserve fd

	PUSH 53d
	PUSH 0x01010101
	PUSH eax
	CALL connectsocket
	ADD esp, 0xC

	; Check if the socket is connected
	CMP eax, 0x0
	JNZ .error

	; ------------------
	; Start pushing data
	; ------------------

	;9. Push the record class
	MOV ax, 0x0001
	CALL swap_ax
	PUSH word ax

	;8. Push the record type
	MOV ax, 0x0001
	CALL swap_ax
	PUSH word ax

	;7. Push label encoded data

	; Get the label length
	PUSH dword [ebp + 0x8]
	CALL label_encoder
	ADD esp, 0x4

	PUSH dword [ebp+0x8]
	CALL strlen
	ADD esp, 0x4

	INC eax
	MOV ecx, eax

	SUB esp, ecx
	MOV esi, [ebp + 0x8]
	MOV edi, esp
	REP MOVSB

	; Move the length in edx coz we need it
	MOV edx, eax

	MOV esi, [ebp - 0x4] ;Get back fd

	; 6. PUSH number of additional RRs
	XOR eax, eax
	MOV ax, 0x0000
	CALL swap_ax
	PUSH word ax

	; 5. PUSH number of RRs
	MOV ax, 0x0000
	CALL swap_ax
	PUSH word ax

	; 4. PUSH number of replies
	MOV ax, 0x0000
	CALL swap_ax
	PUSH word ax

	; 3. PUSH number of queries
	MOV ax, 0x0001
	CALL swap_ax
	PUSH word ax

	;2. PUSH the flags
	MOV ax, 0x0100
	CALL swap_ax
	PUSH word ax

	;1. PUSH the transaction number
	MOV ax, 0x1234
	CALL swap_ax
	PUSH word ax

.sender:
	; Make the call

	MOV eax, 4
	MOV ebx, esi ; The fd
	MOV ecx, esp
	ADD edx, 16d

	INT 0x80

	; CLear the stack
	ADD esp, edx

.receiver:
	; Make some space in the stack first
	SUB esp, 1024d
	
	MOV eax, 3
	MOV ebx, esi
	MOV ecx, esp
	MOV edx, 1024
	INT 0x80

	SUB eax, 4
	MOV eax, dword [esp + eax]

	;clear the stakc
	ADD esp, edx	

.close_the_socket:
	PUSH eax

	MOV eax, 6
	MOV ebx, esi
	INT 0x80

	POP eax

	JMP .done

.error:
	PUSH erromsg
	CALL strprint
	
	MOV ebx, eax
	MOV eax, 1
	INT 0x80

.done:
	MOV esp, ebp
	POP ebp
	RET


; Print IP address
; Usage: printip(int ip_address)
dot DB ".", 0
printip:
	PUSH ebp
	MOV ebp, esp

	; Get the ip address
	MOV eax, [ebp + 0x8]

	;Use ecx as the counter
	XOR ecx, ecx

	; Make the same buffer for all the digits
	SUB esp, 22d
	LEA esi, [esp]

.printip_loop:
	XOR ebx, ebx
	MOV bl, al

	;Preserve eax and esi and ecx
	PUSH eax
	PUSH esi
	PUSH ecx

	PUSH ebx
	PUSH esi
	CALL inttostr
	ADD esp, 0x8

	PUSH eax
	CALL strprint
	ADD esp, 0x4

	POP ecx; get ecx back
	POP esi; get esi back
	POP eax; get eax back

	; Shift right and see if ecx is 4
	SHR eax, 0x8
	INC ecx
	CMP ecx, 0x4
	JZ .printip_done

	;Preserve eax and esi and ecx
	PUSH eax
	PUSH esi
	PUSH ecx

	PUSH dot
	CALL strprint
	ADD esp, 0x4

	POP ecx; get ecx back
	POP esi; get esi back
	POP eax; get eax back

	JMP .printip_loop

.printip_done:
	
	; Clear the stack junk
	ADD esp, 22d

	MOV esp, ebp
	POP ebp
	RET