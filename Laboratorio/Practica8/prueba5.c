#include <16f877.h> //se define el micro
#fuses HS,NOPROTECT,
#use delay(clock=20000000) //se define la velocidad del reloj
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7) //se define la tasa de transferencia, y se indica que pines 
//son los receptores y transmisores de datos
#org 0x1F00, 0x1FFF void loader16F877(void) {} //for the 8k 16F876/7
void Apagado(){
 output_b(0x00); //se apagan todos los bits del puerto B
 delay_ms(500); //hay un retardo de 500ms =.5s
 return;
}
void Prendido(){
 output_b(0xFF); //se apagan todos los bits del puerto B
 delay_ms(500); //hay un retardo de 500ms =.5s
 return;
}
void CorDer(){
  int i=128;
  while(i>=1){
    output_b(i); //ponermos el bit mas significativo de B como prendido
    i=i/2;
    delay_ms(500);
  }
  return;
}
void CorIzq(){
  int i=1;
  DO{
    output_b(i); //ponermos el bit mas significativo de B como prendido
    delay_ms(500);
     i=i*2;
  }WHILE(i<128);
  output_b(i); //ponermos el bit mas significativo de B como prendido
  delay_ms(500);
  return;
}
void IdaVuelta(){
   CorDer();
   CorIzq();
   return;
}
void Parpadeo(){
   Apagado();
   Prendido();
   return;
}

void main(){
int selector=5;
#bit RCIF=0x0C.5;
#byte RCREG=0x1A;
   while(1){
      if(RCIF==1){
         selector=(int)RCREG-48;
         switch (selector){
            case 0:
               Apagado();
               break;
            case 1:
               Prendido();
               break;
            case 2:
               CorDer();
               break;
            case 3:
               CorIzq();
               break;
            case 4:
               IdaVuelta();
               break;
            case 5:
               Parpadeo();
               break;
            default:
               printf("error");
               break;
         }
      }
   }//while
}//main 
