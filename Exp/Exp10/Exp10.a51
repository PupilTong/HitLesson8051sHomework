ORG 0000H
	LJMP MAIN
ORG 1000H
	MAIN:
		MOV A,#00H;
		CLR P2.4
		CLR P2.5
		CLR P2.6
		SETB P2.1
		LOOP:
			NOP
			NOP
			CLR P2.1;START
			NOP
			WAIT:
				JNB P2.3,WAIT
			;MOV 030H,#01H
			;ACALL DelayMs
			SETB P2.1
			MOV A,P1;
			MOV P0,A
			SJMP LOOP
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
END