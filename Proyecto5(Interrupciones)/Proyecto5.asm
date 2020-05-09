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
RegAux3 equ 0x30
RegAux4 equ 0x31
Apuntador equ 0x32
ContadorH equ 0x33
ContadorL equ 0x34
STATUSAUX equ 0x35
WAUX equ 0x36

	org 0					; vector de reset
	goto inicio				; ve al inicio del programa

	ORG 4
	GOTO Interrupciones		;Direccion de las interrupciones
 	org 5
inicio 						; Etiqueta de inicio de programa
	BCF INTCON,TMR1ON		;APAGAMOS EL TEMPORIZADOR EN LO QUE INICIALIZAMOS TODO

	CLRF INTCON
	CLRF PIR1
	CLRF ContadorH			
	CLRF ContadorL
	CLRF PORTA				; Limpiamos PORTA
	CLRF PORTB				; Limpiamos PORTB
	CLRF PORTC				; Limpiamos PORTC
	CLRF PORTD				; Limpiamos PORTD
	BSF STATUS,RP0			; Ponemos un 1 en el bit 5 de STATUS (RP0)
 	BCF STATUS,RP1 			; Ponemos un 0 en el bit 6 de STATUS (RP1) para cambiar de banco 0 al 1					
	CLRF PIE1
	BSF  PIE1,TMR1IE
	MOVLW H'40'				; W <- h'40'
	MOVWF ADCON1			; ADCON1 <- (W) 
	MOVLW H'3F'				; W <- h'3F'
	MOVWF TRISA 			; TRISA <- (W) configuramos PORTA como entrada
	MOVLW H'FF'				; W <- h'FF' B'11111111' We need inputs for the dipswitch
	MOVWF TRISB				; TRISB <- (W) configuramos PORTB como entrada
	MOVLW H'B8'				; W <- h'F8' B'10111000' WE NEEED FOUR OUTPUTS
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
	BSF RCSTA,SPEN		;habiliatamos el puerto serie
	CALL Renicia_Timer1
	CLRF PIR1
	BSF INTCON,PEIE
	BSF INTCON,GIE
	MOVLW 0X30
	MOVWF T1CON


	CALL Inicia_LCD			; Se llama a la subrutina que inicializa el LCD
	BSF T1CON,TMR1ON

Comportamiento:
	CLRF numero
	CLRF RegAux3
	CLRF RegAux4
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


;===================================================================================
loop:
	MOVF PORTB,W			; W <- (PORTA) leer entrada en PORTA
	ANDLW H'03'				; Se realiza un AND logico con H'03' (Mascara de bits)
	ADDWF PCL,F				; Se agrega al PC el valor resultante de aplicar la mascara
	goto Decimal			; Mostrar el voltaje en Decimal 			PORTB: 00
	goto Hexadecimal		; Mostrar el voltaje en Hexadecimal 		PORTB: 01
	goto Binario			; Mostrar el voltaje en binario 			PORTB: 10
	goto Voltaje			; Mostrar el voltaje real 					PORTB: 11
	
Decimal
	MOVLW 0x44			; D
	CALL LCD_Datos
	MOVLW 0x27	 		; '
	CALL LCD_Datos
	MOVLW 'D'
	CALL TransmitirDato
	MOVLW "'"
	CALL TransmitirDato
	CALL ConversionDecimal
	CALL TerminarLinea
	GOTO Comportamiento

Hexadecimal:
	MOVLW 0x48			; H
	CALL LCD_Datos		
	MOVLW 0x27	 		; '
	CALL LCD_Datos
	MOVLW 'H'
	CALL TransmitirDato
	MOVLW "'"
	CALL TransmitirDato
	CALL MostrarHex
	CALL TerminarLinea
	GOTO Comportamiento
Binario:
	MOVLW 0x42			; B
	CALL LCD_Datos
	MOVLW 0x27	 		; '
	CALL LCD_Datos
	MOVLW 'B'
	CALL TransmitirDato
	MOVLW "'"
	CALL TransmitirDato
	CALL MostrarBinario
	CALL TerminarLinea
	GOTO Comportamiento

