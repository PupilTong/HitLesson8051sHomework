ORG 0000H
	LJMP MAIN;
ORG 000BH
	LJMP Timer0Processer;用作计数服务线程
ORG 1000H
	MAIN:
		 MOV SP,#036H;30延时参数，31定时次数，32TL0，33TH0，034定时计数,35相当于i
		 SETB P2.6 ;I为0时时高电平
		 SETB P2.7
		 MOV 035H,#0
		 ACALL InitialiseTimer0
		 MainFunction:
			JNB P2.0,Check
			MOV A,035H
			CJNE A,#1,NOT1
				CLR P2.6;是1，i为1时A低电平
				SJMP MainFunction
			NOT1:
				CJNE A,#2,NOT2
					SETB P2.6;是2，i为2是A高B低
					CLR P2.7
					SJMP MainFunction
			NOT2:;既不是1又不是2
				CJNE A,#0,NOT0
					SJMP MainFunction;等于0就直接返回
			NOT0:;是3
				SETB P2.6
				CLR EA
				MOV 035H,#0
			SJMP MainFunction
			Check:
				MOV 030H,#2
				ACALL DelayMs
				JB P2.0,MainFunction
			Run:
				CLR P2.6
				MOV 035H,#1
				SETB EA;开启总中断
				Wait:JNB P2.0,Wait
				SJMP MainFunction
	Timer0Processer:
		PUSH Acc
		MOV A,035H
		CJNE A,#1,Dong
			SJMP Next
		Dong:
			MOV TL0,#00H
			MOV TH0,#00H;3906.25HZ
		Next:
			DJNZ 031H,Return;如果没有循环到次数就直接返回2us
			DJNZ 034H,Continue
				MOV 034H,#020;
				INC 035H;i++
				MOV A,035H
				CJNE A,#3,Return
					CLR EA;等于3的话就停止了
					MOV TL0,032H;
					MOV TH0,033H;装入初值
				SJMP Return
		Continue:;时间未到，继续这个频率
			MOV 031H,#0FFH;重新定时256次
		Return:
			CPL P2.3
			POP Acc
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
		MOV 031H,#0FFH;
		MOV 034H,#030;
		MOV 032H,#055H;
		MOV 033H,#055H;128us,约5848hz
		MOV TMOD,#02H;设置T0工作在方式2
		MOV TL0,032H;
		MOV TH0,033H;装入初值
		SETB PT0;高优先级
		SETB ET0;允许T0中断
		SETB TR0;启动T0
		CLR EA;关闭总中断
		RET
END