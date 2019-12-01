;*****************************************************
;*****************************************************
;*  TITLE: PROGRAM #7 IEEE Converter
;*  Author: Jason Lonsinger
;*  Date: 11/5/18
;*  Purpose: Allows you to convert IEEE hex number to normalized binary
;*****************************************************
;* Grading       _____
;* Style         _____
;* Documentation _____  Total _____
;*****************************************************

;*****************************************************
;Header

TITLE "IEEE Convert"
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
;Macros

;macro that prints out a string using the MTA library
PrintString Macro outString
	Local @@str1
	.Data
	@@str1	db	outstring,EOS
	.Code
	push di
	push ax
	LEA di, @@str1
	call StrWrite
	pop ax
	pop di
EndM PrintString

;*****************************************************


;*****************************************************
;Data Section

.Data
	
	inputStr	  db	maxStrLen   dup(?)	;string used for input
	value		  dw 0					    ;stores the inputted hex st
	sentinalStr   db 2			    dup(?)  ;used for checking if user wants to run program again
	outputBuffer  db maxStrLen      dup(?)	;used to output a string
	outputBuffer2 db maxStrLen      dup(?)	;used to output a string
	count		  dw 0						;used to count bits and bytes when parsing string
	numberTab	  db 32			    dup(?)	;table of bits
	isNegative    db 0						;stores weather inputed number is negative or posative
	exponent      dw 0						;stores the "decimal" value of the ieee value
	mantissaValue db 0						;the value of the fraction
	
	exCode 		  db 0   				;DOS error code
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
	
;video mode
	mov ah, 00h
	mov al, 03h
	int 10h	

	jmp Welcome
Welcome:
	;print out welcome string
	PrintString "Welcome to the IEEE Converter!"
	call NewLine				;print new line
	
	;sets values to defaults incase 
	mov value, 0
	mov cx, maxStrLen
	mov si, 0
	mov di, 0
	mov count, 0
	mov exponent, 0
	mov isNegative, 0
	
	jmp ClearTab
ClearTab:
	;clears numberTab to all ones
	cmp si, 32
	jae  Prompt
	
	mov al, 0
	mov ah, 0
	mov numberTab[si], al
	mov count, 0
	inc si
	jmp ClearTab
Prompt:
	;Prints prompt 
	PrintString "Please Enter An 8 Digit Hexadecimal String: "
	
	mov  cx, 9			;size of number able to take in is 8 elements long
	LEA  di, inputStr	;move to storage location
	call StrRead		;read in
	call AscToBin		;convert hex to bin?
	call NewLine		;new line in terminal
	mov  cx, maxStrLen  ;set cx to max
	
	jmp  ParseString
ParseString:
	;takes the string from ascii hex to binary
	mov ax, 0
	mov di, 0
	mov bl, 0
	LEA si, inputStr
	TestCharacter:	
		;is character number or letter
		mov al, [si]	;get ascii character
		cmp al, EOS		;if end
		je  EndTestCharacter

		mov al, [si]
		and al, 0DFh	;capital
		sub al, 'A'		;letter?
		cmp al, 25		;if 0-25 then letter
		ja  Number
		jmp Letter
		Number:
			;convert ascii hex to valid binary number
			mov  al, [si]	;stores value from input into al
			mov  ah,  0		;clear high bit
			sub  al, '0'	;convert ascii number to binary number

			shl al, 4 		;put low nibble into high nibble
			mov value, ax	;store value
			
			mov di, 0		;clear index
			jmp PutIntoTable
		Letter:
			;convert ascii hex to valid binary number for letters A-F
			mov al, [si]	;stores value from input into al
			mov ah, 0		;clear high bit
			and al, 0DFh	;capital numbers only
			sub al, 'A'		;subtract 40
			add al, 10		;add 10
			
			shl al, 4 		;put low nibble into high nibble
			mov value, ax	;store value
			
			mov di, 0		;clear index
			jmp PutIntoTable
			PutIntoTable:
				;only affecting the first 4 values agian
				cmp di, 3
				ja  Increment	;if end of byte go to next
			
				;(si*4)+di=count
				mov ax, si 		;store 0-7
				shl ax, 2		;mul by 4
				mov bx, di		;mov current bit position
				add al, bl		;offset of starting pos + current bit of (1-4)
				mov count, ax	;store count
				
				mov ax, value			;restore shifted value
				shl al, 1				;shift highest bit
				push di					;store di
				mov di, count			;mov count into di as index
				adc numberTab[di], 0	;and with carry flag to set 1 if cf is 1 or 0 if other
				pop di					;restore di
				mov value, ax			;store the value of the shifted number
				inc di					;increment bit i am looking at
				jmp PutIntoTable
		Increment:
			inc si
			jmp TestCharacter
EndTestCharacter:
	jmp convert

