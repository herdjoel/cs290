TITLE Sorting Random Integers     (HerdjProg05.asm)

; Author: Joel Herd
; Last Modified: 11/18/2018
; OSU email address: herdj@oregonstate.edu
; Course number/section: CS 271
; Project Number: Programming Assignment #5      Due Date: 11/18/2018
; Description: This program is a random number generator which takes the number of
; random numbers the user would like to see, and provides a threshold for those random
; numbers. The program prints an unsorted and then a sorted representation of the list
; of random numbers, as well as providing the median value. The objectives for this program
; are: 
;	1.using register indirect addressing
;	2.passing parameters
;	3.generating “random” numbers
;	4.working with arrays

INCLUDE Irvine32.inc

	MAX = 999  ; Upper random number threshold
	MIN = 100  ; Lower random number threshold
	HI = 200  ; Upper random number count
	LO = 10  ; Lower random number count

.data

	progTitle		BYTE	"Sorting Random Integers by Joel Herd",0 
	progInstBegin	BYTE	"This program generates random numbers in the range [",0
	rangeTextBuffer	BYTE	" .. ",0
	progInstEnd1	BYTE	"], ",0
	progInst2		BYTE	"displays the original list, sorts the list, and calculates the",0
	progInst3		BYTE	"median value. Finally, it displays the list sorted in descending order.",0
	randNumPrompt	BYTE	"How many numbers should be generated? [",0
	randNumPrompt2	BYTE	"]: ",0
	invalidError	BYTE	"Invalid input",0
	unsorted		BYTE	"The unsorted random numbers: ",0
	median			BYTE	"The median is ",0
	period			BYTE	".",0
	sorted			BYTE	"The sorted list:",0
	recursiveSort	BYTE	"**EC: Use a recursive sorting algortihm: Merge Sort",0
	requestedSize	DWORD	?
	lowInd			DWORD	?
	leftSideCur		DWORD	?
	rightSideCur	DWORD	?
	middleInd		DWORD	?
	list			DWORD	HI	DUP(?)

.code
main PROC

;	Seed Random Number Generator
	call	Randomize

;	1. Introduce the program.
	push	OFFSET progTitle		; 32
	push	OFFSET recursiveSort	; 28
	push	OFFSET progInstBegin	; 24
	push	OFFSET rangeTextBuffer	; 20
	push	OFFSET progInstEnd1		; 16
	push	OFFSET progInst2		; 12
	push	OFFSET progInst3		; 8
	call	Intro

;	2. Get a user request in the range [min = 10 .. max = 200].
;	Receives: Request by reference
	push	OFFSET randNumPrompt
	push	OFFSET rangeTextBuffer
	push	OFFSET randNumPrompt2
	push	OFFSET invalidError
	push	OFFSET requestedSize
	call	GetData

;	3. Generate request random integers in the range [lo = 100 .. hi = 999], storing them in consecutive elementsof an array.
;	Receives: Request by value, Array by reference
	push	OFFSET list	
	push	requestedSize
	call	FillArray

;	4. Display the list of integers before sorting, 10 numbers per line.
;	Receives: Array by reference, request by value, title by reference
	push	OFFSET list		; 16
	push	requestedSize	; 12
	push	OFFSET unsorted	; 8
	call	DisplayList

;	5. Sort the list in descending order (i.e., largest first).
;	Receives: Array by reference, request by value
	push	leftSideCur
	push	rightSideCur
	push	middleInd
	push	OFFSET list		; 16
	mov		lowInd, 0
	push	lowInd			; 12
	push	requestedSize	; 8
	call	MergeSort

;	6. Calculate and display the median value, rounded to the nearest integer.
;	Receives: array by reference, request by value
	push	OFFSET list
	push	requestedSize
	push	OFFSET median
	call	DisplayMedian

