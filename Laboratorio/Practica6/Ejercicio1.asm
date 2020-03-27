	processor 16f877		; micro a usar
	include<p16f877.inc>	; libreria para ocupar nombres de registros

;Retardo 20 MicroSegundo
valor1 equ h'21'			; registros a ocupar para la subrutina de retardo




	org 0					; vector de reset
	goto inicio				; ve al inicio del programa
 	org 5
inicio 						; Etiqueta de inicio de programa
	CLRF PORTA				; Limpiamos PORTA
	CLRF PORTB
	BSF STATUS,5			; Ponemos un 1 en el bit 5 de STATUS (RP0)
 	BCF STATUS,6 			; Ponemos un 0 en el bit 6 de STATUS (RP1) para cambiar de banco 0 al 1
	MOVLW H'40'				; W <- h'40'
	MOVWF ADCON1			; ADCON1 <- (W) 
	MOVLW H'3F'				; W <- h'3F'
	MOVWF TRISA 			; TRISA <- (W) configuramos PORTA como entrada
	MOVLW H'00'				; W <- h'00'
	MOVWF TRISB				; PORT B AS OUTPUT
	BCF STATUS,5			; regresar al banco 0 poniendo el bit 5 de STATUS (RP0) en 0
	MOVLW 0x81
	MOVWF ADCON0

	GOTO Comportamiento
Comportamiento:
	BSF ADCON0,2			; 
	CALL Retardo_20_micro	;
	BTFSC	ADCON0,2		;
	GOTO Comportamiento		;
	MOVF ADRESH,W			;
	MOVWF PORTB				;

	GOTO Comportamiento					; fin del programa
	

;Retardo de 20 Microsegundo
Retardo_20_micro
	MOVLW 0x66		
 	movwf valor1			
Loop 
	decfsz valor1
 	goto Loop
	return
	
	END

