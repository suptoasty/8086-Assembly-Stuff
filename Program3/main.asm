;*****************************************************
;*****************************************************
;*  TITLE: PROGRAM #4 Frequency Calc
;*  Author: Jason Lonsinger
;*  Date: 10/24/18
;*  Purpose: Allows you to add find the frequency of a string of characters
;*****************************************************
;* Grading       _____
;* Style         _____
;* Documentation _____  Total _____
;*****************************************************


;*****************************************************
;Header

TITLE "String Frequency Counter"
.MODEL small
STACK  256
;*****************************************************


;*****************************************************
;CONSTANTS

EOS         EQU 0   ;end of string
maxStrLen   EQU 255 ;maximum entry string length is
					;	255 so end of string can be added 
					;	to the end of the buffer and table
maxTableLen EQU 26	;the length of the table

;bell    EQU 7   ;bell character -- <crt>G
;*****************************************************


;*****************************************************
;Data Section

.Data

	StrWelcome 	db "Welcome, input a string of characters. ",  EOS	;application start message
	StrHeader	db "  Letter       Frequency",				   EOS  ;header for column labels
	StrDivider	db "  ------       ---------",				   EOS	;divider for StrHeader
	StrAgain    db "Would you like to go again (Y/N)? ",       EOS  ;message to repeat
	StrExit     db "Frequency Counter Terminated! ",           EOS  ;message on exit
	StrSpace4	db "    ",		 EOS	;four spaces
	StrSpace10	db "          ", EOS	;ten  spaces
	
	inputStr	 db	maxStrLen   dup(?)	;string used for input
	sentinalStr  db 2			dup(?)  ;used for checking if user wants to run program again
	Ftable		 db maxTableLen dup(?)	;table of frequencies
	outputBuffer db 100 dup(?)			;used to print out table
	row			 db	0					;used for iteration through rows
	
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
	;goto to welcome
	jmp welcome
	
Welcome:
	;print out welcome string
	mov di, OFFSET StrWelcome	;store string for writing
	call StrWrite				;write string
	
	call NewLine				;print new line
	;goto to clearTable
	jmp ClearTable
	
ClearTable:
	;clears table
	mov cx, maxStrLen
	mov di, 0 					;use as index
	zloop:
		mov Ftable[di], 0		;mov 0 into Ftable position with offset of di
		inc di					;increment di for next iteration
		cmp di, maxTableLen		;compare di to end of table
		jne zloop				;continue clearing table
	;goto to StrInput
	jmp StrInput
		
StrInput:
	;read string from cmd and convert to upper case
	;read from cmd into inputStr
	mov di, OFFSET inputStr		;thing to read into
	call StrRead				;actual read
	
	mov si, OFFSET inputStr		;use si as index storage
	ploop:
		mov al, [si]			;mov value at si into al
		cmp al, EOS				;check if at end of table
		je	ploopDone			;if above is true end loop
		and al, 0DFh			;use a hex mask to force upper case lettering
		sub al, 'A'				;use an ascii character to evaluate input
		cmp al, 25				;bounds checking as part of aboce evaluation
		ja	NotALetter			;account for invalid input
		mov ah, 0				;adjust for 16 bit values
		mov di, ax				;adjust
		inc Ftable[di]			;offset
	NotALetter:
		;ignore things that are not letters
		inc si		;skip over thing that is not a letter
		jmp	ploop	;continue loop
	ploopDone:
		call NewLine
		;goto table output
		jmp PrintTable
		
PrintTable:
	;prints out the table
	;;;;prints the header for columns
		;header left section
	call NewLine
	mov di, OFFSET StrHeader
	call StrWrite
	
		;;header right section
		;	move to past left section
	mov di, OFFSET StrSpace4				;spacing for letter
	call StrWrite
	call StrWrite
	
	mov di, OFFSET StrHeader
	call StrWrite
		;;
	
	call NewLine	;newline for divider
	
		;;divider left section
	mov di, OFFSET StrDivider
	call StrWrite
	
		;divider right section
		;	mov past left divider
	mov di, OFFSET StrSpace4		
	call StrWrite
	call StrWrite
	
	mov di, OFFSET StrDivider
	call StrWrite
		;;
		
	call NewLine
	;;;;
	
	;prints table
	mov row, 0	;set row index to 0
	oloop:
		mov di, OFFSET StrSpace4		;spacing for letter
		call StrWrite
		
		mov al, row						;store row value in al
		add al, 'A'						;set letter to use based on value in al
		mov outputBuffer, al			;value into buffer
		mov outputBuffer+1, EOS			;adjust for end of string
		mov di, OFFSET outputBuffer		;print out letter in buffer
		call StrWrite
	
		mov di, OFFSET StrSpace10		;print out space for second column
		call StrWrite
		
		mov al, row						;mov value into al again
		mov ah, 0						;clear high bit of ax register
		mov si, ax						;mov ax register into si index offset
		mov al, Ftable[si]				;use index offset to put frequency for letter into al
		mov di, OFFSET outputBuffer		;print out the frequency
		mov cx, 3						;	padded with three zeros
		call BinToAscDec				;convert value from binary to ascii decimal
		call StrWrite
		
		;call NewLine					;new line to separate letter - frequency pair
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		add row, 13
		mov di, OFFSET StrSpace4		;spacing for letter
		call StrWrite
		call StrWrite
		call StrWrite
		call StrWrite
		call StrWrite
		
		mov al, row						;store row value in al
		add al, 'A'						;set letter to use based on value in al
		mov outputBuffer, al			;value into buffer
		mov outputBuffer+1, EOS			;adjust for end of string
		mov di, OFFSET outputBuffer		;print out letter in buffer
		call StrWrite
	
		mov di, OFFSET StrSpace10		;print out space for second column
		call StrWrite
		
		mov al, row						;mov value into al again
		mov ah, 0						;clear high bit of ax register
		mov si, ax						;mov ax register into si index offset
		mov al, Ftable[si]				;use index offset to put frequency for letter into al
		mov di, OFFSET outputBuffer		;print out the frequency
		mov cx, 3						;	padded with three zeros
		call BinToAscDec				;convert value from binary to ascii decimal
		call StrWrite
		
		call NewLine					;new line to separate letter - frequency pair
		sub row, 13 
		;;;;;;;;;;
		
		inc row							;inc row
		cmp row, 13						;compare to letters A-M
		jb  oloopIt						;If row is less than value for N repeat loop
		; jmp oloop2
		jmp Sentinal
;helps to avoid jmp out of range
oloopIt:
	jmp oloop
	
	
Sentinal:
	;ask if user wants to run program again
	;prompt
	mov di, OFFSET StrAgain
	call StrWrite
	
	;read
	mov di, OFFSET sentinalStr
;	mov cx, 2
	call StrRead
	
	;validate input
	cmp sentinalStr, 'n'
	je	Done
	cmp sentinalStr, 'N'
	je  Done
	call NewLine
	
	;if invalid jmp
	jmp ClearTable
	
	
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