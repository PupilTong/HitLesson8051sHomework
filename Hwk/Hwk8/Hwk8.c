#include<reg51.h>
#include<DS18B20.h>
#define SignPort P2 
sbit SignSelect0=P1^0;
sbit SignSelect1=P1^1;
sbit SignSelect2=P1^2;
sbit SignSelect3=P1^3;
unsigned char data TempBuf[4]=0;
unsigned int SignInt=0;

void delay(unsigned int z){
	unsigned int x, y;
	for(x=z;x>0;x--)
	for(y=110;y>0;y--);
}
void InitialiseTimer0(){
	TMOD=0x02;//设置T0工作在方式2
	TL0=0x00;
	TH0=0x00;//装入初值
	PT0=0;//低优先级
	ET0=1;//允许T0中断
	TR0=1;//启动T0
	EA=1;//总中断
}
unsigned char TransferNumberToSignCode(unsigned int Number){
	unsigned char Return;
	switch(Number){
		case 0:Return=0x3f;break;
		case 1:Return=0x06;break;
		case 2:Return=0x5b;break;
		case 3:Return=0x4f;break;
		case 4:Return=0x66;break;
		case 5:Return=0x6d;break;
		case 6:Return=0x7d;break;
		case 7:Return=0x07;break;
		case 8:Return=0x7f;break;
		case 9:Return=0x6f;break;
		case 0xa:Return=0x77;break;
		case 0xb:Return=0x7c;break;
		case 0xc:Return=0x39;break;
		case 0xd:Return=0x5e;break;
		case 0xe:Return=0x79;break;
		case 0xf:Return=0x71;break;
	}
	Return=~Return;//共阳极请取消注释
	return(Return);
}
void Timer0Processer(void) interrupt 1{
	SignPort=0xff;
	SignSelect0=0;
	SignSelect1=0;
	SignSelect2=0;
	SignSelect3=0;
	switch(SignInt){
		case 0:
			SignSelect0=~SignSelect0;
			SignPort=TransferNumberToSignCode(TempBuf[0]);
			break;
		case 1:
			SignSelect1=~SignSelect1;
			SignPort=TransferNumberToSignCode(TempBuf[1])&0x7F;//点亮小数点
			break;
		case 2:
			SignSelect2=~SignSelect2;
			SignPort=TransferNumberToSignCode(TempBuf[2]);
			break;
		case 3:
			SignSelect3=~SignSelect3;
			SignPort=TransferNumberToSignCode(TempBuf[3]);
			break;
	}
	SignInt++;
	if(SignInt==4){
		SignInt=0;
	}
}
void main(){
	InitialiseTimer0();
	while(1){
		Temperaturepro(TempBuf);
		delay(100);
	}
}