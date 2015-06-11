ORG 0000H
	LJMP MAIN;
;ORG 0003H
	;LJMP Int0Processer;
ORG 000BH
	LJMP Timer0Processer
ORG 1000H
	MAIN:
		 MOV P1,#0FEH;
		 MOV A,P2;
		 CJNE A,#0FEH,MAIN;不等于01h说明没有按下
		 MOV 030H,#05H;
		 ACALL DelayMs;延迟50ms消抖
		 MOV A,P2;
		 CJNE A,#0FEH,MAIN;不等于01h说明没有按下,是抖动
		 MOV SP,#034H;030延迟传参，031定时中断次数，032中断低八位，033中断高八位
		 MOV 031H,#0AH;定时10次
		 MOV 032H,#0B0H;
		 MOV 033H,#03CH;定时100ms
		 ACALL InitialiseTimer0;初始化中断
		 MOV R5,#00H;R5=0则运行
		 MainFunction:
				SJMP MainFunction;
	Timer0Processer:
		MOV TL0,032H;
		MOV TH0,033H;重新装入初值
		DJNZ 031H,Return;如果没有循环到次数就直接返回
		MOV 031H,#0AH;重新定时10次
		CPL P1.0;到了循环次数，P1.0口取反
		Return:
			RETI;
	InitialiseTimer0:
		MOV TMOD,#01H;设置T0工作在方式1
		MOV TL0,032H;
		MOV TH0,033H;装入初值
		SETB ET0;允许T0中断
		SETB EA;总中断
		SETB TR0;启动T0
		RET
	;Int0Processer:
		;RETI;
	;InitialiseInt0:
		;CLR IT0;电平触发方式
		;SETB PX0;高优先级
		;SETB EX0;int0中断允许
		;SETB EA ;总中断允许
		;RET
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
		
END