#include <16f877.h> //se dice que micro computador utilizamos
#fuses HS,NOPROTECT,
#use delay(clock=20000000) //Se asigna la velocidad del reloj
#org 0x1F00, 0x1FFF void loader16F877(void) {} //for the 8k 16F876/7
int var1; //una variable del tipo int
void main(){
while(1){
var1=input_a(); //se asigna el valor de tipo int leyendo el puerto A
output_b(var1); //se muestra el valor que se guardo en el puerto B
}//while
}//main
