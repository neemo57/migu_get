%include "io.asm"
%include "sockets.asm"
%include "fileio.asm"
%include "dns.asm"
%include "url_utils.asm"
%include "http.asm"

section .data
	test_prompt DB "website >>", 0
	usage_prompt DB "Usage: migu_get http://<url>"
	
section .text
	
	global _start

	_start:
		MOV ebp, esp

		POP ecx
		CMP ecx, 0x2
		JNE bad_url

		PUSH dword [ebp + 0x8]
		CALL get_ip_address
		ADD esp, 0x4

		BSWAP eax
		PUSH eax
		PUSH dword [ebp + 0x8]
		CALL fetch_webpage
		ADD esp, 0x8

	_exit:
		MOV ebx, eax
		MOV eax, 1
		INT 0x80

	bad_url:
		PUSH usage_prompt
		CALL strprint
		ADD esp, 0x4

		CALL _exit