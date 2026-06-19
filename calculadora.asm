section .text
global _start

; =================================================================
; FUNÇÃO: print_string
; Parâmetros na pilha:
;   [ebp + 12] -> Tamanho da string (inteiro)
;   [ebp + 8]  -> Endereço da string (ponteiro)
; =================================================================

print_string:
    push ebp                ; Preparação: salva o antigo EBP em [ebp]
    mov ebp, esp            ; Preparação: define o novo EBP como base

    ; Preserva os registradores que serão modificados pela syscall
    push ebx    ; Salva Registrador de Base em [ebp+4]
    push ecx    ; Salva Registrador de Contador em [ebp+8]
    push edx    ; Salva Registrador de Dados em [ebp+12]

    ; Prepara a chamada sys_write (na ordem dos parâmetros direita para esquerda)
    mov eax, 4              ; Código da syscall sys_write
    mov ebx, 1              ; File Descriptor: 1 = stdout (monitor)
    mov ecx, [ebp + 8]      ; Recupera o 1º parâmetro: ponteiro da string
    mov edx, [ebp + 12]     ; Recupera o 2º parâmetro: tamanho da string
    int 0x80                ; Chama o Sistema Operacional

    ; Restaura os registradores na ordem inversa da que preservou
    pop edx    ; Recupera Registrador de Dados em [ebp+12]
    pop ecx    ; Recupera Registrador de Contador em [ebp+8]     
    pop ebx    ; Recupera Registrador de Base em [ebp+4]

    mov esp, ebp    ; Finalização: Desfaz o frame de pilha
    pop ebp         ; Finalização: Restaura o EBP original
    ret             ; Retorna para o fluxo de execução original

; =================================================================
; FUNÇÃO: read_string
; Parâmetros na pilha:
;   [ebp + 12] -> Tamanho máximo do buffer (inteiro)
;   [ebp + 8]  -> Endereço do buffer na memória (ponteiro)
; Saída:
;   EAX -> Quantidade de bytes lidos de fato (retorno padrão)
; =================================================================

read_string:
    push ebp                ; Preparação: salva o antigo EBP em [ebp]
    mov ebp, esp            ; Preparação: define o novo EBP como base

    ; Preserva os registradores que serão modificados pela syscall
    push ebx    ; Salva Registrador de Base em [ebp+4]
    push ecx    ; Salva Registrador de Contador em [ebp+8]
    push edx    ; Salva Registrador de Dados em [ebp+12]

    mov eax, 3              ; Código da syscall sys_read
    mov ebx, 0              ; File Descriptor: 0 = stdin (teclado)
    mov ecx, [ebp + 8]      ; Recupera o 1º parâmetro: ponteiro do buffer
    mov edx, [ebp + 12]     ; Recupera o 2º parâmetro: tamanho do buffer
    int 0x80                ; Chama o Sistema Operacional

    ; Restaura os registradores na ordem inversa da que preservou
    pop edx    ; Recupera Registrador de Dados em [ebp+12]
    pop ecx    ; Recupera Registrador de Contador em [ebp+8]     
    pop ebx    ; Recupera Registrador de Base em [ebp+4]

    mov esp, ebp    ; Finalização: Desfaz o frame de pilha
    pop ebp         ; Finalização: Restaura o EBP original
    ret             ; Retorna para o fluxo de execução original

