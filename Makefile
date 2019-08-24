default:
	make hariboteos.img

clean:
	rm ipl.bin haribote.sys hariboteos.img

run: hariboteos.img
	D:/VirtualBox/VBoxManage startvm HariboteOS

ipl.bin: ipl.asm
	nasm -o ipl.bin ipl.asm

haribote.sys: haribote.asm
	nasm -o haribote.sys haribote.asm

hariboteos.img: ipl.bin haribote.sys
	dd if=/dev/zero of=hariboteos.img count=1440 bs=1k
	dd if=ipl.bin of=hariboteos.img count=1440 bs=1k conv=notrunc
	imdisk -a -t file -f hariboteos.img -m A: && cp haribote.sys A:/haribote.sys && imdisk -d -m A:


