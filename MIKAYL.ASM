        .model small
;=======================================================================================;
        .stack 100h
;=======================================================================================;
        .data
		;====data for general use====;

choice    db 10, "Choice: $" ;To prompt user input in character

buff      dw 26           ;MAX NUMBER OF CHARACTERS ALLOWED (25)
          dw ?            ;NUMBER OF CHARACTERS ENTERED BY USER  
          dw 26 dup(0)    ;CHARACTERS ENTERED BY USER

charinput db ?		
num		  db 0			  ;variable for printNum proc
secchange db 51 dup('='), '$'		 
;^String Buffer;

        ;====data for MMENU====;

mmenu1    db 10, "##################################################", 10, 13, "#              WELCOME TO MIKAYL'S               #", 10, 13, "#          ASSEMBLY INVENTORY SYSTEM!            #", 10, 13, "##################################################$"
mmenu2    db "Pick an Option:", 10, 13, "1.	List Inventory", 10, 13, "2.	Quit Program$"
mmerror   db 10, "Invalid Input! Only enter numbers 1-2", 10, '$'
mexit 	  db "Thank you for using my Program!", 10, 9, 9, "-Mikayl Bin Abdul Jalal (TP065957)$"
		;====data for table listing====;
		;Table has 51 characters;
		
header    db 10, 10, "No.", 9, "Name", 9, 9, "Quantity", 9, "Priority", 9, 10, 13, "===================================================$"
tail	  db "===================================================", 10, '$'

		;====data for table====;
	   ;No. Name            Quantity
array db 1, "Strawberry     ", 3 ;No (0), Name (1-15), Quantity (16)
	  db 2, "Lemon          ", 7 ;No (17), Name (18-32), Quantity (33)
	  db 3, "Poptart        ", 11 ;No (34), Name (35-49), Quantity (50)
	  db 4, "Apple          ", 15 ;No (51), Name (52-66), Quantity (67)
	  db 5, "Carrot         ", 9 ;No (68), Name (69-83), Quantity (84)
								; bx + 17 to jump to next row.
len_array equ $-array ;Gets the length of array which is 85

		;====data for SecondMenu====;
menu2title 		db "==================INVENTORY MENU===================$"
menu2prompt   	db 10, "Pick an Option:", 10, 13, "1.	Add Item Quantity", 10, 13, "2.	Subtract Item Quantity", 10, 13, "3.	Return to Main Menu$"
menu2error 		db 10, "Invalid Input! Only enter numbers 1-3", 10, '$'
tambahprompt	db 10, "Which Item No.? $"
tambahprompt2	db 10, "How much would you like to add? $"
tolakprompt		db 10, "Which Item No.? $"
tolakprompt2	db 10, "How much would you like to subtract? $"
user_row_input	db 0

;=======================================================================================;
        .code

        ;====Macro to Initialize Data====;
init macro
        mov ax, @data
        mov ds, ax
endm

		;====Macro to clear screen====;
cls macro
		mov ah, 0h
		mov al, 03h
		int 10h
endm

        ;====Macro for printing string====;
printString macro addrString
        mov ah, 09h
        lea dx, addrString
        int 21h
endm

        ;====Macro for printing String inputs====;
printInput macro addrString
        mov ah, 09h
        mov dx, offset addrString + 2 ;String input needs to be printed after the second byte.
        int 21h
endm

        ;====Macro for print characters====;
printChar macro valChar
        mov ah, 02h
        mov dl, valChar
        int 21h
endm

        ;====Macro for getting character user inputs====;
getChar macro addrChar
        mov ah, 01h
        int 21h
        mov addrChar, al
endm

getNum macro addrChar
        mov ah, 01h
        int 21h
        sub al, '0'
        mov addrChar, al
endm

colorRed macro
		mov ah, 09h
		mov bl, 04h
		mov cx, 1
		int 10h
endm

colorGreen macro
		mov ah, 09h
		mov bl, 02h
		mov cx, 1
		int 10h
endm

        ;====Macro for getting string user input====;
getString macro addrString
        mov ah, 0ah
        mov dx, offset addrString
        int 21h
        mov si, offset addrString + 1
        mov cl, [ si ]
        mov ch, 0
        inc cx
        add si, cx
        mov al, '$' ;Put the breaking character at the end of string.
        mov [ si ], al
endm

clearReg Macro 		;Clears all registers
		xor ax, ax
		xor bx, bx
		xor cx, cx
		xor dx, dx
