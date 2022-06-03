; *********************************************************************************
;	1º entrega do Projeto de IAC 2022
;	Trabalho realizado por:
;		-> Nathaniel Prazeres
;		-> João Nogueira
;		-> Guilherme Peixoto
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
DISPLAY					EQU	0A000H
TEC_LIN					EQU	0C000H		; endereço das linhas do teclado (periférico POUT-2)
TEC_COL					EQU	0E000H		; endereço das colunas do teclado (periférico PIN)
MAX_TECLADO				EQU	16			; linha a testar (4ª linha, 1000b)
MASCARA					EQU	0FH			; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; Teclas para controlo do jogo
TECLA_ESQUERDA			EQU	0			
TECLA_DIREITA			EQU	2			
TECLA_MOVE_INIMIGO		EQU	3			
TECLA_DIMINUI			EQU	4			 
TECLA_AUMENTA			EQU	5			

DEFINE_LINHA			EQU	600AH		; endereço do comando para definir a linha
DEFINE_COLUNA			EQU	600CH		; endereço do comando para definir a coluna
DEFINE_PIXEL			EQU	6012H		; endereço do comando para escrever um pixel
APAGA_AVISO				EQU	6040H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRA				EQU	6002H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO	EQU	6042H		; endereço do comando para selecionar uma imagem de fundo
SELECIONA_SOM			EQU	6048H		; endereço do comando para selecionar o som a reproduzir
REPRODUZ_SOM			EQU	605AH		; endereço do comando para reproduzir o som selecionado

CENARIO_JOGO			EQU	0

LINHA_PLAYER			EQU	27			; linha do boneco (a meio do ecrã))
COLUNA_PLAYER			EQU	30			; coluna do boneco (a meio do ecrã)

LINHA_INIMIGO			EQU	0			; linha do inimigo
COLUNA_INIMIGO			EQU	10			; coluna do inimigo

LARGURA					EQU	5			; largura do boneco
ALTURA					EQU	5			; altura do boneco

DIMENSAO_METEORO_1		EQU 1			; dimensão do meteoro distante (1 x 1)

DIMENSAO_METEORO_2		EQU 2			; dimensão do meteoro a aproximar-se (2 x 2)

DIMENSAO_METEORO_3		EQU 3			; dimensão do meteoro já visivel (3 x 3)

DIMENSAO_METEORO_4		EQU 4			; dimensão do meteoro perto (4 x 4)

DIMENSAO_METEORO_FINAL	EQU 5			; dimensão do meteoro final (5 x 5)


MIN_COLUNA				EQU	0			; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA				EQU	63			; número da coluna mais à direita que o objeto pode ocupar
ATRASO					EQU	1000H		; atraso para limitar a velocidade de movimento do boneco


; *********************************************************************************
; * Cores :
; *********************************************************************************

; Cores nave:
VERMELHO_PRETO			EQU	0F300H
VERMELHO_ESCURO			EQU	0F800H		
VERMELHO_MEDIO			EQU	0FC00H
VERMELHO				EQU 0FF00H
DOURADO					EQU	0FFC0H

;Cores inimigo:
ROXO_PRETO				EQU 0F303H
ROXO_ESCURO				EQU 0F808H
ROXO_MEDIO				EQU 0FC0CH
ROXO_FORTE				EQU	0FF0FH
ROXO_BACO				EQU 09F0FH
ROXO_TRANS				EQU 04F0FH
ROXO_BRANCO				EQU 0FF6FH

;Cores amigo:
AMARELO_PRETO			EQU 0F303H
AMARELO_ESCURO			EQU	0F880H
AMARELO_MEDIO			EQU	0FCC0H
AMARELO_FORTE			EQU 0FFF0H
AMARELO_TRANS			EQU	03FF0H
AMARELO_BACO			EQU	09FF0H
AMARELO_BRANCO			EQU	0FFF7H

;Cores extra:
VERDE					EQU 0F0F0H
AZUL					EQU	0F00FH
BRANCO					EQU 0FFFFH
PRETO					EQU 0F000H


; *********************************************************************************
; * Dados 
; >> R11 e R12 não podem ser usados <<
; *********************************************************************************

	PLACE	1000H
pilha:
	STACK	200H			; espaço reservado para a pilha 
							; (400H bytes, pois são 200H words)
SP_inicial:					; este é o endereço (1400H) com que o SP deve ser 
							; inicializado. O 1.º end. de retorno será 
							; armazenado em 13FEH (1400H-2)

