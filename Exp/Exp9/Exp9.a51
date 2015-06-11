ORG 0000H
	LJMP MAIN
ORG 1000H
	MAIN:
		MOV A,#00H;
		LOOP:
			CLR P2.0
			CLR P2.1
			MOV P1,A
			SETB P2.0
			SETB P2.1
			INC A
			MOV 030H,#05H
			ACALL DelayMs
			SJMP LOOP
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
END