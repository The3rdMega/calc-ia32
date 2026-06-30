section .data
    ; Mensagens do Menu e Saudação
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

    ; Mensagens padrão de operandos e resultado
    msg_num1 db "Digite o primeiro numero: ", 0
    TAM_MSG_NUM1 equ $ - msg_num1
    
    msg_num2 db "Digite o segundo numero: ", 0
    TAM_MSG_NUM2 equ $ - msg_num2

    msg_resultado db "Resultado: ", 0
    TAM_MSG_RESULTADO equ $ - msg_resultado

    ; MENSAGEM NOVA PARA ESPERAR O ENTER
    msg_enter db "Pressione ENTER para continuar...", 10, 0
    TAM_MSG_ENTER equ $ - msg_enter

    ; Informação de Ligação
    global print_string
    extern calcular_soma
    extern calcular_sub 
    extern calcular_mult
    extern calcular_div
    extern calcular_exp
    extern calcular_mod

section .bss
    ; APENAS AS VARIÁVEIS PERMITIDAS PELO ROTEIRO:
    buffer_nome_usuario resb 50 
    buffer_choice resb 3 
    choice_precisao resd 1  
    buffer_menu_current resb 3 
    menu_current resd 1 
    
    ; AS VARIÁVEIS DE NÚMERO E BUFFERS FORAM EXCLUÍDAS DAQUI!

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
; FUNÇÃO: pedir_numero
; Pede um número ao usuário usando um buffer LOCAL na pilha.
; Decide dinamicamente entre conversão de 16 ou 32 bits.
; Parâmetros na pilha:
;   [ebp + 12] -> Tamanho da mensagem (msg_num1 ou msg_num2)
;   [ebp + 8]  -> Endereço da mensagem
; Saída:
;   EAX -> Valor inteiro convertido
; =================================================================
pedir_numero:
    push ebp
    mov ebp, esp
    sub esp, 20             ; ALOCAÇÃO LOCAL: Cria um buffer temporário de 20 bytes na pilha

    ; -------------------------------------------------------------
    ; 1. Imprime a mensagem pedindo o número
    ; -------------------------------------------------------------
    push dword [ebp + 12]
    push dword [ebp + 8]
    call print_string
    add esp, 8

    ; -------------------------------------------------------------
    ; 2. Lê do teclado e guarda no buffer LOCAL
    ; -------------------------------------------------------------
    push dword 20
    lea eax, [ebp - 20]     ; 'lea' carrega o endereço da variável local [ebp-20]
    push eax
    call read_string
    add esp, 8

    ; -------------------------------------------------------------
    ; 3. Verifica a precisão escolhida pelo usuário
    ; -------------------------------------------------------------
    mov ecx, [choice_precisao]  ; Traz a precisão global (0 para 16, 1 para 32)
    cmp ecx, 0
    je .converte_16_bits        ; Se for 0, pula para a função de 16 bits

.converte_32_bits:
    ; -------------------------------------------------------------
    ; Chama a conversão de 32 bits
    ; -------------------------------------------------------------
    lea eax, [ebp - 20]     ; Passa o endereço do buffer local
    push eax
    call str_to_int_32
    add esp, 4
    jmp .fim_pedir_numero   ; Pula para o fim, pois o EAX já está com a resposta

.converte_16_bits:
    ; -------------------------------------------------------------
    ; Chama a conversão de 16 bits
    ; -------------------------------------------------------------
    lea eax, [ebp - 20]     ; Passa o endereço do buffer local
    push eax
    call str_to_int_16
    add esp, 4              ; A função _16 já garante a saída no EAX (via movsx)

.fim_pedir_numero:
    ; O EAX agora contém o número matemático convertido!
    mov esp, ebp            ; Desfaz o frame de pilha (e destrói o buffer temporário)
    pop ebp
    ret

