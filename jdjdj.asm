;*****************************************************
;*****************************************************
;*  TITLE: PROGRAM #6 Postfix Expression
;*  Author: Jason Lonsinger
;*  Date: 11/2/18
;*  Purpose: Computes a postfix expression
;*****************************************************
;* Grading       _____
;* Style         _____
;* Documentation _____  Total _____
;*****************************************************


;*****************************************************
;Header

TITLE "Postfix Expression Calc"
.MODEL small
STACK  256
;*****************************************************


;*****************************************************
;CONSTANTS

EOS         EQU 0     ;end of string
maxStrLen   EQU 40    ;maximum entry string length
maxTabLen	EQU 26	  ;table length

;bell    EQU 7   ;bell character -- <crt>G
;*****************************************************


;*****************************************************
;Data Section

.Data

	StrWelcome 	db "Welcome, input a postfix expression. ",  		   EOS	;application start message
	StrPrompt	db "Enter A Postfix Expression: ", EOS
	StrAgain    db "Would you like to go again (Y/N)? ",       EOS  ;message to repeat
	StrExit     db "Calculator Terminated! ",           EOS  ;message on exit
	StrOver		db "Number Entered To Large!", EOS ;error message
	StrInpErr	db "Input Invalid Enter A Posative Number!", EOS; error message
	StrSpace	db " ", EOS	;spacing for output
	StrEnter	db "Enter A Value For ", EOS
	StrColon	db ": ",EOS
	
	inputStr	  db maxStrLen  dup(?)	;string used for input
	valueInputStr db maxStrLen	dup(?)	;string for value input
	outputBuffer  db maxStrLen	dup(?)	;used to print out table
	outputBuffer2 db maxStrLen  dup(?)  ;used for printing fully evaluated expression
	sentinalStr   db 2			dup(?)  ;used for checking if user wants to run program again
	
	OpTable 	  db maxTabLen  dup(?)
	OperandTable  dw maxTabLen  dup(?)	;Used to Store Known Operands
	OperatorTable dw maxTabLen	dup(?)	;Used to store operators
	Reoccuring	  dw maxTabLen	dup(?)	;Used to tell if a variable is already used
	
	
	exCode 		 db 0   ;DOS error code
;*****************************************************


;*****************************************************
;CODE

.CODE
	;retrive needed subroutines from mta.lib
    EXTRN StrLength:proc,   StrRead:proc
    EXTRN StrWrite:proc,    NewLine:proc
    EXTRN BinToAscHex:proc, SBinToAscDec:proc, BinToAscDec:proc
    EXTRN BinToAscBin:proc, AscToBin:proc
;********************************
;EntryPoint

Start:
	mov ax, @Data   ;Initialize DS to address
    mov ds, ax      ; of data segment
    mov es, ax      ;Make es = ds	
	jmp Welcome		;welcome user
	
Welcome:
	;print greeting
	mov di, OFFSET StrWelcome
	call StrWrite
	call NewLine
	
	mov di, 0		   ;clear index for next section
	mov si, 0
	jmp ClearReOcTable ;jump to label
	
ClearReOcTable:
	;clear values that have been seen
	mov Reoccuring[di], 0	;put 0 in every value of table
	cmp di, 51				;if end of table
	je	UserInput			;	then take in input
	add di, 1				;else inc di
	jmp ClearReOcTable		;then continue to clear table
	
UserInput:
	;print prompt
	mov di, OFFSET StrPrompt
	call StrWrite
	call NewLine

	;take in input
	mov di, OFFSET inputStr
	call StrRead
	
	mov di, 0
	jmp ParseInput
	
