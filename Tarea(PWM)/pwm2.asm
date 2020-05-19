	processor 16f877
	include<p16f877.inc>

;Retardo 1 Segundo
valor1 equ h'21'			; registros a ocupar para la subrutina de retardo
valor2 equ h'22'	
valor3 equ h'23'
cte1 equ 0XD7
cte2 equ 50h
cte3 equ 60h

ct1 equ 0x19	;valor para la suma 
ct2 equ 0x1A	;VALOR PARA LA SUMA 
RegAux equ 0x20
	ORG 0
	GOTO inicio
	ORG 5
;el codigo crea un PWM con un periodo de 819.2 micro segundos
;en caso de que el reloj sea de 20MHZ como fue mi caso
inicio: 
	BSF STATUS,RP0		;RP0=1
	BCF STATUS,RP1		;RP1=0 NOW IN BANK 01
	BCF TRISC,1			;WE SET PORTC,1 AS OUTPUT
	BCF TRISC,2			;WE SET PORTC,2 AS OUTPUT
	MOVLW D'255'		;LOAD D'255 TO WORK REG
	MOVWF PR2			;MOVE W TO PR2 setting the period for PWM
	BCF STATUS,RP0		;RETURN TO BANK 00
	MOVLW B'00001100'	;LOAD THE VALUE TO W
	MOVWF CCP2CON		;PUT W TO CCP2CONFIGURATION, setting to work as PWM
	MOVLW B'00000111'	;PUT THE VALUE TO W
	MOVWF T2CON			;PUT THE VALUE W HAD TO T2CON, postcale 1:1, turn on timer2, prescale 16
	MOVLW 0x00			;PUT THE VALUE TO W
	MOVWF CCPR2L		;SET CCPR2L WITH THE VALUE W HAS, initializing the 8 MsB of PWM, setting the duty cicle
	BCF STATUS,C
loop:
	BTFSC STATUS,C
	CALL set_zero
	CALL Retardo_1_Segundo
	CALL Retardo_1_Segundo
	CALL Retardo_1_Segundo

add:
	MOVF CCP2CON,W			;W HAS THE VALUE CCP2CON
	XORLW 0X20				;WE MAKE THIS TO CHECK WHETHER CCP2X IS 1 OR 0
	MOVWF RegAux
	BTFSC RegAux,5			;check
	GOTO SUM19				;1
	GOTO SUM20				;0
SUM19:
	BSF CCP2CON,5
	MOVLW ct1
	ADDWF CCPR2L,F
	GOTO loop
SUM20:
	BCF CCP2CON,5
	MOVLW ct2
	ADDWF CCPR2L,F
	GOTO loop
set_zero:
	MOVLW B'00001100'	;LOAD THE VALUE TO W
	MOVWF CCP2CON		;PUT W TO CCP2CONFIGURATION, setting to work as PWM
	MOVLW 0x00			;PUT THE VALUE TO W
	MOVWF CCPR2L		;SET CCPR2L WITH THE VALUE W HAS, initializing the 8 MsB of PWM, setting the duty cicle
	RETURN
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
	return

	END
	