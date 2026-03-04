import os

# 1. Compilar o assembly
os.system("nasm -f bin linceos.asm -o linceos.bin")

# 2. Criar uma imagem de disco de 1.44MB (Disquete)
# O QEMU precisa que o ficheiro tenha o tamanho correto de um disco
with open("linceos.bin", "rb") as f:
    kernel_data = f.read()

# Preencher o resto do ficheiro com zeros para fazer 1.44MB
padding = b"\x00" * (1474560 - len(kernel_data))

with open("linceos.img", "wb") as f:
    f.write(kernel_data + padding)

print("Imagem linceos.img criada com sucesso!")
# 3. Executar no QEMU
# -kernel carrega o binário diretamente
# -vga std ativa o modo 320x200
os.system("qemu-system-i386 -kernel linceos.bin -vga std")