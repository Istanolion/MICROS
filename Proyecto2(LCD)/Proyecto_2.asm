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
valor4 equ h'24'			; registros a ocupar para la subrutina de retardo
valor5 equ h'25'	
valor6 equ h'26'
cte4 equ 34h
cte5 equ 42h
cte6 equ 60h
;Retardo 400 milisegundos
valor7 equ h'27'			; registros a ocupar para la subrutina de retardo
valor8 equ h'28'	
valor9 equ h'29'
cte7 equ 59h
cte8 equ 4Dh
cte9 equ 60h
;Retardo 100 milisegundos
valor10 equ h'30'			; registros a ocupar para la subrutina de retardo
valor11 equ h'31'	
valor12 equ h'32'
cte10 equ 20h
cte11 equ 35h
cte12 equ 61h
;Auxiliar register for the keypad
RegAux equ 0x33
RegAux2 equ 0x34

;PortA is used to read the deepswitches
;PORTB is used to Read the KeyPad
;PORTC is used for LCD control signals
;C0 is RS
;C1 is RW
;C2 is E
;PORTD is used to transfer data to the LCD


	org 0					; vector de reset
	goto inicio				; ve al inicio del programa
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

Comportamiento:
	CALL Inicia_LCD			; Se llama a la subrutina que inicializa el LCD
	CALL createSymbols		; Llama la subrutina que crea guarda en CGRAM los caracteres nuevos
loop:
	MOVLW 0x01
	call LCD_Comando
	MOVLW 0x02
	call LCD_Comando
	CLRF RegAux
	MOVLW 0x02
	MOVWF RegAux2
	MOVF PORTA,W			; W <- (PORTA) leer entrada en PORTA
	ANDLW H'07'				; Se realiza un AND logico con H'07' (Mascara de bits)
	ADDWF PCL,F				; Se agrega al PC el valor resultante de aplicar la mascara
	goto HolaMundo			; Llama la subrutina Hola Mundo 0
	goto Names				; Llama la subrutina que imprime los nombres 1
	goto Hexadecimal		; 2
	goto Binario			;3
	goto Decimal			;4
	goto puma				; Llama la subrutina que imprime el puma 5

	goto loop
	goto loop


Hexadecimal:
	MOVLW 0x48;
	CALL LCD_Datos
	MOVLW 0x27;
	CALL LCD_Datos
	CALL ReadKeypad			;WE Read the units, W HAS THE VALUE READ BY THE KEYPAD
	GOTO loop
Binario:
	MOVLW 0x48;
	CALL LCD_Datos
	MOVLW 0x27;
	CALL LCD_Datos
	CALL ReadKeypad			;WE Read the units, W HAS THE VALUE READ BY THE KEYPAD
	MOVLW 0xC0	; Dir that starts line 2
	CALL LCD_Comando
	MOVLW 0x42;
	CALL LCD_Datos
	MOVLW 0x27;
	CALL LCD_Datos
	CALL ConversionBinario
	GOTO loop

Decimal
	MOVLW 0x48;
	CALL LCD_Datos
	MOVLW 0x27;
	CALL LCD_Datos
	CALL ReadKeypad			;WE Read the units, W HAS THE VALUE READ BY THE KEYPAD
	MOVLW 0xC0	; Dir that starts line 2
	CALL LCD_Comando
	MOVLW 0x44;
	CALL LCD_Datos
	MOVLW 0x27;
	CALL LCD_Datos
	CALL ConversionDecimal	
	GOTO loop

;==========================================================================
ConversionDecimal:
centena: 
	MOVLW 0x64
	SUBWF RegAux,w
	BTFSS STATUS,C
	GOTO Indecena
	INCF RegAux2
	MOVWF RegAux
	GOTO centena
Indecena:
	MOVF RegAux2,w
	CALL LCD_Digito
	CLRF RegAux2
decena:  
	MOVLW 0x0A
	SUBWF RegAux,w
	BTFSS STATUS,C
	GOTO swap
	INCF RegAux2
	MOVWF RegAux
	GOTO decena
swap: MOVF RegAux2,w
	CALL LCD_Digito
	CLRF RegAux2
unidad: MOVLW 0x01
	SUBWF RegAux,w
	BTFSS STATUS,C
	GOTO finDecimal
	INCF RegAux2
	MOVWF RegAux
	GOTO unidad
finDecimal
	MOVF RegAux2,w
	CALL LCD_Digito
	RETURN
