TITLE Program 6B     (HerdjProg06B.asm)

; Author:  Joel Herd
; Last Modified:  12/2/18
; OSU email address:  herdj@oregonstate.edu
; Course number/section:  CS 271
; Project Number:   6 Option B      Due Date: 12/2/18
; Description: For this program we're designing a system that will drill 
;	and practice students in combinatorics. The student will be prompted
;	to provide the number of elements in a set, and the number of elements 
;	to be chosen from that set. They will then be expected to respond with
;	the correct number of total combinations from the dimensions they provided.

INCLUDE Irvine32.inc

	MAX = 80		; Max Characters to be read from string

.data

	; Introduce Program
	welcome		BYTE	"Welcome to the Combinations Calculator Implemented by Joel Herd",0 
	ecDecl		BYTE	"**EC: Each problem is numbered and score is kept.",0
	premise		BYTE	"I'll give you a combinations problem.  You enter your answer, ",0
	premise2	BYTE	"and I'll let you know if you're right.",0 

	; Challenge User
	problem		BYTE	"Problem ",0
	problemNum	DWORD	?
	promptSet	BYTE	"Number of elements in the set: ",0
	promptSubSet	BYTE	"Number of elements to choose from the set: ",0
	promptWays	BYTE	"How many ways can you choose? ",0
	userInput	BYTE	MAX+1 DUP(?)

	; Reveal Answer
	responsePt1	BYTE	"There are ",0
	; Result
	result		DWORD	?						
	responsePt3	BYTE	" combinations of ",0
	; Subset
	r			DWORD	?					
	responsePt5	BYTE	" items from a set of ",0 	
	; Total Set
	n			DWORD	?	
	userAnswer	DWORD	?
	wrongAns	BYTE	"You need more practice.",0
	correctAns	BYTE	"You are correct!",0

	; Keep Track of user's score
	wonGameMsg	BYTE	"The number of problems you have solved correctly is: ",0
	score		DWORD	?

	; Allow user to play again
	reprompt	BYTE	"Another problem? (y/n): ",0 
	playAgain	DWORD	?

	; Errors
	validInput	DWORD	?
	invalidResp	BYTE	"Invalid response.",0 

	; End Program
	goodbye		BYTE	"OK ... goodbye.",0

; Macro to Display Strings
wStrClf MACRO str
	pushad
	mov		edx, OFFSET str
	call	WriteString
	call	Crlf
	popad
ENDM

; Macro to Display Strings with no Crlf
wString MACRO str
	pushad
	mov		edx, OFFSET str
	call	WriteString
	popad
ENDM

; Macro to Read Strings
rString	MACRO str
	pushad
	mov		edx, OFFSET str
	mov		ecx, MAX
	call 	ReadString
	popad
ENDM

.code

; Mostly pushing parameters and calling procedures
main PROC

	; Display title, programmer name, and instructions
	call	introduction

	; Game Loop
	mov		problemNum, 0
	mov		playAgain, 0
Challenge:
	mov		result, 1
	mov		eax, 0
	mov		ebx, 0
	mov		ecx, 0
	mov		edx, 0 
	mov		r, 0
	mov		n, 0
	mov		userInput, 0
	mov		userAnswer, 0

	; Generate the random numbers and displays the problem
	push	OFFSET problemNum
	push	OFFSET r
	push	OFFSET n
	call	showProblem

	; Prompt / Get user's answer
	push	OFFSET userAnswer
	call	getData

	; Do the Calculations
	push	r
	push	n
	push	OFFSET result
	call	combinations

	; Display the student's answer, the calculated result, and a brief
	; Statement about the student's performance
	push	userAnswer
	push	result
	push	n
	push	r
	push	OFFSET score
	push	OFFSET playAgain
	call	showResults

	; If user opts to keep playing, loop
	mov		eax, playAgain
	cmp		eax, 2
	je		Challenge

	; End Game
	mov		edx, OFFSET goodbye
	call	WriteString

	exit
main ENDP

; Display title, programmer name, and instructions
; Receives: N/A
; Returns: N/A
; Requires: N/A
introduction PROC
	pushad
	wStrClf	welcome		
	wStrClf	ecDecl	
	wStrClf	premise	
	wStrClf	premise2	
	call	Crlf
	popad
	ret
introduction ENDP 

; Prompts for r and n and displays the problem
; Receives: Parameters via the Stack
; Returns: Increments problemNum, and fetches n and r from user
; Requires: N/A
showProblem  PROC
	; Set Stack Frame
	push	ebp
	mov		ebp, esp
	pushad
	mov		edi, [ebp+16] 	; OFFSET problemNum
	mov		eax, [ebp+16]
	push	[eax]
	pop		eax
	inc		eax
	mov		[edi], eax
	mov		ecx, [ebp+12] 	; OFFSET r
	mov		ebx, [ebp+8]	; OFFSET n

	; Problem Number
	wString problem
	call	WriteDec
	call	Crlf

	; Get user input and verify
