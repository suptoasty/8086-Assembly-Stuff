;*****************************************************
;*****************************************************
;*  TITLE: PROGRAM #4 Sieve of Eratosthenes
;*  Author: Jason Lonsinger
;*  Date: 11/2/18
;*  Purpose: Calculates prime numbers
;*****************************************************
;* Grading       _____
;* Style         _____
;* Documentation _____  Total _____
;*****************************************************


;*****************************************************
;Header

TITLE "Prime Number Table"
.MODEL small
STACK  256
;*****************************************************


;*****************************************************
;CONSTANTS

EOS         EQU 0     ;end of string
maxStrLen   EQU 40    ;maximum entry string length
maxTabLen	EQU 10000 ;table length

;bell    EQU 7   ;bell character -- <crt>G
;*****************************************************


;*****************************************************
;Data Section

.Data

	StrWelcome 	db "Welcome, input an upper limit. ",  		   EOS	;application start message
	StrAgain    db "Would you like to go again (Y/N)? ",       EOS  ;message to repeat
	StrExit     db "Seive Terminated! ",           EOS  ;message on exit
	StrOver		db "Number Entered To Large!", EOS ;error message
	StrInpErr	db "Input Invalid Enter A Posative Number!", EOS; error message
	StrSpace	db " ", EOS	;spacing for output
	
	Ftable       db maxTabLen	dup(?)
	inputStr	 db	maxStrLen   dup(?)	;string used for input
	outputBuffer db maxStrLen	dup(?)	;used to print out table
	outputBuffer2 db maxStrLen	dup(?)	;used to print out table
	sentinalStr  db 2			dup(?)  ;used for checking if user wants to run program again
	column		 db 0		;used to tell when a newline is needed when printing
	maxNumber	 dw 0
	currentPrime dw 2
	prime		 dw 2
	
	
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
	;print out welcome string
	mov  di, OFFSET StrWelcome	;store string for writing
	call StrWrite				;write string
	
	call NewLine				;print new line

	mov  di, OFFSET inputStr	;mov for storage
	mov  cx, maxStrLen			;get max string length
	call StrRead				;read from cmd
	inc  ax						;adjust for nth position notation
	call AscToBin				;convert to binary
	mov  maxNumber, ax			;store binary number
	jc	 ErrInp					;error if non numbers
	
	call NewLine				;NewLine
	
	mov currentPrime, 2			;reset default prime number
	mov column, 0				;no columns printed
	mov bx, 0					;reset register
	mov si, 0					;reset index
	jmp ClearTable				;default values
ErrInp:
	;Prints invalid input error
	mov  di, OFFSET StrInpErr
	call StrWrite
	jmp Sentinal
ClearTable:
	;reset values so valid primes are not skiped on rerun
	mov Ftable[si], 0   ;set default value for element at index of si
	
	;clear values 0-1
	mov Ftable[0], 1	;0 is not prime
	mov Ftable[1], 1	;1 is not prime
	
	cmp si, maxTabLen	;if end of table
	je  TablePrime		;  Print prime numbers
	
	inc si				;increment index
	jmp ClearTable		;next iteration
TablePrime:
	;print out prime number in currentPrime
	mov al, column	;rest counter for column
	cmp al, 14		;compare to 15
	je  Line		;if equal print new line
	inc al			;else inc
	mov column, al	;store new value in column
	
	;print out currentPrime
	mov di, OFFSET outputBuffer		;used for storage
	mov ax, currentPrime			;mov current prime to ax
	mov cx, 4						;ensure four spaces
	call BinToAscDec				;convert to ascii
	call StrWrite					;print ax
	
	mov di, OFFSET StrSpace			;move spaces to be printed
	call StrWrite					;print spaces

	mov si, 0
	mov di, currentPrime			;mov current number into si
	cmp di, maxNumber				;if current prime is less than and not equal to max number
	ja Sentinal						;else quit
	ClearMultples:
		;removes multiples of current prime number
		mov Ftable[di], 1			;clear current prime
		
		cmp di, maxTabLen			;if cmp current index to max number
		ja FindNextPrime			;if values are all cleared find next prime		
		
		add di, currentPrime		;add number to get next multiple
		jmp ClearMultples			;continue clearing values
	FindNextPrime:
		cmp Ftable[si], 0			;if 0 then si is valid prime
		je  SetPrime				;set currentPrime to prime number in si
		
		;cmp si, maxNumber			;if si is past desired elements
		;ja Sentinal					;exit
		
		inc si						;else increment di
		jmp FindNextPrime			;check next number
	SetPrime:
		mov currentPrime, si		;move index that is prime into currentPrime
		jmp TablePrime				;continue printing list
Line:
	mov column, 0		;reset column
	call newline		;print new row
	jmp  TablePrime		;print next value
	
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