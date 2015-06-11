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
		RET			  ;2us
	GetP1KeypadTo3435:;将写入A 030H 034H R7，将读取P1，结果输出在034H
		MOV A,P1
		CJNE A,#0F0H,StartProcesser
		EndProcesser:
			POP Acc
			POP Acc
			LJMP MainFunction
		StartProcesser:
		MOV 035H,P1;临时保存P1
		MOV 030H,#02H;延时20ms消抖
		ACALL DelayMs;调用延时函数
		MOV A,P1;临时保存P1
		CJNE A,035H,EndProcesser;比较35与P1,如果不相等说明是抖动，直接返回
		MOV P1,#00FH;
		MOV 034H,P1;触发中断后扫描出按键位置
		MOV P1,#0F0H;--------------------------------------------------------
		ORL 034H,A;0000 1110 ORL 1110 0000 = 1110 1110 EEH-----------------------------------
		RET
	SearchKeypadValue:;传入参数请放入034H，结果将放在034H，将使用DPTR、A，需要TAB1
		MOV DPTR,#TAB1
		MOV A,034H
		MOV A,#00H;
		SearchKeypadValueLoop:
			PUSH Acc;
			MOVC A,@A+DPTR;查表结果送A
			CJNE A,034H,SearchKeypadValueNotTrue;不等于就跳转
			POP Acc;
			MOV 034H,A;输出结果
		RET;
		SearchKeypadValueNotTrue:
			POP Acc;
			INC A
			CJNE A,#10H,NotSearchFailed;还没到第16个（15）,就继续循环
				LJMP EndProcesser;到了，直接退出
			NotSearchFailed:
				SJMP SearchKeypadValueLoop;
	TransferNumberToSignCode:;数字转换段码;传入参数请放入034H，结果将放在034H，将使用DPTR,A，需要TAB2
		PUSH Acc
		MOV DPTR,#TAB2
		MOV A,034H
		MOVC A,@A+DPTR;查表
		CPL A;【共阴极请注释此句，共阳极请保持此句有效】
		MOV 034H,A;结果保存在034H中
		POP Acc
		RET
	TAB1:
		DB 0EEH,0DEH,0BEH,07EH;0,1,2,3
		DB 0EDH,0DDH,0BDH,07DH;4,5,6,7
		DB 0EBH,0DBH,0BBH,07BH;8,9,A,B
		DB 0E7H,0D7H,0B7H,077H;C,D,E,F
	TAB2:;这是段码表
		DB 03FH,006H,05BH,04FH,066H,06DH,07DH,007H,07FH,06FH;0-9
		DB 077H,07CH,039H,05EH,079H,071H;A-F
END