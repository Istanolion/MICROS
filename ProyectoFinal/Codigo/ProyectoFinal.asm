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
RegAux equ 0x20		;reg de la conversion a/d
RegFlag equ 0x24	;registro con la bandera de incremento/decremento
ContadorL equ 0x34	;cuantas veces se ha desbordado timer1
STATUSAUX equ 0x35	;guardar el status mientras la interrupcion
WAUX equ 0x36		;guardar w mientras la interrupcion

Contrasena1 equ 0x37	;guardar 1 digito de la contraseña
Contrasena2 equ 0x38	;guardar 2 digito de la contraseña
Contrasena3 equ 0x39	;guardar 3 digito de la contraseña
Contrasena4 equ 0x40	;guardar 4 digito de la contraseña
Contrasena5 equ 0x40	;guardar 5 digito de la contraseña
Contrasena6 equ 0x40	;guardar 6 digito de la contraseña
Contrasena7 equ 0x40	;guardar 7 digito de la contraseña
Contrasena8 equ 0x40	;guardar 8 digito de la contraseña

;===============================================================================

	org 0					; vector de reset
	goto inicio				; ve al inicio del programa

;	ORG 4
;	GOTO Interrupciones		;Direccion de las interrupciones
 	org 5
inicio 						; Etiqueta de inicio de programa
	BCF INTCON,TMR1ON		;APAGAMOS EL TEMPORIZADOR EN LO QUE INICIALIZAMOS TODO
	CLRF RegAux
	CLRF RegFlag				
	CLRF INTCON
	CLRF PIR1			
	CLRF ContadorL
	CLRF PORTA				; Limpiamos PORTA
	CLRF PORTB				; Limpiamos PORTB
	CLRF PORTC				; Limpiamos PORTC
	CLRF PORTD				; Limpiamos PORTD
	BSF STATUS,RP0			; Ponemos un 1 en el bit 5 de STATUS (RP0)
 	BCF STATUS,RP1 			; Ponemos un 0 en el bit 6 de STATUS (RP1) para cambiar de banco 0 al 1					
	MOVLW D'255'			;LOAD D'255 TO WORK REG
	MOVWF PR2				;MOVE W TO PR2 setting the period for PWM
	CLRF PIE1
	BSF  PIE1,TMR1IE
	MOVLW H'40'				; W <- h'40'
	MOVWF ADCON1			; ADCON1 <- (W) 
	MOVLW H'3F'				; W <- h'3F'
	MOVWF TRISA 			; TRISA <- (W) configuramos PORTA como entrada
	MOVLW H'FF'				; W <- h'FF' B'11111111' We need inputs for the dipswitch
	MOVWF TRISB				; TRISB <- (W) configuramos PORTB como entrada
	MOVLW H'85'				; W <- h'F8' B'10000101' WE NEEED FOUR OUTPUTS
	MOVWF TRISC				; TRISC <- (W) configuramos PORTC como salida
	MOVLW H'00'				; W <- h'00'
	MOVWF TRISD				; TRISD <- (W) configuramos PORTD como salida

	BCF STATUS,RP0			; regresar al banco 0 poniendo el bit 5 de STATUS (RP0) en 0


	CALL Inicia_LCD			; Se llama a la subrutina que inicializa el LCD

;===============================================================================
Comportamiento:
	MOVLW 0x01
	call LCD_Comando
	MOVLW 0x02
	call LCD_Comando

;===============================================================================
loop:
	MOVF PORTB,W			; W <- (PORTB) leer entrada en PORTA
	ANDLW H'01'				; Se realiza un AND logico con H'01' (Mascara de bits)
	ADDWF PCL,F				; Se agrega al PC el valor resultante de aplicar la mascara

;	GOTO ProgramarContraseña ;No es recomendable ponerla de momento hasta que todo funcione
;	GOTO DesbloquearPuerta

; ==============================================================================

; RUTINA PARA INICIALIZAR LA PANTALLA LCD 16X2
Inicia_LCD
	BCF PORTC, 3						; RS = 0
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
	BSF PORTC, 5        				; Enable = 1
	BCF PORTC, 3						; RS = 0
	call Retardo_200_Microsegundos     	; TIEMPO DE ESPERA
	BCF PORTC, 5    					; ENABLE=0    
	call Retardo_400_Microsegundos     	; TIEMPO DE ESPERA
	return     
;SUBRUTINA PARA ENVIAR UN DATO
LCD_Datos
	MOVWF PORTD
	call Retardo_200_Microsegundos     	; TIEMPO DE ESPERA
	BSF PORTC, 5        				; Enable = 1		
	BSF PORTC, 3						; RS = 1
	call Retardo_200_Microsegundos     	; TIEMPO DE ESPERA
	BCF PORTC, 5    					; ENABLE=0    
	call Retardo_400_Microsegundos     	; TIEMPO DE ESPERA
	return     