; =================================================================
; FUNÇÃO: str_to_int_32
; Converte uma string ASCII (com sinal) para inteiro de 32 bits.
; Parâmetros na pilha:
;   [ebp + 8]  -> Endereço da string a ser convertida (ponteiro)
; Saída:
;   EAX -> Valor inteiro resultante (32 bits)
; =================================================================
str_to_int_32:
    push ebp                
    mov ebp, esp            

    push ebx    
    push ecx    
    push edx    
    push esi    
    push edi    

    mov esi, [ebp + 8]      ; ESI aponta para o início da string
    sub eax, eax            ; EAX = 0 (Acumulador de 32 bits)
    sub ecx, ecx            ; ECX = 0 
    sub edi, edi            ; EDI = 0 (Flag de sinal)
    mov ebx, 10             ; EBX = 10 (Multiplicador de 32 bits)

    ; VERIFICAÇÃO DO SINAL NEGATIVO 
    mov cl, [esi]           
    cmp cl, '-'             
    jne .loop_converter     

    mov edi, 1              ; Levanta a flag de número negativo
    inc esi                 ; Avança o ponteiro 

.loop_converter:
    mov cl, [esi]           
    
    cmp cl, 10              ; É um '\n'?
    je .aplica_sinal        
    cmp cl, 0               ; É um '\0'?
    je .aplica_sinal        

    sub cl, 30h             ; Converte ASCII para numérico

    mul ebx                 ; EDX:EAX = EAX * EBX
    add eax, ecx            ; Soma no acumulador

    inc esi                 
    jmp .loop_converter     

.aplica_sinal:
    cmp edi, 1              
    jne .fim_conversao      

    neg eax                 ; Inverte sinal em 32 bits

.fim_conversao:
    pop edi    
    pop esi    
    pop edx    
    pop ecx    
    pop ebx    

    mov esp, ebp    
    pop ebp         
    ret

; =================================================================
; FUNÇÃO: str_to_int_16
; Converte uma string ASCII (com sinal) para inteiro de 16 bits.
; Parâmetros na pilha:
;   [ebp + 8]  -> Endereço da string a ser convertida (ponteiro)
; Saída:
;   EAX -> Valor inteiro resultante estendido (regra do roteiro)
; =================================================================
str_to_int_16:
    push ebp                
    mov ebp, esp            

    push ebx    
    push ecx    
    push edx    
    push esi    
    push edi    

    mov esi, [ebp + 8]      ; Ponteiros DEVEM continuar em 32 bits
    sub ax, ax              ; AX = 0 (Acumulador matemático de 16 bits)
    sub cx, cx              ; CX = 0 
    sub edi, edi            ; Flag de sinal (pode manter 32 bits para lógica de controle)
    mov bx, 10              ; BX = 10 (Multiplicador de 16 bits)

    ; VERIFICAÇÃO DO SINAL NEGATIVO 
    mov cl, [esi]           
    cmp cl, '-'             
    jne .loop_converter     

    mov edi, 1              ; Levanta a flag de número negativo
    inc esi                 

.loop_converter:
    mov cl, [esi]           
    
    cmp cl, 10              
    je .aplica_sinal        
    cmp cl, 0               
    je .aplica_sinal        

    sub cl, 30h             

    ; Matemática estrita em 16 bits
    mul bx                  ; DX:AX = AX * BX
    add ax, cx              ; Soma no acumulador de 16 bits

    inc esi                 
    jmp .loop_converter     

.aplica_sinal:
    cmp edi, 1              
    jne .finaliza_extensao      

    neg ax                  ; Inverte sinal do registrador de 16 bits

.finaliza_extensao:
    ; O roteiro exige a saída em EAX. Pegamos o AX e estendemos o sinal para 32 bits.
    movsx eax, ax           

    pop edi    
    pop esi    
    pop edx    
    pop ecx    
    pop ebx    

    mov esp, ebp    
    pop ebp         
    ret

