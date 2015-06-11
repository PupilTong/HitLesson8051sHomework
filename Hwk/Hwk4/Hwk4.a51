ORG 0000H
	LJMP MAIN;
ORG 000BH
	LJMP Timer0Processer;用作计数服务线程
ORG 1000H
	MAIN:
		 MOV SP,#039H;30延时参数，31定时次数，32TL0，33TH0，34段码查询参数，35保存计数，36P0显示，37P2显示,38按下次数
		 ACALL InitialiseTimer0
		 MOV 038H,#0H
		 MainFunction:
			JNB P3.7,Check
			MOV A,035H
			CJNE A,#100,RUN
			MOV 038H,#02;停止计时置标志位
			CLR EA
			SJMP MainFunction;
		RUN:
			MOV B,#10
			DIV AB
			MOV 034H,B;取个位
			ACALL TransferNumberToSignCode;低四位转换
			MOV 037H,034H;保存低四位段码结果
			MOV 034H,A;
			ACALL TransferNumberToSignCode;高四位转换
			MOV 036H,034H
			ORL 036H,#80H
			MOV P0,#00H
			MOV P0,036H
			MOV P2,#00H
			MOV P2,037H
			SJMP MainFunction
		Check:
			MOV 030H,#02H
			ACALL DelayMs;消抖
			JNB P3.7,Start
			SJMP MainFunction
		Start:
			INC 038H
			MOV A,038H
			CJNE A,#03H,RETU
				MOV 035H,#0H
				MOV 038H,#0
			WAIT:JNB P3.7,WAIT;等待松开
			SJMP MainFunction
			RETU:
				CPL EA
				JNB P3.7,WAIT;等待松开
				SJMP MainFunction
	Timer0Processer:
		MOV TL0,032H;2us
		MOV TH0,033H;2us装入初值
		DJNZ 031H,Return;如果没有循环到次数就直接返回2us
			MOV 031H,#02H;重新定时2次2us
			INC 035H;1us
			NOP ;1US
		Return:
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
		MOV 031H,#02H;定时2次
		MOV 032H,#0BAH;
		MOV 033H,#03CH;15546,49990us
		MOV TMOD,#01H;设置T0工作在方式1
		MOV TL0,032H;
		MOV TH0,033H;装入初值
		SETB PT0;高优先级
		SETB ET0;允许T0中断
		SETB TR0;启动T0
		CLR EA;关闭总中断
		RET
	TransferNumberToSignCode:;数字转换段码;传入参数请放入034H，结果将放在034H，将使用DPTR,A，需要TAB2
		PUSH Acc
		MOV DPTR,#TAB2
		MOV A,034H
		MOVC A,@A+DPTR;查表
		;CPL A;【共阴极请注释此句，共阳极请保持此句有效】
		MOV 034H,A;结果保存在034H中
		POP Acc
		RET
	TAB2:;这是段码表
		DB 03FH,006H,05BH,04FH,066H,06DH,07DH,007H,07FH,06FH;0-9
		DB 077H,07CH,039H,05EH,079H,071H;A-F
END