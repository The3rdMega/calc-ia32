section .text
    global calcular_exp      ; Exporta a função para o calculadora.asm enxergar
    extern print_string      ; Importa a função de print do arquivo principal
    extern calcular_mult     ; Importa a função de calcular_mult

; =================================================================
; FUNÇÃO: calcular_exp
; Parâmetros na pilha:
;   [ebp + 16] -> num2 (Inteiro de 32 bits)
;   [ebp + 12] -> num1 (Inteiro de 32 bits)
;   [ebp + 8]  -> Precisao (0 = 16 bits, 1 = 32 bits)
; Retorno:
;   EAX -> Resultado da exponenciação
; =================================================================
calcular_exp:
    push ebp                ; Preparação: salva o antigo EBP em [ebp]
    mov ebp, esp            ; Preparação: define o novo EBP como base

    push ebx            ; Preserva EBX pois usamos ele para os cálculos

    ; Verifica qual é a precisão escolhida
    mov eax, [ebp + 12] ; Carrega num1 em EAX
    mov ebx, [ebp + 16] ; Carrega num2 em EBX (expoente)
    
    ; -------------------------------------------------------------
    ; TRATAMENTO DE CASOS BASE (Edge Cases)
    ; -------------------------------------------------------------
    ; Caso Expoente = 0 (Ex: 5^0 = 1)
    cmp ebx, 0
    je .exp_zero
    
    ; Caso Expoente = 1 (Ex: 5^1 = 5). 
    ; O resultado já está no EAX (a própria base), só retornar!
    cmp ebx, 1
    je .fim


.exp_loop:
    ; Empilhando os parâmetros para a função calcular_mult
    ; Regra: empilhar da direita para a esquerda (num2, num1, precisao)

    push eax                ; 1º PUSH: O EAX atual é o nosso "acumulador" (vai como num2)

    mov edx, [ebp + 12]     ; Trazemos a base original direto da memória
    push edx                ; 2º PUSH: A base (vai como num1)


    mov edx, [ebp + 8]      ; Trazemos a flag de precisão direto da memória
    push edx                ; 3º PUSH: A flag (vai como precisão)

    call calcular_mult          ; Pula para o arquivo mult.asm
    add esp, 12                 ; Limpa os 3 parâmetros da pilha (3 * 4 = 12 bytes)
    
    dec ebx                 ; EAX = EAX * Base. Diminui 1 do expoente.
    cmp ebx, 1              ; O expoente chegou a 1?
    je .fim                 ; Se sim, terminamos
    jmp .exp_loop           ; Se não, volta pro loop com o novo EAX

; -------------------------------------------------------------
; BLOCOS DE FINALIZAÇÃO
; -------------------------------------------------------------
.exp_zero:
    mov eax, 1              ; Qualquer número elevado a 0 é 1
    jmp .fim

.fim:
    pop ebx                 ; Restaura o EBX
    mov esp, ebp
    pop ebp
    ret