ParseInput:	
	
	mov di, 0					;clear index
	mov si, OFFSET inputStr		;mov input from user to si index
	ploop:
		;determine if value is a letter or number and evaluate exit coniditons
		mov ax, [si]	;mov value at position into al
		cmp ax, EOS		;if end of string exit
		je  ploopDone	;exit if end of string
		and ax, 0DFh	;mask to get capital letters
		sub ax, 'A'		;normalize value to 0-25
		cmp ax, 51		;if end of alphabet
		ja  NotALetter	;not a letter
		;mov ah, 0		;other wise clear high bit
		;ax definitly has a letter
		mov di, ax
	floop:
		
		cmp Reoccuring[di], 1	;if already marked
		je  NotALetter			;go to next value entered
		
		mov bx, 1
		
		mov Reoccuring[di], bx	;else mark letter as accounted for
		; mov bl, inputStr[si]	;store ascii value in bl
		; mov bh, 0				;clear high bit
		; mov OpTable[di], bl		;store value at same position
		jmp NotALetter
	NotALetter:
		add si, 1			;increment to next value entered
		jmp ploop			;start loop over
	ploopDone:
		mov si, 0			;clear index
		mov di, 0			;clear index
		;mov OpTable+1, EOS	;mov EOS into end of table
		jmp InputValues		;go to value input

InputValues:	
	mov bx, Reoccuring[si] 	;put value into al
	cmp bx, 1				;if value is used
	je  PrintOperand		;print out the operand
	
	cmp si, 50					;if end of table
	je  InputDone				;end of loop
	
	jmp NotUsed					;else move on to next value
	
	;prompts user for a value for an operand
	PrintOperand:
		;write prompt
		call NewLine
		mov di, OFFSET StrEnter
		call StrWrite
		
		; mov al, bl
		; add al, 'A'
		
		;print operand
		mov di, OFFSET outputBuffer
		; mov al, inputStr[0]
		; mov ah, 0
		;call BinToAscDec
		call StrWrite
		
		;colon
		mov di, OFFSET StrColon
		call StrWrite
		
		jmp InputValue
	;allows user to input value for operand
	InputValue:
		;input value
		mov di, OFFSET valueInputStr
		mov cx, maxStrLen
		call StrRead
		call AscToBin
		
		jmp NotUsed
	NotUsed:
		inc si ;get next index
		inc si
		jmp InputValues ;get next value
InputDone:
	mov si, 0
	mov di, 0
	mov ax, 0
	mov bx, 0
	jmp Sentinal
		
RevalutateExpression:
	;push values to stack from table
	;pop two values from stack if operator
	;evaluate
	;push result onto stack
	
	;check if letter or operator
	mov si, OFFSET inputStr
	sloop:
		mov di, [si]	;mov value at position into al
		cmp di, EOS		;if end of string exit
		je  sloopDone	;exit if end of string
		and di, 0DFh	;mask to get capital letters
		sub di, 'A'		;normalize value to 0-25
		cmp di, 25		;if end of alphabet
		ja  sloopInc	;not a letter
		
		;is an operand push onto stack
		push OperandTable[si]
		
		jmp sloopInc
	operatorEval:
		;is an operator
		pop ax
		pop bx
		
		cmp di, '/'
		je 	Division
		cmp di, '*'
		je  Mulitplication
		cmp di, '+'
		je  Addition
		cmp di, '-'
		je  Subtraction
	sloopInc:
		inc si
		jmp sloop
	sloopDone:
		call NewLine
		mov di, OFFSET outputBuffer2
		mov cx, 1
		call BinToAscDec
		call StrWrite
	
		jmp Sentinal

	jmp Sentinal

Division:
	idiv bx
	cbw
	jmp sloopInc
Mulitplication:
	imul bx
	cbw
	jmp sloopInc
Addition:
	add ax, bx
	jmp sloopInc
Subtraction:
	sub ax, bx
	jmp sloopInc
	
Sentinal:
	;ask if user wants to run program again
	;prompt
	call NewLine
	mov di, OFFSET StrAgain
	call StrWrite
	
	;read
	mov di, OFFSET sentinalStr
	mov cx, 2
	call StrRead
	
	;validate input
	cmp sentinalStr, 'n'
	je	Done
	cmp sentinalStr, 'N'
	je  Done
	call NewLine
	
	;if invalid jmp
	jmp Welcome
	
;********************************
;* terminate

Done:
	call NewLine
	
	;print exit message
	mov di, OFFSET StrExit
	call StrWrite
	
    ;call NewLine
    call NewLine

    mov ah, 04Ch        ;Dos Function: Exit program
    mov al, exCode      ;Return exit code value
    int 21h             ;Call Dos. Terminate program
	
	
	

    END Start           ;End of program / entry point
;********************************
;*****************************************************