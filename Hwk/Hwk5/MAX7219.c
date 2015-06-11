#include<reg51.h>
#include<MAX7219.h>
unsigned char TransferNumberToSignCode(unsigned int Number){
////////利用片内的bcd转换器
//	unsigned char Return;
//	switch(Number){
//		case 0:Return=0x3f;break;
//		case 1:Return=0x06;break;
//		case 2:Return=0x5b;break;
//		case 3:Return=0x4f;break;
//		case 4:Return=0x66;break;
//		case 5:Return=0x6d;break;
//		case 6:Return=0x7d;break;
//		case 7:Return=0x07;break;
//		case 8:Return=0x7f;break;
//		case 9:Return=0x6f;break;
//		case 0xa:Return=0x77;break;
//		case 0xb:Return=0x7c;break;
//		case 0xc:Return=0x39;break;
//		case 0xd:Return=0x5e;break;
//		case 0xe:Return=0x79;break;
//		case 0xf:Return=0x71;break;
//	}
//	//Return=~Return;//共阳极请不要注释，共阴极请注释
//	return(Return);


return(Number);
}
void Max7219Sign(unsigned int SelectPort,unsigned int Number){
	switch(SelectPort){
		case 0:Max7219Send(0x01,TransferNumberToSignCode(Number));break;
		case 1:Max7219Send(0x02,TransferNumberToSignCode(Number));break;
		case 2:Max7219Send(0x03,TransferNumberToSignCode(Number));break;
		case 3:Max7219Send(0x04,TransferNumberToSignCode(Number));break;
		case 4:Max7219Send(0x05,TransferNumberToSignCode(Number));break;
		case 5:Max7219Send(0x06,TransferNumberToSignCode(Number));break;
		case 6:Max7219Send(0x07,TransferNumberToSignCode(Number));break;
		case 7:Max7219Send(0x08,TransferNumberToSignCode(Number));break;
	}
}
void Max7219Close(){
	Max7219Send(0x0c, 0x00);//工作模式地址0x0C 0X00:关闭 0x01 正常
}
void Max7219SendOneData(unsigned char Data){
	unsigned char i;
	for(i=0;i<8;i++){
		Clk=0;
		Din=Data&0x80;//写地址最高低位
		DelayTenUs();//10us
		Clk=1;
		DelayTenUs();//10us
		Data<<=1;
	}
}
void Max7219Send(unsigned char Address,unsigned char Data){
	Load=0;//开始传输
	DelayTenUs();//10us
	Max7219SendOneData(Address);
	Max7219SendOneData(Data);
	Load=1;//结束传输
}	
void InitialiseMax7219(){
	Max7219Send(0x0b,4);//4位选通
	Max7219Send(0x09,0xff);//编码模式地址0x09 0x00~0xff,为一的则位选通
	Max7219Send(0x0A,0x07);//亮度，0x0f最亮
	Max7219Send(0x0c, 0x01);//工作模式地址0x0C 0X00:关闭 0x01 正常
}
void DelayTenUs(){
	#pragma ASM
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
	#pragma ENDASM 
}