	processor 16f877		
	include<p16f877.inc>	
CONTADOR EQU 0X20			
	ORG 0				
	GOTO INICIO				
	ORG 4					
	GOTO INTERRUPCIONES		
	ORG 5					
INICIO 						
	BSF STATUS,5			; Cambiamos los valores de STATUS
	BCF STATUS,6			; Para cambiar al banco 1
	CLRF TRISB				; Limpiamos TRISB para definir PORTB como salidas
	MOVLW B'00000111'		; W <- B'00000111'
	MOVWF OPTION_REG		; Temporizador, flanco de bajada, Pre-divisor del TMR0 = 256
	BCF STATUS,5			; Cambiamos al banco 1
	BCF INTCON,T0IF			; Bandera de estado del TIMER0. No ha ocurrido desbordamiento
	BSF INTCON,T0IE			; Habilita interrupción por desbordamiento del TIMER0
	BSF INTCON,GIE			; Habilita interrupciones generales
	CLRF PORTB				
	CLRF CONTADOR			
	GOTO $					
INTERRUPCIONES				
	BTFSS INTCON,T0IF		; Pregunta quien ha solicitado la interrupción (Bandera de estado del TIMER0)
	GOTO SAL_NO_FUE_TMR0	; No fue el TIMER0 quien la solicito
	INCF CONTADOR			; Incrementamos el contador
	MOVLW D'150'			; W <- 150
	SUBWF CONTADOR,W		; W <- Contador - 150
	BTFSS STATUS,Z			; Si no da 0 la resta
	GOTO SAL_INT			; Ve a SAL_INT
	COMF PORTB				; Si da 0, Haz el complemento de PORTB
	CLRF CONTADOR			
SAL_INT						
	BCF INTCON,T0IF			; Bandera de estado del TIMER0. No ha ocurrido desbordamiento
SAL_NO_FUE_TMR0				
	RETFIE					; Sale de la interrupcion
	END						
