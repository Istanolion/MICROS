	processor 16f877
	include <p16f877.inc>
apunta equ 0x20
dato equ 0x21
vueltas equ 0x22

;En general el programa imprime de forma continua el mensaje MICROCOMPUTADORAS 2020 UN NUMERO INFINITO DE VECES

	ORG 0
	GOTO inicio
inicio
	ORG 5
	CLRF vueltas		;limpiamos el #vueltas
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
	INCF vueltas		;incrementamos el #de vueltas
ciclo:
	MOVF vueltas,W		;w=#vueltas
	SUBLW d'21'			;le restamos 21
	BTFSC STATUS,Z		;CHECAMOS LA BANDERA Z
	GOTO $ 
	CALL texto		;llamos texto
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
	
	MOVLW 'D'
	RETURN
	MOVLW 'I'
	RETURN
	MOVLW 'E'
	RETURN
	MOVLW 'G'
	RETURN	
	MOVLW 'O'
	RETURN
	MOVLW ' '
	RETURN
	MOVLW 'I'
	RETURN
	MOVLW 'Ñ'
	RETURN
	MOVLW 'A'
	RETURN
	MOVLW 'K'
	RETURN
	MOVLW 'I'
	RETURN
	MOVLW ' '
	RETURN
	MOVLW 'G'
	RETURN
	MOVLW 'A'
	RETURN
	MOVLW 'R'
	RETURN
	MOVLW 'C'
	RETURN
	MOVLW 'I'
	RETURN
	MOVLW 'A'
	RETURN
	MOVLW 'R'
	RETURN
	MOVLW 'E'
	RETURN
	MOVLW 'B'
	RETURN
	MOVLW 'O'
	RETURN
	MOVLW 'L'
	RETURN
	MOVLW 'L'
	RETURN
	MOVLW 'O'
	RETURN
	MOVLW ' '
	RETURN
	MOVLW 'R'
	RETURN
	MOVLW 'O'
	RETURN
	MOVLW 'J'
	RETURN
	MOVLW 'A'
	RETURN
	MOVLW 'S'
	RETURN
	MOVLW ' '
	RETURN
	MOVLW ' '
	RETURN
	MOVLW '3'
	RETURN
	MOVLW '1'
	RETURN
	MOVLW '4'
	RETURN
	MOVLW '3'
	RETURN
	MOVLW '2'
	RETURN
	MOVLW '4'
	RETURN
	MOVLW '9'
	RETURN
	MOVLW '4'
	RETURN
	MOVLW '8'
	RETURN
	MOVLW 0x0D
	RETURN
	MOVLW 0x0A
	RETURN
	MOVLW '$'
	RETURN

	END
