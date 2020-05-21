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

	org 0					; vector de reset
	goto inicio				; ve al inicio del programa

	ORG 4
	GOTO Interrupciones		;Direccion de las interrupciones
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
	BSF TXSTA,BRGH		;damos transmision alta velocidad
	MOVLW D'129'		;pasamos a w el valor que vamos a dar de baud rate
	MOVWF SPBRG			;baud rate=9600
	BCF TXSTA,SYNC		;comunicacion asincrona
	BSF TXSTA,TXEN		;activamos la transmision
	BCF STATUS,RP0			; regresar al banco 0 poniendo el bit 5 de STATUS (RP0) en 0
	MOVLW 0x81
	MOVWF ADCON0
	MOVLW B'00001100'	;LOAD THE VALUE TO W
	MOVWF CCP2CON		;PUT W TO CCP2CONFIGURATION, setting to work as PWM
	MOVLW B'00000111'	;PUT THE VALUE TO W
	MOVWF T2CON			;PUT THE VALUE W HAD TO T2CON, postcale 1:1, turn on timer2, prescale 16
	MOVLW 0x00			;PUT THE VALUE TO W
	MOVWF CCPR2L		;SET CCPR2L WITH THE VALUE W HAS, initializing the 8 MsB of PWM, setting the duty cicle


	BSF RCSTA,SPEN		;habiliatamos el puerto serie
	CALL Renicia_Timer1
	CLRF PIR1
	BSF INTCON,PEIE
	BSF INTCON,GIE
	MOVLW 0X30
	MOVWF T1CON


	CALL Inicia_LCD			; Se llama a la subrutina que inicializa el LCD
	CALL createSymbols		; Llama la subrutina que crea guarda en CGRAM los caracteres nuevos

Comportamiento:
	MOVLW 0x01
	call LCD_Comando
	MOVLW 0x02
	call LCD_Comando



;===================================================================================
loop:
	MOVF PORTB,W			; W <- (PORTB) leer entrada en PORTA
	ANDLW H'01'				; Se realiza un AND logico con H'01' (Mascara de bits)
	ADDWF PCL,F				; Se agrega al PC el valor resultante de aplicar la mascara
	GOTO automatico
	GOTO manual
automatico:
	BSF T1CON,TMR1ON



	MOVF CCPR2L, W 			; Leemos el registro CCPR2L
	MOVWF RegAux			; Lo copiamos al registro auxiliar para evitar problemas
	CALL ImprimirSimbolos	; Hacemos la comparacion para imprimir simbolos



	GOTO Comportamiento
manual:
	BCF T1CON,TMR1ON		; Apagamos el timer1
	CALL Renicia_Timer1		; Reiniciamos el Timer
	CLRF ContadorL			; limpiamos el contador de desborde
	BSF ADCON0,2			; EMPEZAMOS LA CONVERSION A/D
check:	
	BTFSC	ADCON0,2		; CHECAMOS SI SE TERMINO LA CONVERSION A/D
	GOTO check				; SE REGRESA EN CASO DE QUE NO SE HAYA ACABADO
	MOVF ADRESH,W			; PASAMOS ADRESH A W PARA TENER EL VALOR DE LA CONVERSION
	MOVWF CCPR2L			; EL RESULTADO DE LA CONVERSION ES AHORA EL DUTY CYCLE
	
	MOVF ADRESH, W 			; Leemos el resultado de la conversion del registro ADRESH
	MOVWF RegAux			; Lo copiamos al registri auxiliar para evitar problemas
	CALL ImprimirSimbolos	; Hacemos la comparacion para imprimir simbolos
	
	GOTO Comportamiento
;==========================================================================
;AQUI VA LO NECESARIO PARA TRANSMITIR DATOS VIA PUERTO SERIE
;Esta etiqueta debe de ser llamada
;ES NECESARIO QUE W TENGA EL VALOR DEL DATO A ENVIAR PREVIAMENTE

