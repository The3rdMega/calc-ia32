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
    pop edx    ; Recupera Registrador de Dados em [ebp-12]
    pop ecx    ; Recupera Registrador de Contador em [ebp-8]     
    pop ebx    ; Recupera Registrador de Base em [ebp-4]

    mov esp, ebp    ; Finalização: Desfaz o frame de pilha
    pop ebp         ; Finalização: Restaura o EBP original
    ret             ; Retorna para o fluxo de execução original

section .data
    welcome_msg db "Bem-vindo. Digite seu nome: ", 0
    TAM_MSG_WELCOME equ $ - welcome_msg
    
    greeting_msg_1 db "Hola, ", 0
    TAM_MSG_GREETING_1 equ $ - greeting_msg_1
    
    greeting_msg_2 db ", bem-vindo ao programa de CALC IA-32", 10, 0 ; 10 é o \n para saltar linha no final
    TAM_MSG_GREETING_2 equ $ - greeting_msg_2

section .bss
    buffer_nome_usuario resb 50     ; Reserva 50 bytes para o nome do usuário

section .text
_start:
    ; -------------------------------------------------------------
    ; EXIBIR MENSAGEM (WELCOME)
    ; -------------------------------------------------------------
    push dword TAM_MSG_WELCOME ; Empilha o 2º Parâmetro (Tamanho da string)
    push welcome_msg           ; Empilha o 1º Parâmetro (Endereço da string)
    call print_string          ; Executa a função
    add esp, 8                 ; Limpa a pilha (2 parâmetros de 4 bytes cada = 8)

    ; -------------------------------------------------------------
    ; LER TECLADO (USERNAME)
    ; -------------------------------------------------------------
    push dword 50            ; Empilha o 2º parâmetro (Tamanho Máximo do buffer)
    push buffer_nome_usuario ; Empilha o 1º Parâmetro (Endereço do buffer)
    call read_string         ; Executa a função
    add esp, 8               ; Limpa a pilha (8 bytes)

    ; EAX contém a quantidade de caracteres digitados pelo usuário

    ; -------------------------------------------------------------
    ; TRATAMENTO DO TAMANHO DO NOME
    ; -------------------------------------------------------------
    dec eax                  ; Subtrai 1 de EAX para descartar o '\n' digitado
    mov esi, eax             ; Salva o tamanho corrigido em ESI (protegido contra print_string)

    ; -------------------------------------------------------------
    ; EXIBIR MENSAGEM (GREETING)
    ; -------------------------------------------------------------
    push dword TAM_MSG_GREETING_1 ; Empilha o 2º Parâmetro (Tamanho da string)
    push greeting_msg_1           ; Empilha o 1º Parâmetro (Endereço da string)
    call print_string             ; Executa a função
    add esp, 8                    ; Limpa a pilha (2 parâmetros de 4 bytes cada = 8)

    ; ---
    ; Aqui exibimos o nome do usuário
    ; ---
    push esi                      ; Empilha o 2º Parâmetro (Tamanho da string)
    push buffer_nome_usuario      ; Empilha o 1º Parâmetro (Endereço da string)
    call print_string             ; Executa a função
    add esp, 8                    ; Limpa a pilha (2 parâmetros de 4 bytes cada = 8)


    push dword TAM_MSG_GREETING_2 ; Empilha o 2º Parâmetro (Tamanho da string)
    push greeting_msg_2           ; Empilha o 1º Parâmetro (Endereço da string)
    call print_string             ; Executa a função
    add esp, 8                    ; Limpa a pilha (2 parâmetros de 4 bytes cada = 8)

    ; -------------------------------------------------------------
    ; FINALIZAÇÃO DO PROGRAMA (Temporária, para testes)
    ; -------------------------------------------------------------
    mov eax, 1               ; sys_exit
    mov ebx, 0               ; Status 0 (Sucesso)
    int 0x80