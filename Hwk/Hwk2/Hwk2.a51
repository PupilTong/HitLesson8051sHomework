ORG 0000H
	LJMP MAIN
ORG 0013H
	LJMP Int1Processer;
ORG 1000H
	MAIN:
		 MOV SP,#032H;
		 MOV A,#07fH;
		 ACALL InitialiseInt1;��ʼ���ж�
		 MainFunction:
			WaveLed:;��ˮ��ģʽ
				MOV 031H,#08
				WaveToR:
					MOV P2,A;
					RR A;
					MOV 030H,#019H;
					ACALL DelayMs;
					DJNZ 031H,WaveToR
				MOV 031H,#08
				WaveToL:
					MOV P2,A;
					RL A;
					MOV 030H,#019H;
					ACALL DelayMs;
					DJNZ 031H,WaveToL
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
	Int1Processer:
		FlashLed:;��˸ģʽ
			PUSH ACC;
			MOV A,#0AAH
			MOV P2,A
			RR A
			MOV 030H,#050;
			ACALL DelayMs;
			MOV P2,A
			MOV 030H,#050;
			ACALL DelayMs;
			POP ACC;
		RETI;
	InitialiseInt1:
		CLR IT1;��ƽ������ʽ
		SETB PX1;�����ȼ�
		SETB EX1;int1�ж�����
		SETB EA ;���ж�����
		RET
		
END