TransmitirDato:
	BCF T1CON,TMR1ON
	MOVWF TXREG				;PONEMOS LO QUE TENGA W EN TXREG
	BSF STATUS,RP0			;NOS MOVEMOS AL BANCO 01
CheckTrans:	
	BTFSS TXSTA,TRMT		;CHECAMOS SI LA TRANSMISION TERMINO
	GOTO CheckTrans			;Nos regresamos en loop
	BCF STATUS,RP0			;Nos regresamos al banco 00
	BSF T1CON,TMR1ON
	RETURN	

TerminarLinea:
	MOVLW 0x0D
	CALL TransmitirDato
	MOVLW 0x0A
	CALL TransmitirDato
	RETURN
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

;=============================================================================
createSymbols:

	MOVLW 0X40
	CALL LCD_Comando


	MOVLW 0x10
	CALL LCD_Datos	
	MOVLW 0x10
	CALL LCD_Datos
	MOVLW 0x01
	CALL LCD_Datos
	MOVLW 0x01
	CALL LCD_Datos
	MOVLW 0x10
	CALL LCD_Datos
	MOVLW 0x10
	CALL LCD_Datos
	MOVLW 0x01
	CALL LCD_Datos
	MOVLW 0x01
	CALL LCD_Datos


	MOVLW 0x00
	CALL LCD_Datos	
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos


	MOVLW 0x00
	CALL LCD_Datos	
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos



	MOVLW 0x00
	CALL LCD_Datos	
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos



	MOVLW 0x00
	CALL LCD_Datos	
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos



	MOVLW 0x00
	CALL LCD_Datos	
	MOVLW 0x00
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos



	MOVLW 0x00
	CALL LCD_Datos	
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos



	MOVLW 0xFF
	CALL LCD_Datos	
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos
	MOVLW 0xFF
	CALL LCD_Datos


;REDIRECT TO DDRAM
	MOVLW H'80'         				
	CALL LCD_Comando
	RETURN				


; =============================================================================

ImprimirSimbolos
	;0 32 64 96 128 160 192 224 255

	MOVLW D'0'					; Si tiene el valor igual a 0
	SUBWF RegAux,W				; Resta de comprobacion
	BTFSC STATUS, Z				; Si cumple con la condicion
	GOTO PrintCero				; Imprime el simbolo correspondiente

	MOVLW D'255'				;  Si tiene el valor igual o menor a  255
	SUBWF RegAux,W				;  Resta de comprobacion
	BTFSC STATUS, C				;  Si cumple con la condicion
	GOTO PrintCien				;  Imprime el simbolo correspondiente
	
	CALL PrintUno						
	MOVLW D'32'					; Si tiene el valor igual o menor a  32
	SUBWF RegAux,W				; Resta de comprobacion
	BTFSC STATUS, C				; Si cumple con la condicion
	CALL PrintDos				; Imprime el simbolo correspondiente
								
	MOVLW D'64'					;  Si tiene el valor igual o menor a  64
	SUBWF RegAux,W				;  Resta de comprobacion
	BTFSC STATUS, C				;  Si cumple con la condicion
	CALL PrintTres				;  Imprime el simbolo correspondiente

	MOVLW D'96'					;  Si tiene el valor igual o menor a  96
	SUBWF RegAux,W				;  Resta de comprobacion
	BTFSC STATUS, C				;  Si cumple con la condicion
	CALL PrintCuatro				;  Imprime el simbolo correspondiente

	MOVLW D'128'				;  Si tiene el valor igual o menor a  128
	SUBWF RegAux,W				;  Resta de comprobacion
	BTFSC STATUS, C				;  Si cumple con la condicion
	CALL PrintCinco				;  Imprime el simbolo correspondiente

	MOVLW D'160'				;  Si tiene el valor igual o menor a  160
	SUBWF RegAux,W				;  Resta de comprobacion
	BTFSC STATUS, C				;  Si cumple con la condicion
	CALL PrintSeis				;  Imprime el simbolo correspondiente

	MOVLW D'192'				;  Si tiene el valor igual o menor a  192
	SUBWF RegAux,W				;  Resta de comprobacion
	BTFSC STATUS, C				;  Si cumple con la condicion
	CALL PrintSiete				;  Imprime el simbolo correspondiente

	MOVLW D'224'				;  Si tiene el valor igual o menor a  224
	SUBWF RegAux,W				;  Resta de comprobacion
	BTFSC STATUS, C				;  Si cumple con la condicion
	CALL PrintOcho				;  Imprime el simbolo correspondiente



				
	GOTO Comportamiento			; Si no es ningun caso, regresa al inicio


