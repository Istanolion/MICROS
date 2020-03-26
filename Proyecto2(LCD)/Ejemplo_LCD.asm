 ; PORTB BUS DE DATOS B0-D0 ... B7-D7
 ; RS - A0
 ; E - A1
 ; R/W - GND

 processor 16f877
 include<p16f877.inc>
 
valor equ h'20'
valor1 equ h'21'
valor2 equ h'22'
contador equ h'23'
dato equ h'24'
    org 0
    goto inicio
     org 5
inicio clrf PORTA
       CLRF PORTB 
      bsf STATUS,5
      bcf STATUS,6
   movlw b'000000000'
   movwf TRISB
   movlw 0x07
   movwf ADCON1
   movlw b'000000000'
   movwf TRISA
   bcf STATUS,5

   call inicia_lcd
 
otrom:  movlw 0x80
   call comando
  movlw a'F'
  call datos
  movlw a'I'
  call datos
  call retardo_1seg
  goto otrom
   
inicia_lcd movlw 0x30
      call comando
      call ret100ms
      movlw 0x30
      call comando
      call ret100ms
     movlw 0x38
     call comando
     movlw 0x0c
     call comando
     movlw 0x01
     call comando
     movlw 0x06
     call comando
    movlw 0x02
    call comando
    return

comando movwf PORTB 
    call ret200
    bcf PORTA,0
    bsf PORTA,1
    call ret200
    bcf PORTA,1
    return

datos movwf PORTB
    call ret200
    bsf PORTA,0
    bsf PORTA,1
;RS,E=1
    call ret200
    bcf PORTA,1
;E=0
    call ret200
    call ret200
    return
 ; PORTB BUS DE DATOS B0-D0 ... B7-D7
 ; RS - A0
 ; E - A1
 ; R/W - GND

ret200 movlw 0x02
       movwf valor1 
loop   movlw d'164'
      movwf valor
loop1 decfsz valor,1
      goto loop1
      decfsz valor1,1
      goto loop
      return

ret100ms movlw 0x03 
rr  movwf valor
tres movlw 0xff
 movwf valor1
dos movlw 0xff
 movwf valor2
uno decfsz valor2
  goto uno
 decfsz valor1
 goto dos
 decfsz valor
 goto tres
return

retardo_1seg:  ;Falta esta subrutina de 1 segundo

           return

  end