endm

		;====End Program====;
terminate macro
        mov ah, 4ch
        int 21h
endm

;;;Everything below here are all procs;;;

MainMenu proc
		printString mmenu1
		printChar 10
		printChar 10
		printString mmenu2	
		ret
MainMenu endp

MMinput proc		;Input check for Main Menu (Only 1-3 [31h - 33h])
MMstart:
		printString choice
		getChar charinput ;Store the ascii char in charinput
		clearReg
		mov bh, charinput
		cmp bh, 31h
		jl MMinvalidsec
		cmp bh, 32h
		jg MMinvalidsec
		jmp MMend
MMinvalidsec:
		printString mmerror
		jmp MMstart
MMend:		
		ret
MMinput endp

SecondMenu proc
		printString menu2prompt
		ret
SecondMenu endp

SMinput proc
SMstart:
		printString choice
		getChar charinput ;Store the ascii char in charinput
		clearReg
		mov bh, charinput
		cmp bh, 31h
		jl SMinvalidsec
		cmp bh, 33h
		jg SMinvalidsec
		jmp SMend
SMinvalidsec:
		printString menu2error
		jmp SMstart
SMend:		
		ret
SMinput endp

project proc			;Uses global variable num
		push ax
		push bx
		push cx
        mov al, num     ;al is numerator, num is from data segmant
        cmp al, 20h
		je ALPHABET
		cmp al, 10      ;check whether al is one digit or two digit
        jl ONEDIGIT    ;jump to onedigit printing block if it is onedigit
		cmp al, 41h
		jge ALPHABET
        mov ah, 00      ;clear out ah to store remainder
        mov bl, 10      ;setting denominator as 10
        div bl          ; al/bl 
        mov bl, ah      ; remainder is stored in ah
        mov dl, al      ; quotient is stored in al
        mov ah, 02h     ; BEGIN PRINTING BIJS
        add dl, '0'     ; Setting to ascii number
        int 21h         ; IT'S ARIANA GRANDE!
        mov dl, bl      ; putting the remainder value into the dl
        add dl, '0'     ; Setting to ascii number again
        int 21h         ; IT'S BEYONCE!
		printChar 32
		pop cx
		pop bx
        pop ax          ; Skipping to the end of macro
		ret
ALPHABET:
		mov ah, 02h
		mov dl, num
		int 21h
		pop cx
		pop bx
		pop ax
		ret
ONEDIGIT:
        mov ah, 02h     ; This one dont need explain
        mov dl, num
        add dl, '0'
        int 21h
		printChar 32
		pop cx
		pop bx
		pop ax
		ret
project endp

project_table proc
	push ax
	push bx
	push cx
	mov bx, 0
	printString header
	printChar 10
foo2_start:
	mov ah, array[bx]
	mov num, ah
	call project			;Printing No.
	printChar 9
	mov cl, 15			;Setting up the count for looping until end of string.
foo2_name:
	inc bx				;Parse each character in stirng.
	mov ah, array[bx]
	mov num, ah
	call project
	dec cl
	jnz foo2_name
	printChar 9
	inc bx
	mov ah, array[bx]
	mov num, ah
	call project
	printChar 9
	printChar 9
	mov ah, num
	cmp ah, 5
	jle foo2_priority
	push bx
	colorGreen
	printChar 02h
	pop bx
	jmp foo2_nextline
foo2_priority:
	push bx
	colorRed
	printChar 21h
	pop bx
foo2_nextline:
	printChar 10
	inc bx
	cmp bx, len_array
	jl foo2_start
	pop cx
	pop bx
	pop ax
	ret
project_table endp

tambah_menu proc
tambah_no_apa:
	printString tambahprompt
	getNum bh ;To check what row user want
	printChar 10
	cmp bh, 1   ;Item no 1
	jl tambah_no_apa
	cmp bh, 5	;Item no 5
	jg tambah_no_apa
	mov user_row_input, bh
	mov cl, 10
tambah_berapa:
	printString tambahprompt2
	getNum al
	cmp al, 0
	jl tambah_berapa
	cmp al, 9
	jg tambah_berapa
	mul cl
	mov bh, al	
	getNum al
	cmp al, 0
	jl tambah_berapa
	cmp al, 9
	jg tambah_berapa
	add bh, al
	ret
tambah_menu endp

