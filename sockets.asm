;------------------------------------------------------------------------
;=== Assembly Library used by webpage_downloader to work with sockets =======
;------------------------------------------------------------------------

section .data
tcp_addr:
	DW 2
	DW 0x5000
	DD 0x00000000
	DD 0x0
	DD 0x0

tcp_connection:
	DD 0 ; File descriptor
	DD tcp_addr
	DD 16


udpsocketargs DD 2, 2, 0
tcpsocketargs DD 2, 1, 0

createudpsocket:
	PUSH ebp
	MOV ebp, esp

	MOV eax, 102
	MOV ebx, 1
	MOV ecx, udpsocketargs
	INT 0x80

	MOV esp, ebp
	POP ebp
	RET

createtcpsocket:
	PUSH ebp
	MOV ebp, esp

	MOV eax, 102
	MOV ebx, 1
	MOV ecx, tcpsocketargs
	INT 0x80

	MOV esp, ebp
	POP ebp
	RET

;----------------------
;- Connect to an IP ---
; Usage: connect(int file_descriptor, int ip, int port)
;----------------------

connectsocket:
	PUSH ebp
	MOV ebp, esp

	; Get file descriptor
	MOV edx, [ebp + 0x8]
	MOV [tcp_connection], edx

	; Get ip
	MOV eax, [ebp + 0xC]
	BSWAP eax ; Byte swap
	MOV [tcp_addr + 0x4], eax

	; Get port
	MOV eax, [ebp + 0x10]
	XCHG al, ah ; Byte exchange
	MOV [tcp_addr + 0x2], ax

	; Invoke sys_connect
	MOV eax, 102d
	MOV ebx, 0x3
	MOV ecx, tcp_connection
	INT 0x80

	MOV esp, ebp
	POP ebp
	RET