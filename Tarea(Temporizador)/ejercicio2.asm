	processor 16f877
	include<p16f877.inc>
Contador equ 0x20
	ORG 0
	GOTO Inicio			;Vector de Reset
	ORG 4
	GOTO Interrupciones	;vector de interrupcion

	ORG 5				;inicio del programa
Inicio: BSF STATUS,5	;ponemos 1 en el bit 5 del reg status 
	BCF STATUS,6		;ponemos 0 en bit 6 del reg status estamos en el banco 01 de memoria
	CLRF TRISB			;colocamos el reg b como salida
	MOVLW B'00000111'	;cargamos el dato a w
	MOVWF OPTION_REG	;colocamos w en el reg OPtion_Reg, poeniendo ps2:0 en alto
						;haciendo la division de frecuencia a 256
	BCF STATUS,5		;regresamos al banco 00
	BCF INTCON,T0IF		;ponemos la bandera del timer0 en 0 
	BSF	INTCON,T0IE		;habilitamos la interrupcion por desbordamiento de timer 0
	BSF INTCON,GIE		;Habilitamos la interrupciones generales
	CLRF PORTB			;limpiamos el puerto b
	CLRF Contador		;limpiamos el reg 0x20
	GOTO $

Interrupciones:	BTFSS INTCON,T0IF	;checamos la interrupcion si fue por desbordamiento del timer0
	GOTO SAL_NO_FUE_TMR0		;en caso de que no sea NOS VAMOS A OTRA ETIQUETA
	INCF Contador		;incrementamos el registor contador
	MOVLW D'150'		;PASAMOS EL DATO A W
	SUBWF Contador,W	;Hacemos la resta Contador - w y la guardamos en w
	BTFSS STATUS,Z 		;CHECAMOS LA BANDERA Z ES DECIR SI EL RESULTADO FUE 0
	GOTO SAL_INT		;NOS SALTAMOS A SAL_INT
	COMF PORTB			;aqui saltamos cuando es 0 la resta se hace el complemento A1 del reg (prende y apaga)
	CLRF Contador 		;limpiamos el registro contador
SAL_INT: BCF INTCON,T0IF		;limpia la bandera para que pueda volver a ocurrir el desbordamiento
SAL_NO_FUE_TMR0: RETFIE			;nos regresamos de la interrupcion
	END