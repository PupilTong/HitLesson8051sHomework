ORG 0000H
	LJMP MAIN
ORG 0013H
	LJMP Int1Processer;
ORG 1000H
	MAIN:
		 MOV SP,#032H;
		 MOV A,#07fH;
		 ACALL InitialiseInt1;初始化中断
		 MainFunction:
			WaveLed:;流水灯模式
				MOV 031H,#08
				WaveToR:
					MOV P2,A;
					RR A;
					MOV 030H,#019H;
					ACALL DelayMs;
					DJNZ 031H,WaveToR
				MOV 031H,#08
				WaveToL:
					MOV P2,A;
					RL A;
					MOV 030H,#019H;
					ACALL DelayMs;
					DJNZ 031H,WaveToL
				SJMP MainFunction;
	DelayMs:      ;延时上限256ms，误差每次8us，误差来自于LCALL、返回指令、R7的保护和恢复，请使用LCALL、SCALL访问本子程序,【请将参数放在30H中】,本条指令不含现场保护，本条指令需要R7&R6存储器！
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
	Int1Processer:
		FlashLed:;闪烁模式
			PUSH ACC;
			MOV A,#0AAH
			MOV P2,A
			RR A
			MOV 030H,#050;
			ACALL DelayMs;
			MOV P2,A
			MOV 030H,#050;
			ACALL DelayMs;
			POP ACC;
		RETI;
	InitialiseInt1:
		CLR IT1;电平触发方式
		SETB PX1;高优先级
		SETB EX1;int1中断允许
		SETB EA ;总中断允许
		RET
		
END