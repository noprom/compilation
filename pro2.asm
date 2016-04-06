;==================================STACK==================================
STACKSG		SEGMENT		STACK 'S'
			DW	64	DUP('ST')
STACKSG		ENDS
;==================================DATA==================================
DATA 		SEGMENT
	ARY1	DB	18,3,0,5,100,6,7,8,30,10,11,36,13,20,15,16,17,1,19,14
			DB	'$'
			;数组一,
	CT1		EQU		($-ARY1-1)	;数组一元素个数
			DB	0
	TEMP1	DB	0 				;数组一输出时下标
			DB  0
	ARY2	DB	35,3,5,9,7,11,13,15,17,19,21,23,100,27,39,31,0,1,37,29
			DB	'$'
			;数组二
	CT2		EQU		($-ARY2-1)	;数组二元素个数
			DB 	0
	TEMP2	DB	0 				;数组二输出时下标
			DB 	0
	ARY3	DB	40 	DUP(?)		;声明数组三
			DB	'$'
	CT3		DB	0 				;数组三元素个数,初始为0
			DB	0
	TEMP3	DB	0 				;数组三输出时下标
			DB 	0
	FLAG 	DB 	0 				;输出0判断flag

DATA		ENDS
;==================================CODE==================================
CODE 		SEGMENT
			ASSUME	CS:CODE, DS:DATA, SS:STACKSG
MAIN	PROC	FAR
		MOV		AX,DATA
		MOV		DS,AX
;==================ARY1 BUBBLE SORT==================
		MOV		DI,CT1-1		;外层循环次数
LOP11:
		MOV  	CX,DI
		MOV		BX,0
LOP12:
		MOV		AL,ARY1[BX]
		CMP		AL,ARY1[BX+1]
		JLE		CONT1			;小于等于不作变化

		XCHG	AL,ARY1[BX+1]	;大于则交换位置
		MOV		ARY1[BX],AL
CONT1:
		ADD 	BX,1
		LOOP	LOP12
		DEC		DI
		JNZ		LOP11
;==================ARY1 BUBBLE ENDS==================

;==================ARY2 BUBBLE SORT==================
;排序方式相同,注释略
		MOV		DI,CT2-1
LOP21:
		MOV  	CX,DI
		MOV		BX,0
LOP22:
		MOV		AL,ARY2[BX]
		CMP		AL,ARY2[BX+1]
		JLE		CONT2
		XCHG	AL,ARY2[BX+1]
		MOV		ARY2[BX],AL

CONT2:
		ADD 	BX,1
		LOOP	LOP22
		DEC		DI
		JNZ		LOP21
;==================ARY2 BUBBLE ENDS==================

;==================输 出 排 序 结 果==================
		CALL 	OUTARY1
		CALL	OUTCR
		CALL 	OUTARY2
		CALL	OUTCR
;==================输  出  完  毕==================


		MOV		TEMP1,CT1-1		;初始化数组一循环下标
		MOV 	TEMP2,CT2-1		;初始化数组二循环下标
		MOV		CT3,0 			;初始化数组三元素个数

LOPC:	
		MOV		BL,TEMP1
		CMP		BL,0
		JL 		DONE			
		;若数组一已经遍历,则循环结束

		MOV 	BL,TEMP2
		CMP		BL,0
		JL 		DONE			
		;若数组二已经遍历,则循环结束

		MOV 	BX,WORD PTR TEMP1
		MOV 	AX,WORD PTR ARY1[BX]
		AND		AX,00FFH		
		;或取当前ARY1的元素

		MOV		BX,WORD PTR TEMP2
		MOV 	BX,WORD PTR ARY2[BX]
		AND		BX,00FFH
		;或取当前ARY2的元素

		CMP		AX,BX			;比较两数组当前元素
		JE 		E 				;ARY1=ARY2,跳转至等于处理
		JL 		L 				;ARY1<ARY2,跳转至小于处理
		JG 		G				;ARY1>ARY2,跳转至大于处理
E:		
		;等于处理
		MOV		BX,WORD PTR CT3
		AND 	BX,00FFH
		MOV 	ARY3[BX],AL
		;将元素存入ARY3

		DEC 	TEMP1		
		DEC 	TEMP2		
		;更改两数组下标,向前移动

		INC 	CT3
		;数组三元素个数加一

		JMP		LOPC	;继续遍历

L:	
		;小于处理,ARY1<ARY2
		DEC 	TEMP2	;数组二下标递减(ARY1,ARY2均为升序排列)
		JMP		LOPC	;继续遍历

G:
		;大于处理,ARY1>ARY2
		DEC 	TEMP1	;数组一下标处理
		JMP 	LOPC	;继续遍历

DONE:
		;遍历结束,输出ARY3
		CALL 	OUTARY3

		MOV     AX,4C00H
		INT     21H
MAIN   	ENDP

;===============================================
OUTCR	PROC
		;输出回车
		MOV  	AH,2 		;OUTPUT CR
     	MOV  	DL,0DH    	;OUTPUT CR
     	INT  	21H       	;OUTPUT CR
     	MOV  	DL,0AH    	;OUTPUT CR
     	INT  	21H       	;OUTPUT CR
     	RET
OUTCR	ENDP
;===============================================

;===============================================
OUTS	PROC
		;输出','
		MOV  	AH,2 		
     	MOV  	DL,','   	
     	INT  	21H       	
		RET
OUTS	ENDP
;===============================================

;===============================================
OUTARY1	PROC
		;输出ARY1
OUT1:
		CMP		TEMP1,CT1
		JGE		EXIT1
		MOV		DI,TEMP1
		MOV		BX,WORD PTR ARY1[DI]
		AND		BX,00FFH
		CALL	TERN	;调用二进制十进制转换并输出
		CALL	OUTS	;输出','
		INC		TEMP1
		JMP		OUT1
EXIT1:
		RET
OUTARY1 ENDP
;===============================================

;===============================================
OUTARY2	PROC
		;注释同上,略
OUT2:
		CMP		TEMP2,CT2
		JGE		EXIT2
		MOV		DI,TEMP2
		MOV		BX,WORD PTR ARY2[DI]
		AND		BX,00FFH
		CALL	TERN
		CALL	OUTS
		INC		TEMP2
		JMP		OUT2
EXIT2:
		RET
OUTARY2 ENDP
;===============================================

;===============================================
OUTARY3	PROC
		;注释同上，略
OUT3:
		MOV 	BX,TEMP3
		CMP		BX,CT3
		JGE		EXIT3
		MOV		DI,TEMP3
		MOV		BX,WORD PTR ARY3[DI]
		AND		BX,00FFH
		CALL	TERN
		CALL	OUTS
		INC		TEMP3
		JMP		OUT3
EXIT3:
		RET
OUTARY3 ENDP
;===============================================

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

CODE   	ENDS
       	END     MAIN
