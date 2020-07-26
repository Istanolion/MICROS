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

Contrasena1 equ 0x37	;guardar 1 digito de la contrasena
Contrasena2 equ 0x38	;guardar 2 digito de la contrasena
Contrasena3 equ 0x39	;guardar 3 digito de la contrasena
Contrasena4 equ 0x3A 	;guardar 4 digito de la contrasena
Contrasena5 equ 0x3B	;guardar 5 digito de la contrasena
Contrasena6 equ 0x3C	;guardar 6 digito de la contrasena
Contrasena7 equ 0x3D	;guardar 7 digito de la contrasena
Contrasena8 equ 0x3E	;guardar 8 digito de la contrasena

ContrasenaIngresada1 equ 0x3F	;guardar 1 digito de la contrasena
ContrasenaIngresada2 equ 0x40	;guardar 2 digito de la contrasena
ContrasenaIngresada3 equ 0x41	;guardar 3 digito de la contrasena
ContrasenaIngresada4 equ 0x42 	;guardar 4 digito de la contrasena
ContrasenaIngresada5 equ 0x43	;guardar 5 digito de la contrasena
ContrasenaIngresada6 equ 0x44	;guardar 6 digito de la contrasena
ContrasenaIngresada7 equ 0x45	;guardar 7 digito de la contrasena
ContrasenaIngresada8 equ 0x46	;guardar 8 digito de la contrasena

IngresadoAux equ 0x47 

;===============================================================================

	org 0					; vector de reset
	goto inicio				; ve al inicio del programa

;	ORG 4
;	GOTO Interrupciones		;Direccion de las interrupciones
 	org 5
inicio 						; Etiqueta de inicio de programa
	CLRF PORTA				; Limpiamos PORTA
	CLRF PORTB				; Limpiamos PORTB
	CLRF PORTC				; Limpiamos PORTC
	CLRF PORTD				; Limpiamos PORTD
	BSF STATUS,5			; Ponemos un 1 en el bit 5 de STATUS (RP0)
 	BCF STATUS,6 			; Ponemos un 0 en el bit 6 de STATUS (RP1) para cambiar de banco 0 al 1
	MOVLW H'06'				; W <- h'06'
	MOVWF ADCON1			; ADCON1 <- (W) desactivar convertidor
	MOVLW H'07'				; W <- h'07' B'00000111'
	MOVWF TRISA 			; TRISA <- (W) configuramos PORTA como entrada
	MOVLW H'F0'				; W <- h'F0' B'11110000' We need inputs and outputs. high is input_low is output
	MOVWF TRISB				; TRISB <- (W) configuramos PORTB como entrada
	MOVLW H'F8'				; W <- h'F8' B'11111000' WE NEEED THRRE OUTPUTS
	MOVWF TRISC				; TRISC <- (W) configuramos PORTC como salida
	MOVLW H'00'				; W <- h'00'
	MOVWF TRISD				; TRISD <- (W) configuramos PORTD como salida
 	BCF STATUS,5			; regresar al banco 0 poniendo el bit 5 de STATUS (RP0) en 0

	MOVLW H'01'				; W <- h'01'
	MOVWF Contrasena1		; Contrasena1 <- (W) 
	MOVLW H'02'				; W <- h'02'
	MOVWF Contrasena2		; Contrasena2 <- (W) 
	MOVLW H'03'				; W <- h'03'
	MOVWF Contrasena3		; Contrasena3 <- (W) 
	MOVLW H'04'				; W <- h'04'
	MOVWF Contrasena4		; Contrasena4 <- (W) 
	MOVLW H'05'				; W <- h'05'
	MOVWF Contrasena5		; Contrasena5 <- (W) 
	MOVLW H'06'				; W <- h'06'
	MOVWF Contrasena6		; Contrasena6 <- (W) 
	MOVLW H'07'				; W <- h'07'
	MOVWF Contrasena7		; Contrasena7 <- (W) 
	MOVLW H'08'				; W <- h'08'
	MOVWF Contrasena8		; Contrasena8 <- (W) 


	CALL Inicia_LCD			; Se llama a la subrutina que inicializa el LCD
	CALL createSymbols		; Llama la subrutina que crea guarda en CGRAM los caracteres nuevos

;===============================================================================

Comportamiento:
	CALL PrintMensajeBienvenida
LimpiarPantalla:
	MOVLW H'01'
	call LCD_Comando
	MOVLW H'02'
	call LCD_Comando