linha_boneco:				; linha em que cada boneco está (inicializada com a linha inicial)
	WORD		LINHA_PLAYER
	WORD		LINHA_INIMIGO
                              
coluna_boneco:				; coluna em que cada boneco está (inicializada com a coluna inicial)
	WORD		COLUNA_PLAYER
	WORD		COLUNA_INIMIGO
							
DEF_PLAYER:					; tabela que define o boneco (altura, largura, pixels)
	WORD		LARGURA
	WORD		ALTURA
	WORD		0, 0, VERMELHO, 0, 0								
	WORD		0, 0, VERMELHO_MEDIO, 0, 0								; display das cores do jogador
	WORD		VERMELHO_MEDIO, 0, VERMELHO_ESCURO, 0, VERMELHO_MEDIO
	WORD		VERMELHO_PRETO, DOURADO, VERMELHO_PRETO, DOURADO, VERMELHO_PRETO
	WORD		0, PRETO, 0, PRETO, 0

; Modelo dos meteoros inimigos:

DEF_INIMIGO_LONGE:			; tabela que define o inimigo longe (dimensão, pixels)
	WORD 				DIMENSAO_METEORO_1
	WORD				ROXO_TRANS

DEF_INIMIGO_PEQUENO:		; tabela que define o inimigo pequeno (dimensão, pixels)
	WORD				DIMENSAO_METEORO_2
	WORD				ROXO_BACO, ROXO_BACO
	WORD				ROXO_BACO, ROXO_BACO

DEF_INIMIGO_MEDIO:			; tabela que define o inimigo médio (dimensão, pixels)
	WORD				DIMENSAO_METEORO_3
	WORD				ROXO_PRETO, ROXO_PRETO, ROXO_PRETO
	WORD				ROXO_ESCURO, PRETO, ROXO_ESCURO
	WORD 				ROXO_MEDIO, ROXO_MEDIO, ROXO_MEDIO

DEF_INIMIGO_4:				; tabela que define o inimigo na penúltima fase (dimensão, pixels)
	WORD				DIMENSAO_METEORO_4
	WORD				ROXO_PRETO, ROXO_PRETO, ROXO_PRETO, ROXO_PRETO
	WORD				ROXO_ESCURO, ROXO_ESCURO, ROXO_ESCURO, ROXO_ESCURO
	WORD				ROXO_MEDIO, ROXO_MEDIO, ROXO_MEDIO, ROXO_MEDIO
	WORD				ROXO_FORTE, ROXO_FORTE, ROXO_FORTE, ROXO_FORTE

DEF_INIMIGO_GRANDE:			; tabela que define o inimigo final (altura, largura, pixels)
	WORD				DIMENSAO_METEORO_FINAL
	WORD				DIMENSAO_METEORO_FINAL
	WORD				0, ROXO_PRETO, ROXO_PRETO, ROXO_PRETO, 0
	WORD				ROXO_PRETO, ROXO_ESCURO, ROXO_ESCURO, ROXO_ESCURO, ROXO_PRETO
	WORD				ROXO_ESCURO, ROXO_MEDIO, BRANCO, ROXO_MEDIO, ROXO_ESCURO
	WORD				ROXO_MEDIO, ROXO_FORTE, ROXO_FORTE, ROXO_FORTE, ROXO_MEDIO
	WORD				0, ROXO_BRANCO, ROXO_BRANCO, ROXO_BRANCO, 0

; Modelos dos meteoros bons:

DEF_BOM_LONGE:				; tabela que define o meteoro bom longe (dimensão, pixels)
	WORD				DIMENSAO_METEORO_1
	WORD				AMARELO_TRANS

DEF_BOM_PEQUENO:			; tabela que define o meteoro bom pequeno (dimensão, pixels)
	WORD				DIMENSAO_METEORO_2
	WORD				AMARELO_BACO, AMARELO_BACO
	WORD				AMARELO_BACO, AMARELO_BACO

DEF_BOM_MEDIO:				; tabela que define o meteoro bom médio (dimensão, pixels)
	WORD 				DIMENSAO_METEORO_3
	WORD				AMARELO_FORTE, AMARELO_BRANCO, AMARELO_FORTE
	WORD				AMARELO_BRANCO, BRANCO, AMARELO_BRANCO
	WORD				AMARELO_FORTE, AMARELO_BRANCO, AMARELO_FORTE