PromptForSet:
	wString	promptSet
	rString	userInput
	push	[ebp+8]			; OFFSET n
	call	inputToInteger
	push	[ebp+8]			; OFFSET n
	push	12
	push	3
	call	verifyInteger
	mov		edi, [ebp+8]
	mov		eax, [edi]
	cmp		eax, 0
	je		BadInputSet
	jmp		PromptForSubSet

BadInputSet:
	wStrClf	invalidResp
	jmp		PromptForSet

	; Get user input and verify
PromptForSubSet:
	wString	promptSubSet
	rString	userInput
	push	[ebp+12] 		; OFFSET r
	call	inputToInteger
	push	[ebp+12] 		; OFFSET r
	mov		esi, [ebp+8]	; n
	push	[esi]
	push	1
	call	verifyInteger
	mov		edi, [ebp+12]
	mov		eax, [edi]
	cmp		eax, 0
	je		BadInputSubSet
	jmp		ExitProc

BadInputSubSet:
	wStrClf	invalidResp
	jmp		PromptForSubSet

ExitProc:
	popad
	pop		ebp
	ret 12
showProblem ENDP

; Prompt / Get user's answer
; Receives: Parameters via the Stack
; Returns: Updates userAnswer
; Requires: N/A
getData  PROC
	; Set Stack Frame
	push	ebp
	mov		ebp, esp
	pushad
	mov		eax, [ebp+8]	; OFFSET userAnswer

	; Get user input and verify
PromptAgain:
	wString	promptWays
	rString	userInput
	push	[ebp+8]			; OFFSET userAnswer
	call	inputToInteger
	push	[ebp+8]			; OFFSET userAnswer
	push	32767
	push	0
	call	verifyInteger
	mov		edi, [ebp+8]
	mov		eax, [edi]
	cmp		eax, 0
	je		BadInput
	call	Crlf
	jmp		ExitProc

BadInput:
	wString	invalidResp
	jmp		PromptAgain

ExitProc:
	popad
	pop		ebp
	ret 4
getData ENDP

; Do the Calculations
; Receives: Parameters via the Stack
; Returns: Updates Result
; Requires: N/A
combinations  PROC
	; Set Stack Frame
	push	ebp
	mov		ebp, esp
	pushad

	mov		eax, [ebp+8]	; OFFSET result

	; Calculate r!
	push	eax				; OFFSET result
	push	[ebp+16]		; r
	call	factorial

	; Save factorial result and reset result
	mov		eax, [ebp+8]    ; r!
	push	[eax]
	mov		edi, [ebp+8]
	mov		eax, 1
	mov		[edi], eax
	pop		eax				

	; EAX = r!

	; Calculate n!
	push	[ebp+8]			; OFFSET result
	push	[ebp+12]		; n
	call	factorial

	; Save factorial result and reset result
	mov		ebx, [ebp+8]    ; n!
	push	[ebx]
	mov		ebx, 1
	mov		edi, [ebp+8]
	mov		[edi], ebx
	pop		ebx				

	; EBX = n!

	; Calculate (n-r)!
	push	[ebp+8]			; OFFSET result
	mov		esi, [ebp+16]	; r
	mov		ecx, esi
	mov		esi, [ebp+12]	; n
	mov		edx, esi
	sub		edx, ecx
	push	edx				; (n - r)
	call	factorial

	; Save factorial result and reset result
	mov		ecx, [ebp+8]    ; (n - r)!
	push	[ecx]
	mov		ecx, 0
	mov		edi, [ebp+8]
	mov		[edi], ecx
	pop		ecx				; ECX = (n - r)!

	; Multiply r! and (n-r)!
	mov		edx, 0
	mul		ecx
	mov		ecx, eax		; r!(n - r)! in ECX

	; Divide n! by r!(n - 1)!
	mov		edx, 0
	mov		eax, ebx		; n! in EAX (from EBX)
	div		ecx

	mov		[edi], eax		; Save result

	popad
	pop		ebp
	ret 12
combinations ENDP

; Display the student's answer, the calculated result, and a brief
; Statement about the student's performance
; Receives: Parameters via the Stack
; Returns: Updates playAgain
; Requires: N/A
showResults  PROC
	; Set Stack Frame
	push	ebp
	mov		ebp, esp
	pushad

	; Print Results
	wString	responsePt1
	mov		eax, [ebp+24]	; result
	call	WriteDec
	wString	responsePt3
	mov		eax, [ebp+16]	; n
	call	WriteDec
	wString responsePt5
	mov		eax, [ebp+20]	; r
	call	WriteDec
	call	Crlf

	mov		edx, [ebp+28]	; userAnswer
	mov		eax, [ebp+24]	; result
	cmp		edx, eax
	je		CorrectAnswer
	wStrClf	wrongAns
	jmp GamesWon

