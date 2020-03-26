	PROCESSOR 16f877
	INCLUDE <p16f877.inc>
	ORG 0
rega equ H'20'; 
regb equ H'21'; 
resultado equ H'22';resultado=a/b con numeros enteros
regRes equ H'23'; RESIDUO
regAux equ H'24'
	GOTO inicio 
	ORG 5
inicio: MOVLW 0x00
	MOVWF resultado
	MOVWF regRes
	XORWF regb,w
	BTFSC STATUS,Z
	GOTO $
	MOVF rega,w
	MOVWF regAux
	MOVF regb,w
	SUBWF rega,w
	BTFSS STATUS,C
	GOTO $
	GOTO div
div: MOVF regb,w
	SUBWF rega,f
	BTFSS STATUS,C
	GOTO residuo
	INCF resultado
	GOTO div
residuo: ADDWF rega,w
	MOVWF regRes
	MOVF regAux,w
	MOVWF rega
	GOTO $
	END
