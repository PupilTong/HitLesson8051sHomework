ORG 0000H
	LJMP MAIN;
ORG 1000H
	MAIN:
		MOV SP,#048H;030�ӳٴ��Σ�031��ʱ�жϴ�����032��ʱ���жϵͰ�λ��033��ʱ���жϸ߰�λ
		;034������ʱ����/��ʼ�����򴫲���ʼ��ַ,035���̴��������ʱ�������Ĵ�������д��֧��䣩/��ʼ�����򴫲���ֹ��ַ,036H���̽��
		;037-03E��ʾ���ִ洢,03F����ʾλѡָ��;040H��Ϊ���ڷ�����ʼ��ַ/ָ�룬041H���ڷ�����ֹ��ַ
		;042H ��ʾ������
		;MOV 036H,#0FFH;
		MOV 030H,05H;
		ACALL DelayMs
		ACALL InitialiseLcd
		MOV DPTR,#0C00H
		MOV A,#48H;H
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#65H;e
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#6CH;l
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#6CH;l
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#6FH;o
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#20H;�ո�
		MOVX @DPTR,A;
		ACALL WaitLcd
		;-------------------
		MOV A,#57H;W
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#65H;e
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#6CH;l
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#63H;c
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#6FH;o
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#6DH;m
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#65H;e
		MOVX @DPTR,A;
		ACALL WaitLcd
		;---------------------------
		MOV DPTR,#8000H
		MOV A,#0C0H
		MOVX @DPTR,A
		ACALL WaitLcd
		MOV DPTR,#0C000H
		MOV A,#54H;T
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#6FH;o
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#20H;�ո�
		MOVX @DPTR,A;
		ACALL WaitLcd
		;---------------------------
		MOV A,#43H;C
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#68H;h
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#69H;i
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#6EH;n
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#61H;a
		MOVX @DPTR,A;
		ACALL WaitLcd
		MainFunction:
			SJMP MainFunction;
	InitialiseLcd:
		MOV DPTR,#8000H;
		MOV A,#30H
		MOVX @DPTR,A;
		MOV 030H,#01;
		ACALL DelayMs
		MOVX @DPTR,A
		MOV 030H,#01;
		ACALL DelayMs
		MOVX @DPTR,A;
		ACALL WaitLcd
		MOV A,#08H
		MOVX @DPTR,A
		ACALL WaitLcd
		MOV A,#01H
		MOVX @DPTR,A
		ACALL WaitLcd
		MOV A,#06H
		MOVX @DPTR,A
		ACALL WaitLcd
		
		MOV DPTR,#8000H;
		MOV A,#01H;;��������ACΪ0
		MOVX @DPTR,A
		ACALL WaitLcd
		MOV A,#30H;
		MOVX @DPTR,A;8λ�ӿڣ�������ʾ��5x7����
		ACALL WaitLcd
		MOV A,#0EH;
		MOVX @DPTR,A;����ʾ����꣬����˸
		ACALL WaitLcd
		MOV A,#06H
		MOVX @DPTR,A;������ʾ��acΪ����
		ACALL WaitLcd;�������
		RET
	WaitLcd:
		PUSH DPL
		PUSH DPH
		PUSH PSW
		PUSH Acc
		Wait:
			MOV DPTR,#8000H
			MOVX A,@DPTR
			JB Acc.7,Wait
		POP Acc
		POP PSW
		POP DPH
		POP DPL
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
END