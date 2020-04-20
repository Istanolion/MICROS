	processor 16f877		; micro a usar
	include<p16f877.inc>	; libreria para ocupar nombres de registros

;Retardo 1 Segundo
valor1 equ h'21'			; registros a ocupar para la subrutina de retardo
valor2 equ h'22'	
valor3 equ h'23'
cte1 equ 0XD7
cte2 equ 50h
cte3 equ 60h
;Retardo 200 milisegundos
cte4 equ 34h
cte5 equ 42h
cte6 equ 60h
;Retardo 400 milisegundos
cte7 equ 59h
cte8 equ 4Dh
cte9 equ 60h
;Retardo 100 milisegundos
cte10 equ 20h
cte11 equ 35h
cte12 equ 61h
;REG AUX CONVERSION DIGITAL-LCD
RegAux2 equ 0x26
numero equ 0x25

	org 0					; vector de reset
	goto inicio				; ve al inicio del programa
 	org 5
inicio 						; Etiqueta de inicio de programa
	CLRF PORTA				; Limpiamos PORTA
	CLRF PORTB				; Limpiamos PORTB
	CLRF PORTC				; Limpiamos PORTC
	CLRF PORTD				; Limpiamos PORTD
	BSF STATUS,RP0			; Ponemos un 1 en el bit 5 de STATUS (RP0)
 	BCF STATUS,RP1 			; Ponemos un 0 en el bit 6 de STATUS (RP1) para cambiar de banco 0 al 1
	MOVLW H'40'				; W <- h'40'
	MOVWF ADCON1			; ADCON1 <- (W) 
	MOVLW H'3F'				; W <- h'3F'
	MOVWF TRISA 			; TRISA <- (W) configuramos PORTA como entrada
	MOVLW H'00'				; W <- h'F0'
	MOVWF TRISB				; PORT B AS OUTPUT
	MOVLW H'F8'				; W <- h'F8' B'11111000' WE NEEED THRRE OUTPUTS
	MOVWF TRISC				; TRISC <- (W) configuramos PORTC como salida
	MOVLW H'00'				; W <- h'00'
	MOVWF TRISD				; TRISD <- (W) configuramos PORTD como salida
	BCF STATUS,RP0			; regresar al banco 0 poniendo el bit 5 de STATUS (RP0) en 0
	MOVLW 0x81
	MOVWF ADCON0

	CALL Inicia_LCD			; Se llama a la subrutina que inicializa el LCD
Comportamiento:
	CLRF numero
	MOVLW 0x01
	call LCD_Comando
	MOVLW 0x02
	call LCD_Comando
	BSF ADCON0,2			; EMPEZAMOS LA CONVERSION A/D
	CALL Retardo_20_micro
	BTFSC	ADCON0,2		; CHECAMOS SI SE TERMINO LA CONVERSION A/D
	GOTO Comportamiento		; SE REGRESA EN CASO DE QUE NO SE HAYA ACABADO
	MOVF ADRESH,W			; PASAMOS ADRESH A W PARA TENER EL VALOR DE LA CONVERSION
	MOVWF RegAux2			; RegAux2=AdresH
	CALL Unidades			; Mandamos a escribir las unidades (enteros) de la lectura
	CALL Decimales			; Mandamos a escribir lo que esta depues del punto decimal
	MOVLW 0X56
	CALL LCD_Datos
	GOTO Comportamiento					; fin del programa
;===============================================================================	
Unidades:	SUBLW 0x32				; 0x32-W SI ES POSITIVO ENTONCES SE ENCUENTRA EN 0.X
	BTFSC STATUS,C			; CHECAMOS EL CARRY SI ES 0 ENTONCES EL RESULTADO ES NEGATIVO W MAYOR
	GOTO Write0Point		; Mandamos a escribir 0. en el LCD
	MOVF ADRESH,W			; Regresamos a w el valor de la conversion A/D		
	SUBLW 0x65				; 0x65-W SI ES POSITIVO ENTONCES SE ENCUENTRA EN 1.X
	BTFSC STATUS,C			; CHECAMOS EL CARRY SI ES 0 ENTONCES EL RESULTADO ES NEGATIVO W MAYOR
	GOTO Write1Point		; Mandamos a escribir 1. en el LCD
	MOVF ADRESH,W			; Regresamos a w el valor de la conversion A/D	
	SUBLW 0x98				; 0x98-W SI ES POSITIVO ENTONCES SE ENCUENTRA EN 2.X
	BTFSC STATUS,C			; CHECAMOS EL CARRY SI ES 0 ENTONCES EL RESULTADO ES NEGATIVO W MAYOR
	GOTO Write2Point		; Mandamos a escribir 2. en el LCD
	MOVF ADRESH,W			; Regresamos a w el valor de la conversion A/D	
	SUBLW 0xCB				; 0xCB-W SI ES POSITIVO ENTONCES SE ENCUENTRA EN 3.X
	BTFSC STATUS,C			; CHECAMOS EL CARRY SI ES 0 ENTONCES EL RESULTADO ES NEGATIVO W MAYOR
	GOTO Write3Point		; Mandamos a escribir 3. en el LCD
	MOVF ADRESH,W			; Regresamos a w el valor de la conversion A/D	
	SUBLW 0xFF				; 0xFF-W SI ES POSITIVO ENTONCES SE ENCUENTRA EN 4.X
	BTFSS STATUS,Z			; CHECAMOS EL ZERO SI ES 1 W=FF
	GOTO Write4Point		; Mandamos a escribir 4. en el LCD
	GOTO Write5P0			; Mandamos a escribir 5.0 en el LCD
