#ifndef __MAX7219_H_
#define __MAX7219_H_
sbit Din=P3^0;
sbit Load=P3^1;
sbit Clk=P3^2;
void Max7219Send(unsigned char Address,unsigned char Data);
void Max7219Sign(unsigned int SelectPort,unsigned int Number);
void DelayTenUs();
#endif