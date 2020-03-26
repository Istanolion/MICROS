	PROCESSOR 16f877
	INCLUDE <p16f877.inc>
	ORG 0
rega equ H'20'; 
regb equ H'21'; 
resultadoH equ H'22'
resultadoL equ H'23'; resultado mul
	GOTO inicio 
	ORG 5
inicio: MOVLW 0x00
	MOVWF resultadoL
	MOVWF resultadoH
	XORWF rega,w
	BTFSC STATUS,Z
	GOTO zero
	MOVLW 0x00
	XORWF regb,w
	BTFSC STATUS,Z
	GOTO zero
	MOVF rega,w
	MOVWF resultadoL
	GOTO mul
zero: MOVLW 0x00
	MOVWF resultadoL
	MOVWF resultadoH
	GOTO $
mul: DECF regb
	BTFSC STATUS,Z
	GOTO $
	MOVF rega,w
	ADDWF resultadoL,w
	BTFSC STATUS,C
	INCF resultadoH
	MOVWF resultadoL
	GOTO mul
	END