;	7. Display the sorted list, 10 numbers per line.
;	Receives: Array by reference, request by value, title by reference
	push	OFFSET list
	push	requestedSize
	push	OFFSET sorted
	call	DisplayList

	exit	; exit to operating system
main ENDP

;	1. Introduce the program.
Intro PROC
;
; Introduces the user to the program and details the extra credit that was
; completed. 
; Receives: This procedure takes strings which will be written to the console.
; Returns: N/A
; Requires: N/A
;
;	Set up Stack Frame (Activation Record)
	push	ebp				
	mov		ebp, esp

	mov		edx, [ebp+32]
	call	WriteString
	call	Crlf
	mov		edx, [ebp+28]
	call	WriteString
	call	Crlf
	mov		edx, [ebp+24]
	call	WriteString
	mov		eax, MIN
	call	WriteDec
	mov		edx, [ebp+20]
	call	WriteString
	mov		eax, MAX
	call	WriteDec
	mov		edx, [ebp+16]
	call	WriteString
	call	Crlf
	mov		edx, [ebp+12]
	call	WriteString
	call	Crlf
	mov		edx, [ebp+8]
	call	WriteString
	call	Crlf

;	Restore Stack
	pop		ebp
	ret 28
Intro ENDP

;	2. Get a user request in the range [min = 10 .. max = 200].
GetData PROC
;
; This procedure prompts the user to provide an integer within the
; global Min/Max bounds, and will let the user know if the input
; does not satisfy these bounds.
; Receives: Request by reference, and strings for user interaction.
; Returns: An integer for the size of requested list to be sorted.
; Requires: User to input valid integer.
;

;	Set up Stack Frame (Activation Record)
	push	ebp				
	mov		ebp, esp

PromptForInt:
	mov		edx, [ebp+24]
	call	WriteString
	mov		eax, LO
	call	WriteDec
	mov		edx, [ebp+20]
	call	WriteString
	mov		eax, HI
	call	WriteDec
	mov		edx, [ebp+16]
	call	WriteString
	call	ReadInt
	cmp		eax, LO
	jl		BadInput
	cmp		eax, HI
	jg		BadInput
	mov		ebx, [ebp+8]
	mov		[ebx], eax
	jmp		ExitGetData

BadInput:
	mov		edx, [ebp+12]
	call	WriteString
	call	Crlf
	jmp		PromptForInt

ExitGetData:
;	Restore Stack
	pop		ebp
	ret		20
GetData ENDP

;	3. Generate request random integers in the range [lo = 100 .. hi = 999], storing them in consecutive elements of an array.
FillArray PROC
;
; This procedure will take the integer provided by the user and create a respective number of 
; random integers to populate a list with.
; Receives: Request by value, Array by reference
; Returns: Populated List of random integers.
; Requires: Integer provided by user is greater than zero, and array size must be greater
; than the number of requested random integers. 
;

;	Set up Stack Frame (Activation Record)
	push	ebp	
	mov		ebp, esp
	mov		edi, [ebp+12]		; Array
	mov		ecx, [ebp+8]		; Request

GenerateRandoms:
	mov		eax, MAX
	sub		eax, MIN
	call	RandomRange
	add		eax, MIN
	mov		[edi], eax
	add		edi, 4
	loop	GenerateRandoms
	pop		ebp					; Restore Stack
	ret		8
FillArray ENDP

;	4. Display the list of integers before sorting, 10 numbers per line.
;	7. Display the sorted list, 10 numbers per line.
DisplayList PROC
;
; Prints the list to the console in order by index. 
; Receives: Array by reference, request by value, title by reference
; Returns: N/A
; Requires: The Array must be populated with valid integers.
;

;	Set up Stack Frame (Activation Record)
	push	ebp	
	mov		ebp, esp
	mov		esi, [ebp+16]		; Array
	mov		ecx, [ebp+12]		; Request
	mov		edx, [ebp+8]		; Title
	call	Crlf
	call	WriteString
	call	Crlf
	mov		ebx, 10

