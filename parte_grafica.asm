; *********************************************************************************
; * IST-UL
; * Modulo:    lab4-comandos-xadrez.asm
; * Descrição: Este programa ilustra o funcionamento do ecrã, em que os pixels
; *            são escritos por meio de comandos.
; *            Desenha um padrão de xadrez no ecrã, preenchendo todos os pixels.
; *			Tem dois ciclos um dentro do outro (ciclo das colunas dentro do ciclo das linhas)
; *			Troca a cor do pixel, pixel sim, pixel não 
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
DEFINE_LINHA    		EQU 600AH      ; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH      ; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H      ; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU 6040H      ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		EQU 6002H      ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU 6042H      ; endereço do comando para selecionar uma imagem de fundo

LINHA                    EQU    25      ; linha onde se começa a desenhar a nave
COLUNA                   EQU    45      ; coluna onde se começa a desenhar a nave

N_LINHAS        EQU  32        ; número de linhas do ecrã (altura)
N_COLUNAS       EQU  64        ; número de colunas do ecrã (largura)

COR_PIXEL       EQU 0FF00H     ; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)

; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H
pilha:
	STACK 100H			; espaço reservado para a pilha 
						; (200H bytes, pois são 100H words)
SP_inicial:				; este é o endereço (1200H) com que o SP deve ser 
						; inicializado. O 1.º end. de retorno será 
						; armazenado em 11FEH (1200H-2)
							
DEF_BONECO:				; tabela que define o boneco (cor, largura, pixels)
	WORD		LARGURA
	WORD		COR_PIXEL, 0, COR_PIXEL, 0, COR_PIXEL		; # # #   as cores podem ser diferentes

; *********************************************************************************
; * Código
; *********************************************************************************
PLACE   0                     ; o código tem de começar em 0000H


inicio:
	MOV  SP, SP_inicial		; inicializa SP para a palavra a seguir
						; à última da pilha
                            
	MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 0			; cenário de fundo número 0
	MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
     
     MOV  R1, LINHA			; linha do boneco
	MOV  R2, COLUNA		; coluna do boneco
	MOV	R4, DEF_BONECO		; endereço da tabela que define o boneco
	CALL	desenha_boneco		; desenha o boneco

fim:
	JMP  fim                 ; termina programa



;inicio:
;     MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
;     MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
;	MOV	R1, 0			; cenário de fundo número 0
;     MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
;     
;     MOV  R6, 0               ;contador de colunas a meter pixeis
;     MOV  R7, 0               ;contador de linhas a meter pixeis
;     MOV  R3, 0               ; primeiro pixel a 0                   
;     MOV  R1, 0               ; linha corrente

proxima_linha:       		; escreve os pixels na linha corrente
     MOV  R2, 0               ; coluna corrente
     MOV  R6, 0               ; dar reset ao contador das colunas
     ADD  R7, 1
     CMP  R7, 3
     ;MOV  R7, 0               ; dar reset ao contador das linhas
     JZ   fim

poe_cor:    
	MOV  R3, COR_PIXEL		; pixel com cor
     ADD  R6, 1
     CMP  R6, 3
     JGE  fim_linha
	JMP  proxima_coluna

proxima_coluna:       		; escreve o pixel na coluna corrente
	MOV  [DEFINE_LINHA], R1	; seleciona a linha
	MOV  [DEFINE_COLUNA], R2	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	; altera a cor do pixel na linha e coluna selecionadas
     ADD  R2, 2               ; próxima coluna
     MOV  R5, N_COLUNAS
     CMP  R2, R5              ; chegou à última coluna?
     JGE  fim_linha
troca_cor:           		; troca a cor, de 0 para COR_PIXEL ou vice-versa
	CMP  R3, 0			; se a cor é 0, vai alterar a cor para COR_PIXEL. Se não, põe a 0.
	JZ   poe_cor
	MOV  R3, 0			; pixel desligado
	JMP  proxima_coluna
	
fim_linha:
     ADD  R1, 1               ; próxima linha
     MOV  R4, N_LINHAS
     CMP  R1, R4              ; chegou à última linha?
     JNZ  proxima_linha

;corpo:
;     ADD R2, 1                ; adiciona 1 à coluna
;     JMP troca_cor

fim:
     JMP  fim                 ; termina programa

;descobrir como construir o corpo da nave