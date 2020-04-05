	processor 16f877		; micro a usar
	include<p16f877.inc>	; libreria para ocupar nombres de registros

;Variables para el DELAY
valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
cte1 equ 10h 
cte2 equ 50h
cte3 equ 60h


A equ 0x08	
E equ 0x06
I equ 0x70
O equ 0x40
U equ 0x41
Am equ 0x20
Em equ 0x04
Im equ 0x7B
Om equ 0x23
Um equ 0x63

VA equ 0x41
VE equ 0x45
VI equ 0x49
VO equ 0x4F
VU equ 0x55

VAM equ 0x61
VEM equ 0x65
VIM equ 0x69
VOM equ 0x6F
VUM equ 0x75

org 0					; vector de reset
	GOTO inicio				; ve al inicio del programa
 	org 5
inicio 						; Etiqueta de inicio de programa
	CLRF PORTB				; LIMPIAMOS EL PORTB QUE OCUPAREMOS PARA LOS LEDS
	CLRF PORTC				;Limpiamos el PORTC (solo se ocuparan RC6 y RC7)
	;RC6 Transmission RC7 Reception
	BSF STATUS,5			; Ponemos un 1 en el bit 5 de STATUS (RP0)
 	BCF STATUS,6 			; Ponemos un 0 en el bit 6 de STATUS (RP1) para cambiar de banco 0 al 1
	MOVLW H'00'				; W <- h'00' B'00000000' We need outputs. high is input_low is output
	MOVWF TRISB				; TRISB <- (W) configuramos PORTB como SALIDA
	
	BSF	TXSTA,2				; Ponemos el valor de BRGH seleccionando la velocidad ALTA
	;PONEMOS Y MANDAMOS EL VALOR DEL BAUD AL REGISTRO CORRESPONDIENTE
	MOVLW .32
	MOVWF SPBRG
	;
	BCF TXSTA,4				; Ponemos la comunicacion asincrona
	BSF TXSTA,5				; Habilitamos la transmision
	BCF STATUS,5			; regresar al banco 0 poniendo el bit 5 de STATUS (RP0) en 0
	BSF RCSTA,4				; Habilitamos la comunicacion continua
	BSF RCSTA,7				; Habilitamos el puerto serie
	

	GOTO Recepcion
Recepcion:
	BTFSS PIR1,5			; Checamos si la recepcion termino
	GOTO Recepcion
	MOVF RCREG,W			; Leemos RCREG	
	MOVWF valor1
	
	MOVF valor1,W
	XORLW VA
	BTFSC STATUS,Z
	GOTO PonerA
	
	MOVF valor1,W
	XORLW VE
	BTFSC STATUS,Z
	GOTO PonerE

	MOVF valor1,W
	XORLW VI
	BTFSC STATUS,Z
	GOTO PonerI

	MOVF valor1,W
	XORLW VO
	BTFSC STATUS,Z
	GOTO PonerO

	MOVF valor1,W
	XORLW VU
	BTFSC STATUS,Z
	GOTO PonerU

	MOVF valor1,W
	XORLW VAM
	BTFSC STATUS,Z
	GOTO PonerAm
	
	MOVF valor1,W
	XORLW VEM
	BTFSC STATUS,Z
	GOTO PonerEm

	MOVF valor1,W
	XORLW VIM
	BTFSC STATUS,Z
	GOTO PonerIm

	MOVF valor1,W
	XORLW VOM
	BTFSC STATUS,Z
	GOTO PonerOm

	MOVF valor1,W
	XORLW VUM
	BTFSC STATUS,Z
	GOTO PonerUm

	GOTO Recepcion
RetRec:
	MOVWF PORTB
	CALL Retardo
	GOTO Recepcion
PonerA:
	MOVLW A 
	GOTO RetRec
PonerE:
	MOVLW E 
	GOTO RetRec  
PonerI:
	MOVLW I  
	GOTO RetRec 
PonerO:
	MOVLW O  
	GOTO RetRec 
PonerU:
	MOVLW U 
	GOTO RetRec

PonerAm:
	MOVLW Am 
	GOTO RetRec
PonerEm:
	MOVLW Em 
	GOTO RetRec  
PonerIm:
	MOVLW Im  
	GOTO RetRec 
PonerOm:
	MOVLW Om 
	GOTO RetRec 
PonerUm:
	MOVLW Um 
	GOTO RetRec


Retardo 
     MOVLW cte1      ;Rutina que genera un DELAY
     MOVWF valor1
tres MOVWF cte2
     MOVWF valor2
dos  MOVLW cte3
     MOVWF valor3
uno  DECFSZ valor3 
     GOTO uno 
     DECFSZ valor2
     GOTO dos
     DECFSZ valor1   
     GOTO tres
     RETURN
     

	END
