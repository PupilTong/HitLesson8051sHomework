ORG 0000H
	LJMP MAIN
ORG 1000H
	MAIN:
		 MOV SP,#034H;
		 MOV A,#01H;
		 MainFunction:
			MOV 031H,#08;ѭ��8��
			MOV 032H,#0
			MOV 033H,#0FFH
			Loop1:
				MOV A,#07FH
				MOV 032H,031H
				Loop2:
					RL A
					PUSH Acc
					ANL A,033H
					MOV P0,A
					POP Acc
					MOV 030H,#50
					ACALL DelayMs
					DJNZ 032H,Loop2
				ANL A,033H
				MOV 033H,A;�����Ѿ����ĵ�
				DJNZ 031H,Loop1
			MOV 031H,#08;ѭ��8��
			MOV 032H,#0
			MOV 033H,#0FFH
			Loop3:
				MOV A,#0FEH
				MOV 032H,031H
				Loop4:
					RR A
					PUSH Acc
					ANL A,033H
					MOV P0,A
					POP Acc
					MOV 030H,#50
					ACALL DelayMs
					DJNZ 032H,Loop4
				ANL A,033H
				MOV 033H,A;�����Ѿ����ĵ�
				DJNZ 031H,Loop3
			LJMP MainFunction
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