	PROCESSOR 16f877
	INCLUDE <p16f877.inc>
	ORG 0
rega equ H'20'; 
regb equ H'21'; 
resultado equ H'22'; resultado mul
	GOTO inicio 
	ORG 5
inicio: MOVLW 0x00
	XORWF rega,w
	BTFSC STATUS,Z
	GOTO zero
	BTFSC regb,w
	GOTO zero
	MOVF rega,w
	MOVWF resultado
	GOTO mul
zero: MOVLW 0x00
	MOVWF resultado
	GOTO $
mul: DECSF regb
	GOTO $
	MOVF rega,w
	ADDWF rega,w
	MOVWF resultado
	GOTO mul