; =================================================================
; FUNÇÃO: int_to_str
; Converte um valor numérico em EAX para texto e joga num buffer.
; Parâmetros na pilha:
;   [ebp + 12] -> O valor inteiro (ex: o resultado da soma)
;   [ebp + 8]  -> Endereço do buffer de destino para o texto
; =================================================================
int_to_str:
    push ebp                ; Preparação: salva o antigo EBP em [ebp]
    mov ebp, esp            ; Preparação: define o novo EBP como base

    push ebx    ; Salva Registrador de Base em [ebp+4]
    push ecx    ; Salva Registrador de Contador em [ebp+8]
    push edx    ; Salva Registrador de Dados em [ebp+12]
    push esi    ; Salva Registrador de Stack Pointer em [ebp+16]
    push edi    ; Salva Registrador de Extended Destination Index em [ebp+18]

    mov eax, [ebp + 12]     ; Traz o número para o EAX
    mov edi, [ebp + 8]      ; Traz o ponteiro do buffer para o EDI

    ; Verifica se o número é 0
    cmp eax, 0
    je .trata_zero

    ; Verifica se o número é negativo
    cmp eax, 0
    jge .inicia_conversao   ; Jump if Greater or Equal (se positivo, pula)
    
    ; Se for negativo, coloca um '-' no buffer e inverte o número
    mov byte [edi], '-'
    inc edi
    neg eax                 ; Transforma negativo em positivo matematicamente

.inicia_conversao:
    mov ebx, 10             ; Nosso divisor
    mov ecx, 0              ; Contador de dígitos na pilha

.loop_divide:
    cmp eax, 0              ; Acabou o número?
    je .desempilha          ; Se sim, vai para a montagem da string

    sub edx, edx            ; OBRIGATÓRIO: Zera EDX antes do 'div'
    div ebx                 ; Divide EDX:EAX por 10. EAX = Quociente, EDX = Resto!
    
    add dl, 30h             ; Converte o resto para ASCII ('0' a '9')
    push edx                ; Empilha o caractere (a divisão sai de trás pra frente)
    inc ecx                 ; Conta que guardamos um dígito
    jmp .loop_divide

.trata_zero:
    mov byte [edi], '0'
    inc edi
    jmp .finaliza_string

.desempilha:
    ; Tiramos da pilha de trás pra frente e colocamos no buffer
    cmp ecx, 0
    je .finaliza_string
    pop edx
    mov [edi], dl           ; Grava o caractere
    inc edi
    dec ecx
    jmp .desempilha

.finaliza_string:
    mov byte [edi], 10      ; Quebra de linha (\n)
    inc edi
    mov byte [edi], 0       ; Terminador de string (nulo)
    
    ; --- NOVIDADE: Calcular o tamanho exato da string ---
    mov eax, edi            ; EAX = ponteiro de memória atual (final da string)
    sub eax, [ebp + 8]      ; Subtrai o ponteiro inicial = Quantidade de bytes escritos!
    
    pop edi    ; Recupera Registrador de Extended Destination Index em [ebp-18]
    pop esi    ; Recupera Registrador de Stack Pointer em [ebp-16]
    pop edx    ; Recupera Registrador de Dados em [ebp-12]
    pop ecx    ; Recupera Registrador de Contador em [ebp-8]     
    pop ebx    ; Recupera Registrador de Base em [ebp-4]
    
    mov esp, ebp
    pop ebp
    ret

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
    mov eax, [menu_current]

    cmp eax, 1
    je .chama_soma
    cmp eax, 2
    je .chama_sub
    cmp eax, 3
    je .chama_mult
    cmp eax, 4
    je .chama_div
    cmp eax, 5
    je .chama_exp
    cmp eax, 6
    je .chama_mod
    cmp eax, 7
    je exec_sair

    jmp menu_anchor           ; Segurança contra erro de digitação

.chama_soma:
    call exec_soma
    jmp esperar_enter
.chama_sub:
    call exec_subtracao
    jmp esperar_enter
.chama_mult:
    call exec_multiplicacao
    jmp esperar_enter
.chama_div:
    call exec_divisao
    jmp esperar_enter
.chama_exp:
    call exec_exponenciacao
    jmp esperar_enter
.chama_mod:
    call exec_mod
    jmp esperar_enter

esperar_enter:
    ; -------------------------------------------------------------
    ; Item 41: Esperar o usuário digitar ENTER para voltar ao menu
    ; -------------------------------------------------------------
    push dword TAM_MSG_ENTER
    push msg_enter
    call print_string
    add esp, 8

    ; Lê algo inútil do teclado apenas para pausar a tela
    push dword 3
    push buffer_menu_current
    call read_string
    add esp, 8

    jmp menu_anchor         ; Agora sim, volta pro Menu!

; =================================================================
; BLOCOS DE EXECUÇÃO DAS OPERAÇÕES
; =================================================================
section .text

