ORG 0000H
	LJMP MAIN;
ORG 1000H
	MAIN:
		 MOV SP,#035H;30延时参数 34段码查询参数
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
	DelayMs:      ;【12mhz时才准确】延时上限256ms，误差每次8us，误差来自于LCALL、返回指令、R7的保护和恢复，请使用LCALL、SCALL访问本子程序,【请将参数放在30H中】,本条指令不含现场保护，本条指令需要R7&R6存储器！
		PUSH 030H;保护30H,2us
		MOV 030H,#05AH;DEC=90,1us ,111*90=9990
		DelayMsCircle1:;9992US
			PUSH 030H;2us
			MOV 030H,#034H;DEC=52,1us
			DelayMsCircle2:
				DJNZ 030H,DelayMsCircle2;2us*52=104us
			POP 030H;2us
			DJNZ 030H,DelayMsCircle1  		;2us;DelayMsCircle执行一次需要4us,循环4*249=996US
		POP 030H;恢复30H,2us
		NOP;1US
		NOP;1US
		NOP;1US
		DJNZ 030H,DelayMS		   	    ;转移，2us
		RET
	TransferNumberToSignCode:;数字转换段码;传入参数请放入034H，结果将放在034H，将使用DPTR,A，需要TAB2
		PUSH Acc
		MOV DPTR,#TAB2
		MOV A,034H
		MOVC A,@A+DPTR;查表
		CPL A;【共阴极请注释此句，共阳极请保持此句有效】
		MOV 034H,A;结果保存在034H中
		POP Acc
		RET
	TAB2:;这是段码表
		DB 03FH,006H,05BH,04FH,066H,06DH,07DH,007H,07FH,06FH;0-9
		DB 077H,07CH,039H,05EH,079H,071H;A-F
END