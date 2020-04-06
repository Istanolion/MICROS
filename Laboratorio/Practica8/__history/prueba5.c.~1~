#include <16f877.h> //se define el micro
#fuses HS,NOPROTECT,
#use delay(clock=20000000) //se define la velocidad del reloj
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7) //se define la tasa de transferencia, y se indica que pines 
//son los receptores y transmisores de datos
#org 0x1F00, 0x1FFF void loader16F877(void) {} //for the 8k 16F876/7
void main(){
while(1){
 output_b(0xff); //se prende todos los bits del puerto B
 printf(" Todos los bits encendidos \n\r"); //se manda un mensaje a la consola
 delay_ms(1000); //hay un retardo de 1000ms
 output_b(0x00); //se apagan todos los bits del puerto B
 printf(" Todos los leds apagados \n\r");
 delay_ms(1000);
}//while
}//main 