PrintList:
	cmp		ebx, 0
	jle		NewLine
	mov		eax, [esi]
	call	WriteDec
	add		esi, 4
	mov		ax, 9
	call	WriteChar			; Tab
	dec		ebx
	loop	PrintList
	jmp		EndDisplay

NewLine:
	call	Crlf
	mov		ebx, 10
	jmp		PrintList
	
;	Restore Stack
EndDisplay:
	pop		ebp
	ret		12
DisplayList ENDP

;	5. Sort the list in descending order (i.e., largest first).
MergeSort PROC
;
; This procedure will sort the Array of random integers in
; descending order. It is designed to be called recursively. 
; Receives: Array by reference, request by value, upper/lower bounds, and a middle point
; Returns: Sorted Array
; Requires: The Array is populated with random integers.
;
	;	Set up Stack Frame (Activation Record)
	push	ebp	
	mov		ebp, esp
	mov		edi, [ebp+16]		; Array
	mov		ebx, [ebp+12]		; Low
	mov		ecx, [ebp+8]		; High
	cmp		ebx, ecx
	jge		EndMerge

	;	Find Middle point to divide array
	mov		eax, ebx
	add		eax, ecx			; Sum Lower and Upper Limit
	mov		ebx, 2
	mov		edx, 0
	div		ebx					
	mov		[ebp+20], eax		; Average to get Middle Point

	;	Call MergeSort on first half
	push	[ebp+28]
	push	[ebp+24]
	push	[ebp+20]
	push	[ebp+16]			; Array
	mov		ebx, [ebp+12]
	push	ebx					; Low
	push	eax					; Middle as High
	call	MergeSort

	;	Increment Middle Point
	mov		eax, [ebp+20]
	inc		eax
	mov		[ebp+20], eax

	;	Call MergeSort on second half
	push	[ebp+28]
	push	[ebp+24]
	push	[ebp+20]
	push	[ebp+16]			; Array
	push	eax					; Middle + 1 as Low
	mov		ebx, [ebp+8]
	push	ebx					; High
	call	MergeSort

	; Stage Left/Right values for Sorting
	mov		eax, [ebp+20]		; Middle
	add		eax, eax
	add		eax, eax			; Convert to Bit Index
	mov		edx, [edi+eax]		
	mov		[ebp+24], edx		; Set Right Side value 

	mov		eax, [ebp+12]		; Lower Limit
	add		eax, eax
	add		eax, eax			; Convert to Bit Index
	mov		ecx, [edi+eax]
	mov		[ebp+28], ecx		; Set Left Side value 
	
SortHalves:
	mov		eax, [ebp+12]		; Lower Limit
	add		eax, eax
	add		eax, eax			; Convert to Bit Index	
	mov		ecx, eax
	mov		eax, [ebp+20]		; Middle 
	add		eax, eax
	add		eax, eax			; Convert to Bit Index	
	cmp		ecx, eax
	jge		NoLeftValue
	mov		eax, [ebp+28]
	jmp		StageRightValue

NoLeftValue:
	mov		eax, 0

StageRightValue:
	push	eax
	mov		eax, [ebp+8]		; Upper Limit
	add		eax, eax
	add		eax, eax			; Convert to Bit Index
	mov		ecx, eax
	mov		eax, [ebp+20]		; Middle 
	add		eax, eax
	add		eax, eax			; Convert to Bit Index	
	mov		edx, eax
	pop		eax
	cmp		edx, ecx
	jg		NoRightValue
	push	eax
	mov		eax, [ebp+12]		; Lower Limit
	add		eax, eax
	add		eax, eax			; Convert to Bit Index
	mov		edx, eax
	pop		eax
	cmp		edx, ecx
	jge		NoRightValue
	mov		ebx, [ebp+24]
	jmp		CompareValues

NoRightValue:
	mov		ebx, 0