exec_soma:
    push ebp
    mov ebp, esp
    
    ; -------------------------------------------------------------
    ; ALOCAÇÃO LOCAL: O Mapa da Pilha
    ; [ebp - 4]  -> Guarda o num1 (4 bytes)
    ; [ebp - 8]  -> Guarda o num2 (4 bytes)
    ; [ebp - 12] -> Guarda o TAMANHO EXATO da string de saída (4 bytes)
    ; [ebp - 32] -> Guarda o buffer_resultado (20 bytes)
    ; TOTAL ALOCADO: 32 bytes!
    ; -------------------------------------------------------------
    sub esp, 32

    ; -------------------------------------------------------------
    ; 1. Pede o num1
    ; -------------------------------------------------------------
    push dword TAM_MSG_NUM1
    push msg_num1
    call pedir_numero
    add esp, 8
    mov [ebp - 4], eax      ; GUARDA NA VARIÁVEL LOCAL 1

    ; -------------------------------------------------------------
    ; 2. Pede o num2
    ; -------------------------------------------------------------
    push dword TAM_MSG_NUM2
    push msg_num2
    call pedir_numero
    add esp, 8
    mov [ebp - 8], eax      ; GUARDA NA VARIÁVEL LOCAL 2

    ; -------------------------------------------------------------
    ; 3. Empilha e chama o módulo de matemática
    ; -------------------------------------------------------------
    push dword [ebp - 8]    ; Empilha num2
    push dword [ebp - 4]    ; Empilha num1
    push dword [choice_precisao] 
    call calcular_soma      ; Chama a função externa
    add esp, 12

    ; -------------------------------------------------------------
    ; 4. Converte o Resultado (EAX) para String
    ; -------------------------------------------------------------
    push eax                ; Resultado matemático retornado no EAX
    lea edx, [ebp - 32]     ; Endereço do buffer local
    push edx
    call int_to_str
    add esp, 8

    ; A MÁGICA SEGURA: O EAX agora tem o tamanho exato. 
    ; Vamos guardar ele na nossa nova variável local!
    mov [ebp - 12], eax     

    ; -------------------------------------------------------------
    ; 5. Imprime "Resultado: "
    ; -------------------------------------------------------------
    push dword TAM_MSG_RESULTADO
    push msg_resultado
    call print_string
    add esp, 8

    ; -------------------------------------------------------------
    ; 6. Imprime o número com o tamanho cravado!
    ; -------------------------------------------------------------
    push dword [ebp - 12]   ; Puxa o tamanho exato da variável local
    lea edx, [ebp - 32]     ; Puxa o endereço do buffer local
    push edx
    call print_string
    add esp, 8

    ; Desfaz o Stack Frame local e volta para o _start
    mov esp, ebp
    pop ebp
    ret

exec_subtracao:
    push ebp
    mov ebp, esp
    
    ; -------------------------------------------------------------
    ; ALOCAÇÃO LOCAL: O Mapa da Pilha
    ; [ebp - 4]  -> Guarda o num1 (4 bytes)
    ; [ebp - 8]  -> Guarda o num2 (4 bytes)
    ; [ebp - 12] -> Guarda o TAMANHO EXATO da string de saída (4 bytes)
    ; [ebp - 32] -> Guarda o buffer_resultado (20 bytes)
    ; TOTAL ALOCADO: 32 bytes!
    ; -------------------------------------------------------------
    sub esp, 32

    ; -------------------------------------------------------------
    ; 1. Pede o num1
    ; -------------------------------------------------------------
    push dword TAM_MSG_NUM1
    push msg_num1
    call pedir_numero
    add esp, 8
    mov [ebp - 4], eax      ; GUARDA NA VARIÁVEL LOCAL 1

    ; -------------------------------------------------------------
    ; 2. Pede o num2
    ; -------------------------------------------------------------
    push dword TAM_MSG_NUM2
    push msg_num2
    call pedir_numero
    add esp, 8
    mov [ebp - 8], eax      ; GUARDA NA VARIÁVEL LOCAL 2

    ; -------------------------------------------------------------
    ; 3. Empilha e chama o módulo de matemática
    ; -------------------------------------------------------------
    push dword [ebp - 8]    ; Empilha num2
    push dword [ebp - 4]    ; Empilha num1
    push dword [choice_precisao] 
    call calcular_sub      ; Chama a função externa
    add esp, 12

    ; -------------------------------------------------------------
    ; 4. Converte o Resultado (EAX) para String
    ; -------------------------------------------------------------
    push eax                ; Resultado matemático retornado no EAX
    lea edx, [ebp - 32]     ; Endereço do buffer local
    push edx
    call int_to_str
    add esp, 8

    ; A MÁGICA SEGURA: O EAX agora tem o tamanho exato. 
    ; Vamos guardar ele na nossa nova variável local!
    mov [ebp - 12], eax     

    ; -------------------------------------------------------------
    ; 5. Imprime "Resultado: "
    ; -------------------------------------------------------------
    push dword TAM_MSG_RESULTADO
    push msg_resultado
    call print_string
    add esp, 8

    ; -------------------------------------------------------------
    ; 6. Imprime o número com o tamanho cravado!
    ; -------------------------------------------------------------
    push dword [ebp - 12]   ; Puxa o tamanho exato da variável local
    lea edx, [ebp - 32]     ; Puxa o endereço do buffer local
    push edx
    call print_string
    add esp, 8

    ; Desfaz o Stack Frame local e volta para o _start
    mov esp, ebp
    pop ebp
    ret