;==========================================================================
ConversionBinario:
	MOVLW 0x80
	CALL RESTA
	MOVLW 0x40
	CALL RESTA
	MOVLW 0x20
	CALL RESTA
	MOVLW 0x10
	CALL RESTA

	MOVLW 0x08
	CALL RESTA
	MOVLW 0x04
	CALL RESTA
	MOVLW 0x02
	CALL RESTA
	MOVLW 0x01
	CALL RESTA
	RETURN
RESTA:
	SUBWF RegAux,w  ;RegAux-w ->W c=1 positivo
	BTFSS STATUS,C
	GOTO Imprimir0;Entra si c=0 ie negativo  PRINT 0
	MOVWF RegAux   ;JUMP SI C=1 POSITIVE
	MOVLW 0x01
	CALL LCD_Digito
	RETURN
Imprimir0:
	MOVLW 0x00
	GOTO LCD_Digito
	
;===========================================================================
Digito:
	SWAPF RegAux
	ADDWF RegAux,F
	CALL LCD_Digito
	DECFSZ RegAux2
	GOTO ReadKeypad
	CALL Retardo_1_Segundo
	RETURN
Letra:
	SWAPF RegAux
	ADDWF RegAux,F
	CALL LCD_Letra
	DECFSZ RegAux2
	GOTO ReadKeypad
	CALL Retardo_1_Segundo
	RETURN
LCD_Digito:
	ADDLW 0x30			;W+30, now W has the value needed for the LCD to Display the correct number
	CALL LCD_Datos		;The display shows the value read by the keypad
	RETURN
LCD_Letra:	 
	ADDLW 0x37			;w+37, now w Has the value needed for the LCD to Display the correct Letter
	CALL LCD_Datos
	RETURN
;===========================================================================
ReadKeypad:
	BCF PORTB,3
	BSF PORTB,0 	;ROW 7-A
	MOVLW 0x07
	BTFSC PORTB,4   ;IF PORTB,4=1 THEN THE NUMBER IS 7
	GOTO Digito		;NUMBER 7
	
	MOVLW 0x08
	BTFSC PORTB,5   ;IF PORTB,5=1 THEN THE NUMBER IS 8
	GOTO Digito		;NUMBER 8

	MOVLW 0x09
	BTFSC PORTB,6   ;IF PORTB,6=1 THEN THE NUMBER IS 9
	GOTO Digito		;NUMBER 9
	
	MOVLW 0x0A
	BTFSC PORTB,7   ;IF PORTB,7=1 THEN THE NUMBER IS A
	GOTO Letra		;NUMBER A

	BCF PORTB,0
	BSF PORTB,1 	;ROW 4,5,6,B
	MOVLW 0x04
	BTFSC PORTB,4   ;IF PORTB,4=1 THEN THE NUMBER IS 7
	GOTO Digito		;NUMBER 7
	
	MOVLW 0x05
	BTFSC PORTB,5   ;IF PORTB,5=1 THEN THE NUMBER IS 8
	GOTO Digito		;NUMBER 8

	MOVLW 0x06
	BTFSC PORTB,6   ;IF PORTB,6=1 THEN THE NUMBER IS 9
	GOTO Digito		;NUMBER 9
	
	MOVLW 0x0B
	BTFSC PORTB,7   ;IF PORTB,7=1 THEN THE NUMBER IS A
	GOTO Letra		;NUMBER A
	
	BCF PORTB,1
	BSF PORTB,2 	;ROW 4,5,6,B
	MOVLW 0x01
	BTFSC PORTB,4   ;IF PORTB,4=1 THEN THE NUMBER IS 7
	GOTO Digito		;NUMBER 7
	
	MOVLW 0x02
	BTFSC PORTB,5   ;IF PORTB,5=1 THEN THE NUMBER IS 8
	GOTO Digito		;NUMBER 8

	MOVLW 0x03
	BTFSC PORTB,6   ;IF PORTB,6=1 THEN THE NUMBER IS 9
	GOTO Digito		;NUMBER 9
	
	MOVLW 0x0C
	BTFSC PORTB,7   ;IF PORTB,7=1 THEN THE NUMBER IS A
	GOTO Letra		;NUMBER A

	BCF PORTB,2
	BSF PORTB,3 	;ROW 4,5,6,B
	MOVLW 0x0F
	BTFSC PORTB,4   ;IF PORTB,4=1 THEN THE NUMBER IS 7
	GOTO Letra		;NUMBER 7
	
	MOVLW 0x00
	BTFSC PORTB,5   ;IF PORTB,5=1 THEN THE NUMBER IS 8
	GOTO Digito		;NUMBER 8

	MOVLW 0x0E
	BTFSC PORTB,6   ;IF PORTB,6=1 THEN THE NUMBER IS 9
	GOTO Letra		;NUMBER 9
	
	MOVLW 0x0D
	BTFSC PORTB,7   ;IF PORTB,7=1 THEN THE NUMBER IS A
	GOTO Letra		;NUMBER A

	GOTO ReadKeypad