; =============================================================================

PrintCero
	MOVLW 0x30
	CALL LCD_Datos
	GOTO Comportamiento

PrintCien
	MOVLW 0x31
	CALL LCD_Datos
	MOVLW 0x30
	CALL LCD_Datos
	MOVLW 0x30
	CALL LCD_Datos
	GOTO Comportamiento

PrintUno
	MOVLW 0x00
	CALL LCD_Datos
	return

PrintDos
	MOVLW 0x01
	CALL LCD_Datos
	return

PrintTres
	MOVLW 0x02
	CALL LCD_Datos
	return

PrintCuatro
	MOVLW 0x03
	CALL LCD_Datos
	return

PrintCinco
	MOVLW 0x04
	CALL LCD_Datos
	return

PrintSeis
	MOVLW 0x05
	CALL LCD_Datos
	return

PrintSiete
	MOVLW 0x06
	CALL LCD_Datos
	return

PrintOcho
	MOVLW 0x07
	CALL LCD_Datos
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

Interrupciones:
	MOVWF WAUX			;GUARDAMOS LA QUE TENIA W
	SWAPF STATUS,W		;W GUARDA TODO EL STATUS
	MOVWF STATUSAUX		; guardamos el status en un registro
	CLRF STATUS			;limpiamos status
	BTFSS PIR1,TMR1IF	;CHECAMOS SI LA INTERRUPCION FUE DADA POR EL DESBORDE DEL TIMER1
	GOTO nTimer			;nos salimos en caso de que no sea
	INCF ContadorL,f	;incrementamos la parte baja de nuestro contador aux
	MOVF ContadorL,W	;W TIENE EL VALOR DEL CONTADOR
	XORLW 0x0A			; XOR CON UN VALOR DE D'10'
	BTFSC STATUS,Z		;CHECAMOS SI LA XOR DIO 0
	GOTO logica			;1
	;0
Out: CALL Renicia_Timer1	;reiniciamos el timer1 a su valor predeterminado y bajamos la bandera de desborde
nTimer:
	SWAPF STATUSAUX,W
	MOVWF STATUS
	SWAPF WAUX,F
	SWAPF WAUX,W
	BCF PIR1,TMR1IF	;REINICIAMOS LA BANDERA DE DESBORDE DEL TIMER1	
	RETFIE

Renicia_Timer1:
	MOVLW 0x0B
	MOVWF TMR1H	
	MOVLW 0xD2
	MOVWF TMR1L	
;AQUI SE REGRESO A UN VALOR INICIAL EL TIMER1 PARA QUE EL DESBORDE OCURRA CADA .1SEG 

	RETURN
logica:
	CLRF ContadorL		;limpiamos el contador
	BTFSS RegFlag,0		;checamos la bandera de incremento/decremento
	GOTO Incremento		;bandera=0
Decremento:				;bandera=1
	DECF CCPR2L			;DECREMENTAMOS EL DUTY CYCLE
	BTFSC STATUS,Z		;CHECAMOS SI LA XOR DIO 0
	DECF RegFlag		;1
	GOTO Out			;0
Incremento:
	INCF CCPR2L			;INCREMENTAMOS EL DUTY CYCLE
	MOVF CCPR2L,W		;W=DC
	XORLW 0xFF			;CHECAMOS SI EL dC YA LLEGO A FF
	BTFSC STATUS,Z		;CHECAMOS SI LA XOR DIO 0
	INCF RegFlag		;1
	GOTO Out			;0

	END