exec_multiplicacao:
        push ebp
    mov ebp, esp
    
    ; -------------------------------------------------------------
    ; ALOCAÇÃO LOCAL: O Mapa da Pilha
    ; [ebp - 4]  -> Guarda o num1 (4 bytes)
    ; [ebp - 8]  -> Guarda o num2 (4 bytes)
    ; [ebp - 12] -> Guarda o TAMANHO EXATO da string de saída (4 bytes)
    ; [ebp - 32] -> Guarda o buffer_resultado (20 bytes)
    ; TOTAL ALOCADO: 32 bytes!
    ; -------------------------------------------------------------
    sub esp, 32

    ; -------------------------------------------------------------
    ; 1. Pede o num1
    ; -------------------------------------------------------------
    push dword TAM_MSG_NUM1
    push msg_num1
    call pedir_numero
    add esp, 8
    mov [ebp - 4], eax      ; GUARDA NA VARIÁVEL LOCAL 1

    ; -------------------------------------------------------------
    ; 2. Pede o num2
    ; -------------------------------------------------------------
    push dword TAM_MSG_NUM2
    push msg_num2
    call pedir_numero
    add esp, 8
    mov [ebp - 8], eax      ; GUARDA NA VARIÁVEL LOCAL 2

    ; -------------------------------------------------------------
    ; 3. Empilha e chama o módulo de matemática
    ; -------------------------------------------------------------
    push dword [ebp - 8]    ; Empilha num2
    push dword [ebp - 4]    ; Empilha num1
    push dword [choice_precisao] 
    call calcular_mult      ; Chama a função externa
    add esp, 12

    ; -------------------------------------------------------------
    ; 4. Converte o Resultado (EAX) para String
    ; -------------------------------------------------------------
    push eax                ; Resultado matemático retornado no EAX
    lea edx, [ebp - 32]     ; Endereço do buffer local
    push edx
    call int_to_str
    add esp, 8

    ; A MÁGICA SEGURA: O EAX agora tem o tamanho exato. 
    ; Vamos guardar ele na nossa nova variável local!
    mov [ebp - 12], eax     

    ; -------------------------------------------------------------
    ; 5. Imprime "Resultado: "
    ; -------------------------------------------------------------
    push dword TAM_MSG_RESULTADO
    push msg_resultado
    call print_string
    add esp, 8

    ; -------------------------------------------------------------
    ; 6. Imprime o número com o tamanho cravado!
    ; -------------------------------------------------------------
    push dword [ebp - 12]   ; Puxa o tamanho exato da variável local
    lea edx, [ebp - 32]     ; Puxa o endereço do buffer local
    push edx
    call print_string
    add esp, 8

    ; Desfaz o Stack Frame local e volta para o _start
    mov esp, ebp
    pop ebp
    ret

