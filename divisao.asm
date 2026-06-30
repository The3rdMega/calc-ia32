section .data
    ; Mensagem de erro do Overflow da Multiplicação
    msg_divzero db "ERRO: DIVISÃO POR ZERO.", 10, 0
    TAM_MSG_DIVZERO equ $ - msg_divzero

section .text
    global calcular_div      ; Exporta a função para o calculadora.asm enxergar
    extern print_string      ; Importa a função de print do arquivo principal

; =================================================================
; FUNÇÃO: calcular_div
; Parâmetros na pilha:
;   [ebp + 16] -> num2 (Inteiro de 32 bits)
;   [ebp + 12] -> num1 (Inteiro de 32 bits)
;   [ebp + 8]  -> Precisao (0 = 16 bits, 1 = 32 bits)
; Retorno:
;   EAX -> Resultado da divisão
;   EDX -> Resto da divisão
; =================================================================
calcular_div:
    push ebp                ; Preparação: salva o antigo EBP em [ebp]
    mov ebp, esp            ; Preparação: define o novo EBP como base

    push ebx            ; Preserva EBX pois usamos ele para os cálculos

    ; Verifica qual é a precisão escolhida
    mov ecx, [ebp + 8]  ; ECX recebe a flag de precisão (0 ou 1)
    cmp ecx, 0
    je .div_16bits     ; Se for 0, pula para o bloco de 16 bits

.div_32bits:
    ; -------------------------------------------------------------
    ; Lógica de 32 bits
    ; -------------------------------------------------------------
    mov eax, [ebp + 12] ; Carrega num1 em EAX
    mov ebx, [ebp + 16] ; Carrega num2 em EBX

    cmp ebx, 0           ; Verifica se o divisor de 32 bits é zero
    je .erro_div_zero

    cdq
    idiv ebx    ; EAX = EDX:EAX / EBX

    jmp .fim            ; Pula direto para o final (ignorando o bloco de 16 bits)

.div_16bits:
    ; -------------------------------------------------------------
    ; Lógica de 16 bits
    ; -------------------------------------------------------------
    mov eax, [ebp + 12] ; Carrega num1 em EAX
    mov ebx, [ebp + 16] ; Carrega num2 em EBX

    cmp bx, 0           ; Verifica se o divisor de 16 bits é zero
    je .erro_div_zero

    cwd
    idiv bx    ; AX = DX:AX / BX

    ; O resultado está em AX. Mas a regra exige a saída em EAX.
    ; Usamos a instrução 'movsx' (Move with Sign-Extension) para estender o 
    ; número de 16 para 32 bits mantendo o sinal positivo ou negativo intacto.
    movsx eax, ax
    movsx edx, dx
    jmp .fim

.erro_div_zero:
    ; -------------------------------------------------------------
    ; Abortar o programa em caso de divisão por Zero
    ; (Podemos alterar para voltar para o Menu depois)
    ; -------------------------------------------------------------
    push dword TAM_MSG_DIVZERO
    push msg_divzero
    call print_string       ; Executa o print_string que mora no calculadora.asm
    add esp, 8

    mov eax, 1              ; sys_exit
    mov ebx, 1              ; Exit status 1 (indica que saiu com erro)
    int 0x80

.fim:
    ; -------------------------------------------------------------
    ; Epílogo comum
    ; -------------------------------------------------------------
    pop ebx
    mov esp, ebp
    pop ebp
    ret