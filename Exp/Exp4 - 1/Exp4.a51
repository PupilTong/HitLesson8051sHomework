ORG 0000H
	LJMP MAIN;
ORG 0003H
	LJMP Int0Processer;
ORG 000BH
	LJMP Timer0Processer;������ʾ�����߳�
ORG 0013H
	LJMP Int1Processer;
ORG 0023H
	LJMP SerialProcesser;
ORG 1000H
	MAIN:
		 MOV P1,#0F0H;
		 MOV P2,#01H;��ʼ����ѡ�����λ
		 MOV 037H,#090H;
		 MOV 038H,#0F9H;
		 MOV 039H,#090H;
		 MOV 03AH,#0F9H;
		 MOV 03BH,#0F9H;
		 MOV 03CH,#000H;
		 MOV 03DH,#0F9H;
		 MOV 03EH,#000H;
		 MOV 03FH,#00H;��ʼ��ָ��
		 MOV SP,#048H;030�ӳٴ��Σ�031��ʱ�жϴ�����032��ʱ���жϵͰ�λ��033��ʱ���жϸ߰�λ
		 ;034������ʱ����/��ʼ�����򴫲���ʼ��ַ,035���̴��������ʱ�������Ĵ�������д��֧��䣩/��ʼ�����򴫲���ֹ��ַ,036H���̽��
		 ;037-03E��ʾ���ִ洢,03F����ʾλѡָ��;040H��Ϊ���ڷ�����ʼ��ַ/ָ�룬041H���ڷ�����ֹ��ַ
		 ;MOV 036H,#0FFH;
		 ACALL InitialiseSerial;��ʼ������
		 ACALL InitialiseTimer0;��ʼ����ʱ��0
		 MOV TMOD,#022H;�������ö�ʱ��������ʽ
		 ACALL InitialiseInt0;��ʼ���ж�0�������ж�
		 ACALL InitialiseInt1;��ʼ���ж�1�����ڷ���
		 MainFunction:
				SJMP MainFunction;
	Int0Processer:
		ACALL GetP1KeypadTo3435;
		ACALL SearchKeypadValue;
		ACALL TransferNumberToSignCode;
		MOV 040H,039H;
		MOV 039H,038H;
		MOV 038H,037H;����ȫ��Ϊ�������֣�037H����
		MOV 037H,034H;���һλ�������������
		RETI
	Int1Processer:
		MOV 040H,#037H
		MOV 041H,#03AH;��037���͵�3A
		ACALL SerialSent;
		RETI
	Timer0Processer:
		;MOV TL0,032H;
		;MOV TH0,033H;����װ���ֵ
		DJNZ 031H,Return;���û��ѭ����������ֱ�ӷ���
		MOV 031H,#0AH;���¶�ʱ10��
		ACALL FlashSigner;
		Return:
			RETI;
	FlashSigner:;λѡɨ��
		MOV P0,#0FFH;��������
		MOV A,P2;
		RR A;
		MOV P2,A;λѡ
		MOV A,03FH;45h�����һ��ѡ����һλ
		ADD A,#037H;037h�ǵ�һλ���������ַ
		MOV R0,A;R0��ʱ����
		MOV A,@R0;ȡĿ���ַ������
		MOV P0,A;
		INC 03FH;
		MOV A,03FH
		CJNE A,#08H,Return;��δ���������
		MOV 03FH,#00H;�Ѿ����������
		RET
	SerialProcesser:;ר�ô��ڽ��մ�����
		PUSH Acc
		JB RI,SerialReceive;
		CLR TI;
		MOV A,040H
		CJNE A,041H,ToSerialSentFrame;Ŀ�ĵ�ַ������ĩ��ַ�ͼ�������
		SerialProcesserEnd:
			POP Acc
			RETI
		SerialReceive:
			CLR RI
			MOV A,SBUF;�յ������ݴ���A
			MOV 03EH,03DH;
			MOV 03DH,03CH;
			MOV 03CH,03BH;����ȫ��Ϊ�������֣�037H����
			MOV 03BH,A;���һλ�������������
			POP Acc
			RETI
		ToSerialSentFrame:
			ACALL SerialSentFrame;���ʷ��ͺ���
			SJMP SerialProcesserEnd;
	SerialSent:;���ڷ��ͣ�ר�ú���
		DEC 040H;ĩ��ַ��һ����ΪҪ���͵����ݰ���ĩ��ַ
		SerialSentFrame:;����һ������֡
			MOV R1,041H;����Ŀ���ַ
			MOV A,@R1;����Ŀ���ַ����
			MOV SBUF,A;��������
			DEC 041H;��Ϊ��ʼ��ʱFF������������һ
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
	GetP1KeypadTo3435:;��д��A 030H 034H R7������ȡP1����������034H
		MOV 035H,P1;��ʱ����P1
		MOV 030H,#02H;��ʱ20ms����
		ACALL DelayMs;������ʱ����
		MOV A,P1;��ʱ����P1
		CJNE A,035H,EndProcesser;�Ƚ�35��P1,��������˵���Ƕ�����ֱ�ӷ���
		MOV P1,#00FH;
		MOV 034H,P1;�����жϺ�ɨ�������λ��
		MOV P1,#0F0H;--------------------------------------------------------
		ORL 034H,A;0000 1110 ORL 1110 0000 = 1110 1110 EEH-----------------------------------
		RET
		EndProcesser:
			POP Acc;ֱ�������ת��������ʱ����ĵ�ַ
			POP Acc;
			RETI;�����жϴ������
	SearchKeypadValue:;������������034H�����������034H����ʹ��DPTR��A����ҪTAB1
		MOV DPTR,#TAB1
		MOV A,034H
		MOV A,#00H;
		SearchKeypadValueLoop:
			PUSH Acc;
			MOVC A,@A+DPTR;�������A
			CJNE A,034H,SearchKeypadValueNotTrue;�����ھ���ת
			POP Acc;
			MOV 034H,A;������
		RET;
		SearchKeypadValueNotTrue:
			POP Acc;
			INC A
			CJNE A,#0FH,NotSearchFailed;��û����16����15��,�ͼ���ѭ��
				LJMP EndProcesser;���ˣ�ֱ���˳�
			NotSearchFailed:
				SJMP SearchKeypadValueLoop;
	TransferNumberToSignCode:;����ת������;������������034H�����������034H����ʹ��DPTR,A����ҪTAB2
		PUSH Acc
		MOV DPTR,#TAB2
		MOV A,034H
		MOVC A,@A+DPTR;���
		CPL A;����������ע�ʹ˾䣬�������뱣�ִ˾���Ч��
		MOV 034H,A;���������034H��
		POP Acc
		RET
	InitialiseInt0:
		SETB IT0;�½��ش�����ʽ
		CLR PX0;�����ȼ�
		SETB EX0;int0�ж�����
		;SETB EA ;���ж�����
		RET
	InitialiseInt1:
		SETB IT1;�½��ش�����ʽ
		CLR PX1;�����ȼ�
		SETB EX1;int0�ж�����
		SETB EA ;���ж�����
		RET
	InitialiseTimer0:
		MOV 031H,#0AH;��ʱ10��,500us
		MOV 032H,#000H;
		MOV 033H,#000H;��ʱԼ50us
		MOV TMOD,#02H;����T0�����ڷ�ʽ2
		MOV TL0,032H;
		MOV TH0,033H;װ���ֵ
		CLR PT0;�����ȼ�
		SETB ET0;����T0�ж�
		SETB TR0;����T0
		;SETB EA;���ж�
		RET
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
	TAB1:
		DB 0EEH,0DEH,0BEH,07EH;0,1,2,3
		DB 0EDH,0DDH,0BDH,07DH;4,5,6,7
		DB 0EBH,0DBH,0BBH,07BH;8,9,A,B
		DB 0E7H,0D7H,0B7H,077H;C,D,E,F
	TAB2:;���Ƕ����
		DB 03FH,006H,05BH,04FH,066H,06DH,07DH,007H,07FH,06FH;0-9
		DB 077H,07CH,039H,05EH,079H,071H;A-F
END