exec_divisao:
        push ebp
    mov ebp, esp
    
    ; -------------------------------------------------------------
    ; ALOCAÇÃO LOCAL: O Mapa da Pilha
    ; [ebp - 4]  -> Guarda o num1 (4 bytes)
    ; [ebp - 8]  -> Guarda o num2 (4 bytes)
    ; [ebp - 12] -> Guarda o TAMANHO EXATO da string de saída (4 bytes)
    ; [ebp - 32] -> Guarda o buffer_resultado (20 bytes)
    ; TOTAL ALOCADO: 32 bytes!
    ; -------------------------------------------------------------
    sub esp, 32

    ; -------------------------------------------------------------
    ; 1. Pede o num1
    ; -------------------------------------------------------------
    push dword TAM_MSG_NUM1
    push msg_num1
    call pedir_numero
    add esp, 8
    mov [ebp - 4], eax      ; GUARDA NA VARIÁVEL LOCAL 1

    ; -------------------------------------------------------------
    ; 2. Pede o num2
    ; -------------------------------------------------------------
    push dword TAM_MSG_NUM2
    push msg_num2
    call pedir_numero
    add esp, 8
    mov [ebp - 8], eax      ; GUARDA NA VARIÁVEL LOCAL 2

    ; -------------------------------------------------------------
    ; 3. Empilha e chama o módulo de matemática
    ; -------------------------------------------------------------
    push dword [ebp - 8]    ; Empilha num2
    push dword [ebp - 4]    ; Empilha num1
    push dword [choice_precisao] 
    call calcular_div      ; Chama a função externa
    add esp, 12

    ; -------------------------------------------------------------
    ; 4. Converte o Resultado (EAX) para String
    ; -------------------------------------------------------------
    push eax                ; Resultado matemático retornado no EAX
    lea edx, [ebp - 32]     ; Endereço do buffer local
    push edx
    call int_to_str
    add esp, 8

    ; A MÁGICA SEGURA: O EAX agora tem o tamanho exato. 
    ; Vamos guardar ele na nossa nova variável local!
    mov [ebp - 12], eax     

    ; -------------------------------------------------------------
    ; 5. Imprime "Resultado: "
    ; -------------------------------------------------------------
    push dword TAM_MSG_RESULTADO
    push msg_resultado
    call print_string
    add esp, 8

    ; -------------------------------------------------------------
    ; 6. Imprime o número com o tamanho cravado!
    ; -------------------------------------------------------------
    push dword [ebp - 12]   ; Puxa o tamanho exato da variável local
    lea edx, [ebp - 32]     ; Puxa o endereço do buffer local
    push edx
    call print_string
    add esp, 8

    ; Desfaz o Stack Frame local e volta para o _start
    mov esp, ebp
    pop ebp
    ret

exec_exponenciacao:
        push ebp
    mov ebp, esp
    
    ; -------------------------------------------------------------
    ; ALOCAÇÃO LOCAL: O Mapa da Pilha
    ; [ebp - 4]  -> Guarda o num1 (4 bytes)
    ; [ebp - 8]  -> Guarda o num2 (4 bytes)
    ; [ebp - 12] -> Guarda o TAMANHO EXATO da string de saída (4 bytes)
    ; [ebp - 32] -> Guarda o buffer_resultado (20 bytes)
    ; TOTAL ALOCADO: 32 bytes!
    ; -------------------------------------------------------------
    sub esp, 32

    ; -------------------------------------------------------------
    ; 1. Pede o num1
    ; -------------------------------------------------------------
    push dword TAM_MSG_NUM1
    push msg_num1
    call pedir_numero
    add esp, 8
    mov [ebp - 4], eax      ; GUARDA NA VARIÁVEL LOCAL 1

    ; -------------------------------------------------------------
    ; 2. Pede o num2
    ; -------------------------------------------------------------
    push dword TAM_MSG_NUM2
    push msg_num2
    call pedir_numero
    add esp, 8
    mov [ebp - 8], eax      ; GUARDA NA VARIÁVEL LOCAL 2

    ; -------------------------------------------------------------
    ; 3. Empilha e chama o módulo de matemática
    ; -------------------------------------------------------------
    push dword [ebp - 8]    ; Empilha num2
    push dword [ebp - 4]    ; Empilha num1
    push dword [choice_precisao] 
    call calcular_exp      ; Chama a função externa
    add esp, 12

    ; -------------------------------------------------------------
    ; 4. Converte o Resultado (EAX) para String
    ; -------------------------------------------------------------
    push eax                ; Resultado matemático retornado no EAX
    lea edx, [ebp - 32]     ; Endereço do buffer local
    push edx
    call int_to_str
    add esp, 8

    ; A MÁGICA SEGURA: O EAX agora tem o tamanho exato. 
    ; Vamos guardar ele na nossa nova variável local!
    mov [ebp - 12], eax     

    ; -------------------------------------------------------------
    ; 5. Imprime "Resultado: "
    ; -------------------------------------------------------------
    push dword TAM_MSG_RESULTADO
    push msg_resultado
    call print_string
    add esp, 8

    ; -------------------------------------------------------------
    ; 6. Imprime o número com o tamanho cravado!
    ; -------------------------------------------------------------
    push dword [ebp - 12]   ; Puxa o tamanho exato da variável local
    lea edx, [ebp - 32]     ; Puxa o endereço do buffer local
    push edx
    call print_string
    add esp, 8

    ; Desfaz o Stack Frame local e volta para o _start
    mov esp, ebp
    pop ebp
    ret

