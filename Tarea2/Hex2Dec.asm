PROCESSOR 16f877
	INCLUDE <p16f877.inc>
	ORG 0
rega equ H'20'; numero en HEX
decH equ H'21'; 
decL equ H'22'
regAux equ H'23'; resultado mul
	GOTO inicio 
	ORG 5
inicio: MOVLW 0x00
	MOVWF decH
	MOVWF decL
	MOVF rega,w
	MOVWF regAux
	GOTO centena
centena: MOVLW 0x64
	SUBWF regAux,w
	BTFSS STATUS,C
	GOTO decena
	INCF decH
	MOVWF regAux
	GOTO centena
decena: MOVLW 0x0A
	SUBWF regAux,w
	BTFSS STATUS,C
	GOTO swap
	INCF decL
	MOVWF regAux
	GOTO decena
swap: SWAPF decL
unidad: MOVLW 0x01
	SUBWF regAux,w
	BTFSS STATUS,C
	GOTO $
	INCF decL
	MOVWF regAux
	GOTO unidad
	END