;===========================================================================
HolaMundo:
	MOVLW 0x48
	CALL LCD_Datos 
	MOVLW 0x6F
	CALL LCD_Datos 
	MOVLW 0x6C
	CALL LCD_Datos 
	MOVLW 0x61
	CALL LCD_Datos 
	MOVLW 0x20 
	CALL LCD_Datos
	MOVLW 0x4D 
	CALL LCD_Datos
	MOVLW 0x75 
	CALL LCD_Datos
	MOVLW 0x6E 
	CALL LCD_Datos
	MOVLW 0x64 
	CALL LCD_Datos
	MOVLW 0x6F
	CALL LCD_Datos
	goto loop
;================================================================================
puma:
	MOVLW 0x01
	CALL LCD_Datos
	MOVLW 0x02
	CALL LCD_Datos
	MOVLW 0x03
	CALL LCD_Datos

	MOVLW 0xC0	; Dir that starts line 2
	CALL LCD_Comando

	MOVLW 0x04
	CALL LCD_Datos
	MOVLW 0x05
	CALL LCD_Datos
	MOVLW 0x06
	CALL LCD_Datos
	goto loop
; ===========================================================================
moveDisplay:
	MOVLW 0X18				;Move display to Left
	CALL LCD_Comando
	Return
;=============================================================================
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
;ALL FOR THE Ñ
;Puma Time
	MOVLW 0x01
	CALL LCD_Datos
	MOVLW 0x0F
	CALL LCD_Datos
	MOVLW 0x1F
	CALL LCD_Datos
	MOVLW 0x1F
	CALL LCD_Datos
	MOVLW 0x0F
	CALL LCD_Datos
	MOVLW 0x0C
	CALL LCD_Datos
	MOVLW 0x0E
	CALL LCD_Datos
	MOVLW 0x0E
	CALL LCD_Datos

	MOVLW 0x1E
	CALL LCD_Datos
	MOVLW 0x1F
	CALL LCD_Datos
	MOVLW 0x1F
	CALL LCD_Datos
	MOVLW 0x1F
	CALL LCD_Datos
	MOVLW 0x1F
	CALL LCD_Datos
	MOVLW 0x1C
	CALL LCD_Datos
	MOVLW 0x1D
	CALL LCD_Datos
	MOVLW 0x1D
	CALL LCD_Datos

	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x18
	CALL LCD_Datos
	MOVLW 0x1C
	CALL LCD_Datos
	MOVLW 0x1C
	CALL LCD_Datos
	MOVLW 0x18
	CALL LCD_Datos
	MOVLW 0x18
	CALL LCD_Datos
	MOVLW 0x18
	CALL LCD_Datos
	MOVLW 0x18
	CALL LCD_Datos

	MOVLW 0x06
	CALL LCD_Datos
	MOVLW 0x06
	CALL LCD_Datos
	MOVLW 0x07
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x01
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	
	MOVLW 0x1D
	CALL LCD_Datos
	MOVLW 0x01
	CALL LCD_Datos
	MOVLW 0x17
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x1E
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos

	MOVLW 0x10
	CALL LCD_Datos
	MOVLW 0x10
	CALL LCD_Datos
	MOVLW 0x10
	CALL LCD_Datos

;REDIRECT TO DDRAM
	MOVLW H'80'         				
	CALL LCD_Comando
	RETURN				
