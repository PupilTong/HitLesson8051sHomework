ORG 0000H
	LJMP MAIN;
ORG 000BH
	LJMP Timer0Processer;�������������߳�
ORG 1000H
	MAIN:
		 MOV SP,#039H;30��ʱ������31��ʱ������32TL0��33TH0��34�����ѯ������35���������36P0��ʾ��37P2��ʾ,38���´���
		 ACALL InitialiseTimer0
		 MOV 038H,#0H
		 MainFunction:
			JNB P3.7,Check
			MOV A,035H
			CJNE A,#100,RUN
			MOV 038H,#02;ֹͣ��ʱ�ñ�־λ
			CLR EA
			SJMP MainFunction;
		RUN:
			MOV B,#10
			DIV AB
			MOV 034H,B;ȡ��λ
			ACALL TransferNumberToSignCode;����λת��
			MOV 037H,034H;�������λ������
			MOV 034H,A;
			ACALL TransferNumberToSignCode;����λת��
			MOV 036H,034H
			ORL 036H,#80H
			MOV P0,#00H
			MOV P0,036H
			MOV P2,#00H
			MOV P2,037H
			SJMP MainFunction
		Check:
			MOV 030H,#02H
			ACALL DelayMs;����
			JNB P3.7,Start
			SJMP MainFunction
		Start:
			INC 038H
			MOV A,038H
			CJNE A,#03H,RETU
				MOV 035H,#0H
				MOV 038H,#0
			WAIT:JNB P3.7,WAIT;�ȴ��ɿ�
			SJMP MainFunction
			RETU:
				CPL EA
				JNB P3.7,WAIT;�ȴ��ɿ�
				SJMP MainFunction
	Timer0Processer:
		MOV TL0,032H;2us
		MOV TH0,033H;2usװ���ֵ
		DJNZ 031H,Return;���û��ѭ����������ֱ�ӷ���2us
			MOV 031H,#02H;���¶�ʱ2��2us
			INC 035H;1us
			NOP ;1US
		Return:
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
		MOV 031H,#02H;��ʱ2��
		MOV 032H,#0BAH;
		MOV 033H,#03CH;15546,49990us
		MOV TMOD,#01H;����T0�����ڷ�ʽ1
		MOV TL0,032H;
		MOV TH0,033H;װ���ֵ
		SETB PT0;�����ȼ�
		SETB ET0;����T0�ж�
		SETB TR0;����T0
		CLR EA;�ر����ж�
		RET
	TransferNumberToSignCode:;����ת������;������������034H�����������034H����ʹ��DPTR,A����ҪTAB2
		PUSH Acc
		MOV DPTR,#TAB2
		MOV A,034H
		MOVC A,@A+DPTR;���
		;CPL A;����������ע�ʹ˾䣬�������뱣�ִ˾���Ч��
		MOV 034H,A;���������034H��
		POP Acc
		RET
	TAB2:;���Ƕ����
		DB 03FH,006H,05BH,04FH,066H,06DH,07DH,007H,07FH,06FH;0-9
		DB 077H,07CH,039H,05EH,079H,071H;A-F
END