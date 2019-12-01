TITLE "EXAMPLE PROGRAM #1"
;*  TITLE: EXAMPLE PROGRAM #!
;*  Author: Jason Lonsinger
;*  Date: 9/12/18
;*  Purpose: Allows you to get the sum of two numbers
;*****************************************************
;* Grading       _____
;* Style         _____
;* Documentation _____  Total _____
;*****************************************************


;********************************
;Header
.MODEL small
STACK  256
;********************************\


;********************************
;CONSTANTS
EOS     EQU 0   ;end of string
maxLen  EQU 40  ;maximum entry string length
bell    EQU 7   ;bell character -- <crt>G
;********************************


;*********************************
;Data Section
.Data
    exCode  db  0   ;DOS error code

    enter1  db  'enter first number : '     ,EOS    ;Prompt for 1st number
    enter2  db  'enter second number: '     ,EOS    ;Prompt for 2nd number
    sumout  db  'The Sum is         : '     ,EOS    ;Sum output label
    number1 dw  0                                   ;first number
    number2 dw  0                                   ;second number
    sum     dw  0                                   ;sum
    buffer  db  maxLen dup (?)                      ;Input/output buffer
    inperror    db  bell, 'Invalid number -- Reenter.',EOS ;Input/Output buffer
    sumerror    db  bell, 'The sum is too large.',EOS   ;sum error message
;********************************


;********************************
;CODE
.CODE
    EXTRN StrLength:proc,   StrRead:proc
    EXTRN StrWrite:proc,    NewLine:proc
    EXTRN BinToAscHex:proc, SBinToAscDec:proc, BinToAscDec:proc
    EXTRN BinToAscBin:proc, AscToBin:proc


;***************************
;* Entry point
Start:
    mov ax, @Data   ;Initialize DS to address
    mov ds, ax      ; of data segment
    mov es, ax      ;Make es = ds
;***************************


;***************************
;* first number
First:
    call NewLine           ;Start new display line
    mov  di, OFFSET enter1 ;display message to enter
    call StrWrite          ;first number

    mov  di, OFFSET buffer ;buffer will get user's entry
    mov  cx, maxLen        ;maximum string legth
    call StrRead           ;get entry from keybaord

    call AscToBin          ;convert string to binary--> ax
    mov  number1, ax       ;Save value int variable
    jnc  second            ;jump if cf is 0--no error
    call NewLine
    mov  di, OFFSET inperror ;else display error message
    call StrWrite
    jmp  First             ;Let user try
;***************************

;***************************
;* second number
Second:
    call NewLine           ;Start new display line
    mov  di, OFFSET enter2 ;display message to enter
    call StrWrite          ;first number

    mov  di, OFFSET buffer ;buffer will get user's entry
    mov  cx, maxLen        ;maximum string legth
    call StrRead           ;get entry from keybaord

    call AscToBin          ;convert string to binary--> ax
    mov  number2, ax       ;Save value int variable
    jnc  GetSum            ;jump if cf is 0--no error
    call NewLine
    mov  di, OFFSET inperror ;else display error message
    call StrWrite
    jmp  Second            ;Let user try
;***************************


;***************************
;* get sum
GetSum:
    call NewLine            
    mov  ax, number1        ;put first number into ax
    add  ax, number2        ;add second number to ax    
    jc   TooBig             ;carry set means answer is to big
    mov  sum, ax            ;save ax into variable
    mov  di, OFFSET sumout  ;Display sum
    call StrWrite           ;  output label
    mov  di, OFFSET buffer  ;Point to buffer string
    mov  ax, sum            ;number arguements for bintoascdec
    mov  cx, 1              ;length argument for bin to asc dec
    call BinToAscDec        ;convert sum to string for printing 
    call StrWrite           ;send buffer to string
    jmp  Done
;***************************


;***************************
;* Print error message if the sum is too big
TooBig:
    mov  di, OFFSET sumerror    ;Print out "Sum to big"
    call StrWrite               ;Error message
;***************************
;*********************************

;***************************
;* terminate
Done:
    call NewLine
    call NewLine

    mov ah, 04Ch        ;Dos Function: Exit program
    mov al, exCode      ;Return exit code value
    int 21h             ;Call Dos. Terminate program

    END Start           ;End of program / entry point
;********************************
