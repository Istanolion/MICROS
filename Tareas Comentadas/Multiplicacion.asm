	processor 16f877		  ;micro a usar
	include<p16f877.inc>	;libreria para ocupar nombres de registros
multiplo1 equ h'25'	
multiplo2 equ h'26'
resultado equ h'27'
	org 0					        ; vector de reset
	goto inicio				    ; ve al inicio del programa
 	org 5
inicio 
	clrf resultado
Primero
	movlw H'0'				    ; W <- H'0'
	subwf multiplo1,W		  ; W <- multiplo1 - W
	btfsc STATUS,Z			  ; Si la resta da 0, el primer multiplo es 0
	goto Zero				      ; Ve a zero
	movlw H'0'				    ; W <- multiplo2
	subwf multiplo2,W		  ; W <- multiplo2 - W
	btfsc STATUS,Z			  ; Si la resta da 0, el segundo multiplo es 0
	goto Zero				      ; Ve a zero
	goto Multiplicar		  ; Si no comprueba si alguno es cero ve a multiplicar
Zero
	movlw H'0'				    ; W <- H'0'
	movwf resultado			  ; resultado <- W
	goto Primero
Multiplicar
	movf multiplo1,0		  ; W <- multiplo1
	addwf resultado			  ; resultado <- W
	decf multiplo2			  ; decrementamos W
	movlw H'0'				    ; W <- H'0'
	subwf multiplo2, W		; W <- multiplo2 - W
	btfsc STATUS,Z			  ; Si multiplo2 es 0
	goto $				        ; Finaliza programa
	goto Multiplicar		  ; Si no, sigue sumando para seguir con la multiplicacion

	END                   ; Fin del programa

