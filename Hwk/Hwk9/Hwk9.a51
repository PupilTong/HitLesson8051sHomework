ORG 0000H
	LJMP MAIN;
ORG 000BH
	LJMP Timer0Processer;�������������߳�
ORG 1000H
	MAIN:
		 MOV SP,#039H;30��ʱ������31��ʱ������32TL0��33TH0
		 ACALL InitialiseTimer0
		 MOV A,#0
		 MOV P1,A
		 MainFunction:
			SJMP MainFunction
	Timer0Processer:;ÿ�ν����ʱ12US
		MOV 032H,#0BAH;2us
		MOV 033H,#03CH;2us
		DJNZ 031H,Return;2us
			CPL A;1us
			MOV P1,A;1us
			MOV 031H,#20H;��ʱ20��,2us
			RETI;2us
		Return:
			NOP;1us
			NOP;1us
			NOP;1us
			NOP;1us
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
		MOV 031H,#20H;��ʱ20��,25MS*20=500MS
		MOV 032H,#064H;
		MOV 033H,#09EH;40548,24MS988us
		MOV TMOD,#01H;����T0�����ڷ�ʽ1
		MOV TL0,032H;
		MOV TH0,033H;װ���ֵ
		SETB PT0;�����ȼ�
		SETB ET0;����T0�ж�
		SETB TR0;����T0
		SETB EA;�������ж�
		RET
END