exec_mod:
        push ebp
    mov ebp, esp
    
    ; -------------------------------------------------------------
    ; ALOCAÇÃO LOCAL: O Mapa da Pilha
    ; [ebp - 4]  -> Guarda o num1 (4 bytes)
    ; [ebp - 8]  -> Guarda o num2 (4 bytes)
    ; [ebp - 12] -> Guarda o TAMANHO EXATO da string de saída (4 bytes)
    ; [ebp - 32] -> Guarda o buffer_resultado (20 bytes)
    ; TOTAL ALOCADO: 32 bytes!
    ; -------------------------------------------------------------
    sub esp, 32

    ; -------------------------------------------------------------
    ; 1. Pede o num1
    ; -------------------------------------------------------------
    push dword TAM_MSG_NUM1
    push msg_num1
    call pedir_numero
    add esp, 8
    mov [ebp - 4], eax      ; GUARDA NA VARIÁVEL LOCAL 1

    ; -------------------------------------------------------------
    ; 2. Pede o num2
    ; -------------------------------------------------------------
    push dword TAM_MSG_NUM2
    push msg_num2
    call pedir_numero
    add esp, 8
    mov [ebp - 8], eax      ; GUARDA NA VARIÁVEL LOCAL 2

    ; -------------------------------------------------------------
    ; 3. Empilha e chama o módulo de matemática
    ; -------------------------------------------------------------
    push dword [ebp - 8]    ; Empilha num2
    push dword [ebp - 4]    ; Empilha num1
    push dword [choice_precisao] 
    call calcular_mod      ; Chama a função externa
    add esp, 12

    ; -------------------------------------------------------------
    ; 4. Converte o Resultado (EAX) para String
    ; -------------------------------------------------------------
    push eax                ; Resultado matemático retornado no EAX
    lea edx, [ebp - 32]     ; Endereço do buffer local
    push edx
    call int_to_str
    add esp, 8

    ; A MÁGICA SEGURA: O EAX agora tem o tamanho exato. 
    ; Vamos guardar ele na nossa nova variável local!
    mov [ebp - 12], eax     

    ; -------------------------------------------------------------
    ; 5. Imprime "Resultado: "
    ; -------------------------------------------------------------
    push dword TAM_MSG_RESULTADO
    push msg_resultado
    call print_string
    add esp, 8

    ; -------------------------------------------------------------
    ; 6. Imprime o número com o tamanho cravado!
    ; -------------------------------------------------------------
    push dword [ebp - 12]   ; Puxa o tamanho exato da variável local
    lea edx, [ebp - 32]     ; Puxa o endereço do buffer local
    push edx
    call print_string
    add esp, 8

    ; Desfaz o Stack Frame local e volta para o _start
    mov esp, ebp
    pop ebp
    ret

exec_sair:
    ; -------------------------------------------------------------
    ; FINALIZAÇÃO DO PROGRAMA
    ; -------------------------------------------------------------
    mov eax, 1               ; sys_exit
    mov ebx, 0               ; Status 0 (Sucesso)
    int 0x80