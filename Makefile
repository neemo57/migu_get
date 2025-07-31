migu_get: main.asm io.asm sockets.asm fileio.asm dns.asm url_utils.asm http.asm
	nasm -f elf32 main.asm -o main.o
	ld -m elf_i386 main.o -o migu_get