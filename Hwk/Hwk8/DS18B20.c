#include<DS18B20.h>
#include"reg51.h"
sbit DsPort=P1^6;
void Delayus(unsigned int num){
	while(num--);
}
 
/******************************************************
 
�������ƣ�void InitialiseDS18B20(void)
 
����ֵ����
 
��������
 
���ã���ʼ��18B20
 
*******************************************************/
 
void InitialiseDS18B20(void){
	char x=0;
	DsPort=1;
	Delayus(10);//������ʱ
	DsPort=0;
	Delayus(80);//��ʱ>480us 540us
	DsPort=1; //�������� 15-60us
	Delayus(20);
	x=DsPort;//������״̬ Ϊ0��λ�ɹ���Ϊ1�򲻳ɹ�
	Delayus(30);
	DsPort=1;//�ͷ�����
}
/******************************************************
�������ƣ�unsigned char ReadOneChar(void)
����ֵ��unsigned char Data
������ ��
���ã���ȡ1820һ���ֽ�
*******************************************************/
unsigned char ReadOneChar(void)
{
unsigned char i;
unsigned char Data=0;
for(i=0;i<8;i++)
{
DsPort=0;
Data>>=1;
DsPort=1;//������
if(DsPort)
{Data|=0x80;}//��1 /// ��0���ƴ���
Delayus(8);//15us�ڶ���һ����
}
return(Data);
}
/******************************************************
�������ƣ�void WriteOneChar(unsigned char Data)
����ֵ����
������ unsigned char Data
���ã���1820дһ���ֽ�
*******************************************************/
/////****дDS18B20***/
//д0 60us���꣬д1 30us �ڶ���
 
void WriteOneChar(unsigned char Data)
{
	unsigned char i=0;
	for(i=0;i<8;i++){
		DsPort=0;
		DsPort=Data&0x01;//д�����������λ
		Delayus(10);
		///////////
		DsPort=1;//������
		Data>>=1;
	}
	Delayus(8);
}
/******************************************************
�������ƣ�int ReadOneTemperature(void)
����ֵ��int t
������ ��
���ã����¶�ֵ
*******************************************************/
////////***��ȡ�¶�ֵ***********/
//// ÿ�ζ�д��Ҫ�ȸ�λ
int ReadOneTemperature(void){
	unsigned char a=0;
	unsigned char b=0;
	float tep=0;
	int t;
	InitialiseDS18B20();
	WriteOneChar(0xcc);//������ROM����
	WriteOneChar(0x44);//������ʼת������
	InitialiseDS18B20();
	WriteOneChar(0xcc);//������ROM����
	WriteOneChar(0xbe);//���Ĵ����������ֽڣ�ǰ���ֽ�Ϊת��ֵ
	a=ReadOneChar(); //a����ֽ�
	b=ReadOneChar(); //b����ֽ�
	t=b;
	t<<=8;//���ֽ�ת��Ϊ10����
	t=t|a;
	tep=t*0.0625;//ת������Ϊ0.0625/LSB
	t=tep*10+0.5;//����1λС������������****�����10��ԭ��ȷ�¶�ֵ��
	return(t);
}
/******************************************************
�������ƣ�uint Temperaturepro(void)
����ֵ��void
������ void
���ã��¶ȴ���
*******************************************************/
void Temperaturepro(unsigned char* data TempBuf){
	int temp;
	EA=0;//�ر��ж�
	temp=ReadOneTemperature();
	EA=1;
	TempBuf[3]=temp/1000;//��λ
	TempBuf[2]=temp/100%10;//ʮλ
	TempBuf[1]=temp%100/10; //��λ
	TempBuf[0]=temp%10; //С��
}