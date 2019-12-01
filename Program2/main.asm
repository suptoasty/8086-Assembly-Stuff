;*****************************************************
;*****************************************************
;*  TITLE: PROGRAM #2 Calculator
;*  Author: Jason Lonsinger
;*  Date: 10//18
;*  Purpose: Allows you to add, subtract, and compare numbers
;*****************************************************
;* Grading       _____
;* Style         _____
;* Documentation _____  Total _____
;*****************************************************


;*****************************************************
;Header

TITLE "Calculator"
.MODEL small
STACK  256
;*****************************************************


;*****************************************************
;CONSTANTS

EOS     EQU 0   ;end of string
maxLen  EQU 30  ;maximum entry string length

;bell    EQU 7   ;bell character -- <crt>G
;*****************************************************


;*****************************************************
;Data Section

.Data
    exCode  db  0   ;DOS error code
	
	StrWelcome 			  db  "Calculator. ",EOS 				;application start message
	StrPromptFirstNumber  db  "Enter first  value: ",EOS 		;prompt first number
	StrPromptSecondNumber db  "Enter second value: ",EOS        ;prompt second number
	StrPromptOperator     db  "Enter operation (+, -, C): ",EOS ;prompt for operator
	StrPromptResult		  db  "Result: ",EOS					;displays result
	
	buffer    		  db maxLen dup(?)		;buffer for side and temp storage
	StrFirstNumber	  db maxLen dup(?)		;stores inputted operand
	StrSecondNumber	  db maxLen dup(?)		;stores inputted operand
	StrOperator		  db maxLen dup(?)		;stores inputted operator
	
	FirstNumber		dw 0 ;stores value of first number
	SecondNumber	dw 0 ;stores value of second number
	Result			dw 0 ;stores result after operation
	
	StrEqual    db " = ",EOS
	StrGreater  db " > ",EOS
	StrLesser   db " < ",EOS
	
	StrOvfError db "Input Invalid! Enter Any Integer. ",EOS   ;value input error
	StrInpError db "Wrong Operator Entered! Try Again. ",EOS  ;operator input error
	StrAgain  db "Would you like to go again (Y/N)? ",EOS ;message to repeat
	StrExit   db "Calculator Program Terminated! ",EOS 	;message on exit
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
Welcome:
	call NewLine 			  ;print a new line
	mov di, OFFSET StrWelcome ;move string into di to write or read
	call StrWrite			  ;print out string
	
	call NewLine			  ;prints new line and carriage return
EnterFirstValue:
	;prompt
	mov di, OFFSET StrPromptFirstNumber
	call StrWrite
	
	;read
	mov di, OFFSET StrFirstNumber
	mov cx, maxLen ;max number of characters
	call StrRead
	
	;conversion to binary for modifying
	call AscToBin
	mov FirstNumber, ax
	jc  ToError ;input error jmp see ToError
	jz  ToError ;prevents blank space from being input
	
	call NewLine
	jmp EnterSecondValue ;input valid jmp to second input
EnterSecondValue:
	;prompt
	mov di, OFFSET StrPromptSecondNumber
	call StrWrite
	
	;read
	mov di, OFFSET StrSecondNumber
	mov cx, maxLen
	call StrRead
	
	;conversion to binary for modifying
	call AscToBin
	mov SecondNumber, ax
	jc  ToError ;input error jmp see ToError
	jz  ToError ;prevents blank space from being input
	
	call NewLine
	jmp EnterOperatorValue ;input valid jmp to third input
	
;used to overcome limited jump range of jo
ToError:
	jmp ValueInputError

;Recieves Operator and Evaluates it
EnterOperatorValue:
	;prompt
	mov di, OFFSET StrPromptOperator
	call StrWrite
	
	;read
	mov di, OFFSET StrOperator
	mov cx, 2 ;only allow 1 character
	call StrRead
	
	call NewLine
	
	;if lvalue == rvalue then jump to operation label
	cmp StrOperator, '+'
	je  AddNumbers				;addition chosen
	cmp StrOperator, '-'
	je  SubtractNumbers			;subtraction chosen
	cmp StrOperator, 'C'
	je  CompareNumbers			;comparison chosen
	cmp StrOperator, 'c'
	je  CompareNumbers			;comparison chosen
	
	;else jmp to input error
	jmp InputError				;input error jmp to InputError
	
AddNumbers:
	mov ax, FirstNumber
	add ax, SecondNumber
	jc  ToError
	mov Result, ax
	
	mov di, OFFSET StrPromptResult
	call StrWrite
	
	mov di, OFFSET buffer
	mov ax, Result
	mov cx, 1 ;removes zero padding
	call SBinToAscDec
	call StrWrite
	
	jmp Again

SubtractNumbers:
	mov ax, FirstNumber
	sub ax, SecondNumber
	mov Result, ax
	
	mov di, OFFSET StrPromptResult
	call StrWrite
	
	mov di, OFFSET buffer
	mov ax, Result
	mov cx, 1 ;removes zero padding
	call BinToAscDec
	call StrWrite

	jmp Again

CompareNumbers:
	;greater
	mov ax, FirstNumber
	cmp ax, SecondNumber
	
	jg CompareGreater
	;lesser
	jl CompareLesser
	;equal
	jge CompareEqual
	jle CompareEqual
	je  CompareEqual
	

CompareGreater:
	mov di, OFFSET StrFirstNumber
	call StrWrite
	
	mov di, OFFSET StrGreater
	call StrWrite
	
	mov di, OFFSET StrSecondNumber
	call StrWrite
	
	jmp Again
	
CompareLesser:
	mov di, OFFSET StrFirstNumber
	call StrWrite
	
	mov di, OFFSET StrLesser
	call StrWrite
	
	mov di, OFFSET StrSecondNumber
	call StrWrite

	jmp Again
	
CompareEqual:
	mov di, OFFSET StrFirstNumber
	call StrWrite
	
	mov di, OFFSET StrEqual
	call StrWrite
	
	mov di, OFFSET StrSecondNumber
	call StrWrite

	jmp Again

Again:
	;prompt
	call NewLine
	
	mov di, OFFSET StrAgain
	call StrWrite
	
	;read
	mov di, OFFSET buffer
	mov cx, 2
	call StrRead
	
	;validate input
	cmp buffer, 'n'
	je	Done
	cmp buffer, 'N'
	je  Done
	call NewLine
	
	;if invalid jmp
	jmp EnterFirstValue

ValueInputError:
	call NewLine
	mov di, OFFSET StrOvfError
	call StrWrite
	
	jmp Start
	
InputError:
	call NewLine
	mov di, OFFSET StrInpError
	call StrWrite
	
	jmp Start

;********************************
;********************************
;* terminate

Done:
	call NewLine
	mov di, OFFSET StrExit
	call StrWrite
	
    call NewLine
    call NewLine

    mov ah, 04Ch        ;Dos Function: Exit program
    mov al, exCode      ;Return exit code value
    int 21h             ;Call Dos. Terminate program

    END Start           ;End of program / entry point
;********************************
;*****************************************************