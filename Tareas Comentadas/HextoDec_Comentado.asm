	processor 16f877		;micro a usar
	include<p16f877.inc>		;libreria para ocupar nombres de registros
	
rega equ H'20'				; numero en HEX
decH equ H'21'				; Registro parte alta
decL equ H'22'				; Registro
regAux equ H'23'			; Reg Auxiliar

	org 0				; Vector de reset
	goto inicio			; Ve al inicio del programa
 	org 5

inicio: 
	MOVLW 0x00			; Cargamos el valor 0 en W
	MOVWF decH			; Limpiamos el registro
	MOVWF decL			; Limpiamos el registro
	MOVF rega,w 			; copiamos rega en W
	MOVWF regAux 			; copiamos w en regAux
	GOTO centena 			; Ve a centena
centena: 
	MOVLW 0x64 			; Copiamos el valor de 64 en w
	SUBWF regAux,w 			; Realizamos la resta con regAux y la almacenamos en w
	BTFSS STATUS,C 			; Comprobamos el estado de la bandera C de STATUS
	GOTO decena 			; Si esta en 0 vamos a decena
	INCF decH 			; Si esta en 1 incrementamos decH
	MOVWF regAux 			; Copiamos W en regAux
	GOTO centena 			; Ve a centena
decena: 
	MOVLW 0x0A 			; Copiamos el valor de 0A en W
	SUBWF regAux,w 			; Realizamos la resta con regAux y la almacenamos en W
	BTFSS STATUS,C 			; Comprobamos el estado de la bandera C de STATUS
	GOTO swap 			; Si esta en 0 vamos a swap
	INCF decL 			; Si esta en 1 incrementamos decL
	MOVWF regAux 			; Copiamos W en regAux
	GOTO decena 			; Y repetimos procedimiento
swap: 
	SWAPF decL 			; Realiza un intercambio de parte alta con parte baja
unidad: 
	MOVLW 0x01			; Copiamos el valor de 01 en W
	SUBWF regAux,w 			; Realizamos la resta con regAux y almacenamos en w el resultado
	BTFSS STATUS,C 			; Comprobamos el estado de la bandera C de STATUS
	GOTO $  			; Si es 0 terminamos programa
	INCF decL 			; Si es 1 Incrementamos decL
	MOVWF regAux 			; Copiamos w en regAux
	GOTO unidad			; Repetimos procedimiento
	END 				; Fin programa
