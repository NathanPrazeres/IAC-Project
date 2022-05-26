DISPLAYS	EQU		0A000H
TEC_LIN		EQU		0C000H
TEC_COL		EQU		0E000H
MAX_LINHA	EQU		8
MASCARA		EQU		0FH
LINHA		EQU		1

PLACE		0

inicio:
	MOV		R2, TEC_LIN
	MOV		R3, TEC_COL
	MOV		R4, DISPLAYS
	MOV		R5, MASCARA

	MOV 	R8, 0				; contador extra
	MOV		R1, 0
	MOVB	[R4], R1

ciclo:
	MOV		R1, LINHA			; linha no teclado
	MOV		R6, MAX_LINHA
	SHL		R6, 1

	MOV 	R7, 0				; iniciar contador para tranformar teclas

espera_tecla:
	MOVB	[R2], R1
	MOVB	R0, [R3]
	AND		R0, R5

	CMP		R0, 0
	JNZ		continua

	SHL		R1, 1
	CMP		R1, R6
	JNZ		espera_tecla

	MOV		R1, LINHA
	JMP		espera_tecla

continua:
	MOV		R6, R1				; guardar a linha do botao pressionado

n_linha:              			; transforma linhas de 1,2,4,8 para 0,1,2,3
   	SHR 	R1, 1
   	JZ 		nova_linha
   	ADD 	R7, 1
   	JMP 	n_linha

nova_linha:
   	MOV 	R1, R7          	; atualiza linha
   	MOV 	R7, 0            	; reset contador

n_coluna:              			; transforma colunas de 1,2,4,8 para 0,1,2,3
    SHR 	R0, 1
    JZ 		nova_coluna
    ADD 	R7, 1
    JMP 	n_coluna

nova_coluna:
   	MOV 	R0, R7          	; atualiza coluna            		
   	MOV 	R7, 4				; Tecla = 4 * linha + coluna
   	MUL 	R1, R7
	ADD 	R1, R0  

	MOVB	[R4], R1

	MOV		R0, 0002H			; a tecla 2 adiciona 1 ao contador R8
	MOV 	R9, 0000H			; a tecla 0 remove 1 ao contador R8
	CMP 	R1, R0
	JZ	 	adiciona
	CMP		R1, R9
	JZ		subtrai
	JMP		ha_tecla

adiciona:
	ADD		R8, 1
	JMP		ha_tecla

subtrai:
	SUB		R8, 1

ha_tecla:						; HÁ UM BUG: SE CLICAR INSTANTANEAMENTE NUM OUTRO BOTAO DA MESMA LINHA, CONSIDERA O MESMO
	MOV		R1, R6
	MOVB	[R2], R1
	MOVB	R0, [R3]
	AND		R0, R5
	CMP		R0, 0
	JNZ		ha_tecla
	JMP		ciclo