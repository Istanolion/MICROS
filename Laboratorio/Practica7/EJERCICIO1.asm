	processor 16f877		; micro a usar
	include<p16f877.inc>	; libreria para ocupar nombres de registros

;Variables para el DELAY
valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
cte1 equ 10h 
cte2 equ 50h
cte3 equ 60h



	org 0					; vector de reset
	GOTO inicio				; ve al inicio del programa
 	org 5
inicio 						; Etiqueta de inicio de programa
	CLRF PORTB				; LIMPIAMOS EL PORTB QUE OCUPAREMOS PARA LOS LEDS
	CLRF PORTC				;Limpiamos el PORTC (solo se ocuparan RC6 y RC7)
	;RC6 Transmission RC7 Reception
	BSF STATUS,5			; Ponemos un 1 en el bit 5 de STATUS (RP0)
 	BCF STATUS,6 			; Ponemos un 0 en el bit 6 de STATUS (RP1) para cambiar de banco 0 al 1
	MOVLW H'00'				; W <- h'00' B'00000000' We need outputs. high is input_low is output
	MOVWF TRISB				; TRISB <- (W) configuramos PORTB como SALIDA
	
	BSF	TXSTA,2				; Ponemos el valor de BRGH seleccionando la velocidad ALTA
	;PONEMOS Y MANDAMOS EL VALOR DEL BAUD AL REGISTRO CORRESPONDIENTE
	MOVLW .32
	MOVWF SPBRG
	;
	BCF TXSTA,4				; Ponemos la comunicacion asincrona
	BSF TXSTA,5				; Habilitamos la transmision
	BCF STATUS,5			; regresar al banco 0 poniendo el bit 5 de STATUS (RP0) en 0
	BSF RCSTA,4				; Habilitamos la comunicacion continua
	BSF RCSTA,7				; Habilitamos el puerto serie
	

	GOTO Recepcion
Recepcion:
	BTFSS PIR1,5			; Checamos si la recepcion termino
	GOTO Recepcion
	MOVF RCREG,W			; Leemos RCREG	
	

	ANDLW 0X07				; Mascara de datos solo nos importa del 0 al 7
	ADDWF PCL,F				; PARA SALTAR A LA OPCION INDICADA
	GOTO Apagados			;0
	GOTO Prendidos			;1	
	GOTO CorDer				;2
	GOTO CorIzq				;3
	GOTO IdaVuelta			;4
	GOTO Parpadeo			;5
	GOTO Recepcion			;6
	GOTO Recepcion			;7

Apagados:
	MOVLW 0x00				; Apagamos todos los bits
	MOVWF PORTB				; PORTB TIENE TODO APAGADO
	CALL Retardo
	GOTO Recepcion
Prendidos:
	MOVLW 0xFF				; Prendemos todos los bits
	MOVWF PORTB				; PORTB TIENE TODO prendido
	CALL Retardo
	GOTO Recepcion
CorDer:
	MOVLW 0x80				;B'1000 0000
	MOVWF PORTB				;PORTB<-W
	CALL LoopD
	GOTO Recepcion
LoopD: 
	CALL Retardo
	BTFSC PORTB,0			;checamos si llego a la posicion final
	RETURN
	RRF PORTB,F				; movemos un bit a la der
	GOTO LoopD

CorIzq:
	MOVLW 0x01				;B'0000 0001
	MOVWF PORTB				;PORTB<-W
	CALL LoopI
	GOTO Recepcion
LoopI: 
	CALL Retardo
	BTFSC PORTB,7			;checamos si llego a la posicion final
	RETURN
	RLF PORTB,F				; movemos un bit a la IZQ
	GOTO LoopI

IdaVuelta:
	MOVLW 0x80				;B'1000 0000
	MOVWF PORTB				;PORTB<-W
	CALL LoopD
	CALL LoopI
	GOTO Recepcion

Parpadeo:
	MOVLW 0x00				; Apagamos todos los bits
	MOVWF PORTB				; PORTB TIENE TODO APAGADO
	CALL Retardo
	CALL Retardo
	CALL Retardo
	MOVLW 0xFF				; Prendemos todos los bits
	MOVWF PORTB				; PORTB TIENE TODO prendido
	CALL Retardo
	GOTO Recepcion

Retardo 
     MOVLW cte1      ;Rutina que genera un DELAY
     MOVWF valor1
tres MOVWF cte2
     MOVWF valor2
dos  MOVLW cte3
     MOVWF valor3
uno  DECFSZ valor3 
     GOTO uno 
     DECFSZ valor2
     GOTO dos
     DECFSZ valor1   
     GOTO tres
     RETURN
     

	END
