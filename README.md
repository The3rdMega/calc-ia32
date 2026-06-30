# Calculadora IA-32 - Trabalho de Software Básico

Este projeto consiste em uma calculadora implementada em linguagem Assembly IA-32, capaz de realizar operações aritméticas básicas e avançadas, respeitando as especificações providenciada pelo roteiro da disciplina de Software Básico (CIC0104 - 2026/1).

## Especificações do Projeto
- Arquitetura: IA-32 (x86).

- SO: Desenvolvido e testado em ambiente Linux (WSL/Ubuntu).
- Montador: NASM (Netwide Assembler).
- Ligador: LD (GNU Linker).
- Requisitos: Implementação modular em arquivos separados, passagem de parâmetros via pilha, uso de registradores locais (variáveis na pilha), suporte a duas precisões (16 e 32 bits) e tratamento de erros (Overflow e Divisão por Zero).

## Como Compilar e Executar
O projeto é composto por vários módulos que devem ser montados individualmente e ligados para gerar um executável único.

1. Pré-requisitos
Certifique-se de ter o nasm e o binutils (que contém o ld) instalados no seu sistema Linux:

```sudo apt update
sudo apt install nasm binutils
```

2. Compilação e Ligação
Na pasta raiz do projeto, utilize o seguinte comando no terminal para montar todos os arquivos e gerar o executável calculadora:

```bash
nasm -f elf calculadora.asm -o calculadora.o
nasm -f elf soma.asm -o soma.o
nasm -f elf subtracao.asm -o subtracao.o
nasm -f elf multiplicacao.asm -o multiplicacao.o
nasm -f elf exponenciacao.asm -o exponenciacao.o
nasm -f elf divisao.asm -o divisao.o
nasm -f elf mod.asm -o mod.o
```

ld -m elf_i386 calculadora.o soma.o subtracao.o multiplicacao.o exponenciacao.o divisao.o mod.o -o calculadora
3. Execução
Após a geração do binário, execute o programa com o comando:

```bash
./calculadora
```

## Detalhes da Implementação
- Modularização: O código principal (calculadora.asm) gerencia o fluxo (I/O, menu, conversões), enquanto as operações matemáticas residem em arquivos independentes.
- Passagem de Parâmetros: Todos os argumentos entre funções são passados via pilha (push), conforme exigido.
- Segurança: O programa verifica condições de estouro matemático (Overflow) nas operações de soma, subtração e multiplicação, encerrando a execução com status de erro caso necessário. Divisões por zero são tratadas para evitar falhas críticas.
- Variáveis Locais: Todas as variáveis de processamento numérico são alocadas localmente na pilha (usando sub esp, X), garantindo a conformidade com as boas práticas de baixo nível.

Desenvolvido por: Arthur Luiz Lima de Araújo (232000472) e Gabriel de Castri Dias (211055432)
Disciplina: CIC0104 - Software Básico - 2026/1 - Turma 02
Professor: Bruno Luiggi Macchiavello Espinoza