Decimales:
	MOVLW 0x05				;W=0x05
	SUBWF RegAux2,F			;F=F-5
	BTFSS STATUS,C			; SI C=0 ENTONCES NEGATIVO SINO 
	GOTO Nxt
	INCF numero				; incrementamos el numero (nos dira que digito poner)
	GOTO Decimales			; para ver las el primer digito después del punto decimal
Nxt:	
	ADDWF RegAux2,F         ;f=f+5 para regresar al valor positivo
	MOVF numero,W			;w=numero
	CALL LCD_Digito			;se manda a imprimir el numero al LCD
	CLRF numero				;limpiamos Reg numero
LoopDec: 
	MOVLW 0x01
	SUBWF RegAux2,F			;decrementamos el regAux
	BTFSS STATUS,C			;C=0 ENTONCES EL RESULTADO FUE NEGATIVO
	GOTO add2
	INCF numero
	INCF numero
	GOTO LoopDec
add2:			
	MOVF numero,W
	CALL LCD_Digito	
	Return
;==============================================================================
;AQUI PONDREMOS LAS FUNCIONES PARA ESCRIBIR AL LCD LOS NUMEROS 
Write0Point:
	MOVLW 0x30 				;Pasamos el codigo del caracter
	CALL LCD_Datos 			;Mandamos el dato al LCD
	MOVLW 0x2E				;Pasamos el codigo del caracter .
	CALL LCD_Datos			;Mandamos el dato al LCD
	MOVF ADRESH,W			; REGRESAMOS A W EL DATO DE LA CONVERSION A/D
	RETURN
Write1Point:
	MOVLW 0x33
	SUBWF RegAux2,F			;le quitamos el valor referente a la unidad, para dejar RegAux2 entre 0 y .99v
	MOVLW 0x31 				;Pasamos el codigo del caracter
	CALL LCD_Datos 			;Mandamos el dato al LCD
	MOVLW 0x2E				;Pasamos el codigo del caracter .
	CALL LCD_Datos			;Mandamos el dato al LCD
	MOVF ADRESH,W			; REGRESAMOS A W EL DATO DE LA CONVERSION A/D
	RETURN
Write2Point:
	MOVLW 0x66
	SUBWF RegAux2,F			;le quitamos el valor referente a la unidad, para dejar RegAux2 entre 0 y .99v
	MOVLW 0x32 				;Pasamos el codigo del caracter
	CALL LCD_Datos 			;Mandamos el dato al LCD
	MOVLW 0x2E				;Pasamos el codigo del caracter .
	CALL LCD_Datos			;Mandamos el dato al LCD
	MOVF ADRESH,W			; REGRESAMOS A W EL DATO DE LA CONVERSION A/D
	RETURN
Write3Point:
	MOVLW 0x99
	SUBWF RegAux2,F			;le quitamos el valor referente a la unidad, para dejar RegAux2 entre 0 y .99v
	MOVLW 0x33 				;Pasamos el codigo del caracter
	CALL LCD_Datos 			;Mandamos el dato al LCD
	MOVLW 0x2E				;Pasamos el codigo del caracter .
	CALL LCD_Datos			;Mandamos el dato al LCD
	MOVF ADRESH,W			; REGRESAMOS A W EL DATO DE LA CONVERSION A/D
	RETURN
Write4Point:
	MOVLW 0xCC
	SUBWF RegAux2,F			;le quitamos el valor referente a la unidad, para dejar RegAux2 entre 0 y .99v
	MOVLW 0x34 				;Pasamos el codigo del caracter
	CALL LCD_Datos 			;Mandamos el dato al LCD
	MOVLW 0x2E				;Pasamos el codigo del caracter .
	CALL LCD_Datos			;Mandamos el dato al LCD
	MOVF ADRESH,W			; REGRESAMOS A W EL DATO DE LA CONVERSION A/D
	RETURN
Write5P0:	
	MOVLW 0x35 				;Pasamos el codigo del caracter
	CALL LCD_Datos 			;Mandamos el dato al LCD
	MOVLW 0x2E				;Pasamos el codigo del caracter .
	CALL LCD_Datos			;Mandamos el dato al LCD
	MOVLW 0x00
	MOVWF RegAux2
	RETURN
