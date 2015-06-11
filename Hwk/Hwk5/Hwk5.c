#include<reg51.h>
#include<MAX7219.h>
sbit Sounder=P3^7;
unsigned int Time=30;
unsigned int intertimes;
unsigned int start=0;
void delay(unsigned int z){
	unsigned int x, y;
	for(x=z;x>0;x--)
	for(y=110;y>0;y--);
}
void Voice(unsigned char Tone){
	unsigned long i;
	Sounder=0;
	for(i=500/Tone;i>0;i--){
		Sounder=~Sounder;
		delay(Tone);
	}
	Sounder=0;
}
unsigned int Get10(unsigned int Number){//�õ�ʮλ
	return(Number/10);
}
unsigned int Get1(unsigned int Number){
	return(Number%10);
}
void InitialiseTimer0(){
	TMOD=0x01;//����T0�����ڷ�ʽ1
	TL0=0xAF;
	TH0=0x3C;//װ���ֵ 50ms
	intertimes=20;//1s
	PT0=0;//�����ȼ�
	ET0=1;//����T0�ж�
	TR0=1;//����T0
	EA=0;//���ж�
}
void Timer0Processer(void) interrupt 1{
	TL0=0xAF;
	TH0=0x3C;//װ���ֵ 50ms
	intertimes--;
	if(intertimes==0){
		intertimes=20;
		Time--;
		Max7219Sign(0,Get10(Time));
		Max7219Sign(1,Get1(Time));
		if(Time==0){
			start=0;
			Voice(3);
			InitialiseTimer0();
		}
	}
	
}
void ResetTimes(){
	Time=30;
	Max7219Sign(0,Get10(Time));
	Max7219Sign(1,Get1(Time));
}
void main(void){
	P1=0xff;
	InitialiseMax7219();
	ResetTimes();
	InitialiseTimer0();
	P1=0xff;
	while(1){
		if(P2!=0xff){//��ʼ��ť�����ð�ť
			P2=0xff;
			delay(10);
			if(P2==0xFE&&start==0){//����ʱ��
				InitialiseTimer0();
				ResetTimes();
				Max7219Sign(3,0);
			}
			if(P2==0xfd){//��ʼ/ֹͣ
				if(start==0){//���¿�ʼ
					start=1;
					ResetTimes();
					EA=1;
					Voice(3);
				}
				else{//ֹͣ
					start=0;
					InitialiseTimer0();
					Voice(3);
				}
			}
			while(P2!=0xff);
		}
		if(start){
			if(P1!=0xff){
				delay(10);
				if(P1!=0xff){
					switch(P1){
						case 0x7F:Max7219Sign(3,8);break;
						case 0xBF:Max7219Sign(3,7);break;
						case 0xDF:Max7219Sign(3,6);break;
						case 0xEf:Max7219Sign(3,5);break;
						case 0xF7:Max7219Sign(3,4);break;
						case 0xFB:Max7219Sign(3,3);break;
						case 0xFD:Max7219Sign(3,2);break;
						case 0xFE:Max7219Sign(3,1);break;
					}
					Voice(1);
					start=0;
					InitialiseTimer0();
				}
			}
		}
	}
}