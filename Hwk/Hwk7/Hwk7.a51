ORG 0000H
	LJMP MAIN;
ORG 1000H
	MAIN:
		 MOV SP,#035H;30��ʱ���� 34�����ѯ����
		 MOV A,#0
		 MainFunction:
			CJNE A,#10,RUN
				MOV A,#0
				SJMP MainFunction
			RUN:
				MOV 034H,A
				ACALL TransferNumberToSignCode
				MOV P0,034H
				MOV 030H,#50
				ACALL DelayMs
				INC A
				SJMP MainFunction
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
		RET
	TransferNumberToSignCode:;����ת������;������������034H�����������034H����ʹ��DPTR,A����ҪTAB2
		PUSH Acc
		MOV DPTR,#TAB2
		MOV A,034H
		MOVC A,@A+DPTR;���
		CPL A;����������ע�ʹ˾䣬�������뱣�ִ˾���Ч��
		MOV 034H,A;���������034H��
		POP Acc
		RET
	TAB2:;���Ƕ����
		DB 03FH,006H,05BH,04FH,066H,06DH,07DH,007H,07FH,06FH;0-9
		DB 077H,07CH,039H,05EH,079H,071H;A-F
END