ORG 0000H
	LJMP MAIN;
ORG 000BH
	LJMP Timer0Processer;用作计数服务线程
ORG 1000H
	MAIN:
		 MOV SP,#039H;30延时参数，31定时次数，32TL0，33TH0
		 ACALL InitialiseTimer0
		 MOV A,#0
		 MOV P1,A
		 MainFunction:
			SJMP MainFunction
	Timer0Processer:;每次进入耗时12US
		MOV 032H,#0BAH;2us
		MOV 033H,#03CH;2us
		DJNZ 031H,Return;2us
			CPL A;1us
			MOV P1,A;1us
			MOV 031H,#20H;定时20次,2us
			RETI;2us
		Return:
			NOP;1us
			NOP;1us
			NOP;1us
			NOP;1us
			RETI;2us
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
	InitialiseTimer0:
		MOV 031H,#20H;定时20次,25MS*20=500MS
		MOV 032H,#064H;
		MOV 033H,#09EH;40548,24MS988us
		MOV TMOD,#01H;设置T0工作在方式1
		MOV TL0,032H;
		MOV TH0,033H;装入初值
		SETB PT0;高优先级
		SETB ET0;允许T0中断
		SETB TR0;启动T0
		SETB EA;开启总中断
		RET
END