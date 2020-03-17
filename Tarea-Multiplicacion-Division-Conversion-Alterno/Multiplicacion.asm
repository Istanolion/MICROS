	processor 16f877
	include<p16f877.inc>

num1 	equ h'20'
num2 	equ h'21'
resultado	equ h'22'

		org 0
		goto inicio
		org 5
inicio: movlw h'0'
		movwf resultado		
multiplicar:
		movf num1,W
		addwf resultado,F
		decf num2
		btfss STATUS,2
		goto multiplicar
		end