ORG 0000H
	LJMP MAIN;
ORG 0003H
	LJMP Int0Processer;
;ORG 000BH
	;LJMP Timer0Processer
ORG 0013H
	LJMP Int1Processer;
ORG 0023H
	LJMP SerialProcesser;
ORG 1000H
	MAIN:
		 MOV P1,#00FH;
		 MOV SP,#037H;030延迟传参，031定时中断次数，032中断低八位，033中断高八位,034键盘，035键盘,036H键盘结果
		 MOV 036H,#0FFH;
		 ;MOV 031H,#0AH;定时10次
		 ;MOV 032H,#0B0H;
		 ;MOV 033H,#03CH;定时100ms
		 ACALL InitialiseSerial;初始化串口
		 ACALL InitialiseInt0;初始化中断
		 ACALL InitialiseInt1;初始化中断
		 MainFunction:
				SJMP MainFunction;
	Int0Processer:
		ACALL GetP1KeypadTo3435;
		ACALL SearchKeypadValue;
		MOV P2,036H;
		RETI
	InitialiseInt0:
		SETB IT0;下降沿触发方式
		CLR PX0;低优先级
		SETB EX0;int0中断允许
		;SETB EA ;总中断允许
		RET
	Int1Processer:
		ACALL SerialSent;
		RETI
	InitialiseInt1:
		SETB IT1;下降沿触发方式
		CLR PX1;低优先级
		SETB EX1;int0中断允许
		SETB EA ;总中断允许
		RET
	SerialProcesser:;专用串口接收处理函数
		JB RI,SerialReceive;
		CLR TI;
		RETI
		SerialReceive:
		CLR RI
		MOV A,SBUF;收到的数据传入A
		ANL 036H,#00FH;不改变低四位，高四位清零
		ORL A,036H;或操作，其中36H中高4位已经清零，发送来的数据低四位是零
		MOV 036H,A;处理好的数据输入036H
		MOV P2,A;
		RETI
	InitialiseSerial:;初始化串口
		MOV TMOD,#20H;定时器设置
		MOV TH1,#0FDH;
		MOV TL1,#0FDH;在11.0592时是9600
		MOV PCON,#00H;波特率不加倍
		SETB PS;串口中断高优先级
		SETB TR1;启动计数
		CLR SM0;工作方式1
		SETB SM1;工作方式1
		CLR SM2;非多机通讯
		SETB REN;允许接收数据
		SETB ES;启动串口中断
		RET;
	SerialSent:;串口发送，专用函数
		MOV A,036H;
		RL A;
		RL A;
		RL A;
		RL A;左移4次
		ANL A,#0F0H;把右边四位得出来
		MOV SBUF,A;
		Wait:
			JNB TI,Wait;
		RET
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
	GetP1KeypadTo3435:;将写入A 030H 034H 035H，将读取P1，结果输出在034H
		MOV 035H,P1;临时保存P1
		MOV P1,#0F0H;
		NOP
		MOV 034H,P1;触发中断后扫描出按键位置
		MOV 030H,#05H;延时50ms消抖
		ACALL DelayMs;调用延时函数
		MOV A,P1;临时保存P1
		CJNE A,034H,EndProcesser;比较R6与P1,如果不相等说明是抖动，直接返回
		MOV P1,#0FH;--------------------------------------------------------
		MOV A,P1;临时保存P1
		CJNE A,035H,EndProcesser;比较R7与P1,如果不相等说明是抖动，直接返回
		ORL 034H,A;0000 1110 ORL 1110 0000 = 1110 1110 EEH-----------------------------------
		RET
		EndProcesser:
			POP Acc;直接清除跳转到本程序时保存的地址
			POP Acc;
			RETI;跳出中断处理程序
	SearchKeypadValue:;传入参数请放入034H，结果将放在036H，将使用DPTR、A，需要TAB1
		MOV DPTR,#TAB1
		MOV A,#00H;
		SearchKeypadValueLoop:
			PUSH Acc;
			MOVC A,@A+DPTR;查表结果送A
			CJNE A,034H,SearchKeypadValueNotTrue;不等于就跳转
			POP Acc;
			ANL 036H,#0F0H;并不改变高4位的值，低四位清零
			ORL 036H,A;
		RET;
		SearchKeypadValueNotTrue:
			POP Acc;
			INC A
			CJNE A,#0CH,NotSearchFailed;还没到第13个（12）
				LJMP EndProcesser;到了，直接退出
			NotSearchFailed:
				SJMP SearchKeypadValueLoop;
	;Timer0Processer:
		;MOV TL0,032H;
		;MOV TH0,033H;重新装入初值
		;DJNZ 031H,Return;如果没有循环到次数就直接返回
		;MOV 031H,#0AH;重新定时10次
		;CPL P1.0;到了循环次数，P1.0口取反
		;Return:
			;RETI;
	;InitialiseTimer0:
		;MOV TMOD,#01H;设置T0工作在方式1
		;MOV TL0,032H;
		;MOV TH0,033H;装入初值
		;SETB ET0;允许T0中断
		;SETB EA;总中断
		;SETB TR0;启动T0
		;RET
	TAB1:
		DB 07DH,0EEH,0EDH,0EBH,0DEH,0DDH,0DBH;0,1,2,3,4,5,6
		DB 0BEH,0BDH,0BBH,07EH,07BH;7,8,9,*,#
END