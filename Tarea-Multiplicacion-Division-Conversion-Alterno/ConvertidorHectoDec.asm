		processor 16f877
		include <p16f877.inc>
		include <extras.inc>

hexa 	equ h'20'
decH 	equ h'21'
decL	equ h'22'
residuo equ h'70'
temp 	equ h'71'
		org 0
		goto inicio
		org 5
inicio: 
		divlf hexa,d'100',decH,residuo
		divlf residuo,d'10',decL,residuo
		swapf decL
		divlf residuo,d'1',temp,residuo
		addff decL,temp,decL
		end		
