dividendo equ H'20'	 		; Registro utilizado para dividendo
divisor equ H'21'			; Registro utilizado para divisor
resultado equ H'22'			; Resultado = dividendo / divisor con numeros enteros
residuo equ H'23'			; Registro utilizado para residuo
auxiliar equ H'24'			; Registro utilizado para auxiliar

	org 0				; vector de reset
	goto inicio			; ve al inicio del programa
 	org 5				; vector de inicio de programa

inicio: 
	MOVLW 0x00			; Caragamos con 0 a W para limpiar los registros 
	MOVWF resultado
	MOVWF residuo
	XORWF divisor,w 		; Verificamos que divisor no sea 0 con la compuerta XOR
	BTFSC STATUS,Z			; Si la bandera Z se levanta como resultado
	GOTO $				; Termina el programa
	MOVF dividendo,w 		; Copia el valor del dividendo a W
	MOVWF auxiliar			; Y lo copiamos a auxiliar
	MOVF divisor,w 			; Copiamos a divisor en w
	SUBWF dividendo,w 		; y efectuamos una resta que almacenamos en W
	BTFSS STATUS,C 			; Comprobamos que no haya sido negativo
	GOTO $				; Si lo fue termina el programa
	GOTO division			; Si no lo fue ve a divisor
division 
	MOVF divisor,w 			; Copiamos divisor en W
	SUBWF dividendo,f 		; le restamos al dividendo el divisor
	BTFSS STATUS,C 			; Comprobamos la operacion con la bandera C
	GOTO residuo			; si C es cero nos vamos a residuo
	INCF resultado 			; en caso contrario incrementamos el resultado en 1
	GOTO division 			; y repetimos la operacion
residuo: 
	ADDWF dividendo,w 		; agregamos a w el dividendo
	MOVWF residuo 			; y lo movemos a residuo
	MOVF auxiliar,w 		; copiamos el auxiliar en w
	MOVWF dividendo 		; y lo copiamos en dividendo
	GOTO $				; terminamos programa
	END				; Fin de programa
