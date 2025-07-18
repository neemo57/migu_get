%include "io.asm"

section .data
	prompt DB "What is your name gentleman? >>", 0x0
	numprompt DB "Type the number Kosinuwu chan >>",0x0
	happy_prompt DB "Hi there ! Nice to meet you Mr./Mrs.", 0x0
	age_prompt DB "What year were you born? >>", 0x0
	your_age_is DB "So you are currently around ", 0x0
	your_age_is2 DB " years old.", 0xA, 0x0
	name_size DD 30d
	fruit1 DB "Apple", 0
	fruit2 DB "Mango", 0

section .text
	
	global _start

	_start:

	; readname:
	; 	SUB esp, dword [name_size]
	; 	MOV esi, esp
	; 	PUSH esi

	; 	PUSH dword [name_size]
	; 	PUSH esi
	; 	CALL strinput
	; 	POP esi
		
	; 	PUSH esi
	; 	PUSH happy_prompt
	; 	CALL strprint
	; 	POP esi
	; 	POP esi

	; 	PUSH esi
	; 	CALL strprint

	; mystrtoint:
	; 	SUB esp, 11
	; 	MOV esi, esp

	; 	PUSH dword 11d
	; 	PUSH esi
	; 	CALL strinput
	; 	POP esi

	; 	PUSH esi
	; 	CALL strtoint

	agecalc:
		PUSH age_prompt
		CALL linefeedprint

		SUB esp, 10
		MOV esi, esp
		PUSH 10
		PUSH esi
		CALL strinput
		POP esi

		PUSH esi
		CALL strtoint

		MOV ebx, 2025
		SUB ebx, eax

		SUB esp, 22
		MOV esi, esp
		PUSH ebx
		PUSH esi
		CALL inttostr

		PUSH eax
		PUSH your_age_is
		CALL strprint
		POP eax
		POP eax

		PUSH eax
		CALL strprint

		PUSH your_age_is2
		CALL strprint

	_exit:
		MOV ebx, eax
		MOV eax, 1
		INT 0x80