Ingresar:
	call PrintIngresarContrasena
SegundaLinea:
	MOVLW 0xC0	; Dir that starts line 2
	CALL LCD_Comando
Leer:
	call ReadKeypad
	MOVLW IngresadoAux
	MOVF ContrasenaIngresada1
	;call Retardo_1_Segundo

	call ReadKeypad
	MOVLW IngresadoAux
	MOVF ContrasenaIngresada2
	;call Retardo_1_Segundo

	call ReadKeypad
	MOVLW IngresadoAux
	MOVF ContrasenaIngresada3
	;call Retardo_1_Segundo

	call ReadKeypad
	MOVLW IngresadoAux
	MOVF ContrasenaIngresada4
	;call Retardo_1_Segundo


	call ReadKeypad
	MOVLW IngresadoAux
	MOVF ContrasenaIngresada5
	;call Retardo_1_Segundo

	call ReadKeypad
	MOVLW IngresadoAux
	MOVF ContrasenaIngresada6
	;call Retardo_1_Segundo

	call ReadKeypad
	MOVLW IngresadoAux
	MOVF ContrasenaIngresada7
	;call Retardo_1_Segundo

	call ReadKeypad
	MOVLW IngresadoAux
	MOVF ContrasenaIngresada8
	;call Retardo_1_Segundo

	MOVLW 0x01
	call LCD_Comando
	MOVLW 0x02
	call LCD_Comando

	GOTO ComprobarContrasena

;===============================================================================
;loop:
;	MOVF PORTB,W			; W <- (PORTB) leer entrada en PORTA
;	ANDLW H'01'				; Se realiza un AND logico con H'01' (Mascara de bits)
;	ADDWF PCL,F				; Se agrega al PC el valor resultante de aplicar la mascara

;	GOTO ProgramarContrasena ;No es recomendable ponerla de momento hasta que todo funcione
;	GOTO DesbloquearPuerta

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
LCD_Letra:	 
	ADDLW 0x37			;w+37, now w Has the value needed for the LCD to Display the correct Letter
	CALL LCD_Datos
	RETURN


;===========================================================================
createSymbols:
	MOVLW 0X40
	CALL LCD_Comando
	MOVLW 0x00
	CALL LCD_Datos	
	MOVLW 0x0E
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x16
	CALL LCD_Datos
	MOVLW 0x19
	CALL LCD_Datos
	MOVLW 0x11
	CALL LCD_Datos
	MOVLW 0x11
	CALL LCD_Datos
	MOVLW 0x11
	CALL LCD_Datos
;ALL FOR THE N

;REDIRECT TO DDRAM
	MOVLW H'80'         				
	CALL LCD_Comando
	RETURN				

;===========================================================================

Digito:
	CALL LCD_Digito
	GOTO ReadKeypad
	CALL Retardo_1_Segundo
	RETURN

Letra:
	CALL LCD_Letra
	GOTO ReadKeypad
	CALL Retardo_1_Segundo
	RETURN

;===========================================================================