CompareValues:
	cmp		eax, 0
	je		LoadRightValue		; If left side is done
	cmp		ebx, 0
	je		LoadLeftValue		; If right side is done
	cmp		eax, ebx			; If neither is done
	jl		LoadRightValue		; if left > right
	jmp		LoadLeftValue		; if left <= right

LoadRightValue:
	cmp		ebx, 0				; If right side is done too, end merge
	je		EndMerge
	push	eax
	mov		eax, [ebp+12]		; Lower Limit
	add		eax, eax
	add		eax, eax			; Convert to Bit Index
	mov		edx, eax
	mov		eax, [ebp+20]		; Middle 
	add		eax, eax
	add		eax, eax			; Convert to Bit Index	
	mov		ecx, eax
	pop		eax

LoopShift:
	cmp		edx, ecx
	jg		AfterLoop			; Finish Shifting to the right
	mov		eax, [edi+edx]		; Save old value
	mov		[edi+edx], ebx		; Replace old index with new value
	add		edx, 4				
	mov		ebx, eax
	jmp		LoopShift

AfterLoop:
	mov		eax, [ebp+12]		; Lower Limit
	inc		eax
	mov		[ebp+12], eax		; Increment Lower Limit
	mov		eax, [ebp+8]		; Upper Limit
	add		eax, eax
	add		eax, eax			; Convert to Bit Index
	mov		ebx, eax
	mov		eax, [ebp+20]		; Middle
	inc		eax
	mov		[ebp+20], eax		; Increment Middle
	add		eax, eax
	add		eax, eax			; Convert to Bit Index
	cmp		eax, ebx
	jg		SortHalves			; Avoid undeclared index
	mov		ebx, [edi+eax]
	mov		[ebp+24], ebx		; Update Right Target Value
	jmp		SortHalves

LoadLeftValue:
	mov		eax, [ebp+12]		; Lower Limit
	inc		eax
	mov		[ebp+12], eax		; Increment Lower Limit
	add		eax, eax			; Convert to Bit Index
	add		eax, eax
	mov		ecx, eax
	mov		eax, [edi+ecx]
	mov		[ebp+28], eax		; Update Left Target Value
	jmp		SortHalves

EndMerge:
;	Restore Stack
	pop		ebp
	ret		24
MergeSort ENDP

;	6. Calculate and display the median value, rounded to the nearest integer.
DisplayMedian PROC
;
; This procedure calculates the median value of an array of random integers.
; Receives: array by reference, request by value
; Returns: N/A
; Requires: Array must be populated with valid integers.
;
	
;	Set up Stack Frame (Activation Record)
	push	ebp	
	mov		ebp, esp
	mov		esi, [ebp+16]		; Array
	mov		eax, [ebp+12]		; Request
	mov		edx, [ebp+8]		; Title
	call	Crlf
	call	Crlf
	call	WriteString

;	Calculate Median
	mov		edx, 0
	mov		ebx, 2
	div		ebx
	cmp		edx, 1
	je		OddCount

;	Even Count
	mov		ecx, eax
	dec		ecx
	mov		ebx, 4				
	mul		ebx
	mov		ebx, [esi+eax]	
	push	ebx				
	mov		eax, ecx
	mov		ebx, 4
	mul		ebx
	mov		ebx, [esi+eax]		; Lower index value 
	pop		edx					; Upper index value 
	add		ebx, edx			; Sum two middle indices
	mov		edx, 0
	mov		eax, ebx
	mov		ebx, 2
	div		ebx

;	Round to Nearest Integer
	mov		ecx, 1
	cmp		edx, ecx
	jl		WriteNum
	inc		eax
	jmp		WriteNum

OddCount:
	mov		ebx, 4			
	mul		ebx
	mov		ebx, [esi+eax]
	mov		eax, ebx

WriteNum:
	call	WriteDec		
	call	Crlf
	pop		ebp
	ret		12
DisplayMedian ENDP

END main
