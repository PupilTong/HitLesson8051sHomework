#include<reg51.h>
sbit lcdrs = P2^0;
sbit lcdrw = P2^1;
sbit lcden = P2^2;
sbit Sounder=P2^3;
unsigned char CurrentAddress;
unsigned char code first[]=" Powered by Why  ";
unsigned char code second[]="Welcome To China";
void delay(unsigned int z){
	unsigned int x, y;
	for(x=z;x>0;x--)
	for(y=110;y>0;y--);
}
void WriteCom(unsigned char com){ //写入指令数据到LCD
	CurrentAddress=com;
	lcdrw=0;
	lcdrs=0;
	P0=com;
	delay(5);
	lcden=1;
	delay(5);
	lcden=0;
}
void WriteData(unsigned char words){	     //写入字符显示数据到LCD
	CurrentAddress++;
	lcdrw=0;
	lcdrs=1;
	P0=words;
	delay(5);
	lcden=1;
	delay(5);
	lcden=0;
}
void SendData(unsigned int Line,unsigned char* String){//发送字符串信息
	unsigned char i;
	switch(Line){
		case 1:
			WriteCom(0x80);
			for(i=0; i<16 &&String[i]!='\n';i++){
				WriteData(String[i]);
			}
			break;
		case 2:
			WriteCom(0x80+0x40);
			for(i=0; i<16 &&String[i]!='\n';i++){
				WriteData(String[i]);
			}
	}
}
void init1602(){	   //1602液晶初始化设定
	lcdrw=0;
	lcden=0;
	WriteCom(0x3c);
	WriteCom(0x0c);
	WriteCom(0x06);
	WriteCom(0x01);
}
void Delete(){//向前删除
	CurrentAddress--;
	WriteCom(CurrentAddress);
	WriteData(' ');
	CurrentAddress--;
	WriteCom(CurrentAddress);
}
void Reset(){//重新初始化LCD
	init1602();
	SendData(1,first);
	WriteCom(0x80+0x40+0x03);//往→3个字
}
void Voice(unsigned char Tone){
	unsigned int i;
	Sounder=0;
	for(i=255/Tone;i>0;i--){
		Sounder=~Sounder;
		delay(Tone);
	}
	Sounder=0;
}
void main(){
	unsigned char Keyboard1,Keyboard2;
	Reset();
	P1=0xF0;
	while(1){
		if(P1!=0xF0){//线反转法
			delay(10);
			if(P1!=0xF0){
				Keyboard1=P1;
				P1=0x0F;
				Keyboard2=P1;
				Keyboard1=Keyboard1|Keyboard2;
				switch(Keyboard1){
					case 0xEE:WriteData('2');Voice(1);break;
					case 0xDE:WriteData('1');Voice(2);break;
					case 0xBE:WriteData('0');Voice(3);break;
					case 0xED:WriteData('5');Voice(1);break;
					case 0xDD:WriteData('4');Voice(2);break;
					case 0xBD:WriteData('3');Voice(3);break;
					case 0xEB:WriteData('8');Voice(1);break;
					case 0xDB:WriteData('7');Voice(2);break;
					case 0xBB:WriteData('6');Voice(3);break;
					case 0xE7:Reset();Voice(4);break;
					case 0xD7:Delete();Voice(4);break;//
					case 0xB7:WriteData('9');Voice(1);break;
				}
				P1=0xF0;
				while(P1!=0xF0);
			}
		}
	}
}

