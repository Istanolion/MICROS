	processor 16f877		
	include<p16f877.inc>	
CONTADOR EQU 0X20			
	ORG 0					
	GOTO INICIO				
	ORG 4					; Definimos el vector de interrupción
	GOTO INTERRUPCIONES		; Ve a interrupciones
	ORG 5					
INICIO 						
	BSF STATUS,5			; Cambiamos los valores de STATUS
	BCF STATUS,6			; Para cambiar al banco 1
	CLRF TRISB				; Limpiamos TRISB para definir PORTB como salidas
	MOVLW B'00000111'		; W <- B'00000111'
	MOVWF OPTION_REG		; Configuramos TIMER0
	BCF STATUS,5			; Cambiamos al banco 1
	BCF INTCON,T0IF			; Bandera de estado del TIMER0. No ha ocurrido desbordamiento
	BSF INTCON,T0IE			; Habilita interrupción por desbordamiento del TIMER0
	BSF INTCON,GIE			; Habilita interrupciones generales
	CLRF PORTB				
	CLRF CONTADOR			
	GOTO $					; Finaliza programa
INTERRUPCIONES				
	BTFSS INTCON,T0IF		; Pregunta quien ha solicitado la interrupción
	GOTO SAL_INT			; Ve a SAL_INT
	COMF PORTB				; Hace el complemento de PORTB 
	BCF INTCON,T0IF			; Limpia la bandera para indicar que la interrupción ha sido atendida
SAL_INT						
	RETFIE					; Regresa de la interrupcion
	END						
