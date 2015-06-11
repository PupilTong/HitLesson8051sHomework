ORG 0000H
	LJMP MAIN;
ORG 0003H
	LJMP Int0Processer;
;ORG 000BH
	;LJMP Timer0Processer
ORG 0013H
	LJMP Int1Processer;
ORG 0023H
	LJMP SerialProcesser;
ORG 1000H
	MAIN:
		 MOV P1,#00FH;
		 MOV SP,#037H;030�ӳٴ��Σ�031��ʱ�жϴ�����032�жϵͰ�λ��033�жϸ߰�λ,034���̣�035����,036H���̽��
		 MOV 036H,#0FFH;
		 ;MOV 031H,#0AH;��ʱ10��
		 ;MOV 032H,#0B0H;
		 ;MOV 033H,#03CH;��ʱ100ms
		 ACALL InitialiseSerial;��ʼ������
		 ACALL InitialiseInt0;��ʼ���ж�
		 ACALL InitialiseInt1;��ʼ���ж�
		 MainFunction:
				SJMP MainFunction;
	Int0Processer:
		ACALL GetP1KeypadTo3435;
		ACALL SearchKeypadValue;
		MOV P2,036H;
		RETI
	InitialiseInt0:
		SETB IT0;�½��ش�����ʽ
		CLR PX0;�����ȼ�
		SETB EX0;int0�ж�����
		;SETB EA ;���ж�����
		RET
	Int1Processer:
		ACALL SerialSent;
		RETI
	InitialiseInt1:
		SETB IT1;�½��ش�����ʽ
		CLR PX1;�����ȼ�
		SETB EX1;int0�ж�����
		SETB EA ;���ж�����
		RET
	SerialProcesser:;ר�ô��ڽ��մ�����
		JB RI,SerialReceive;
		CLR TI;
		RETI
		SerialReceive:
		CLR RI
		MOV A,SBUF;�յ������ݴ���A
		ANL 036H,#00FH;���ı����λ������λ����
		ORL A,036H;�����������36H�и�4λ�Ѿ����㣬�����������ݵ���λ����
		MOV 036H,A;����õ���������036H
		MOV P2,A;
		RETI
	InitialiseSerial:;��ʼ������
		MOV TMOD,#20H;��ʱ������
		MOV TH1,#0FDH;
		MOV TL1,#0FDH;��11.0592ʱ��9600
		MOV PCON,#00H;�����ʲ��ӱ�
		SETB PS;�����жϸ����ȼ�
		SETB TR1;��������
		CLR SM0;������ʽ1
		SETB SM1;������ʽ1
		CLR SM2;�Ƕ��ͨѶ
		SETB REN;�����������
		SETB ES;���������ж�
		RET;
	SerialSent:;���ڷ��ͣ�ר�ú���
		MOV A,036H;
		RL A;
		RL A;
		RL A;
		RL A;����4��
		ANL A,#0F0H;���ұ���λ�ó���
		MOV SBUF,A;
		Wait:
			JNB TI,Wait;
		RET
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
	GetP1KeypadTo3435:;��д��A 030H 034H 035H������ȡP1����������034H
		MOV 035H,P1;��ʱ����P1
		MOV P1,#0F0H;
		NOP
		MOV 034H,P1;�����жϺ�ɨ�������λ��
		MOV 030H,#05H;��ʱ50ms����
		ACALL DelayMs;������ʱ����
		MOV A,P1;��ʱ����P1
		CJNE A,034H,EndProcesser;�Ƚ�R6��P1,��������˵���Ƕ�����ֱ�ӷ���
		MOV P1,#0FH;--------------------------------------------------------
		MOV A,P1;��ʱ����P1
		CJNE A,035H,EndProcesser;�Ƚ�R7��P1,��������˵���Ƕ�����ֱ�ӷ���
		ORL 034H,A;0000 1110 ORL 1110 0000 = 1110 1110 EEH-----------------------------------
		RET
		EndProcesser:
			POP Acc;ֱ�������ת��������ʱ����ĵ�ַ
			POP Acc;
			RETI;�����жϴ������
	SearchKeypadValue:;������������034H�����������036H����ʹ��DPTR��A����ҪTAB1
		MOV DPTR,#TAB1
		MOV A,#00H;
		SearchKeypadValueLoop:
			PUSH Acc;
			MOVC A,@A+DPTR;�������A
			CJNE A,034H,SearchKeypadValueNotTrue;�����ھ���ת
			POP Acc;
			ANL 036H,#0F0H;�����ı��4λ��ֵ������λ����
			ORL 036H,A;
		RET;
		SearchKeypadValueNotTrue:
			POP Acc;
			INC A
			CJNE A,#0CH,NotSearchFailed;��û����13����12��
				LJMP EndProcesser;���ˣ�ֱ���˳�
			NotSearchFailed:
				SJMP SearchKeypadValueLoop;
	;Timer0Processer:
		;MOV TL0,032H;
		;MOV TH0,033H;����װ���ֵ
		;DJNZ 031H,Return;���û��ѭ����������ֱ�ӷ���
		;MOV 031H,#0AH;���¶�ʱ10��
		;CPL P1.0;����ѭ��������P1.0��ȡ��
		;Return:
			;RETI;
	;InitialiseTimer0:
		;MOV TMOD,#01H;����T0�����ڷ�ʽ1
		;MOV TL0,032H;
		;MOV TH0,033H;װ���ֵ
		;SETB ET0;����T0�ж�
		;SETB EA;���ж�
		;SETB TR0;����T0
		;RET
	TAB1:
		DB 07DH,0EEH,0EDH,0EBH,0DEH,0DDH,0DBH;0,1,2,3,4,5,6
		DB 0BEH,0BDH,0BBH,07EH,07BH;7,8,9,*,#
END