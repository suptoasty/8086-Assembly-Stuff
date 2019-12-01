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

EOS         EQU 0   ;end of string
maxStrLen   EQU 1000;maximum entry string length is
					;	255 so end of string can be added 
					;	to the end of the buffer and table
maxTableLen EQU 1000;the length of the table

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
	
	inputStr	 dw	maxStrLen   dup(?)	;string used for input
	outputBuffer dw maxStrLen	dup(?)	;used to print out table
	sentinalStr  db 2			dup(?)  ;used for checking if user wants to run program again
	Ftable		 dw maxTableLen dup(?)	;table of frequencies
	row			 db	0		;used for iteration through rows
	column		 db 0		;used to tell when a newline is needed when printing
	maxNumber	 db 0
	basePrime	 db 2
	
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
	jmp Welcome
	
Welcome:
;!!!!!!!!!! Input is causing range error!!!!!!!!!!!! FIX

	;print out welcome string
	mov di, OFFSET StrWelcome	;store string for writing
	call StrWrite				;write string
	
	call NewLine				;print new line

	mov di, OFFSET inputStr
	call StrRead
	call AscToBin
	mov maxNumber, al
	jc  ThrowErrorInp
	jz  ThrowErrorInp
	
	cmp ax, maxTableLen
	;je  ThrowErrorMax
	
	call NewLine
	jmp FillTable
ThrowErrorMax:
	jmp ErrMaxToBig
ThrowErrorInp:
	jmp ErrInvalidInput
	
FillTable:
	mov di,  0
	mov row, 2
	
	;adjusts for nth position notation
	mov bl, maxNumber
	mov bh, 0
	add bl, 1

	zloop:
		mov al, row
		mov ah, 0
		
		cmp al, bl
		je	PrintTable
		
		mov Ftable[di], al
		inc di
		inc row
		jmp zloop
		
	jmp PrintTable

		
GenerateTable:
	;!!!!!!!Infinte Loop try nesting two loops!!!!!! FIX
	;ensure starting point of 2
	mov row, 0
	;mov Ftable[di], 2
	mov di, 0
	
	ploop:
		mov al, row
		mov ah, 0
		cmp al, maxNumber	;checks for end of number
		je	GenerateTable	;ints table
		
		mov al, row			;mov starting pos
		mov ah, 0
		add al, basePrime	;add current position with basePrime to find nonPrime Numbers
		mov row, al			;move to that row
		
		mov al, basePrime
		mov ah, 0
		add di, ax			;iterate 
		mov Ftable[di], 0	;clear the nonPrime number
		
		;jmp ploop			;next iteration

	jmp PrintTable			;print table
FindBasePrime:
	mov bl, basePrime
	mov bh, 0
	cmp bl, maxNumber
	je  PrintTable

	mov di, 0 ;iterator
	mov bl, 0
	mov bh, 0
	
	floop:
		mov bl, Ftable[di] 		  ;move element into storage
		mov basePrime, bl		  ;mov possible base into basePrime
		cmp bl, 0		 		  ;if number is 0 move to next element
		jne GenerateTable		  ;  else clear more values
		
		inc di 		;move to next element in table
		jmp floop	;next iteration

		

PrintTable:
	mov row, 	0
	mov column, 0
	oloop:		
		;print number
		mov al, row						;mov value into al again
		mov ah, 0
		mov si, ax						;mov ax register into si index offset
		mov al, Ftable[si]				;use index offset to put frequency for letter into al
		mov di, OFFSET outputBuffer		;print out the frequency
		mov cx, 4						;	padded with three zeros
		call BinToAscDec				;convert value from binary to ascii decimal
		call StrWrite
		
		;evalutate rows and columns
		mov al, column
		cmp al, 15
		je  NewRow
		
		;print spacing
		mov di, OFFSET StrSpace
		mov cx, 1
		call StrWrite
			
		;check for end of string
		mov al, row
			;;;adjust for nth position notation
		mov bl, maxNumber
		mov bh, 0
		sub bl, 2
			;;;
		cmp al, bl
		je	Sentinal
		
		;continue loop
		inc column
		inc row
		jmp oloop
NewRow:
	mov column, 0 ;reset columns
	call NewLine  ;print new row
	
	;check for end of string
	mov al, row
	mov ah, 0
	cmp al, maxNumber
	je	Sentinal
		
	;continue loop
	inc column
	inc row	
	jmp oloop     ;go back to loop
	
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
	
	; ;if invalid jmp
	jmp Welcome
	
ErrMaxToBig:
	mov di, OFFSET StrOver
	call StrWrite
	call newline
	
	jmp Sentinal
ErrInvalidInput:
	mov di, OFFSET StrInpErr
	call StrWrite
	call NewLine
	
	jmp Sentinal
	
;********************************
;* terminate

Done:
	call NewLine
	
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