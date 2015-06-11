ORG 0000H
	LJMP MAIN;
ORG 0003H
	LJMP Int0Processer;
ORG 000BH
	LJMP Timer0Processer;用作显示服务线程
ORG 0013H
	LJMP Int1Processer;
ORG 0023H
	LJMP SerialProcesser;
ORG 1000H
	MAIN:
		 MOV P1,#0F0H;
		 MOV P2,#01H;初始化，选中最低位
		 MOV 037H,#090H;
		 MOV 038H,#0F9H;
		 MOV 039H,#090H;
		 MOV 03AH,#0F9H;
		 MOV 03BH,#0F9H;
		 MOV 03CH,#000H;
		 MOV 03DH,#0F9H;
		 MOV 03EH,#000H;
		 MOV 03FH,#00H;初始化指针
		 MOV SP,#048H;030延迟传参，031定时中断次数，032定时器中断低八位，033定时器中断高八位
		 ;034键盘临时传参/初始化程序传参起始地址,035键盘处理程序临时变量（寄存器不能写分支语句）/初始化程序传参终止地址,036H键盘结果
		 ;037-03E显示数字存储,03F作显示位选指针;040H作为串口发送起始地址/指针，041H串口发送终止地址
		 ;MOV 036H,#0FFH;
		 ACALL InitialiseSerial;初始化串口
		 ACALL InitialiseTimer0;初始化定时器0
		 MOV TMOD,#022H;覆盖设置定时器工作方式
		 ACALL InitialiseInt0;初始化中断0，按键中断
		 ACALL InitialiseInt1;初始化中断1，串口发送
		 MainFunction:
				SJMP MainFunction;
	Int0Processer:
		ACALL GetP1KeypadTo3435;
		ACALL SearchKeypadValue;
		ACALL TransferNumberToSignCode;
		MOV 040H,039H;
		MOV 039H,038H;
		MOV 038H,037H;以上全部为左移数字，037H丢弃
		MOV 037H,034H;最后一位数字是新输入的
		RETI
	Int1Processer:
		MOV 040H,#037H
		MOV 041H,#03AH;从037发送到3A
		ACALL SerialSent;
		RETI
	Timer0Processer:
		;MOV TL0,032H;
		;MOV TH0,033H;重新装入初值
		DJNZ 031H,Return;如果没有循环到次数就直接返回
		MOV 031H,#0AH;重新定时10次
		ACALL FlashSigner;
		Return:
			RETI;
	FlashSigner:;位选扫描
		MOV P0,#0FFH;消除余晖
		MOV A,P2;
		RR A;
		MOV P2,A;位选
		MOV A,03FH;45h存放下一次选中哪一位
		ADD A,#037H;037h是第一位，这是求地址
		MOV R0,A;R0临时保存
		MOV A,@R0;取目标地址的数据
		MOV P0,A;
		INC 03FH;
		MOV A,03FH
		CJNE A,#08H,Return;尚未溢出，返回
		MOV 03FH,#00H;已经溢出，清零
		RET
	SerialProcesser:;专用串口接收处理函数
		PUSH Acc
		JB RI,SerialReceive;
		CLR TI;
		MOV A,040H
		CJNE A,041H,ToSerialSentFrame;目的地址不等于末地址就继续发送
		SerialProcesserEnd:
			POP Acc
			RETI
		SerialReceive:
			CLR RI
			MOV A,SBUF;收到的数据传入A
			MOV 03EH,03DH;
			MOV 03DH,03CH;
			MOV 03CH,03BH;以上全部为左移数字，037H丢弃
			MOV 03BH,A;最后一位数字是新输入的
			POP Acc
			RETI
		ToSerialSentFrame:
			ACALL SerialSentFrame;访问发送函数
			SJMP SerialProcesserEnd;
	SerialSent:;串口发送，专用函数
		DEC 040H;末地址加一，因为要发送的数据包含末地址
		SerialSentFrame:;发送一个数据帧
			MOV R1,041H;保存目标地址
			MOV A,@R1;读入目标地址数据
			MOV SBUF,A;发送数据
			DEC 041H;因为初始化时FF，所以先自增一
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
	GetP1KeypadTo3435:;将写入A 030H 034H R7，将读取P1，结果输出在034H
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
		EndProcesser:
			POP Acc;直接清除跳转到本程序时保存的地址
			POP Acc;
			RETI;跳出中断处理程序
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
			CJNE A,#0FH,NotSearchFailed;还没到第16个（15）,就继续循环
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
	InitialiseInt0:
		SETB IT0;下降沿触发方式
		CLR PX0;低优先级
		SETB EX0;int0中断允许
		;SETB EA ;总中断允许
		RET
	InitialiseInt1:
		SETB IT1;下降沿触发方式
		CLR PX1;低优先级
		SETB EX1;int0中断允许
		SETB EA ;总中断允许
		RET
	InitialiseTimer0:
		MOV 031H,#0AH;定时10次,500us
		MOV 032H,#000H;
		MOV 033H,#000H;定时约50us
		MOV TMOD,#02H;设置T0工作在方式2
		MOV TL0,032H;
		MOV TH0,033H;装入初值
		CLR PT0;低优先级
		SETB ET0;允许T0中断
		SETB TR0;启动T0
		;SETB EA;总中断
		RET
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
	TAB1:
		DB 0EEH,0DEH,0BEH,07EH;0,1,2,3
		DB 0EDH,0DDH,0BDH,07DH;4,5,6,7
		DB 0EBH,0DBH,0BBH,07BH;8,9,A,B
		DB 0E7H,0D7H,0B7H,077H;C,D,E,F
	TAB2:;这是段码表
		DB 03FH,006H,05BH,04FH,066H,06DH,07DH,007H,07FH,06FH;0-9
		DB 077H,07CH,039H,05EH,079H,071H;A-F
END