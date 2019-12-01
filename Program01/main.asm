;*****************************************************
;*****************************************************
;*  TITLE: PROGRAM #1 BaseConverter
;*  Author: Jason Lonsinger
;*  Date: 10//18
;*  Purpose: Allows you to see what a decimal number is in binary and hexadecimal form
;*****************************************************
;* Grading       _____
;* Style         _____
;* Documentation _____  Total _____
;*****************************************************


;*****************************************************
;Header

TITLE "BaseConverter"
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
	
	strwelcome db  "Welcome to the number converter", EOS ;application start message
	strprompt  db  "Please enter your name? ", EOS 		  ;prompt for name
	strgreet   db  "Hello ",EOS 						  ;greeting user
	
	buffer    db maxLen dup(?)		;buffer for side and temp storage
	strname	  db maxLen dup(?)		;stores user name
	
	strnumber db "Enter a posative number to convert between 0-65535: ", EOS ;prompt for number
	numberbin dw  0
	number    dw maxLen dup(?) 						;stores ascii form of number entered
	strbin    db " =BIN: ",EOS 						;message for bin number
	strhex    db " =HEX: ",EOS 						;message for hex number
	
	stragain  db " would you like to go again (Y/N)? ", EOS ;message to repeat
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
	call NewLine		      ;new line
	mov di, OFFSET strwelcome ;print welcome message
	call StrWrite		      ;actually prints message
	jmp Greet
	
	
Greet:
	;prompt
	call NewLine
	mov di, OFFSET strprompt ;prompt for name
	call StrWrite
	
	mov di, OFFSET strname ;store name in buffer
	mov cx, maxLen		   ;use maxLen for strings
	call StrRead		   ;read input into buffer
	
	
	;print greeting
	call NewLine
	mov di, OFFSET strgreet
	call StrWrite
	mov di, OFFSET strname
	call StrWrite
	jmp NumberEntryConversion
	
NumberEntryConversion:
	;prompt user for number
	call NewLine
	mov di, OFFSET strnumber
	call StrWrite
	
	;read string into number with length maxLen
	mov di, OFFSET buffer
	mov cx, maxLen
	call StrRead
	
	mov number, ax    ;original ascii string number
	call AscToBin     ;convert string to binary
	mov numberbin, ax ;store binary number
	
	;conversion 1 binary
		;original number then prompt
	call NewLine
	mov di, OFFSET buffer
	call StrWrite
		
	mov di, OFFSET strbin
	call StrWrite
	
		;converted number
	mov di, OFFSET number
	mov ax, numberbin
	mov cx, 16
	call BinToAscBin
	call StrWrite
	
	
	;conversion 2 hex
		;original number then prompt
	call NewLine
	mov di, OFFSET buffer
	call StrWrite
		
	mov di, OFFSET strhex
	call StrWrite
	
		;converted number
	mov di, OFFSET number
	mov ax, numberbin
	mov cx, 4
	call BinToAscHex
	call StrWrite
	
	;rerun
	call NewLine
	call NewLine
		;prompt then input
	mov di, OFFSET strname
	call StrWrite
	mov di, OFFSET stragain
	call StrWrite
	
	mov di, OFFSET buffer
	mov cx, 2
	call StrRead
	
		;input evaluation
	cmp buffer, 'n'
	je	Done
	cmp buffer, 'N'
	je  Done
	call NewLine
	jmp NumberEntryConversion

;********************************
;********************************
;* terminate

Done:
    call NewLine
    call NewLine

    mov ah, 04Ch        ;Dos Function: Exit program
    mov al, exCode      ;Return exit code value
    int 21h             ;Call Dos. Terminate program

    END Start           ;End of program / entry point
;********************************
;*****************************************************