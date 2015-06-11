#ifndef __DS18B20_H_
#define __DS18B20_H_
void Init_DS18B20(void);
void WriteOneChar(unsigned char Data);
int ReadOneTemperature(void);
void Temperaturepro(unsigned char* data TempBuf);
#endif