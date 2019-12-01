;*****************************************************
;*****************************************************
;*  TITLE: PROGRAM #6 Postfix Expression
;*  Author: Jason Lonsinger
;*  Date: 11/14/18
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

	StrWelcome 	db "Welcome, input a postfix expression. ", EOS	;application start message
	StrPrompt	db "Enter A Postfix Expression: ", EOS
	StrAgain    db "Would you like to go again (Y/N)? ", EOS  ;message to repeat
	StrExit     db "Calculator Terminated! ", EOS  ;message on exit
	StrOver		db "Number Entered To Large!", EOS ;error message
	StrInpErr	db "Input Invalid Enter A Posative Number!", EOS; error message
	StrSpace	db " ", EOS	;spacing for output
	StrEnter	db "Enter A Value For ", EOS ;prompt for value
	StrColon	db ": ", EOS	;prints a colon
	ErrInp		db "Invalid Input! ", EOS	;invalid input error message
	StrEndValue db "Your Value Is: ", EOS   ;end result of expression
	ErrDivZ		db "Can Not Divide By 0! ", EOS ;Error for zero division
	ErrStackSize db "Stack Is empty! ",EOS ;if stack does not have enough values
	
	inputStr	  db maxStrLen  dup(?)	;string used for input
	; valueInputStr db maxStrLen	dup(?)	;string for value input
	valueInputStr dw 2 Dup(?)
	outputBuffer  db maxStrLen	dup(?)	;used to print out table
	outputBuffer2 db maxStrLen  dup(?)  ;used for printing fully evaluated expression
	sentinalStr   db 2			dup(?)  ;used for checking if user wants to run program again
	
	OpTable 	  db maxTabLen  dup(?)  ;stores ascii
	OperandTable  dw maxTabLen  dup(?)	;Used to Store Known Operands
	OperatorTable dw maxTabLen	dup(?)	;Used to store operators
	Reoccuring	  db maxTabLen	dup(?)	;Used to tell if a variable is already used
	stackSize     dw 0					;holds stack size
	tempValue     dw 0					;temporary storage
	
	
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
	
	mov di, 0		   ;clear indexs for next section
	mov si, 0
	jmp ClearReOcTable ;jump to label
	
ClearReOcTable:
	;clear values that have been seen
	mov Reoccuring[di], 0	;put 0 in every value of table
	cmp di, 25				;if end of table
	je	EndClear			;	then take in input
	add di, 1				;else inc di
	jmp ClearReOcTable		;then continue to clear table
EndClear:
	mov di, 0
	jmp ClearOperTable
ClearOperTable:
	;clears operands table
	mov OperandTable[di], 0
	cmp di, 51
	je  UserInput
	
	inc di
	jmp ClearOperTable
	
UserInput:
	;print prompt
	mov di, OFFSET StrPrompt
	call StrWrite
	call NewLine

	;take in input
	mov di, OFFSET inputStr
	call StrRead
	call AscToBin
	jz   ErrInvalidInput ;check for input errors
	jo   ErrInvalidInput ;check for input errors
	
	mov di, 0
	mov dx, 0
	jmp ParseInput
ErrInvalidInput:
	;invalid input error message
	call NewLine
	mov di, OFFSET ErrInp
	call StrWrite
	jmp Sentinal
	
ParseInput:	
	;check expression for reapeat variables
	mov di, 0					;clear index
	mov si, OFFSET inputStr		;mov input from user to si index
	ploop:
		;determine if value is a letter or number and evaluate exit coniditons
		mov al, [si]	;mov value at position into al
		cmp al, EOS		;if end of string exit
		je  ploopDone	;exit if end of string
		and al, 0DFh	;mask to get capital letters
		sub al, 'A'		;normalize value to 0-25
		cmp al, 25		;if end of alphabet
		ja  NotALetter	;not a letter
		mov ah, 0		;other wise clear high bit
		;ax definitly has a letter
		mov di, ax
	floop:
		
		cmp Reoccuring[di], 1	;if already marked
		je  NotALetter			;go to next value entered
		
		mov bl, 1
		mov bh, 0
		
		mov dl, [si]
		mov dh, 0
		mov OpTable[di], dl
		mov Reoccuring[di], bl	;else mark letter as accounted for
		jmp NotALetter
	NotALetter:
		add si, 1			;increment to next value entered
		jmp ploop			;start loop over
	ploopDone:
		mov si, 0			;clear index
		mov di, 0			;clear index
		mov bx, 0
		mov ax, 0
		mov dx, 0
		jmp InputValues		;go to value input
		