DEF_BOM_MEDIO_4:			; tabela que define o meteoro bom na penúltima fase (dimensão, pixels)
	WORD				DIMENSAO_METEORO_4
	WORD				0, AMARELO_FORTE, AMARELO_FORTE, 0
	WORD				AMARELO_FORTE, AMARELO_BRANCO, AMARELO_BRANCO, AMARELO_FORTE
	WORD				AMARELO_FORTE, AMARELO_BRANCO, AMARELO_BRANCO, AMARELO_FORTE
	WORD				0, AMARELO_FORTE, AMARELO_FORTE, 0


DEF_BOM_GRANDE:				; tabela que define o meteoro bom final (altur, largura, pixels)
	WORD				DIMENSAO_METEORO_FINAL
	WORD				DIMENSAO_METEORO_FINAL
	WORD				0, AMARELO_FORTE, AMARELO_FORTE, AMARELO_FORTE, 0
	WORD				AMARELO_FORTE, AMARELO_BRANCO, AMARELO_BRANCO, AMARELO_BRANCO, AMARELO_FORTE
	WORD				AMARELO_FORTE, AMARELO_BRANCO, BRANCO, AMARELO_BRANCO, AMARELO_FORTE
	WORD				AMARELO_FORTE, AMARELO_BRANCO, AMARELO_BRANCO, AMARELO_BRANCO, AMARELO_FORTE
	WORD				0, AMARELO_FORTE, AMARELO_FORTE, AMARELO_FORTE, 0


; *********************************************************************************
; * Código
; *********************************************************************************
	PLACE	0								; o código tem de começar em 0000H
