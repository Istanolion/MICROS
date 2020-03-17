	processor 16f877
	include<p16f877.inc>

num1 	equ h'20'
num2 	equ h'21'
resultado	equ h'22'
residuo equ h'23'

		org 0
		goto inicio
		org 5
inicio: movlw h'0'
		movwf resultado
		movf num2,W
		subwf num1,W
		btfsc STATUS,Z
		goto dividir	
		btfss STATUS,C
		goto fin	;num2 es mayor
dividir:
		movf num2,W
		subwf num1,F
		incf resultado
		movf num2,W
		subwf num1,W
		btfsc STATUS,Z
		goto dividir
		btfsc STATUS,C
		goto dividir
fin:	movf num1,W
		movwf residuo
		end