Convert:
	;converts ieee to standard notation value
	mov al, numberTab[0]	;get sign bit from ieee
	mov isNegative, al		;sets isNegative to 1 if negative or 0 if posative
	
	mov al, 0	;reset al
	
	;multiply each value of exponent by Nth positional power to get biased exponent
	mov bl, numberTab[1]
	shl bl, 7
	add al, bl
	mov bl, numberTab[2]
	shl bl, 6
	add al, bl
	mov bl, numberTab[3]
	shl bl, 5
	add al, bl
	mov bl, numberTab[4]
	shl bl, 4
	add al, bl
	mov bl, numberTab[5]
	shl bl, 3
	add al, bl
	mov bl, numberTab[6]
	shl bl, 2
	add al, bl
	mov bl, numberTab[7]
	shl bl, 1
	add al, bl
	mov bl, numberTab[8]
	add al, bl
	mov ah, 0
	mov exponent, ax
	
	cmp al, 0				;exponent is all 0
	je  CheckZero			;if all 0
	DoneCheckZero:			;jump back from checkzero
		mov ax, exponent	;restore exponent
		mov ah, 0			;clear high bit
		cmp al, 0			;if 0 then not normalized
		je  CheckNormalized ;jump to check normalized
	
	sub ax, 7Fh				;unbias the exponent
	
	mov exponent, ax		;store the exponent for tests and output	
	cmp al, 128				;exponent is all 1
	je  CheckInf			;if exponent is all 1 and mantissa is all 0...check isNegative for + or - inf
	DoneCheckInf:			;if not negative check if not a number
		mov ax, exponent	;resore unbiased exponent
		mov ah, 0			;clear high bit
		cmp al, 128			;if exponent is all 1s
		je  CheckNan		;if exponent is all 1 and first value of mantissa is 1 with all 0 following...isNegative must be 1
	ValidNumber:
		jmp PrintValue		;print out the standard notation number

CheckZero:
	;if zero print out error
	mov al, 0
	mov cx, 0		;counts up for shift nth postiion
	mov si, 31		;counts down from least to most significant bit
	mov dl, 0
	zloop:
		;loops through and adds all numbers in mantissa
		cmp cl, 32
		jae zloopDone
		mov al, numberTab[si]
		shl al, cl
		add dl, al
		
		dec si
		inc cl
		jmp zloop
	zloopDone:		
		;if mantissa is zero
		cmp dl, 0
		je  ErrorZero
		jmp DoneCheckZero	;else check for normalized
CheckNormalized:
	;used to overcome out of range error
	jmp ErrorDenormalized
CheckInf:
	;if inf print posative or negative
	;else jmp back to check if Nan
	mov bl, 0
	mov cx, 0		;counts up for shift nth postiion
	mov si, 31		;counts down from least to most significant bit
	mov al, 0
	iloop:
		;add all values in mantissa together
		cmp si, 8
		jbe iloopDone
		mov bl, numberTab[si]
		;shl bl, cl
		add al, bl
		
		dec si
		inc cl
		jmp iloop
	iloopDone:		
		;if all 0 then INF
		cmp al, 0
		je  ErrorInf
		jmp DoneCheckInf ;else check for NAN
CheckNan:
	jmp ErrorNan
;error messages for all cases below
ErrorZero:
	PrintString "Number is Zero"
	call NewLine
	jmp Sentinal
ErrorInf:
	mov al, isNegative
	cmp al, 1
	je ErrorNegativeInf
	jmp ErrorPosativeInf
ErrorPosativeInf:
	PrintString "+INF"
	call NewLine
	jmp Sentinal
ErrorNegativeInf:
	PrintString "-INF"
	call NewLine
	jmp Sentinal
ErrorNan:
	PrintString "NAN"
	call NewLine
	jmp Sentinal
ErrorDenormalized:
	PrintString "Not Normalized"
	call NewLine
	jmp Sentinal
;

PrintValue:
	;prints out the standard notation value
	
	;print inputted string
	LEA  di, inputStr
	call StrWrite
	
	PrintString " = "
	
	;print sign
	mov al, isNegative	;get value of isNegative
	cmp al, 1			;if 1
	je  PrintNegative	;then print negative else continue
	PrintNegativeDone:	;jumps back here if negative is printed

	;print mantissa here
	PrintString "1."
	jmp PrintMantissa
	PrintMantissaDone:

	;print exponent
	PrintString " x 2^"
	
	LEA di, outputBuffer2
	mov ax, exponent
	mov cx, 1
	call SBinToAscDec
	call StrWrite
	
	call NewLine
	jmp Sentinal
PrintNegative:
	;prints negative symbol if negative
	PrintString "-"
	jmp PrintNegativeDone
	
PrintMantissa:
	;prints the mantissa
	mov di, 0
	mov ax, 0
	mov dx, 0
	mov si, 9
	PrintManBin:
		cmp si, 32
		jae  PrintManBinDone
		
		LEA di, outputBuffer
		;mov cx, 1
		mov al, numberTab[si]
		;mov ah, 0
		add al, "0"
		mov outputBuffer, al
		mov outputBuffer+1, EOS
		call StrWrite
		
		inc si
		jmp PrintManBin
	PrintManBinDone:
		;call NewLine
		jmp PrintMantissaDone

Sentinal:
	PrintString "Would you like to go again (Y/N)? "
	
	;read
	LEA  di, sentinalStr
	call StrRead
	
	;validate input
	cmp  sentinalStr, 'n'
	je	 Done
	cmp  sentinalStr, 'N'
	je   Done
	call NewLine
	
	;if invalid jmp
	jmp  Welcome
	
	
;********************************
;* terminate

Done:
	call NewLine
	
	PrintString "IEEE Converter Terminated!"
	
    call NewLine

    mov ah, 04Ch        ;Dos Function: Exit program
    mov al, exCode      ;Return exit code value
    int 21h             ;Call Dos. Terminate program

    END Start           ;End of program / entry point
;********************************
;*****************************************************