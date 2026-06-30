section .text
    global calcular_mod      ; Exporta a função para o calculadora.asm enxergar
    extern print_string      ; Importa a função de print do arquivo principal
    extern calcular_div      ; Importa a função de calcular_mult

; =================================================================
; FUNÇÃO: calcular_mod
; Parâmetros na pilha:
;   [ebp + 16] -> num2 (Inteiro de 32 bits)
;   [ebp + 12] -> num1 (Inteiro de 32 bits)
;   [ebp + 8]  -> Precisao (0 = 16 bits, 1 = 32 bits)
; Retorno:
;   EAX -> Resultado do mod
; =================================================================
calcular_mod:
    push ebp                ; Preparação: salva o antigo EBP em [ebp]
    mov ebp, esp            ; Preparação: define o novo EBP como base

    push dword [ebp + 16]         ; [ebp + 16] num2
    push dword [ebp + 12]         ; [ebp + 12] num1
    push dword [ebp + 8]          ; [ebp + 8] precisao

    call calcular_div       ; Chama calcular_div como auxiliar (retorna resto em EDX)
    add esp, 12

    ; EDX contém o Resto da divisão
    mov eax,edx
    
    mov esp, ebp
    pop ebp
    ret