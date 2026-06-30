section .text
    global calcular_sub     ; Exporta a função para o calculadora.asm enxergar
    extern print_string      ; Importa a função de print do arquivo principal

; =================================================================
; FUNÇÃO: calcular_sub
; Parâmetros na pilha:
;   [ebp + 16] -> num2 (Inteiro de 32 bits)
;   [ebp + 12] -> num1 (Inteiro de 32 bits)
;   [ebp + 8]  -> Precisao (0 = 16 bits, 1 = 32 bits)
; Retorno:
;   EAX -> Resultado da subtração
; =================================================================
calcular_sub:
    push ebp                ; Preparação: salva o antigo EBP em [ebp]
    mov ebp, esp            ; Preparação: define o novo EBP como base

    push ebx            ; Preserva EBX pois usamos ele para os cálculos

    ; Verifica qual é a precisão escolhida
    mov ecx, [ebp + 8]  ; ECX recebe a flag de precisão (0 ou 1)
    cmp ecx, 0
    je .sub_16bits     ; Se for 0, pula para o bloco de 16 bits

.sub_32bits:
    ; -------------------------------------------------------------
    ; Lógica de 32 bits
    ; -------------------------------------------------------------
    mov eax, [ebp + 12] ; Carrega num1 em EAX
    mov ebx, [ebp + 16] ; Carrega num2 em EBX
    sub eax, ebx        ; EAX = EAX - EBX
    
    jmp .fim            ; Pula direto para o final (ignorando o bloco de 16 bits)

.sub_16bits:
    ; -------------------------------------------------------------
    ; Lógica de 16 bits
    ; -------------------------------------------------------------
    mov eax, [ebp + 12] ; Carrega num1 
    mov ebx, [ebp + 16] ; Carrega num2
    
    ; Aqui subtraímos APENAS as partes baixas (16 bits) dos registradores
    sub ax, bx          ; AX = AX - BX
    
    ; O resultado está em AX. Mas a regra exige a saída em EAX.
    ; Usamos a instrução 'movsx' (Move with Sign-Extension) para estender o 
    ; número de 16 para 32 bits mantendo o sinal positivo ou negativo intacto.
    movsx eax, ax       
    jmp .fim

.fim:
    ; -------------------------------------------------------------
    ; Epílogo comum
    ; -------------------------------------------------------------
    pop ebx
    mov esp, ebp
    pop ebp
    ret