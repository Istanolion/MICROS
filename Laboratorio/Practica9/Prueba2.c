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

#int_rtcc
clock_isr(){
   if(interr==764){
      printf("\nLectura Analogica : ");
      printf("d' %u",valAn);
      printf("\tH': %x",valAn);
      var=(float) valAn*5/255;   //Hacemos la conversion a un valor de voltaje
      printf("\n%f [V]",var);
      interr=0;
   }
   else
      interr++;
}
void main(){
   set_timer0(0);
   setup_counters(RTCC_INTERNAL,RTCC_DIV_256);
   enable_interrupts(INT_RTCC);
   enable_interrupts(GLOBAL);
   setup_port_a(ALL_ANALOG);  //TODOS SON ANALOGICOS
   setup_adc(ADC_CLOCK_INTERNAL);
   set_adc_channel(0);        //se va leer la entrada adc del puerto A0
   delay_us(20);              //esperamos 20 microsegundos
   while(1){
      valAn=read_adc();       //Realizamos la lectura analogica y la guardamos en valAn
      output_b(valAn);
      delay_ms(1000);
   }
}
