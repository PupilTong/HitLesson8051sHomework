ORG 0000H
	LJMP MAIN
ORG 0003H
	LJMP Int0Processer;
ORG 1000H
	MAIN:
		 MOV SP,#031H;
		 MOV A,#01H;
		 ACALL InitialiseInt0;��ʼ���ж�
		 MOV R5,#00H;R5=0������
		 MainFunction:
			WaveLed:;��ˮ��ģʽ
				MOV P1,A;
				RR A;
				MOV 030H,#019H;
				ACALL DelayMs;
				SJMP MainFunction;
	DelayMs:      ;��ʱ����256ms�����ÿ��8us�����������LCALL������ָ�R7�ı����ͻָ�����ʹ��LCALL��SCALL���ʱ��ӳ���,���뽫��������30H�С�,����ָ����ֳ�����������ָ����ҪR7&R6�洢����
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
	Int0Processer:
		FlashLed:;��˸ģʽ
			PUSH ACC;
			MOV P1,#00H;
			MOV 030H,#019H;
			ACALL DelayMs;
			MOV P1,#0FFH;
			MOV 030H,#019H;
			ACALL DelayMs;
			POP ACC;
		RETI;
	InitialiseInt0:
		CLR IT0;��ƽ������ʽ
		SETB PX0;�����ȼ�
		SETB EX0;int0�ж�����
		SETB EA ;���ж�����
		RET
		
END