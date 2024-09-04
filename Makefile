all:
	rm -rf build
	mkdir build
	nasm -f bin src/boot.asm -o build/boot.bin
	nasm -f bin src/myname.asm -o build/myname.bin
	cat build/boot.bin build/myname.bin > game.bin
	qemu-system-x86_64 -drive format=raw,file=game.bin
