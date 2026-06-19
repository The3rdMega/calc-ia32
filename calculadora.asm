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

; =================================================================
; FUNÇÃO: str_to_int
; Converte uma string ASCII com terminação '\n' ou '\0' para um inteiro.
; Parâmetros na pilha:
;   [ebp + 8]  -> Endereço da string a ser convertida (ponteiro)
; Saída:
;   EAX -> Valor inteiro resultante
; =================================================================
str_to_int:
    push ebp                ; Preparação: salva o antigo EBP em [ebp]
    mov ebp, esp            ; Preparação: define o novo EBP como base

    push ebx    ; Salva Registrador de Base em [ebp+4]
    push ecx    ; Salva Registrador de Contador em [ebp+8]
    push edx    ; Salva Registrador de Dados em [ebp+12]
    push esi    ; Salva Registrador de Stack Pointer em [ebp+16]

    mov esi, [ebp + 8]      ; ESI aponta para o início da string
    sub eax, eax            ; EAX = 0 (Nosso Acumulador)
    sub ecx, ecx            ; ECX = 0 (Vai guardar cada caractere lido)
    mov ebx, 10             ; EBX = 10 (O multiplicador constante)

.loop_converter:
    mov cl, [esi]           ; Lê 1 byte (caractere) da string apontada por ESI
    
    cmp cl, 10              ; O caractere é um '\n' (Enter)?
    je .fim_conversao       ; Se sim, terminamos!
    cmp cl, 0               ; O caractere é um '\0' (Fim de string)?
    je .fim_conversao       ; Se sim, terminamos!

    ; Se não for fim de string, é um dígito válido
    sub cl, 30h             ; Converte ASCII para valor numérico ('5' -> 5)

    ; Multiplica o acumulador atual (EAX) por 10
    ; A instrução 'mul ebx' faz: EDX:EAX = EAX * EBX.
    ; Como lidamos com números que cabem em 32 bits, o resultado fica no próprio EAX.
    mul ebx                 

    add eax, ecx            ; Soma o novo dígito ao acumulador

    inc esi                 ; Avança o ponteiro para o próximo caractere da string
    jmp .loop_converter     ; Repete o ciclo

.fim_conversao:
    pop esi    ; Recupera Registrador de Stack Pointer em [ebp-16]
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
    
    greeting_msg_2 db ", bem-vindo ao programa de CALC IA-32", 10, 0
    TAM_MSG_GREETING_2 equ $ - greeting_msg_2

    model_choice_msg db "Vai trabalhar com 16 ou 32 bits (digite 0 para 16, e 1 para 32):", 0
    TAM_MSG_CHOICE equ $ - model_choice_msg

    menu_msg db "ESCOLHA UMA OPÇÃO:", 10
    db "- 1: SOMA", 10
    db "- 2: SUBTRACAO", 10
    db "- 3: MULTIPLICACAO", 10
    db "- 4: DIVISAO", 10
    db "- 5: EXPONENCIACAO", 10
    db "- 6: MOD", 10
    db "- 7: SAIR", 10
    TAM_MSG_MENU equ $ - menu_msg

section .bss
    ; Buffer do nome do usuário
    buffer_nome_usuario resb 50     ; Reserva 50 bytes para o nome do usuário

    ; Buffers da escolha (16 bits ou 32 bits)
    buffer_choice resb 3 ; Buffer temporário para ler o que foi digitado (caractere + \n)
    choice_precisao resd 1  ; Variável de 32 bits para guardar o número final (0 ou 1)
    
    ; -------------------------------------------------------------
    ; Buffers de Seleção do Menu
    ; -------------------------------------------------------------
    buffer_menu_current resb 3 ; Buffer temporário para ler o que foi digitado (caractere + \n)
    menu_current resd 1 ; Variável de 32 bits para guardar o número final (0 ou 1)

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
    ; PERGUNTAR A PRECISÃO (0 ou 1)
    ; -------------------------------------------------------------
    push dword TAM_MSG_CHOICE
    push model_choice_msg
    call print_string
    add esp, 8

    ; -------------------------------------------------------------
    ; LER A RESPOSTA DO TECLADO
    ; -------------------------------------------------------------
    push dword 3        ; Precisamos ler apenas o caractere e o enter
    push buffer_choice
    call read_string
    add esp, 8

    ; CONVERSÃO DE ASCII PARA INTEIRO
    sub eax, eax               ; Limpa o EAX por segurança
    mov al, [buffer_choice]    ; Move o primeiro byte lido (o caractere '0' ou '1') para AL
    sub al, 30h                ; CONVERSÃO: Subtrai 48 (0x30). Agora AL tem o valor numérico 0 ou 1
    mov [choice_precisao], eax ; Salva o valor inteiro de EAX na variável na memória

menu_anchor:
    ; -------------------------------------------------------------
    ; EXIBIÇÃO DO MENU
    ; -------------------------------------------------------------
    push dword TAM_MSG_MENU
    push menu_msg
    call print_string
    add esp, 8

    ; -------------------------------------------------------------
    ; LEITURA DA ESCOLHA DO USUÁRIO
    ; -------------------------------------------------------------
    push dword 3        ; Precisamos ler apenas o caractere e o enter
    push buffer_menu_current
    call read_string
    add esp, 8

    ; CONVERSÃO DE ASCII PARA INTEIRO
    sub eax, eax                     ; Limpa o EAX por segurança
    mov al, [buffer_menu_current]    ; Move o primeiro byte lido para AL
    sub al, 30h                      ; CONVERSÃO: Subtrai 48 (0x30). Agora AL tem o valor numérico da escolha
    mov [menu_current], eax          ; Salva o valor inteiro de EAX na variável na memória

    ; -------------------------------------------------------------
    ; ROTEAMENTO DO MENU (Switch-Case)
    ; -------------------------------------------------------------
    mov eax, [menu_current]  ; Traz a escolha do usuário da memória para o registrador

    cmp eax, 1
    je exec_soma

    cmp eax, 2
    je exec_subtracao

    cmp eax, 3
    je exec_multiplicacao

    cmp eax, 4
    je exec_divisao

    cmp eax, 5
    je exec_exponenciacao

    cmp eax, 6
    je exec_mod

    cmp eax, 7
    je exec_sair

    ; Se o usuário digitou algo diferente de 1 a 7, podemos simplesmente
    ; encerrar o programa por segurança (ou pular de volta para o menu, 
    ; mas vamos focar no caminho feliz por enquanto).
    jmp exec_sair

; =================================================================
; BLOCOS DE EXECUÇÃO DAS OPERAÇÕES
; =================================================================

exec_soma:
    ; Aqui prepararemos os parâmetros e chamaremos a função do arquivo soma.asm
    ; Por enquanto, pula para o fim
    jmp menu_anchor

exec_subtracao:
    ; (A implementar)
    jmp menu_anchor

exec_multiplicacao:
    ; (A implementar)
    jmp menu_anchor

exec_divisao:
    ; (A implementar)
    jmp menu_anchor

exec_exponenciacao:
    ; (A implementar)
    jmp menu_anchor

exec_mod:
    ; (A implementar)
    jmp menu_anchor

exec_sair:
    ; -------------------------------------------------------------
    ; FINALIZAÇÃO DO PROGRAMA
    ; -------------------------------------------------------------
    mov eax, 1               ; sys_exit
    mov ebx, 0               ; Status 0 (Sucesso)
    int 0x80