LCD_Digito:
	ADDLW 0x30			;W+30, now W has the value needed for the LCD to Display the correct number
	CALL LCD_Datos		;The display shows the value read by the keypad
	RETURN
LCD_Letra:	 
	ADDLW 0x37			;w+37, now w Has the value needed for the LCD to Display the correct Letter
	CALL LCD_Datos
	RETURN

; =============================================================================

PrintCero
	MOVLW 0x30
	CALL LCD_Datos
	GOTO Comportamiento

PrintUno
	MOVLW 0x31
	CALL LCD_Datos
	GOTO Comportamiento

PrintDos
	MOVLW 0x32
	CALL LCD_Datos
	GOTO Comportamiento

PrintTres
	MOVLW 0x33
	CALL LCD_Datos
	GOTO Comportamiento

PrintCuatro
	MOVLW 0x34
	CALL LCD_Datos
	GOTO Comportamiento

PrintCinco
	MOVLW 0x35
	CALL LCD_Datos
	GOTO Comportamiento

PrintSeis
	MOVLW 0x36
	CALL LCD_Datos
	GOTO Comportamiento

PrintSiete
	MOVLW 0x37
	CALL LCD_Datos
	GOTO Comportamiento

PrintOcho
	MOVLW 0x38
	CALL LCD_Datos
	GOTO Comportamiento

PrintAsterisco
	MOVLW 0x2A
	CALL LCD_Datos
	GOTO Comportamiento

PrintMensajeBienvenida
	MOVLW 0x42
	CALL LCD_Datos
	MOVLW 0x69
	CALL LCD_Datos
	MOVLW 0x65
	CALL LCD_Datos
	MOVLW 0x6E
	CALL LCD_Datos
	MOVLW 0x76
	CALL LCD_Datos
	MOVLW 0x65
	CALL LCD_Datos
	MOVLW 0x6E
	CALL LCD_Datos
	MOVLW 0x69
	CALL LCD_Datos
	MOVLW 0x64
	CALL LCD_Datos
	MOVLW 0x6F
	CALL LCD_Datos
	GOTO Comportamiento

PrintOpciones
	MOVLW 0x01
	call LCD_Comando
	MOVLW 0x02
	call LCD_Comando
	MOVLW 0x43
	CALL LCD_Datos
	MOVLW 0x6F
	CALL LCD_Datos
	MOVLW 0x6E
	CALL LCD_Datos
	MOVLW 0x74
	CALL LCD_Datos
	MOVLW 0x72
	CALL LCD_Datos
	MOVLW 0x61
	CALL LCD_Datos
	MOVLW 0x76
	CALL LCD_Datos
	MOVLW 0x65
	CALL LCD_Datos
	MOVLW b'11110001'
	CALL LCD_Datos
	MOVLW 0x61
	CALL LCD_Datos
	GOTO Comportamiento
;ascii
;==========
;ñ (1010 0100)
;Ñ (1010 0101)
;
;LCD HD44780U
;==========
;ñ (1111 0001)
;Ñ (1101 0001)

PrintContrasenaIncorrecta
	MOVLW 0x01
	call LCD_Comando
	MOVLW 0x02
	call LCD_Comando
	MOVLW 0x49
	CALL LCD_Datos
	MOVLW 0x6E
	CALL LCD_Datos
	MOVLW 0x63
	CALL LCD_Datos
	MOVLW 0x6F
	CALL LCD_Datos
	MOVLW 0x72
	CALL LCD_Datos
	MOVLW 0x72
	CALL LCD_Datos
	MOVLW 0x65
	CALL LCD_Datos
	MOVLW 0x63
	CALL LCD_Datos
	MOVLW 0x74
	CALL LCD_Datos
	MOVLW 0x6F
	CALL LCD_Datos
	MOVLW 0x2A
	CALL LCD_Datos
	GOTO Comportamiento

PrintAbierto
	MOVLW 0x01
	call LCD_Comando
	MOVLW 0x02
	call LCD_Comando
	MOVLW 0x41
	CALL LCD_Datos
	MOVLW 0x62
	CALL LCD_Datos
	MOVLW 0x69
	CALL LCD_Datos
	MOVLW 0x65
	CALL LCD_Datos
	MOVLW 0x72
	CALL LCD_Datos
	MOVLW 0x74
	CALL LCD_Datos
	MOVLW 0x6F
	CALL LCD_Datos
	GOTO Comportamiento


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

;===========================================================================

;Interrupciones

	END