ReadKeypad:

	BCF PORTB,3
	BSF PORTB,0 	;ROW 7-A
	MOVLW 0x07
	MOVWF IngresadoAux
	MOVLW 0x07
	BTFSC PORTB,4   ;IF PORTB,4=1 THEN THE NUMBER IS 7
	GOTO Digito		;NUMBER 7
	
	MOVLW 0x08
	MOVWF IngresadoAux
	MOVLW 0x08
	BTFSC PORTB,5   ;IF PORTB,5=1 THEN THE NUMBER IS 8
	GOTO Digito		;NUMBER 8

	MOVLW 0x09
	MOVWF IngresadoAux
	MOVLW 0x09
	BTFSC PORTB,6   ;IF PORTB,6=1 THEN THE NUMBER IS 9
	GOTO Digito		;NUMBER 9
	
	MOVLW 0x0A
	MOVWF IngresadoAux
	MOVLW 0x0A
	BTFSC PORTB,7   ;IF PORTB,7=1 THEN THE NUMBER IS A
	GOTO Letra		;NUMBER A

	BCF PORTB,0
	BSF PORTB,1 	;ROW 4,5,6,B
	MOVLW 0x04
	MOVWF IngresadoAux
	MOVLW 0x04
	BTFSC PORTB,4   ;IF PORTB,4=1 THEN THE NUMBER IS 7
	GOTO Digito		;NUMBER 7
	
	MOVLW 0x05
	MOVWF IngresadoAux
	MOVLW 0x05
	BTFSC PORTB,5   ;IF PORTB,5=1 THEN THE NUMBER IS 8
	GOTO Digito		;NUMBER 8

	MOVLW 0x06
	MOVWF IngresadoAux
	MOVLW 0x06
	BTFSC PORTB,6   ;IF PORTB,6=1 THEN THE NUMBER IS 9
	GOTO Digito		;NUMBER 9
	
	MOVLW 0x0B
	MOVWF IngresadoAux
	MOVLW 0x0B
	BTFSC PORTB,7   ;IF PORTB,7=1 THEN THE NUMBER IS A
	GOTO Letra		;NUMBER A
	
	BCF PORTB,1
	BSF PORTB,2 	;ROW 4,5,6,B
	MOVLW 0x01
	MOVWF IngresadoAux
	MOVLW 0x01
	BTFSC PORTB,4   ;IF PORTB,4=1 THEN THE NUMBER IS 7
	GOTO Digito		;NUMBER 7
	
	MOVLW 0x02
	MOVWF IngresadoAux
	MOVLW 0x02
	BTFSC PORTB,5   ;IF PORTB,5=1 THEN THE NUMBER IS 8
	GOTO Digito		;NUMBER 8

	MOVLW 0x03
	MOVWF IngresadoAux
	MOVLW 0x03
	BTFSC PORTB,6   ;IF PORTB,6=1 THEN THE NUMBER IS 9
	GOTO Digito		;NUMBER 9
	
	MOVLW 0x0C
	MOVWF IngresadoAux
	MOVLW 0x0C
	BTFSC PORTB,7   ;IF PORTB,7=1 THEN THE NUMBER IS A
	GOTO Letra		;NUMBER A

	BCF PORTB,2
	BSF PORTB,3 	;ROW 4,5,6,B
	MOVLW 0x0F
	MOVWF IngresadoAux
	MOVLW 0x0F
	BTFSC PORTB,4   ;IF PORTB,4=1 THEN THE NUMBER IS 7
	GOTO Letra		;NUMBER 7
	
	MOVLW 0x00
	MOVWF IngresadoAux
	MOVLW 0x00
	BTFSC PORTB,5   ;IF PORTB,5=1 THEN THE NUMBER IS 8
	GOTO Digito		;NUMBER 8

	MOVLW 0x0E
	MOVWF IngresadoAux
	MOVLW 0x0E
	BTFSC PORTB,6   ;IF PORTB,6=1 THEN THE NUMBER IS 9
	GOTO Letra		;NUMBER 9
	
	MOVLW 0x0D
	MOVWF IngresadoAux
	MOVLW 0x0D
	BTFSC PORTB,7   ;IF PORTB,7=1 THEN THE NUMBER IS A
	GOTO Letra		;NUMBER A

	GOTO ReadKeypad


; =============================================================================

PrintCero
	MOVLW 0x30
	CALL LCD_Datos
	GOTO Leer

PrintUno
	MOVLW 0x31
	CALL LCD_Datos
	GOTO Leer

PrintDos
	MOVLW 0x32
	CALL LCD_Datos
	GOTO Leer

PrintTres
	MOVLW 0x33
	CALL LCD_Datos
	GOTO Leer

PrintCuatro
	MOVLW 0x34
	CALL LCD_Datos
	GOTO Leer

PrintCinco
	MOVLW 0x35
	CALL LCD_Datos
	GOTO Leer

PrintSeis
	MOVLW 0x36
	CALL LCD_Datos
	GOTO Leer

PrintSiete
	MOVLW 0x37
	CALL LCD_Datos
	GOTO Leer

PrintOcho
	MOVLW 0x38
	CALL LCD_Datos
	GOTO Leer

PrintNueve
	MOVLW 0x38
	CALL LCD_Datos
	GOTO Leer

PrintA
	MOVLW 0x41
	CALL LCD_Datos
	GOTO Leer

PrintB
	MOVLW 0x42
	CALL LCD_Datos
	GOTO Leer

PrintC
	MOVLW 0x43
	CALL LCD_Datos
	GOTO Leer

PrintD
	MOVLW 0x44
	CALL LCD_Datos
	GOTO Leer

PrintE
	MOVLW 0x45
	CALL LCD_Datos
	GOTO Leer