tambah proc ;To add item quantity.
	call tambah_menu ;Double digit number is in bh register
	mov cl, bh
	mov ch, user_row_input
	cmp ch, 1
	jz AROW_1
	cmp ch, 2
	jz AROW_2
	cmp ch, 3
	jz AROW_3
	cmp ch, 4
	jz AROW_4
	mov bx, 68		;Move bx to fifth row
	add bx, 16		;Move bx to quantity column
	add cl, array[bx]
	mov array[bx], cl	;Store the added value in the quantity column
	ret
AROW_1:
	mov bx, 0		;Move bx to first row
	add bx, 16		;Move bx to quantity column
	add cl, array[bx]
	mov array[bx], cl 	;Store the added value in the quantity column
	ret
AROW_2:
	mov bx, 17		;Move bx to second row
	add bx, 16		;Move bx to quantity column
	add cl, array[bx]
	mov array[bx], cl	;Store the added value in the quantity column
	ret
AROW_3:
	mov bx, 34		;Move bx to third row
	add bx, 16		;Move bx to quantity column
	add cl, array[bx]
	mov array[bx], cl	;Store the added value in the quantity column
	ret
AROW_4:
	mov bx, 51		;Move bx to fourth row
	add bx, 16		;Move bx to quantity column
	add cl, array[bx]
	mov array[bx], cl	;Store the added value in the quantity column
	ret 
tambah endp

tolak_menu proc
tolak_no_apa:
	printString tolakprompt
	getNum bh
	printChar 10
	cmp bh, 1
	jl tolak_no_apa
	cmp bh, 5
	jg tolak_no_apa
	mov user_row_input, bh
	mov cl, 10
tolak_berapa:
	printString tolakprompt2
	getNum al
	cmp al, 0
	jl tolak_berapa
	cmp al, 9
	jg tolak_berapa
	mul cl
	mov bh, al
	getNum al
	cmp al, 0
	jl tolak_berapa
	cmp al, 9
	jg tolak_berapa
	add bh, al
	ret
tolak_menu endp

tolak proc ;To subtract item quantity.
	call tolak_menu ;Double digit number is in bh register
	mov cl, bh
	mov ch, user_row_input
	cmp ch, 1
	jz SROW_1
	cmp ch, 2
	jz SROW_2
	cmp ch, 3
	jz SROW_3
	cmp ch, 4
	jz SROW_4
	mov bx, 68		;Move bx to fifth row
	add bx, 16		;Move bx to quantity column
	mov ch, array[bx]
	sub ch, cl
	mov array[bx], ch	;Store the added value in the quantity column
	ret
SROW_1:
	mov bx, 0		;Move bx to first row
	add bx, 16		;Move bx to quantity column
	mov ch, array[bx]
	sub ch, cl
	mov array[bx], ch 	;Store the added value in the quantity column
	ret
SROW_2:
	mov bx, 17		;Move bx to second row
	add bx, 16		;Move bx to quantity column
	mov ch, array[bx]
	sub ch, cl
	mov array[bx], ch	;Store the added value in the quantity column
	ret
SROW_3:
	mov bx, 34		;Move bx to third row
	add bx, 16		;Move bx to quantity column
	mov ch, array[bx]
	sub ch, cl
	mov array[bx], ch	;Store the added value in the quantity column
	ret
SROW_4:
	mov bx, 51		;Move bx to fourth row
	add bx, 16		;Move bx to quantity column
	mov ch, array[bx]
	sub ch, cl
	mov array[bx], ch 	;Store the added value in the quantity column
	ret
tolak endp

		;====MAIN====;
main proc
        init
MMENU:	;Flow for main menu;
		clearReg
		cls  ; Can uncomment when SecondMenu waits for user input
		call MainMenu
		call MMinput ;bh register will store user input
		cmp bh, 31h
		jz MENU2
		cmp bh, 32h
		jz FINISH
		
MENU2:	;Flow for listing menu;
		cls
		printString menu2title
		call project_table
		printString tail
		call SecondMenu
		call SMinput
		cmp bh, 31h
		jz TAMBAH_IN_MENU2
		cmp bh, 32h
		jz TOLAK_IN_MENU2
		cmp bh, 33h
		jz MMENU
TAMBAH_IN_MENU2:
		call tambah
		jmp MENU2
TOLAK_IN_MENU2:
		call tolak
		jmp MENU2
		
FINISH:
		cls
		printString mexit
		terminate
		
main endp
end main
