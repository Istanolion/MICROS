	processor 16f877		; micro a usar
	include<p16f877.inc>	; libreria para ocupar nombres de registros

;Retardo 20 MicroSegundo
valor1 equ h'21'			; registros a ocupar para la subrutina de retardo

cte1 equ 0x21
C1Tercios equ 0x22
C2Tercios equ 0x23


	org 0					; vector de reset
	goto inicio				; ve al inicio del programa
 	org 5
inicio 						; Etiqueta de inicio de programa
	CLRF PORTA				; Limpiamos PORTA
	CLRF PORTB
	MOVLW 0x54
	MOVWF C1Tercios
	MOVLW 0xAB
	MOVWF C2Tercios
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
	
	MOVF C1Tercios,W		;
	SUBWF ADRESL			; ADRESL-w ->w si C1Tercios>ADRESL entonces Carry=0
	BTFSC STATUS,C
	GOTO Caso1
	MOVLW C2Tercios,W
	SUBWF ADRESL			; ADRESL-w ->w si C2Tercios>ADRESL entonces Carry=0
	BTFSC STATUS,C
	GOTO Caso2
	GOTO Caso3
	GOTO Comportamiento					; fin del programa
	
Caso1:
	MOVLW 0x00
	MOVWF PORTB
	GOTO Comportamiento
Caso2:
	MOVLW 0x01
	MOVWF PORTB
	GOTO Comportamiento
Caso3:
	MOVLW 0x02
	MOVWF PORTB
	GOTO Comportamiento
;Retardo de 20 Microsegundo
Retardo_20_micro 						; inicio de la subrutina de retardo
	movlw cte1				
 	movwf valor1			
Loop 
	decfsz valor1
 	goto Loop
	return								; fin de la subrutina de retardo

	END