PrintF
	MOVLW 0x46
	CALL LCD_Datos
	GOTO Leer

PrintAsterisco
	MOVLW 0x2A
	CALL LCD_Datos
	GOTO Leer

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
	GOTO LimpiarPantalla

PrintIngresarContrasena
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
	MOVLW 0x73
	CALL LCD_Datos
	MOVLW 0x65
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos ; n creada en la CGRAM
	MOVLW 0x61
	CALL LCD_Datos
	GOTO SegundaLinea

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

	; PORTA
	; 1 Reset
	; 2 Led Rojo: Contraseña equivocada
	; 3 Led Verde: Contraseña correcta
	; 4 Bocina
	; 5 Control de cierre
	; 6 Nada

	MOVLW b'01010000'
	MOVWF PORTA
	call Retardo_1_Segundo
	MOVLW b'01000000'
	call Retardo_1_Segundo
	MOVLW b'01010000'
	call Retardo_1_Segundo
	MOVLW b'00000000'

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
	GOTO Abrir


; =============================================================================

ComprobarContrasena

	MOVLW ContrasenaIngresada1			; Si tiene el valor igual a la contrasena original
	SUBWF Contrasena1,W					; Resta de comprobacion
	BTFSC STATUS, Z						; Si no cumple con la condicion
	GOTO PrintContrasenaIncorrecta		; Manda el mensaje de contrasena ingresada incorrecta

	MOVLW ContrasenaIngresada2			; Si tiene el valor igual a la contrasena original
	SUBWF Contrasena2,W					; Resta de comprobacion
	BTFSC STATUS, C						; Si no cumple con la condicion
	GOTO PrintContrasenaIncorrecta		; Manda el mensaje de contrasena ingresada incorrecta

	MOVLW ContrasenaIngresada3			; Si tiene el valor igual a la contrasena original
	SUBWF Contrasena3,W					; Resta de comprobacion
	BTFSC STATUS, C						; Si no cumple con la condicion
	GOTO PrintContrasenaIncorrecta		; Manda el mensaje de contrasena ingresada incorrecta

	MOVLW ContrasenaIngresada4			; Si tiene el valor igual a la contrasena original
	SUBWF Contrasena4,W					; Resta de comprobacion
	BTFSC STATUS, C						; Si no cumple con la condicion
	GOTO PrintContrasenaIncorrecta		; Manda el mensaje de contrasena ingresada incorrecta

	MOVLW ContrasenaIngresada5			; Si tiene el valor igual a la contrasena original
	SUBWF Contrasena5,W					; Resta de comprobacion
	BTFSC STATUS, C						; Si no cumple con la condicion
	GOTO PrintContrasenaIncorrecta		; Manda el mensaje de contrasena ingresada incorrecta

	MOVLW ContrasenaIngresada6			; Si tiene el valor igual a la contrasena original
	SUBWF Contrasena6,W					; Resta de comprobacion
	BTFSC STATUS, C						; Si no cumple con la condicion
	GOTO PrintContrasenaIncorrecta		; Manda el mensaje de contrasena ingresada incorrecta

	MOVLW ContrasenaIngresada7			; Si tiene el valor igual a la contrasena original
	SUBWF Contrasena7,W					; Resta de comprobacion
	BTFSC STATUS, C						; Si no cumple con la condicion
	GOTO PrintContrasenaIncorrecta		; Manda el mensaje de contrasena ingresada incorrecta

	MOVLW ContrasenaIngresada8			; Si tiene el valor igual a la contrasena original
	SUBWF Contrasena8,W					; Resta de comprobacion
	BTFSC STATUS, C						; Si no cumple con la condicion
	GOTO PrintContrasenaIncorrecta		; Manda el mensaje de contrasena ingresada incorrecta
		
	GOTO PrintAbierto					; Si todas las contrasenas son correctas manda el mensaje de abierto
	
; =============================================================================

Abrir

	; PORTA
	; 1 Reset
	; 2 Led Rojo: Contraseña equivocada
	; 3 Led Verde: Contraseña correcta
	; 4 Bocina
	; 5 Control de cierre
	; 6 Nada
	
	MOVLW b'00111000'
	MOVWF PORTA
	call Retardo_1_Segundo
	MOVLW b'00101000'
	call Retardo_1_Segundo
	MOVLW b'00001000'

	GOTO $


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
