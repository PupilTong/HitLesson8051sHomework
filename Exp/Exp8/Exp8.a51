ORG 0000H
	LJMP MAIN;
ORG 1000H
	MAIN:
		MOV SP,#048H;030延迟传参，031定时中断次数，032定时器中断低八位，033定时器中断高八位
		;034键盘临时传参/初始化程序传参起始地址,035键盘处理程序临时变量（寄存器不能写分支语句）/初始化程序传参终止地址,036H键盘结果
		;037-03E显示数字存储,03F作显示位选指针;040H作为串口发送起始地址/指针，041H串口发送终止地址
		;042H 显示器传参
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
		MOV A,#20H;空格
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
		MOV A,#20H;空格
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
		MOV A,#01H;;清屏并置AC为0
		MOVX @DPTR,A
		ACALL WaitLcd
		MOV A,#30H;
		MOVX @DPTR,A;8位接口，两行显示，5x7点阵
		ACALL WaitLcd
		MOV A,#0EH;
		MOVX @DPTR,A;开显示及光标，不闪烁
		ACALL WaitLcd
		MOV A,#06H
		MOVX @DPTR,A;内容显示，ac为增量
		ACALL WaitLcd;设置完毕
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