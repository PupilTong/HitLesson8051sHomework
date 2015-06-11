#include<reg51.h>
#ifndef LCD_CHAR_1602_2005_4_9//自定义头文件
#define LCD_CHAR_1602_2005_4_9

sbit lcdrs = P1^0;
sbit lcdrw = P1^1;
sbit lcden = P1^2;

unsigned char code first[]="Hello";
unsigned char code second[]="Welcome To China";
void delay(unsigned int z){
	unsigned int x, y;
	for(x=z;x>0;x--)
	for(y=110;y>0;y--);
}
void write_com(unsigned char com){ //写入指令数据到LCD
	lcdrw=0;
	lcdrs=0;
	P0=com;
	delay(5);
	lcden=1;
	delay(5);
	lcden=0;
}
void write_data(unsigned char data){	     //写入字符显示数据到LCD
	lcdrw=0;
	lcdrs=1;
	P0=data;
	delay(5);
	lcden=1;
	delay(5);
	lcden=0;
}
 void init1602(){	   //1602液晶初始化设定
	 lcdrw=0;
	 lcden=0;
	 write_com(0x3c);
	 write_com(0x0c);
	 write_com(0x06);
	 write_com(0x01);
	 write_com(0x80);
}
void clock_init(){
	unsigned char i, j;
	for(i=0;i<5;i++){
 		write_data(first[i]);
	}
	write_com(0x80+0x40);
	for(j=0;j<16;j++){
		write_data(second[j]);
	}
}
void main(){
	init1602();
	clock_init();
}