Voltaje:
	MOVF RegAux2,w          ;
	;Aqui va su procedimiento
	CALL Unidades			; Mandamos a escribir las unidades (enteros) de la lectura
	CALL Decimales			; Mandamos a escribir lo que esta depues del punto decimal
	MOVLW 0X56
	CALL LCD_Datos
	MOVLW 'V'
	CALL TransmitirDato
	CALL TerminarLinea
	GOTO Comportamiento					; fin del programa
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
;Transmitir numero nos permite mandar del simbolo 0 al F
;W debe de contener el numero en Hex a transmitir
TransmitirNumero:
	CALL SelectNumber
	CALL TransmitirDato
	RETURN
SelectNumber:
	CLRF Apuntador
	MOVWF Apuntador	;apuntador tiene ahora el valor de W
	ADDWF Apuntador,w	;se agrega para las opciones de retorno y elegir un solo simbolo
	ADDWF PCL
	
	MOVLW '0'
	RETURN
	MOVLW '1'
	RETURN
	MOVLW '2'
	RETURN
	MOVLW '3'
	RETURN
	MOVLW '4'
	RETURN
	MOVLW '5'
	RETURN
	MOVLW '6'
	RETURN
	MOVLW '7'
	RETURN
	MOVLW '8'
	RETURN
	MOVLW '9'
	RETURN
	MOVLW 'A'
	RETURN
	MOVLW 'B'
	RETURN
	MOVLW 'C'
	RETURN
	MOVLW 'D'
	RETURN
	MOVLW 'E'
	RETURN
	MOVLW 'F'
	RETURN
;==========================================================================
ConversionDecimal:
centena: 
	MOVLW 0x64				;w=D'100'
	SUBWF RegAux2,w			; w=D'RegAux2-D'100
	BTFSS STATUS,C			;Check Status C 
	GOTO Indecena			; RegAux2<D'100 check D'10
	INCF RegAux3			; RegAux2>D'100 inc RegAux3 (Centenar)
	MOVWF RegAux2			; RegAux2= W
	GOTO centena			; loop