;=========================================================================================
Names:
;Nombre de Amos Manuel Vega Lopez
	MOVLW 0x41
	CALL LCD_Datos
	MOVLW 0x6D
	CALL LCD_Datos
	MOVLW 0x6F
	CALL LCD_Datos
	MOVLW 0x73
	CALL LCD_Datos
	MOVLW 0x20
	CALL LCD_Datos
	MOVLW 0x4D
	CALL LCD_Datos
	MOVLW 0x61
	CALL LCD_Datos
 	MOVLW 0x6E
	CALL LCD_Datos
	MOVLW 0x75
	CALL LCD_Datos
	MOVLW 0x65
	CALL LCD_Datos
	MOVLW 0x6C
	CALL LCD_Datos
	MOVLW 0x20
	CALL LCD_Datos
	MOVLW 0x56
	CALL LCD_Datos
	MOVLW 0x65
	CALL LCD_Datos
	MOVLW 0x67
	CALL LCD_Datos
	MOVLW 0x61
	CALL LCD_Datos
	MOVLW 0x20
	CALL LCD_Datos
	MOVLW 0x4C
	CALL LCD_Datos
	MOVLW 0x6F
	CALL LCD_Datos
	MOVLW 0x70
	CALL LCD_Datos
	MOVLW 0x65
	CALL LCD_Datos
	MOVLW 0x7A
	CALL LCD_Datos
;Nombre de Diego Iñaki Garciarebollo Rojas
;We need to put the direction for the next line
	MOVLW 0xC0	; Dir that starts line 2
	CALL LCD_Comando

	MOVLW 0x44
	CALL LCD_Datos
	MOVLW 0x69
	CALL LCD_Datos
	MOVLW 0x65
	CALL LCD_Datos
	MOVLW 0x67
	CALL LCD_Datos
	MOVLW 0x6F
	CALL LCD_Datos
	MOVLW 0x20
	CALL LCD_Datos
	MOVLW 0x49
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos ; ñ creada en la CGRAM
	MOVLW 0x61
	CALL LCD_Datos
	MOVLW 0x6B
	CALL LCD_Datos
	MOVLW 0x69
	CALL LCD_Datos
	MOVLW 0x20
	CALL LCD_Datos
	MOVLW 0x47
	CALL LCD_Datos
	MOVLW 0x61
	CALL LCD_Datos
	MOVLW 0x72
	CALL LCD_Datos
	MOVLW 0x63
	CALL LCD_Datos
	MOVLW 0x69
	CALL LCD_Datos
	MOVLW 0x61
	CALL LCD_Datos
	MOVLW 0x72
	CALL LCD_Datos
	MOVLW 0x65
	CALL LCD_Datos
	MOVLW 0x62
	CALL LCD_Datos
	MOVLW 0x6F
	CALL LCD_Datos
	MOVLW 0x6C
	CALL LCD_Datos
	MOVLW 0x6C
	CALL LCD_Datos
	MOVLW 0x6F
	CALL LCD_Datos
	MOVLW 0x20
	CALL LCD_Datos
	MOVLW 0x52
	CALL LCD_Datos
	MOVLW 0x6F
	CALL LCD_Datos
	MOVLW 0x6A
	CALL LCD_Datos
	MOVLW 0x61
	CALL LCD_Datos
	MOVLW 0x73
	CALL LCD_Datos
	
	CALL moveDisplay
	CALL moveDisplay
	CALL moveDisplay
	CALL moveDisplay
	CALL moveDisplay
	CALL moveDisplay
	CALL moveDisplay
	CALL moveDisplay
	CALL moveDisplay
	CALL moveDisplay
	CALL moveDisplay
	CALL moveDisplay
	CALL moveDisplay
	CALL moveDisplay
	CALL moveDisplay

	goto loop

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
 	movwf valor10			
tres_100 
	movlw cte11
 	movwf valor11
dos_100
	movlw cte12
 	movwf valor12
uno_100
	decfsz valor12
 	goto uno_100
 	decfsz valor11
 	goto dos_100
 	decfsz valor10
 	goto tres_100 
	return								; fin de la subrutina de retardo

Retardo_200_Microsegundos 				; inicio de la subrutina de retardo
	movlw cte4				
 	movwf valor4			
tres_200 
	movlw cte5
 	movwf valor5
dos_200
	movlw cte6
 	movwf valor6
uno_200
	decfsz valor6
 	goto uno_200
 	decfsz valor5
 	goto dos_200
 	decfsz valor4
 	goto tres_200 
	return								; fin de la subrutina de retardo


Retardo_400_Microsegundos 				; inicio de la subrutina de retardo
	movlw cte7				
 	movwf valor7			
tres_400 
	movlw cte8
 	movwf valor8
dos_400
	movlw cte9
 	movwf valor9
uno_400
	decfsz valor9
 	goto uno_400
 	decfsz valor8
 	goto dos_400
 	decfsz valor7
 	goto tres_400 
	return								; fin de la subrutina de retardo


	END
