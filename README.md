# Calculadora IA-32

## Como compilar e ligar (Ubuntu/WSL)

1. Monte todos os arquivos fonte usando o NASM:
\`\`\`bash
nasm -f elf calculadora.asm
nasm -f elf soma.asm
nasm -f elf subtracao.asm
nasm -f elf multiplicacao.asm
nasm -f elf divisao.asm
nasm -f elf exponenciacao.asm
nasm -f elf mod.asm
\`\`\`

2. Ligue os arquivos objeto gerados usando o LD para criar o executável:
\`\`\`bash
ld -m elf_i386 -s -o calculadora calculadora.o soma.o subtracao.o multiplicacao.o divisao.o exponenciacao.o mod.o
\`\`\`

3. Execute o programa:
\`\`\`bash
./calculadora
\`\`\`

> [!INFO] Observação:
> Também é possível executar o programa do zero usando o comando conjunto: 
> \`\`\` nasm -f elf calculadora.asm -o calculadora.o && nasm -f elf soma.asm -o soma.o && nasm -f elf subtracao.asm -o subtracao.o && nasm -f elf multiplicacao.asm -o multiplicacao.o && nasm -f elf exponenciacao.asm -o exponenciacao.o && nasm -f elf divisao.asm -o divisao.o && nasm -f elf mod.asm -o mod.o && ld -m elf_i386 calculadora.o soma.o subtracao.o multiplicacao.o exponenciacao.o divisao.o mod.o -o calculadora && ./calculadora