Indecena:
	MOVF RegAux3,w			;W= RegAux3 (centenar)
	CALL LCD_Digito			; print Centenar
	MOVF RegAux3,w
	CALL TransmitirNumero
	CLRF RegAux3			; Clear RegAux3 (Now we check D'10)
decena:  
	MOVLW 0x0A				;W=D'10
	SUBWF RegAux2,w			;W=RegAux2-D'10
	BTFSS STATUS,C			;Check Status,c
	GOTO swap				;RegAux2<D'10
	INCF RegAux3			;RegAux2>D'10 inc RegAux3(Dec)
	MOVWF RegAux2			;RegAux2=W
	GOTO decena				;loop
swap: MOVF RegAux3,w		;W=RegAux3 (Dec)
	CALL LCD_Digito			;Print Dec
	MOVF RegAux3,w
	CALL TransmitirNumero
	CLRF RegAux3			;Clear RegAux3 (Now we Check Units)
unidad: MOVLW 0x01			;w=D'1'
	SUBWF RegAux2,w			;W=RegAux2-D'1
	BTFSS STATUS,C			;Check Status Carry
	GOTO finDecimal			;RegAux2<D'1
	INCF RegAux3			;RegAux2>D'1 inc RegAux3 (Unit)
	MOVWF RegAux2			;RegAux2=w
	GOTO unidad				;loop
finDecimal
	MOVF RegAux3,w			;w=RegAux3  (unit)
	CALL LCD_Digito			;Print Units
	MOVF RegAux3,w
	CALL TransmitirNumero
	RETURN					; we have finished this procedure
;==========================================================================
MostrarHex:
	MOVLW 0x10				;w=b'0001 0000
	SUBWF RegAux2,W			;W=RegAux2-0x10
	BTFSS STATUS,C 			;CHECK CARRY
	GOTO PHPart				;(PrintHighPart)RegAux2<0x10 we Have Finished the 4 BMS
	INCF RegAux3			;RegAux1>=0x10 we increment RegAux3(Helper to display)
	MOVWF RegAux2			;RegAux2=W
	GOTO MostrarHex			;loop	
PHPart:
	MOVF RegAux3,w			;w=regAux3
	CALL TransmitirNumero	;para mandarlo por puerto serie

	MOVLW 0x0A				;W=D'9 to check if we to print a number or letter
	SUBWF RegAux3,W			;w=RegAux3-D'9
	BTFSS STATUS,C			;CHECK CARRY
	GOTO Pnumero			;RegAux3<=D'9 print number 
	MOVF RegAux3,w
	CALL LCD_Letra			;RegAux3>D'9 print letter
	CLRF RegAux3			; we clean RegAux3 (Now we check 4BLS)
	GOTO Lowpart
Pnumero:
	MOVF RegAux3,w
	CALL LCD_Digito
	CLRF RegAux3			; we clean RegAux3 (Now we check 4BLS)
Lowpart:
	MOVLW 0x01				;w=B'0000 0001
	SUBWF RegAux2,W			;w=RegAux2-d'1
	BTFSS STATUS,C			;CHECK CARRY
	GOTO PLPart				; (PrintLowPart) RegAux2<d'1
	INCF RegAux3			; RegAux2>=d'1
	MOVWF RegAux2			;RegAux2=w
	GOTO Lowpart
PLPart:
	MOVF RegAux3,w			;w=regAux3
	CALL TransmitirNumero	;para mandarlo por puerto serie
	MOVLW 0x0A				;W=D'9 to check if we to print a number or letter
	SUBWF RegAux3,W			;w=RegAux3-D'9
	BTFSS STATUS,C			;CHECK CARRY
	GOTO finish				;RegAux3<=D'9 print number 
	MOVF RegAux3,w
	CALL LCD_Letra			;RegAux3>D'9 print letter
	RETURN
finish:	
	MOVF RegAux3,w
	CALL LCD_Digito
	RETURN
;===============================================================================	
MostrarBinario:
	MOVLW h'80'				;W=B'1000 0000'
	MOVWF RegAux4			;RegAux4=W
ImprimirBinario:
	MOVLW 0x00				;W=00
	XORWF RegAux4,w			; RegAux4==00?
	BTFSC STATUS,Z			; CHECAMOS LA BANDERA z
	RETURN				 	; terminamos de imprimir ie RegAux4=00
	MOVF RegAux4,W			;w=RegAux4
	SUBWF RegAux2,W			; RegAux2-W->W
	BTFSC STATUS,C			; Checamos la bandera Carry 
	GOTO ImprimeUno			; Imprimimos 1
	GOTO ImprimeCero		; Imprimimos 0

ImprimeCero:
	BCF STATUS,C			; LIMPIAMOS EL BIT CARRY
	RRF RegAux4				; rotamos el regAux,4
	MOVLW 0x00
	CALL LCD_Digito
	MOVLW '0'
	CALL TransmitirDato
	GOTO ImprimirBinario
ImprimeUno:
	MOVWF RegAux2			;RegAux2=W(RegAux2-RegAux4)
	BCF STATUS,C			; LIMPIAMOS EL BIT CARRY
	RRF RegAux4				; rotamos el regAux,4
	MOVLW 0x01
	CALL LCD_Digito	
	MOVLW '1'
	CALL TransmitirDato
	GOTO ImprimirBinario

;===============================================================================;
;Todo este bloque es para la puesta de x.xx V	
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
	MOVF numero,W
	CALL TransmitirNumero
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
	MOVF numero,W
	CALL TransmitirNumero
	Return
;==============================================================================
;AQUI PONDREMOS LAS FUNCIONES PARA ESCRIBIR AL LCD LOS NUMEROS 
Write0Point:
	MOVLW 0x30 				;Pasamos el codigo del caracter
	CALL LCD_Datos 			;Mandamos el dato al LCD
	MOVLW 0x2E				;Pasamos el codigo del caracter .
	CALL LCD_Datos			;Mandamos el dato al LCD
	MOVLW '0'
	CALL TransmitirDato
	MOVLW '.'
	CALL TransmitirDato
	MOVF ADRESH,W			; REGRESAMOS A W EL DATO DE LA CONVERSION A/D
	RETURN
Write1Point:
	MOVLW 0x33
	SUBWF RegAux2,F			;le quitamos el valor referente a la unidad, para dejar RegAux2 entre 0 y .99v
	MOVLW 0x31 				;Pasamos el codigo del caracter
	CALL LCD_Datos 			;Mandamos el dato al LCD
	MOVLW 0x2E				;Pasamos el codigo del caracter .
	CALL LCD_Datos			;Mandamos el dato al LCD
	MOVLW '1'
	CALL TransmitirDato
	MOVLW '.'
	CALL TransmitirDato
	MOVF ADRESH,W			; REGRESAMOS A W EL DATO DE LA CONVERSION A/D
	RETURN
Write2Point:
	MOVLW 0x66
	SUBWF RegAux2,F			;le quitamos el valor referente a la unidad, para dejar RegAux2 entre 0 y .99v
	MOVLW 0x32 				;Pasamos el codigo del caracter
	CALL LCD_Datos 			;Mandamos el dato al LCD
	MOVLW 0x2E				;Pasamos el codigo del caracter .
	CALL LCD_Datos			;Mandamos el dato al LCD
	MOVLW '2'
	CALL TransmitirDato
	MOVLW '.'
	CALL TransmitirDato
	MOVF ADRESH,W			; REGRESAMOS A W EL DATO DE LA CONVERSION A/D
	RETURN
Write3Point:
	MOVLW 0x99
	SUBWF RegAux2,F			;le quitamos el valor referente a la unidad, para dejar RegAux2 entre 0 y .99v
	MOVLW 0x33 				;Pasamos el codigo del caracter
	CALL LCD_Datos 			;Mandamos el dato al LCD
	MOVLW 0x2E				;Pasamos el codigo del caracter .
	CALL LCD_Datos			;Mandamos el dato al LCD
	MOVLW '3'
	CALL TransmitirDato
	MOVLW '.'
	CALL TransmitirDato
	MOVF ADRESH,W			; REGRESAMOS A W EL DATO DE LA CONVERSION A/D
	RETURN
Write4Point:
	MOVLW 0xCC
	SUBWF RegAux2,F			;le quitamos el valor referente a la unidad, para dejar RegAux2 entre 0 y .99v
	MOVLW 0x34 				;Pasamos el codigo del caracter
	CALL LCD_Datos 			;Mandamos el dato al LCD
	MOVLW 0x2E				;Pasamos el codigo del caracter .
	CALL LCD_Datos			;Mandamos el dato al LCD
	MOVLW '4'
	CALL TransmitirDato
	MOVLW '.'
	CALL TransmitirDato
	MOVF ADRESH,W			; REGRESAMOS A W EL DATO DE LA CONVERSION A/D
	RETURN
Write5P0:	
	MOVLW 0x35 				;Pasamos el codigo del caracter
	CALL LCD_Datos 			;Mandamos el dato al LCD
	MOVLW 0x2E				;Pasamos el codigo del caracter .
	CALL LCD_Datos			;Mandamos el dato al LCD
	MOVLW '5'
	CALL TransmitirDato
	MOVLW '.'
	CALL TransmitirDato
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
LCD_Letra:	 
	ADDLW 0x37			;w+37, now w Has the value needed for the LCD to Display the correct Letter
	CALL LCD_Datos
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
;===========================================================================
Mensaje_fin:
	CALL TerminarLinea
	MOVLW 'T'
	CALL TransmitirDato
	MOVLW 'I'
	CALL TransmitirDato
	MOVLW 'E'
	CALL TransmitirDato
	MOVLW 'M'
	CALL TransmitirDato
	MOVLW 'P'
	CALL TransmitirDato
	MOVLW 'O'
	CALL TransmitirDato
	MOVLW ' '
	CALL TransmitirDato
	MOVLW 'T'
	CALL TransmitirDato
	MOVLW 'E'
	CALL TransmitirDato
	MOVLW 'R'
	CALL TransmitirDato
	MOVLW 'M'
	CALL TransmitirDato
	MOVLW 'I'
	CALL TransmitirDato
	MOVLW 'N'
	CALL TransmitirDato
	MOVLW 'A'
	CALL TransmitirDato
	MOVLW 'D'
	CALL TransmitirDato
	MOVLW 'O'
	CALL TransmitirDato
	CALL TerminarLinea
	MOVLW 0x01
	call LCD_Comando
	MOVLW 0x02
	call LCD_Comando
	MOVLW 0x54			; T
	CALL LCD_Datos
	MOVLW 0x49			; I
	CALL LCD_Datos
	MOVLW 0x45			; E
	CALL LCD_Datos
	MOVLW 0x4D			; M
	CALL LCD_Datos
	MOVLW 0x50			; P
	CALL LCD_Datos
	MOVLW 0x4F			; O
	CALL LCD_Datos
	MOVLW 0x20			; ESPACIO
	CALL LCD_Datos
	MOVLW 0x54			; T
	CALL LCD_Datos
	MOVLW 0x45			; E
	CALL LCD_Datos
	MOVLW 0x52			; R
	CALL LCD_Datos
	MOVLW 0x4D			; M
	CALL LCD_Datos
	MOVLW 0x49			; I
	CALL LCD_Datos
	MOVLW 0x4E			; N
	CALL LCD_Datos
	MOVLW 0x41			; A
	CALL LCD_Datos
	MOVLW 0x44			; D
	CALL LCD_Datos
	MOVLW 0x4F			; O
	CALL LCD_Datos
	GOTO $
;===========================================================================

Interrupciones:
	MOVWF WAUX			;GUARDAMOS LA QUE TENIA W
	SWAPF STATUS,W		;W GUARDA TODO EL STATUS
	MOVWF STATUSAUX
	CLRF STATUS
	BTFSS PIR1,TMR1IF	;CHECAMOS SI LA INTERRUPCION FUE DADA POR EL DESBORDE DEL TIMER1
	GOTO nTimer			;nos salimos en caso de que no sea
	INCFSZ ContadorL,f	;incrementamos la parte baja de nuestro contador aux
	GOTO only_low		;si el incremento no es igual a cero
	INCF ContadorH,f	;si el incremento es igual a cero
	GOTO Out
;debemos checar el valor de contadoH
only_low:
	MOVF ContadorH,w	;w tiene el valor de ContadorH
	XORLW 0x07			;REALIZAMOS UN XOR CON EL VALOR 0X0
	BTFSC STATUS,Z		;CHECAMOS SI EL XOR DA 0 (IE SON NUMEROS IDENTICOS)
	GOTO CHECK_CL
Out: CALL Renicia_Timer1	;reiniciamos el timer1 a su valor predeterminado y bajamos la bandera de desborde
nTimer:
	SWAPF STATUSAUX,W
	MOVWF STATUS
	SWAPF WAUX,F
	SWAPF WAUX,W
	BCF PIR1,TMR1IF	;REINICIAMOS LA BANDERA DE DESBORDE DEL TIMER1	
	RETFIE
CHECK_CL:
	MOVF ContadorL,w	;w tiene le valor del ContadorL
	XORLW 0x08			; XOR CON UN VALOR DETERMINADO 
	BTFSC STATUS,Z		;CHECAMOS SI LA XOR DIO 0
	GOTO Mensaje_fin	;se llego a los 3 minutos
	GOTO Out
Renicia_Timer1:
	MOVLW 0x0B
	MOVWF TMR1H	
	MOVLW 0xD2
	MOVWF TMR1L	
;AQUI SE REGRESO A UN VALOR INICIAL EL TIMER1 PARA QUE EL DESBORDE OCURRA CADA .1SEG 

	RETURN
	END

