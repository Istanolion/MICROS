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
	MOVWF H'3F'				; W <- h'3F'
	MOVLW TRISA 			; TRISA <- (W) configuramos PORTA como entrada
	MOVLW H'FF'				; W <- h'FF'
	MOVWF TRISB				; TRISB <- (W) configuramos PORTB como entrada
	MOVLW H'FF'				; W <- h'00'
	MOVWF TRISC				; TRISC <- (W) configuramos PORTC como salida
	MOVLW H'FF'				; W <- h'00'
	MOVWF TRISD				; TRISD <- (W) configuramos PORTD como salida
 	BCF STATUS,5			; regresar al banco 0 poniendo el bit 5 de STATUS (RP0) en 0

	MOVF PORTA,W			; W <- (PORTA) leer entrada en PORTA
	ANDLW H'07'				; Se realiza un AND logico con H'07' (Mascara de bits)
	ADDWF PCL,F				; Se agrega al PC el valor resultante de aplicar la mascara
							

; RUTINA PARA INICIALIZAR LA PANTALLA LCD 16X2
Inicia_LCD
	BCF PORTC, 0						; RS = 0
	MOVLW H'30'         				; Enviamos H'30' al bus de datos
	MOVWF PORTD							;
	call LCD_Comando					; Llamamos LCD_Comando
	call Retardo_200_Microsegundos     	; TIEMPO DE ESPERA
	MOVLW H'30'         				; Enviamos H'30' al bus de datos
	MOVWF PORTD							;
	call LCD_Comando					; Llamamos LCD_Comando
	call Retardo_200_Microsegundos     	; TIEMPO DE ESPERA
	MOVLW H'38'         				; Enviamos H'38' al bus de datos
	MOVWF PORTD							;
	call LCD_Comando					; Llamamos LCD_Comando
	MOVLW H'0C'         				; Enviamos H'0C' al bus de datos
	MOVWF PORTD							;
	call LCD_Comando					; Llamamos LCD_Comando
	MOVLW H'01'         				; Enviamos H'01' al bus de datos
	MOVWF PORTD							;
	call LCD_Comando					; Llamamos LCD_Comando
	MOVLW H'06'         				; Enviamos H'06' al bus de datos
	MOVWF PORTD							;
	call LCD_Comando					; Llamamos LCD_Comando
	MOVLW H'02'         				; Enviamos H'02' al bus de datos
	MOVWF PORTD							;
	call LCD_Comando					; Llamamos LCD_Comando
	MOVLW H'80'         				; Enviamos H'80' al bus de datos
	MOVWF PORTD							; Para inicializar el despliegue en el renglon 1, columna 1
	call LCD_Comando					;
	return

;SUBRUTINA PARA ENVIAR COMANDOS
LCD_Comando
	call Retardo_200_Microsegundos     	; TIEMPO DE ESPERA
	BSF PORTC, 2        				; Enable = 1
	BCF PORTC, 0						; RS = 0
	call Retardo_200_Microsegundos     	; TIEMPO DE ESPERA
	BCF PORTC, 2    					; ENABLE=0    
	BCF PORTC, 0						; RS = 0
	call Retardo_400_Microsegundos     	; TIEMPO DE ESPERA
	return     
;SUBRUTINA PARA ENVIAR UN DATO
LCD_Datos
	call Retardo_200_Microsegundos     	; TIEMPO DE ESPERA
	BSF PORTC, 2        				; Enable = 1		
	BSF PORTC, 0						; RS = 0
	call Retardo_200_Microsegundos     	; TIEMPO DE ESPERA
	BSF PORTC, 0						; RS = 0
	BCF PORTC, 2    					; ENABLE=0    
	call Retardo_400_Microsegundos     	; TIEMPO DE ESPERA
	return     

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

