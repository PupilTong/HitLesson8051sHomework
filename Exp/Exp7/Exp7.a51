ORG 0000H
	LJMP MAIN;
	MAIN:
		 MOV P1,#0F0H;
		 MOV SP,#60H;
		 MOV 034H,01H;
		 MainFunction:
				ACALL GetP1KeypadTo3435;
				ACALL SearchKeypadValue;
				ACALL TransferNumberToSignCode;
				MOV P2,034H;
				SJMP MainFunction;

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
		MOV A,P1
		CJNE A,#0F0H,StartProcesser
		EndProcesser:
			POP Acc
			POP Acc
			LJMP MainFunction
		StartProcesser:
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
			CJNE A,#10H,NotSearchFailed;��û����16����15��,�ͼ���ѭ��
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
	TAB1:
		DB 0EEH,0DEH,0BEH,07EH;0,1,2,3
		DB 0EDH,0DDH,0BDH,07DH;4,5,6,7
		DB 0EBH,0DBH,0BBH,07BH;8,9,A,B
		DB 0E7H,0D7H,0B7H,077H;C,D,E,F
	TAB2:;���Ƕ����
		DB 03FH,006H,05BH,04FH,066H,06DH,07DH,007H,07FH,06FH;0-9
		DB 077H,07CH,039H,05EH,079H,071H;A-F
END