#include<DS18B20.h>
#include"reg51.h"
sbit DsPort=P1^6;
void Delayus(unsigned int num){
	while(num--);
}
 
/******************************************************
 
函数名称：void InitialiseDS18B20(void)
 
返回值：无
 
参数：无
 
作用：初始化18B20
 
*******************************************************/
 
void InitialiseDS18B20(void){
	char x=0;
	DsPort=1;
	Delayus(10);//稍作延时
	DsPort=0;
	Delayus(80);//延时>480us 540us
	DsPort=1; //拉高总线 15-60us
	Delayus(20);
	x=DsPort;//读总线状态 为0复位成功，为1则不成功
	Delayus(30);
	DsPort=1;//释放总线
}
/******************************************************
函数名称：unsigned char ReadOneChar(void)
返回值：unsigned char Data
参数： 无
作用：读取1820一个字节
*******************************************************/
unsigned char ReadOneChar(void)
{
unsigned char i;
unsigned char Data=0;
for(i=0;i<8;i++)
{
DsPort=0;
Data>>=1;
DsPort=1;//给脉冲
if(DsPort)
{Data|=0x80;}//读1 /// 读0右移处理
Delayus(8);//15us内读完一个数
}
return(Data);
}
/******************************************************
函数名称：void WriteOneChar(unsigned char Data)
返回值：无
参数： unsigned char Data
作用：向1820写一个字节
*******************************************************/
/////****写DS18B20***/
//写0 60us读完，写1 30us 内读完
 
void WriteOneChar(unsigned char Data)
{
	unsigned char i=0;
	for(i=0;i<8;i++){
		DsPort=0;
		DsPort=Data&0x01;//写所给数据最低位
		Delayus(10);
		///////////
		DsPort=1;//给脉冲
		Data>>=1;
	}
	Delayus(8);
}
/******************************************************
函数名称：int ReadOneTemperature(void)
返回值：int t
参数： 无
作用：读温度值
*******************************************************/
////////***读取温度值***********/
//// 每次读写均要先复位
int ReadOneTemperature(void){
	unsigned char a=0;
	unsigned char b=0;
	float tep=0;
	int t;
	InitialiseDS18B20();
	WriteOneChar(0xcc);//发跳过ROM命令
	WriteOneChar(0x44);//发读开始转换命令
	InitialiseDS18B20();
	WriteOneChar(0xcc);//发跳过ROM命令
	WriteOneChar(0xbe);//读寄存器，共九字节，前两字节为转换值
	a=ReadOneChar(); //a存低字节
	b=ReadOneChar(); //b存高字节
	t=b;
	t<<=8;//高字节转换为10进制
	t=t|a;
	tep=t*0.0625;//转换精度为0.0625/LSB
	t=tep*10+0.5;//保留1位小数并四舍五入****后面除10还原正确温度值）
	return(t);
}
/******************************************************
函数名称：uint Temperaturepro(void)
返回值：void
参数： void
作用：温度处理
*******************************************************/
void Temperaturepro(unsigned char* data TempBuf){
	int temp;
	EA=0;//关闭中断
	temp=ReadOneTemperature();
	EA=1;
	TempBuf[3]=temp/1000;//百位
	TempBuf[2]=temp/100%10;//十位
	TempBuf[1]=temp%100/10; //个位
	TempBuf[0]=temp%10; //小数
}