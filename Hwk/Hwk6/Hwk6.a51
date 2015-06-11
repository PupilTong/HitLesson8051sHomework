ORG 0000H
	LJMP MAIN;
ORG 000BH
	LJMP Timer0Processer;�������������߳�
ORG 1000H
	MAIN:
		 MOV SP,#036H;30��ʱ������31��ʱ������32TL0��33TH0��034��ʱ����,35�൱��i
		 SETB P2.6 ;IΪ0ʱʱ�ߵ�ƽ
		 SETB P2.7
		 MOV 035H,#0
		 ACALL InitialiseTimer0
		 MainFunction:
			JNB P2.0,Check
			MOV A,035H
			CJNE A,#1,NOT1
				CLR P2.6;��1��iΪ1ʱA�͵�ƽ
				SJMP MainFunction
			NOT1:
				CJNE A,#2,NOT2
					SETB P2.6;��2��iΪ2��A��B��
					CLR P2.7
					SJMP MainFunction
			NOT2:;�Ȳ���1�ֲ���2
				CJNE A,#0,NOT0
					SJMP MainFunction;����0��ֱ�ӷ���
			NOT0:;��3
				SETB P2.6
				CLR EA
				MOV 035H,#0
			SJMP MainFunction
			Check:
				MOV 030H,#2
				ACALL DelayMs
				JB P2.0,MainFunction
			Run:
				CLR P2.6
				MOV 035H,#1
				SETB EA;�������ж�
				Wait:JNB P2.0,Wait
				SJMP MainFunction
	Timer0Processer:
		PUSH Acc
		MOV A,035H
		CJNE A,#1,Dong
			SJMP Next
		Dong:
			MOV TL0,#00H
			MOV TH0,#00H;3906.25HZ
		Next:
			DJNZ 031H,Return;���û��ѭ����������ֱ�ӷ���2us
			DJNZ 034H,Continue
				MOV 034H,#020;
				INC 035H;i++
				MOV A,035H
				CJNE A,#3,Return
					CLR EA;����3�Ļ���ֹͣ��
					MOV TL0,032H;
					MOV TH0,033H;װ���ֵ
				SJMP Return
		Continue:;ʱ��δ�����������Ƶ��
			MOV 031H,#0FFH;���¶�ʱ256��
		Return:
			CPL P2.3
			POP Acc
			RETI;2us
	DelayMs:      ;��12mhzʱ��׼ȷ����ʱ����256ms�����ÿ��8us�����������LCALL������ָ�R7�ı����ͻָ�����ʹ��LCALL��SCALL���ʱ��ӳ���,���뽫��������30H�С�,����ָ����ֳ�����������ָ����ҪR7&R6�洢����
		PUSH 030H;����30H,2us
		MOV 030H,#05AH;DEC=90,1us ,111*90=9990
		DelayMsCircle1:;9992US
			PUSH 030H;2us
			MOV 030H,#034H;DEC=52,1us
			DelayMsCircle2:
				DJNZ 030H,DelayMsCircle2;2us*52=104us
			POP 030H;2us
			DJNZ 030H,DelayMsCircle1  		;2us;DelayMsCircleִ��һ����Ҫ4us,ѭ��4*249=996US
		POP 030H;�ָ�30H,2us
		NOP;1US
		NOP;1US
		NOP;1US
		DJNZ 030H,DelayMS		   	    ;ת�ƣ�2us
		RET			  ;2us
	InitialiseTimer0:
		MOV 031H,#0FFH;
		MOV 034H,#030;
		MOV 032H,#055H;
		MOV 033H,#055H;128us,Լ5848hz
		MOV TMOD,#02H;����T0�����ڷ�ʽ2
		MOV TL0,032H;
		MOV TH0,033H;װ���ֵ
		SETB PT0;�����ȼ�
		SETB ET0;����T0�ж�
		SETB TR0;����T0
		CLR EA;�ر����ж�
		RET
END