CorrectAnswer:
	wStrClf	correctAns
	mov		edi, [ebp+12]
	mov		eax, [ebp+12]
	push	[eax]
	pop		eax
	inc		eax
	mov		[edi], eax

GamesWon:
	call	Crlf
	; Games Won Total
	wString	wonGameMsg
	mov		edi, [ebp+12]
	mov		eax, [ebp+12]
	push	[eax]
	pop		eax
	call	WriteDec
	call	Crlf
	call	Crlf

	; Get user input and verify
PlayAgainPrompt:
	wString	reprompt
	rString	userInput
	push	[ebp+8]			; OFFSET playAgain
	call	inputToBool
	push	[ebp+8]			; OFFSET playAgain
	push	2
	push	1
	call	verifyInteger
	mov		edi, [ebp+8]
	mov		eax, [edi]
	cmp		eax, 0
	je		BadInput
	call	Crlf
	jmp		ExitProc

BadInput:
	wStrClf	invalidResp
	jmp		PlayAgainPrompt

ExitProc:
	popad
	pop		ebp
	ret 24
showResults ENDP

; Calculates the factorial of an integer
; Receives: Parameters via the Stack
; Returns: Updates the running total in the Stack
; Requires: N/A
factorial PROC
	; Set Stack Frame
	push	ebp
	mov		ebp, esp
	pushad
	mov		ebx, [ebp+8]			; n
	cmp		ebx, 0
	jle		EndProc

	mov		edi, [ebp+12]
	mov		eax, [edi]
	push	[ebp+12]				; Running Total
	dec		ebx
	push	ebx
	call	factorial
	
	mov		edi, [ebp+12]			; Last Total
	mov		eax, [edi]
	mov		ebx, [ebp+8]			; n
	mul		ebx
	mov		[edi], eax

EndProc:
	popad
	pop		ebp
	ret 8
factorial ENDP 

; Translates String to Integer
; Receives: String
; Returns: Updates validInput as Integer
; Requires: N/A
inputToInteger PROC
	; Set Stack Frame
	push	ebp
	mov		ebp, esp
	pushad
	mov		edi, [ebp+8]			; OFFSET validInput
	mov		esi, OFFSET userInput	; From rString

TranslateLoop:
	; Get Next Character
	mov		bl, [esi]
	inc		esi
	sub		bl, 48

	; Validate next character is an Integer
	cmp		bl, 0
	jl		BadInput
	cmp		bl, 9
	jg		BadInput

	; Multiply EDI by 10
	mov		eax, [edi]
	mov		ecx, 10
	mul		ecx
	mov		[edi], eax
	add		[edi], bl
	jmp		TranslateLoop

BadInput:
	cmp		bl, 208
	je		ExitProc
	mov		edi, 0

ExitProc:
	popad
	pop		ebp
	ret 4
inputToInteger ENDP 

; Translates String to Boolean
; Receives: String
; Returns: Updates playAgain with integer
; Requires: N/A
inputToBool PROC
	; Set Stack Frame
	push	ebp
	mov		ebp, esp
	pushad
	mov		edi, [ebp+8] ; OFFSET playAgain
	mov		esi, OFFSET userInput	; From rString

	; Get Next Character
	mov		bl, [esi]
	inc		esi
	sub		bl, 110

	; Validate next character is an Integer
	cmp		bl, 0
	jne		BadInput

	; NoInput
	mov		edi, [ebp+8] ; OFFSET playAgain
	mov		eax, 1
	mov		[edi], eax
	jmp		NoAdditional

YesInput:
	mov		edi, [ebp+8] ; OFFSET playAgain
	mov		eax, 2
	mov		[edi], eax
	jmp		NoAdditional

BadInput:
	cmp		bl, 11
	je		YesInput
	mov		edi, [ebp+8] ; OFFSET playAgain
	mov		eax, 0
	mov		[edi], eax

NoAdditional:
	mov		bl, [esi]
	inc		esi
	sub		bl, 48
	cmp		bl, 208
	je		EndProc
	jmp		BadInput

EndProc:
	popad
	pop		ebp
	ret 4
inputToBool ENDP 

; Verifies integer is in the correct range
; Receives: Integer
; Returns: Integer set to zero if not in valid range
; Requires: N/A
verifyInteger PROC
	; Set Stack Frame
	push	ebp
	mov		ebp, esp
	pushad

	; If ESI is not in bounds, set to 0
	mov		edi, [ebp+16]
	mov		eax, [ebp+16]
	push	[eax]
	pop		eax
	mov		ebx, [ebp+12]	; MAX
	mov		edx, [ebp+8]	; MIN
	cmp		eax, ebx
	jg		TooHigh
	cmp		eax, edx
	jl		TooLow
	jmp		ExitProc

TooLow:
	mov		eax, 0
	mov		[edi], eax
	jmp		ExitProc

TooHigh:
	mov		eax, 0
	mov		[edi], eax
	jmp		ExitProc

ExitProc:
	popad
	pop		ebp
	ret 12
verifyInteger ENDP 

END main
