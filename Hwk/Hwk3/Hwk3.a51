ORG 0000H
	LJMP MAIN
ORG 0003H
	LJMP Int0Processer;
ORG 1000H
	MAIN:
		 MOV SP,#031H;
		 MOV A,#07fH;
		 ACALL InitialiseInt0;��ʼ���ж�
		 MainFunction:
			MOV P1,#00H
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
		MOV P1,#00FH;
		MOV 030H,#25
		ACALL DelayMs
		MOV P1,#0F0H
		MOV 030H,#25
		ACALL DelayMs
		MOV P1,#00H
		RETI;
	InitialiseInt0:
		SETB IT0;���ش�����ʽ
		SETB PX0;�����ȼ�
		SETB EX0;int1�ж�����
		SETB EA ;���ж�����
		RET
		
END