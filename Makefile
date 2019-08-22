
default:
	nasm -o hariboteos.img hariboteos.asm

run:
	D:/VirtualBox/VBoxManage startvm HariboteOS
