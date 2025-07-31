## migu_get
migu_get is a web page fetcher that you can use to make simple http requests. It's written in x86 assembly without using ANY THIRD LIBRARY.

Yes, sounds batshit crazy. But the program uses ZERO external C libraries and relies purely on system calls.

## Usage:

1. Compile the binary using make
  `make migu_get`
  If you get a NASM not found error, make sure you install the package `nasm`.

 2. Run the binary `migu_get`
    `./migu_get http://<url>`