inicio:
	MOV		SP, SP_inicial					; inicializa SP para a palavra a seguir à última da pilha
                            
    MOV		[APAGA_AVISO], R1				; apaga o aviso de nenhum cenário selecionado
	MOV		[APAGA_ECRA], R1				; apaga o ecrã
	MOV		R1, CENARIO_JOGO				; cenário do jogo
    MOV		[SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	MOV		R1, 0
	MOV		[DISPLAY], R1					; mete no display o cenário
	MOV		R11, 0


bonecos_iniciais:
	MOV		R1, LINHA_INIMIGO				; linha do inimigo
	MOV		R2, COLUNA_INIMIGO				; coluna do inimigo
	MOV		R4, DEF_BOM_GRANDE				; endereço da tabela que define o inimigo
	CALL	desenha_boneco					; desenha o inimigo

    MOV		R1, LINHA_PLAYER				; linha do boneco
    MOV		R2, COLUNA_PLAYER				; coluna do boneco
	MOV		R4, DEF_PLAYER					; endereço da tabela que define o boneco

mostra_boneco:
	CALL	desenha_boneco					; desenha o boneco a partir da tabela

espera_tecla:								; neste ciclo espera-se até uma tecla ser premida
	CALL	teclado							; leitura às teclas
	CMP		R0, -1			
	JZ		espera_tecla					; continua a ler até uma tecla ser selecionada

testa_esquerda:
	MOV		R7, TECLA_ESQUERDA
	CMP		R0, R7
	JNZ		testa_direita
	MOV		R7, -1							; vai deslocar para a esquerda
	CALL	atraso
	JMP		ve_limites

testa_direita:
	MOV		R7, TECLA_DIREITA
	CMP		R0, R7
	JNZ		diminui_display
	MOV		R7, +1							; vai deslocar para a direita
	CALL	atraso
	JMP		ve_limites

diminui_display:							; vai diminuir o numero no display de sete segmentos
	MOV		R7, TECLA_DIMINUI
	CMP		R0, R7
	JNZ		aumenta_display
	SUB		R11, 5
	MOV		[DISPLAY], R11					; subtrair 5 ao valor no display
	CALL	pressionada
	JMP		espera_tecla

aumenta_display:							; vai aumentar o numero no display de sete segmentos
	MOV		R7, TECLA_AUMENTA
	CMP		R0, R7
	JNZ		move_inimigo
	ADD		R11, 5
	MOV		[DISPLAY], R11					; adiciona 5 ao valor no display
	CALL	pressionada
	JMP		espera_tecla


move_inimigo:								; move o meteoro inimigo para baixo
	MOV		R7, TECLA_MOVE_INIMIGO
	CMP		R0, R7
	JNZ		espera_tecla
	CALL	move_boneco_baixo
	CALL	pressionada						; impede o inimigo de ser movido continuamente se a tecla for premida
	JMP		espera_tecla

ve_limites:
	MOV		R6, [R4]						; obtém a largura do boneco
	CALL	testa_limites					; vê se chegou aos limites do ecrã e se sim força R7 a 0 (o que impede o movimento)
	CMP		R7, 0
	JZ		espera_tecla					; se não é para movimentar o objeto, vai ler o teclado de novo

move_boneco:
	CALL	apaga_boneco					; apaga o boneco na sua posição corrente
	
coluna_seguinte:
	ADD		R2, R7							; para desenhar objeto na coluna seguinte (direita ou esquerda)

	JMP		mostra_boneco					; vai desenhar o boneco de novo


; **********************************************************************
; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************

desenha_boneco:
	PUSH 	R1
	PUSH	R2
	PUSH	R3								; põe os registos necessário no stack
	PUSH	R4
	PUSH	R5
	PUSH	R6
	MOV		R5, [R4]						; obtém a largura do boneco
	ADD		R4, 2							; passa para a próxima word 
	MOV		R6, [R4]						; altura do boneco
	ADD		R4, 2							; passa para a próxima word 

desenha_pixels:       						; desenha os pixels do boneco a partir da tabela
	MOV		R3, [R4]						; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel					; escreve cada pixel do boneco
	ADD		R4, 2							; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD		R2, 1               			; próxima coluna
    SUB		R5, 1							; menos uma coluna para tratar
    JNZ		desenha_pixels      			; continua até percorrer toda a largura do objeto
	SUB		R2, LARGURA						; dá reset ao contador a 0
	ADD		R5, LARGURA						; adiciona de volta a largura das colunas que são precisas tratar
	ADD		R1, 1							; próxima linha
	SUB		R6, 1							; menos uma linha para tratar
	JNZ		desenha_pixels					; continua a percorrer a largura até não haverem mais linhas para tratar
	POP		R6
	POP		R5
	POP		R4
	POP		R3								; retira os registos do stack
	POP		R2
	POP		R1
	RET

; **********************************************************************
; APAGA_BONECO - Apaga um boneco na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************

apaga_boneco:
	PUSH 	R1
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH	R6
	MOV		R5, [R4]						; obtém a largura do boneco
	ADD		R4, 2							; endereço da cor do 1º pixel (2 porque a largura é uma word)
	MOV		R6, [R4]						; obtém a altura do boneco
	ADD		R4, 2							; endereço da cor do 1º pixel (2 porque a largura é uma word)

apaga_pixels:       						; desenha os pixels do boneco a partir da tabela
	MOV		R3, 0							; cor para apagar o próximo pixel do boneco
	CALL	escreve_pixel					; escreve cada pixel do boneco
	ADD		R4, 2							; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD		R2, 1               			; próxima coluna
    SUB		R5, 1							; menos uma coluna para tratar
    JNZ		apaga_pixels   	    			; continua até percorrer toda a largura do objeto
	SUB		R2, LARGURA						; dá reset ao contador
	ADD		R5, LARGURA						; volta a adicionar as colunas que são precisas apagar
	ADD		R1, 1							; mais uma linha apagada
	SUB		R6, 1							; menos uma linha para tratar
	JNZ		apaga_pixels					; continua a percorrer a figura em altura até apagar tudo
	POP		R6
	POP		R5
	POP		R4
	POP		R3								; retira os registos do stack
	POP		R2
	POP		R1
	RET


; **********************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; **********************************************************************
escreve_pixel:
	MOV		[DEFINE_LINHA], R1				; seleciona a linha
	MOV		[DEFINE_COLUNA], R2				; seleciona a coluna
	MOV		[DEFINE_PIXEL], R3				; altera a cor do pixel na linha e coluna já selecionadas
	RET

; **********************************************************************
; ATRASO - Executa um ciclo para implementar um atraso.
; Argumentos:   R11 - valor que define o atraso
;
; **********************************************************************
atraso:
	PUSH	R11
	MOV		R11, ATRASO

ciclo_atraso:
	SUB		R11, 1
	JNZ		ciclo_atraso
	POP		R11
	RET

; **********************************************************************
; TESTA_LIMITES - Testa se o boneco chegou aos limites do ecrã e nesse caso
;			   impede o movimento (força R7 a 0)
; Argumentos:	R2 - coluna em que o objeto está
;			R6 - largura do boneco
;			R7 - sentido de movimento do boneco (valor a somar à coluna
;				em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: 	R7 - 0 se já tiver chegado ao limite, inalterado caso contrário	
; **********************************************************************
testa_limites:
	PUSH	R5
	PUSH	R6

testa_limite_esquerdo:						; vê se o boneco chegou ao limite esquerdo
	MOV		R5, MIN_COLUNA
	CMP		R2, R5
	JGT		testa_limite_direito
	CMP		R7, 0							; passa a deslocar-se para a direita
	JGE		sai_testa_limites
	JMP		impede_movimento				; entre limites. Mantém o valor do R7

testa_limite_direito:						; vê se o boneco chegou ao limite direito
	ADD		R6, R2							; posição a seguir ao extremo direito do boneco
	MOV		R5, MAX_COLUNA
	CMP		R6, R5
	JLE		sai_testa_limites				; entre limites. Mantém o valor do R7
	CMP		R7, 0							; passa a deslocar-se para a direita
	JGT		impede_movimento
	JMP		sai_testa_limites

impede_movimento:
	MOV		R7, 0							; impede o movimento, forçando R7 a 0

sai_testa_limites:
	POP		R6
	POP		R5
	RET



move_boneco_baixo:
	PUSH	R1
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	MOV		R3, linha_boneco				; obtem endereço de tabela de posicoes (linha) dos bonecos
	MOV		R5, coluna_boneco				; obtem endereço de tabela de posicoes (coluna) dos bonecos
	MOV		R1, [R3+2]						; obtem a linha do boneco inimigo
	MOV		R2, [R5+2]						; obtem a coluna do boneco inimigo
	MOV		R4, DEF_BOM_GRANDE				; obtem tabela que define o boneco
	CALL	apaga_boneco		
	ADD		R1, 1							; obtem próxima linha
	MOV		[R3+2], R1						; regista proxima linha
	CALL	desenha_boneco					; desenha boneco na nova posicao
	MOV		R1, 0
	MOV		[SELECIONA_SOM], R1 			; obtem som do boneco a movimentar-se
	MOV		[REPRODUZ_SOM], R1	
	POP		R5
	POP		R4
	POP		R3
	POP		R2
	POP		R1
	RET

; **********************************************************************
; TECLADO - Faz uma leitura às teclas de uma linha do teclado e retorna o valor lido
; Argumentos:	R6 - linha a testar (em formato 1, 2, 4 ou 8)
;
; Retorna: 	R0 - valor lido das colunas do teclado (1, 2, 4, ou 8)	
; **********************************************************************
teclado:
	PUSH	R2
	PUSH	R3
	PUSH	R5
	PUSH 	R6
	PUSH 	R7
	MOV	 	R2, TEC_LIN   					; endereço do periférico das linhas
	MOV	 	R3, TEC_COL   					; endereço do periférico das colunas
	MOV	 	R5, MASCARA   					; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOV		R6, MAX_TECLADO


loop_teclado:
	SHR		R6, 1
	JZ		nenhuma							; se chegar ao fim do loop e nenhuma tecla for premida

	MOVB 	[R2], R6      					; a linha a ler passa a ser a do registo R6
	MOVB 	R0, [R3]      					; ler do periférico de entrada (colunas)
	
	AND		R0, R5        					; elimina bits para além dos bits 0-3
	JNZ		fim_teclado						; se alguma tecla for premida quebra o loop
	
	JMP		loop_teclado

nenhuma:
	MOV		R0, -1							; quando nenhuma tecla está selecionada mete R0 a -1
	JMP		skip

fim_teclado:
	CALL	converte_tec_hexa

skip:
	POP		R7
	POP		R6
	POP		R5
	POP		R3
	POP		R2
	RET


converte_tec_hexa:
	PUSH	R6
	PUSH	R7

	MOV		R7, 0

n_linha:              						; transforma linhas de 1,2,4,8 para 0,1,2,3
   	SHR		R6, 1
   	JZ		nova_linha
   	ADD		R7, 1
   	JMP		n_linha

nova_linha:
   	MOV		R6, R7          				; atualiza linha

   	MOV		R7, 0            				; reset contador

n_coluna:              						; transforma colunas de 1,2,4,8 para 0,1,2,3
    SHR		R0, 1
    JZ		nova_coluna
    ADD		R7, 1
    JMP		n_coluna

nova_coluna:
   	MOV		R0, R7          				; atualiza coluna
      		
   	MOV		R7, 4
   	MUL		R6, R7
	ADD		R0, R6  						; Tecla = 4 * linha + coluna

	POP		R7
	POP		R6
	RET


pressionada:
	PUSH	R0
	PUSH	R3
	MOV		R3, -1

loop_pressionada:
	CALL	teclado
	CMP		R0, R3							; o loop mantêm-se até a tecla ser largada
	JNZ		loop_pressionada

	POP		R3
	POP		R0
	RET
