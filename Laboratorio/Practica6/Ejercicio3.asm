	processor 16f877		; micro a usar
	include<p16f877.inc>	; libreria para ocupar nombres de registros

;Retardo 20 MicroSegundo
valor1 equ h'21'			; registros a ocupar para la subrutina de retardo

CAn0 equ 0x22
CAn1 equ 0x23
CAn2 equ 0x24

	org 0					; vector de reset
	goto inicio				; ve al inicio del programa
 	org 5
inicio 						; Etiqueta de inicio de programa
	CLRF PORTA				; Limpiamos PORTA
	CLRF PORTB
	BSF STATUS,5			; Ponemos un 1 en el bit 5 de STATUS (RP0)
 	BCF STATUS,6 			; Ponemos un 0 en el bit 6 de STATUS (RP1) para cambiar de banco 0 al 1
	MOVLW H'00'				; W <- h'40'
	MOVWF ADCON1			; ADCON1 <- (W) 
	MOVLW H'3F'				; W <- h'3F'
	MOVWF TRISA 			; TRISA <- (W) configuramos PORTA como entrada
	MOVLW H'00'				; W <- h'00'
	MOVWF TRISB				; PORT B AS OUTPUT
	BCF STATUS,5			; regresar al banco 0 poniendo el bit 5 de STATUS (RP0) en 0
	GOTO Comportamiento

Comportamiento:
	CALL LecturaAN0
	CALL LecturaAN1
	CALL LecturaAN2
	
	MOVF CAn0,W				;w<-CAn0
	SUBWF CAn1,0			;W <- CAn1-CAn0 CAn0>CAn1  entonces Carry=0
	BTFSS STATUS,C			; checamos la bandera CARRY
	GOTO Comp1				;entra aqui si CARRY=0 Mas grande CAn0
	GOTO Comp2				;Salta aqui si carry=1 Más grande CAn1

	GOTO Comportamiento
Comp1:
	MOVF CAn0,W				;W<-CAn0
	SUBWF CAn2,0			;W<- CAn2-CAn0 	CAn0>CAn2 entonces C=0
	BTFSS STATUS,C			;Checamos la bandera Carry
	GOTO Caso1 				;Entra aqui si Carry=0 Más Grande CAn0
	GOTO Caso3				;Salta aqui si carry=1 Más Grande CAn2

Comp2:
	MOVF CAn1,W				;W<-CAn1
	SUBWF CAn2,0			;W<- CAn2-CAn1 	CAn1>CAn2 entonces C=0
	BTFSS STATUS,C			;Checamos la bandera Carry
	GOTO Caso2 				;Entra aqui si Carry=0 Más Grande CAn1
	GOTO Caso3				;Salta aqui si carry=1 Más Grande CAn2

LecturaAN0:
	MOVLW 0x81
	MOVWF ADCON0
	BSF ADCON0,2			; 
	CALL Retardo_20_micro	;
	BTFSC	ADCON0,2		;
	GOTO LecturaAN0			;
	MOVF ADRESH,W			;W=ADRESH
	MOVWF CAn0
	RETURN

LecturaAN1:
	MOVLW 0x89
	MOVWF ADCON0
	BSF ADCON0,2			; 
	CALL Retardo_20_micro	;
	BTFSC	ADCON0,2		;
	GOTO LecturaAN1			;
	MOVF ADRESH,W			;W=ADRESH
	MOVWF CAn1
	RETURN

LecturaAN2:
	MOVLW 0x91
	MOVWF ADCON0
	BSF ADCON0,2			; 
	CALL Retardo_20_micro	;
	BTFSC	ADCON0,2		;
	GOTO LecturaAN2			;
	MOVF ADRESH,W			;W=ADRESH
	MOVWF CAn2	
	RETURN
	
Caso1:
	MOVLW 0x01
	MOVWF PORTB
	GOTO Comportamiento
Caso2:
	MOVLW 0x03
	MOVWF PORTB
	GOTO Comportamiento
Caso3:
	MOVLW 0x07
	MOVWF PORTB
	GOTO Comportamiento
;Retardo de 20 Microsegundo
Retardo_20_micro
	MOVLW 0x66		
 	movwf valor1			
Loop 
	decfsz valor1
 	goto Loop
	return								; fin de la subrutina de retardo

	END