InputValues:
	;input values for variables
	cmp si, 25
	ja  InputDone
	
	mov bx, si
	mov bh, 0
	mov al, Reoccuring[bx]
	mov ah, 0
	cmp al, 1
	je  PrintCurrentVariable
	jmp InputInc

	PrintCurrentVariable:
		;print message
		call NewLine
		mov di, OFFSET StrEnter
		call StrWrite
		
		;print out letter
		mov al, 'A'
		mov ah, 0
		add ax, si
		mov outputBuffer, al
		
		mov di, OFFSET outputBuffer
		mov cx, 1
		call StrWrite
		
		;print colon
		mov di, OFFSET StrColon
		call StrWrite

		;take in input
		mov di, OFFSET valueInputStr
		mov cx, maxStrLen
		call StrRead
		call AscToBin
		
		;adjust db to dw index size
		mov tempValue, ax
		mov ax, si
		mov bx, 2
		mul bx
	
		;store input in table
		mov bx, ax
		mov ax, tempValue
		mov OperandTable[bx], ax
				
		mov ax, 0
		mov bx, 0
		mov di, 0
		
		jmp InputInc

	InputInc:
		inc si
		jmp InputValues

	InputDone:
		mov si, 0
		mov ax, 0
		mov bx, 0
		mov di, 0
		mov dx, 0
		jmp RevalutateExpression	
		
RevalutateExpression:
	;evaluate the expression
	;check if letter or operator
	mov si, OFFSET inputStr
	mov dx, 0
	mov di, 0
	mov bx, 0
	mov ax, 0
	mov cx, 0
	mov stackSize, 0
	sloop:
		;check expression value by value
		mov bl, [si]	;mov value at position into al
		mov bh, 0
		mov tempValue, bx ;stores ascii for operator comparision
		cmp bl, EOS		;if end of string exit
		je  sloopDone	;exit if end of string
		and bl, 0DFh	;mask to get capital letters
		sub bl, 'A'		;normalize value to 0-25
		cmp bl, 25		;if end of alphabet
		ja  NotVariable	;not a letter		
	
		mov bh, 0
		mov ax, bx	;mov index into ax
		mov bx, 2	;mov 2 into register
		mul bx		;multiply to find value for variable
		mov bx, ax
		
		mov  ax, OperandTable[bx]   ;mov to value to ax
		push ax						;push onto stack
		inc stackSize
		
		jmp  sloopInc				;next iteration
	NotVariable:
		mov bx, tempValue				;mov acii value into dx
		
		cmp stackSize, 2				;check if stack has 1 or less values
		jb  ErrStack

		;check for operation type
		cmp bx, '*'
		je  Multiplication
		cmp bx, '/'
		je  Division
		cmp bx, '+'
		je  Addition
		cmp bx, '-'
		je  Subtraction
	sloopInc:
		inc si			;get next value in table
		jmp sloop		;rerun loop
	sloopDone:
		;Print end value
		call NewLine
		mov  di, OFFSET StrEndValue
		call StrWrite
		mov  di, OFFSET outputBuffer2
		mov  cx, 1
		pop  ax
		call SBinToAscDec
		call StrWrite
	
		jmp Sentinal	;exit loop
ErrStack:
	;stack size error message
	call NewLine
	mov di, OFFSET ErrStackSize
	call StrWrite
	jmp Sentinal
		
Division:	
	pop bx			;pop value
	pop ax			;pop value
	
	cmp bx, 0
	je  ErrDiv
	
	dec stackSize
	dec stackSize

	cwd
	idiv bx
	push ax
	inc stackSize
	
	jmp sloopInc	;continue evalutating expression
ErrDiv:
	call NewLine
	mov di, OFFSET ErrDivZ
	call StrWrite
	jmp Sentinal
	
Multiplication:
	pop bx			;pop value
	pop ax			;pop value

	dec stackSize
	dec stackSize
	
	cwd
	imul bx
	push ax
	inc stackSize

	
	jmp sloopInc	;continue evalutating expression
Addition:
	pop bx			;pop value
	pop ax			;pop value
	
	dec stackSize
	dec stackSize
	
	add  ax, bx		;add them
	push ax			;push back onto stack
	inc stackSize

	
	jmp sloopInc	;continue evalutating expression
Subtraction:
	pop bx			;pop value
	pop ax			;pop value

	dec stackSize
	dec stackSize
	
	sub  ax, bx
	push ax
	inc stackSize

	jmp sloopInc	;continue evalutating expression
	
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
	
    call NewLine
    ;call NewLine

    mov ah, 04Ch        ;Dos Function: Exit program
    mov al, exCode      ;Return exit code value
    int 21h             ;Call Dos. Terminate program
	
	
	

    END Start           ;End of program / entry point
;********************************
;*****************************************************