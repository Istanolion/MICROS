#include <16f877.h> //se define el micro
#device ADC=8;        //EL CONVERTIDOR DE 8 BITS
#fuses HS,NOPROTECT,
#use delay(clock=20000000) //se define la velocidad del reloj
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7) //se define la tasa de transferencia, y se indica que pines 
//son los receptores y transmisores de datos
#org 0x1F00, 0x1FFF void loader16F877(void) {} //for the 8k 16F876/7

long interr=0;
unsigned valAn=0;
float var=0;

#int_rb
port_rb(){
   if(input(pin_b4))
      printf("\nPB4 Activado");
   else
      printf("\nPB4 Desactivado");
   if(input(pin_b5))
      printf("\nPB5 Activado");
   else
      printf("\nPB5 Desactivado");
   if(input(pin_b6))
      printf("\nPB6 Activado");
   else
      printf("\nPB6 Desactivado");
   if(input(pin_b7))
      printf("\nPB7 Activado");
   else
      printf("\nPB7 Desactivado");
}
void main(){
   set_timer0(0);
   setup_counters(RTCC_INTERNAL,RTCC_DIV_256);
   enable_interrupts(INT_RTCC);
   enable_interrupts(GLOBAL);
   enable_interrupts(INT_RB);
   setup_port_a(ALL_ANALOG);  //TODOS SON ANALOGICOS
   setup_adc(ADC_CLOCK_INTERNAL);
   set_adc_channel(0);        //se va leer la entrada adc del puerto A0
   delay_us(20);              //esperamos 20 microsegundos
   while(1){
      printf("\nLeyendo...");
      delay_ms(1000);
   }
}
