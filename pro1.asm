;==================================STACK==================================
STACKSG		SEGMENT		STACK 'S'
			DW	64	DUP('ST')
STACKSG		ENDS
;==================================DATA==================================
DATA 		SEGMENT
		A		DW	0
		B		DW	0
		FLAG    DB  0
		MSGA 	DB  'Please Input A: ','$'
		MSGB	DB 	'Please Input B: ','$'
		MSGH	DB 	'====END INPUT WITH ANY WORD KEY====','$'
DATA		ENDS
;==================================CODE==================================
CODE 		SEGMENT
		ASSUME 	CS:CODE, DS:DATA, SS:STACKSG
MAIN	PROC	FAR
		MOV 	AX,DATA
		MOV		DS,AX
		MOV		BX,0 	;BX FOR TEMP NUMBER,BX寄存器用于存放暂时数据

INPUTASTART:
		;开始输入
		MOV 	AH,9
		LEA 	DX,MSGH
		INT 	21H
		;输出提示信息

		MOV  	AH,2 		;OUTPUT CR
     	MOV  	DL,0DH    	;OUTPUT CR
     	INT  	21H       	;OUTPUT CR
     	MOV  	DL,0AH    	;OUTPUT CR
     	INT  	21H       	;OUTPUT CR
     	;输出回车

		MOV 	AH,9
		LEA 	DX,MSGA
		INT 	21H
		;输出提示信息

INPUTA:
		;循环读入A
		MOV 	AH,1
		INT 	21H

		SUB 	AL,30H		;ASCII转化为二进制数

		JL		SAVE_A		
		CMP		AL,9
		JG		SAVE_A		;输入不是数字则终止A的输入

		CBW					;AL-->AX,AL位拓展

		XCHG	AX,BX 
		MOV		CX,10
		MUL		CX			;AX*10-->AX
		XCHG	AX,BX		
		;以上代码将原来BX中的数据乘10

		ADD		BX,AX 		;AX+BX-->BX

		JMP 	INPUTA		;继续输入A


SAVE_A:

		MOV  	AH,2 		;OUTPUT CR
     	MOV  	DL,0DH    	;OUTPUT CR
     	INT  	21H       	;OUTPUT CR
     	MOV  	DL,0AH    	;OUTPUT CR
     	INT  	21H       	;OUTPUT CR
     	;输出回车

     	MOV		A,BX		;SAVE A,BX-->A
     	MOV		BX,0 		;0-->BX,初始化BX

     	MOV 	AH,9
		LEA 	DX,MSGB
		INT 	21H
		;输出提示信息

INPUTB:
		;以下与INPUTA代码相似，注释略
		MOV 	AH,1
		INT 	21H

		SUB 	AL,30H		;ASCII-->DECIMAL NUMBER

		JL		SAVE_B	
		CMP		AL,9
		JG		SAVE_B 		;JUMP PART

		CBW					;AL-->AX

		XCHG	AX,BX
		MOV		CX,10
		MUL		CX			;AX*10-->AX
		XCHG	AX,BX		

		ADD		BX,AX 		
		JMP 	INPUTB		

SAVE_B:
		MOV		B,BX		;SAVE B,BX-->B

PA:
		MOV		AX,A
		AND		AX,0001H
		CMP		AX,0000H
		;判断A的奇偶

		JG		B2			;A为奇数,跳转至B2

B1:
		;A为偶数
		MOV		AX,B
		AND		AX,0001H
		CMP		AX,0000H
		;判断B的奇偶

		JG		ABXCHG 		;B为奇数,跳转至ABXCHG,交换AB
		JMP 	OUTPUT

B2:
		;A为奇数
		MOV		AX,B
		AND		AX,0001H
		CMP		AX,0000H
		;判断B的奇偶

		JG 		ABINC 		;A为奇数,跳转至ABINC,AB各加一
		JMP 	OUTPUT

ABXCHG:
		;交换AB
		MOV  	AX,A
		MOV 	BX,B
		MOV 	A,BX
		MOV 	B,AX
		JMP 	OUTPUT

ABINC:
		;A+1,B+1
		INC 	WORD PTR A
		INC 	WORD PTR B

OUTPUT:
  		;输出
		MOV 	AH,2
		MOV		DL,'A'
		INT 	21H
		MOV		DL,'='
		INT 	21H

		MOV		BX,A 		;OUTPUT A
		CALL	TERN

		MOV  	AH,2 		;OUTPUT CR
     	MOV  	DL,0DH    	;OUTPUT CR
     	INT  	21H       	;OUTPUT CR
     	MOV  	DL,0AH    	;OUTPUT CR
     	INT  	21H       	;OUTPUT CR

     	MOV 	AH,2
		MOV		DL,'B'
		INT 	21H
		MOV		DL,'='
		INT 	21H

		MOV 	BX,B 		;OUTPUT B
		CALL 	TERN

		MOV     AX,4C00H
      	INT     21H
MAIN	ENDP

;===============================================
TERN	PROC
		;二进制十进制转化
		MOV 	FLAG,0		;标志位初始化

		MOV		CX,10000
		CALL	DEC_DIV
	
		MOV		CX,1000
		CALL	DEC_DIV
	
		MOV		CX,100
		CALL 	DEC_DIV
	
		MOV		CX,10
		CALL 	DEC_DIV

		MOV		CX,1
		CALL	DEC_DIV

		CMP 	FLAG,0 		;若FLAG为0则证明要输出的二进制数为0
		JG 		TEXIT		
		MOV 	AH,2 		;若要输出的二进制数为0,则这个数不会被DIV_DEC输出
		MOV 	DL,'0' 		;因此在这里输出0
		INT 	21H

TEXIT:
		RET
TERN 	ENDP
;===============================================

;===============================================
DEC_DIV PROC
		
		MOV		AX,BX
		MOV 	DX,0

		DIV 	CX
		MOV		BX,DX

		MOV 	DL,AL
		ADD 	DL,30H

		CMP		FLAG,0 		
		JG 		FLAG1 		;FLAG为1,说明之前有非0位,直接输出
		CMP 	DL,'0' 		;FLAG非0,说明之前全部为0位,将当前位于0比较
		JE 		NP   		;当前位为0,不输出
		MOV 	FLAG,1 		;当前位不为0,将FLAG置1

FLAG1: 
		;输出当前位
		MOV		AH,2
		INT 	21H
NP:
		;跳转至此则不输出当前位
		RET
DEC_DIV	ENDP
;===============================================


CODE	ENDS
		END 	MAIN
