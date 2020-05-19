	processor 16f877
	include<p16f877.inc>
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
	MOVLW D'169'	;PUT THE VALUE TO W
	MOVWF CCPR2L		;SET CCPR2L WITH THE VALUE W HAS, initializing the 8 MsB of PWM, setting the duty cicle
	GOTO $
	END
	