; ==============================================================================

; RUTINA PARA INICIALIZAR LA PANTALLA LCD 16X2
Inicia_LCD
	BCF PORTC, 0						; RS = 0
	MOVLW H'30'         				; Enviamos H'30' al bus de datos
	call LCD_Comando					; Llamamos LCD_Comando
	call Retardo_200_Microsegundos     	; TIEMPO DE ESPERA
	MOVLW H'30'         				; Enviamos H'30' al bus de datos
	call LCD_Comando					; Llamamos LCD_Comando
	call Retardo_200_Microsegundos     	; TIEMPO DE ESPERA
	MOVLW H'38'         				; Enviamos H'38' al bus de datos  Decimos que el LCD funciona con 8 bits de datos
	call LCD_Comando					; Llamamos LCD_Comando
	MOVLW H'0E'         				; Enviamos H'0C' al bus de datos  Decimos que se prenda el display, cursor apagado y parpade off
	call LCD_Comando					; Llamamos LCD_Comando
	MOVLW H'01'         				; Enviamos H'01' al bus de datos  Borramos el display
	call LCD_Comando					; Llamamos LCD_Comando
	MOVLW H'06'         				; Enviamos H'06' al bus de datos  Damos el funcionamiento
	call LCD_Comando					; Llamamos LCD_Comando
	MOVLW H'02'         				; Enviamos H'02' al bus de datos  Cursor a Home
	call LCD_Comando					; Llamamos LCD_Comando
	MOVLW H'80'         				; Enviamos H'80' al bus de datos  Forzamos el cursor al incio de la linea 1
	call LCD_Comando					; Esta diciendo que el sig dato a escribir va en el primer slot de la DDRAM
	return

;SUBRUTINA PARA ENVIAR COMANDOS
LCD_Comando
	MOVWF PORTD
	call Retardo_200_Microsegundos     	; TIEMPO DE ESPERA
	BSF PORTC, 2        				; Enable = 1
	BCF PORTC, 0						; RS = 0
	call Retardo_200_Microsegundos     	; TIEMPO DE ESPERA
	BCF PORTC, 2    					; ENABLE=0    
	call Retardo_400_Microsegundos     	; TIEMPO DE ESPERA
	return     
;SUBRUTINA PARA ENVIAR UN DATO
LCD_Datos
	MOVWF PORTD
	call Retardo_200_Microsegundos     	; TIEMPO DE ESPERA
	BSF PORTC, 2        				; Enable = 1		
	BSF PORTC, 0						; RS = 1
	call Retardo_200_Microsegundos     	; TIEMPO DE ESPERA
	BCF PORTC, 2    					; ENABLE=0    
	call Retardo_400_Microsegundos     	; TIEMPO DE ESPERA
	return     
 LCD_Digito:
	ADDLW 0x30			;W+30, now W has the value needed for the LCD to Display the correct number
	CALL LCD_Datos		;The display shows the value read by the keypad
	RETURN
; =============================================================================
;Retardo de 1 segundo
Retardo_1_Segundo 						; inicio de la subrutina de retardo
	movlw cte1				
 	movwf valor1			
tres_1 
	movlw cte2
 	movwf valor2
dos_1 
	movlw cte3
 	movwf valor3
uno_1 
	decfsz valor3
 	goto uno_1
 	decfsz valor2
 	goto dos_1
 	decfsz valor1
 	goto tres_1
	return								; fin de la subrutina de retardo

Retardo_100_Microsegundos 				; inicio de la subrutina de retardo
	movlw cte10				
 	movwf valor1			
tres_100 
	movlw cte11
 	movwf valor2
dos_100
	movlw cte12
 	movwf valor3
uno_100
	decfsz valor3
 	goto uno_100
 	decfsz valor2
 	goto dos_100
 	decfsz valor1
 	goto tres_100 
	return								; fin de la subrutina de retardo

Retardo_200_Microsegundos 				; inicio de la subrutina de retardo
	movlw cte4				
 	movwf valor1			
tres_200 
	movlw cte5
 	movwf valor2
dos_200
	movlw cte6
 	movwf valor3
uno_200
	decfsz valor3
 	goto uno_200
 	decfsz valor2
 	goto dos_200
 	decfsz valor1
 	goto tres_200 
	return								; fin de la subrutina de retardo


Retardo_400_Microsegundos 				; inicio de la subrutina de retardo
	movlw cte7				
 	movwf valor1			
tres_400 
	movlw cte8
 	movwf valor2
dos_400
	movlw cte9
 	movwf valor3
uno_400
	decfsz valor3
 	goto uno_400
 	decfsz valor2
 	goto dos_400
 	decfsz valor1
 	goto tres_400 
	return								; fin de la subrutina de retardo

;Retardo de 20 Microsegundo
Retardo_20_micro
	MOVLW 0x66		
 	movwf valor1			
Loop 
	decfsz valor1
 	goto Loop
	return

	END

