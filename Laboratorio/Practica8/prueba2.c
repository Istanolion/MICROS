#include <16f877.h>
#fuses HS,NOPROTECT,
#use delay(clock=20000000)
#org 0x1F00, 0x1FFF void loader16F877(void) {}
void main(){
while(1){
 output_b(0xFF); //Del puerto B prende el primer bit
 delay_ms(1000); // espera 1000ms 
 output_b(0x00); //Apaga todos los bits del puertoB
 delay_ms(1000); //Espera 1000ms
}//while regresa al while
}//main 
