
;------------------------MANEJO REGISTROS----------------------------
;--------------------------------------------------------------------
;Valor a Registro
;Descrp: Dar un valor directamente a un registro.
;------------------------------------
movlf 	macro	registro, valor
			local 	INIT
INIT:	movlw valor
		movwf registro
		endm
;------------------------------------

;Registro a Registro
;Descrp: Mover valor de un registro a otro directamente.
;------------------------------------
movff 	macro	origen,destino
			local 	INIT
INIT:	movf origen,W
		movwf destino
		endm
;------------------------------------
;--------------------------------------------------------------------




;----------------------COMPARACIONES CON SALTO-----------------------
;--------------------------------------------------------------------
;Saltar si r1 MENOR que un valor
;------------------------------------
jmenor 	macro	r1,valor,destino
			local 	INIT
INIT:	movlw valor
		subwf r1,W	
		btfss STATUS,C
		goto destino ;r1 es menor
		endm
;------------------------------------

;Saltar si r1 MENOR que r2
;------------------------------------
jmenorf 	macro	r1,r2,destino
			local 	INIT
INIT:	movf r2,W
		subwf r1,W	
		btfss STATUS,C
		goto destino ;r1 es menor
		endm
;------------------------------------


;Saltar si r1 MENOR/IGUAL que un valor
;------------------------------------
jmenori 	macro	r1,valor,destino
			local 	INIT
INIT:	movlw valor
		subwf r1,W
		btfsc STATUS,Z
		goto destino	
		btfss STATUS,C
		goto destino ;r1 es menor
		endm
;------------------------------------

;Saltar si r1 MENOR/IGUAL que r2
;------------------------------------
jmenorif 	macro	r1,r2,destino
			local 	INIT
INIT:	movf r2,W
		subwf r1,W
		btfsc STATUS,Z
		goto destino	
		btfss STATUS,C
		goto destino ;r1 es menor
		endm
;------------------------------------

;Saltar si r1 MAYOR que un valor
;------------------------------------
jmayor 	macro	r1,valor,destino
			local 	INIT
INIT:	movlw valor
		subwf r1,W	
		btfsc STATUS,C
		goto destino ;r1 es mayor
		endm
;------------------------------------

;Saltar si r1 MAYOR que r2
;------------------------------------
jmayorf 	macro	r1,r2,destino
			local 	INIT
INIT:	movf r2,W
		subwf r1,W	
		btfsc STATUS,C
		goto destino ;r1 es mayor
		endm
;------------------------------------

;Saltar si r1 MAYOR/IGUAL que un valor
;------------------------------------
jmayori 	macro	r1,valor,destino
			local 	INIT
INIT:	movlw valor
		subwf r1,W	
		btfsc STATUS,Z
		goto destino
		btfsc STATUS,C
		goto destino ;r1 es mayor
		endm
;------------------------------------

;Saltar si r1 MAYOR/IGUAL que r2
;------------------------------------
jmayorif 	macro	r1,r2,destino
			local 	INIT
INIT:	movf r2,W
		subwf r1,W	
		btfsc STATUS,Z
		goto destino
		btfsc STATUS,C
		goto destino ;r1 es mayor
		endm
;------------------------------------


;Saltar si r1 y un valor son IGUALES.
;------------------------------------
jigual 	macro	r1,valor,destino
			local 	INIT
INIT:	movlw valor
		subwf r1,W	
		btfsc STATUS,Z
		goto destino
		endm
;------------------------------------

;Saltar si r1 y r2 son IGUALES.
;------------------------------------
jigualf 	macro	r1,r2,destino
			local 	INIT
INIT:	movf r2,W
		subwf r1,W	
		btfsc STATUS,Z
		goto destino
		endm
;------------------------------------

;Saltar si r1 y un valor son DIFERENTES.
;------------------------------------
jdif 	macro	r1,valor,destino
			local 	INIT
INIT:	movlw valor
		subwf r1,W	
		btfss STATUS,Z
		goto destino
		endm
;------------------------------------

;Saltar si r1 y r2 son DIFERENTES.
;------------------------------------
jdiff 	macro	r1,r2,destino
			local 	INIT
INIT:	movf r2,W
		subwf r1,W	
		btfss STATUS,Z
		goto destino
		endm
;------------------------------------
;--------------------------------------------------------------------



;-----------------------------OPERACIONES----------------------------
;--------------------------------------------------------------------
;SUMA num1+num2
;------------------------------------
addff 	macro	num1,num2,resultado
			local 	INIT
INIT:	movf num2,W	
		addwf num1,W
		movwf resultado
		endm
;------------------------------------

;SUMA num1+valor
;------------------------------------
addlf 	macro	num1,valor,resultado
			local 	INIT
INIT:	movlw valor	
		addwf num1,W
		movwf resultado
		endm
;------------------------------------

;RESTA num1-num2
;------------------------------------
subff	macro	num1,num2,resultado
			local 	INIT
INIT:	movf num2,W	
		subwf num1,W
		movwf resultado
		endm
;------------------------------------

;RESTA num1-valor
;------------------------------------
sublf	macro	num1,valor,resultado
			local 	INIT
INIT:	movlw valor	
		subwf num1,W
		movwf resultado
		endm
;------------------------------------

;MULTIPLICACION num1*num2
;------------------------------------
mulf 	macro	num1,num2,resultado
			local 	INIT,MULTIPLICAR
INIT:	movlf resultado,h'0'	
MULTIPLICAR:
		movf num1,W
		addwf resultado,F
		decf num2
		btfss STATUS,2
		goto MULTIPLICAR
		endm
;------------------------------------

;MULTIPLICACION num1*valor
;------------------------------------
mullf 	macro	num1,valor,resultado
			local 	INIT,MULTIPLICAR
INIT:	movlf resultado,h'0'
MULTIPLICAR:
		addlf resultado,valor,resultado
		decf num1
		btfss STATUS,2
		goto MULTIPLICAR
		endm
;------------------------------------

;DIVISION num1/num2
;------------------------------------
divf 	macro	num1,num2,resultado,residuo
			local 	INIT,DIVIDIR,FIN
INIT:	movlf resultado,h'0'
		jmayorif num1,num2,DIVIDIR
		movff num1,residuo
		goto FIN
DIVIDIR:
		movf num2,W
		subwf num1,F
		incf resultado
		jmayorif num1,num2,DIVIDIR
FIN:	movff num1,residuo	
		endm
;------------------------------------

;DIVISION num1/valor
;------------------------------------
divlf 	macro	num1,valor,resultado,residuo
			local 	INIT,DIVIDIR,FIN
INIT:	movlf resultado,h'0'
		jmayori num1,valor,DIVIDIR
		movff num1,residuo
		goto FIN
DIVIDIR:
		movlw valor
		subwf num1,F
		incf resultado
		jmayori num1,valor,DIVIDIR
FIN:	movff num1,residuo	
		endm
;------------------------------------
;--------------------------------------------------------------------



;-----------------------------CONVERSIORES----------------------------

;--------------------------------------------------------------------
;Convertir de HEX TO DEC
;------------------------------------
hextodec macro hexa,decH,decL
	local INIT
residuo equ h'70'
temp equ h'71'
INIT: 	divlf hexa,d'100',decH,residuo
		divlf residuo,d'10',decL,residuo
		swapf decL
		divlf residuo,d'1',temp,residuo
		addff decL,temp,decL
		endm
;------------------------------------


