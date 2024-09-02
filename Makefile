all:
	rm -rf build
	mkdir build
	nasm -f bin src/game.asm -o build/game.bin
	nasm -f bin src/boot.asm -o build/boot.bin
	cat build/boot.bin build/game.bin > myname.bin
	qemu-system-x86_64 -fda build/myname.bin
