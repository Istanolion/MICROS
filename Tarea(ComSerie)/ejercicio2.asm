	processor 16f877
	include <p16f877.inc>
apunta equ 0x20
dato equ 0x21

;En general el programa imprime de forma continua el mensaje MICROCOMPUTADORAS 2020 UN NUMERO INFINITO DE VECES

	ORG 0
	GOTO inicio
inicio
	ORG 5
	BSF STATUS,RP0		
	BCF STATUS,RP1		;nos movemos al banco 01
	BSF TXSTA,BRGH		;damos transmision alta velocidad
	MOVLW D'129'		;pasamos a w el valor que vamos a dar de baud rate
	MOVWF SPBRG			;baud rate=9600
	BCF TXSTA,SYNC		;comunicacion asincrona
	BSF TXSTA,TXEN		;activamos la transmision
	
	BCF STATUS,RP0		;regresamos al banco 00
	BSF RCSTA,SPEN		;habiliatamos el puerto serie
rep: CLRF apunta		;limpiamos el registro 0x20
ciclo: CALL texto		;llamos texto
	MOVWF dato			;cuando termine texto movemos lo que tenga w al reg 0x21
	SUBLW "$"			;restamos el valor de "$" a w (y lo almacenamos en w)
	BTFSC STATUS,Z		;checamos si la resta es igual a cero
	GOTO rep			;si es cero regresamos a rep
	MOVF dato,W			;si no movemos lo del reg 0x21 a W
	MOVWF TXREG			;pasamos lo que hay w al txreg que es lo que se va a transmitir
	CALL transmite		;llamos a transmite
	INCF apunta			;incrementamos el valor del reg 0x20
	GOTO ciclo			;repetimos el ciclo

transmite: BSF STATUS,RP0	;nos movemos al banco 01
esp: BTFSS TXSTA,TRMT		;chechamos como va la comunicacion
	GOTO esp				;si no ha terminado regresamos en loop
	BCF STATUS,RP0			;si termino nos regresamos al banco 00
	RETURN					;retornamos

texto: MOVF apunta,W	;movemos a w lo que haya en el registro 0x20
	ADDWF apunta,w		;AGREGE ESTA SUMA PARA PODER MANDAR UNA LETRA Y EL RETURN (XQ TEXTO ES LLAMADO CON CALL)
	ADDWF PCL			;añadimos al pcl el valor de w 
	
	MOVLW 'M'
	RETURN
	MOVLW 'I'
	RETURN
	MOVLW 'C'
	RETURN
	MOVLW 'R'
	RETURN	
	MOVLW 'O'
	RETURN
	MOVLW 'C'
	RETURN
	MOVLW 'O'
	RETURN
	MOVLW 'M'
	RETURN
	MOVLW 'P'
	RETURN
	MOVLW 'U'
	RETURN
	MOVLW 'T'
	RETURN
	MOVLW 'A'
	RETURN
	MOVLW 'D'
	RETURN
	MOVLW 'O'
	RETURN
	MOVLW 'R'
	RETURN
	MOVLW 'A'
	RETURN
	MOVLW 'S'
	RETURN
	MOVLW ' '
	RETURN
	MOVLW '2'
	RETURN
	MOVLW '0'
	RETURN
	MOVLW '2'
	RETURN
	MOVLW '0'
	RETURN
	MOVLW 0x0D
	RETURN
	MOVLW 0x0A
	RETURN
	MOVLW '$'
	RETURN

	END
