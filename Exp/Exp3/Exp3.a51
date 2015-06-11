ORG 0000H
	LJMP MAIN;
;ORG 0003H
	;LJMP Int0Processer;
ORG 000BH
	LJMP Timer0Processer
ORG 1000H
	MAIN:
		 MOV P1,#0FEH;
		 MOV A,P2;
		 CJNE A,#0FEH,MAIN;������01h˵��û�а���
		 MOV 030H,#05H;
		 ACALL DelayMs;�ӳ�50ms����
		 MOV A,P2;
		 CJNE A,#0FEH,MAIN;������01h˵��û�а���,�Ƕ���
		 MOV SP,#034H;030�ӳٴ��Σ�031��ʱ�жϴ�����032�жϵͰ�λ��033�жϸ߰�λ
		 MOV 031H,#0AH;��ʱ10��
		 MOV 032H,#0B0H;
		 MOV 033H,#03CH;��ʱ100ms
		 ACALL InitialiseTimer0;��ʼ���ж�
		 MOV R5,#00H;R5=0������
		 MainFunction:
				SJMP MainFunction;
	Timer0Processer:
		MOV TL0,032H;
		MOV TH0,033H;����װ���ֵ
		DJNZ 031H,Return;���û��ѭ����������ֱ�ӷ���
		MOV 031H,#0AH;���¶�ʱ10��
		CPL P1.0;����ѭ��������P1.0��ȡ��
		Return:
			RETI;
	InitialiseTimer0:
		MOV TMOD,#01H;����T0�����ڷ�ʽ1
		MOV TL0,032H;
		MOV TH0,033H;װ���ֵ
		SETB ET0;����T0�ж�
		SETB EA;���ж�
		SETB TR0;����T0
		RET
	;Int0Processer:
		;RETI;
	;InitialiseInt0:
		;CLR IT0;��ƽ������ʽ
		;SETB PX0;�����ȼ�
		;SETB EX0;int0�ж�����
		;SETB EA ;���ж�����
		;RET
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
		
END