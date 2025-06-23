.ORIG x0500

;------------------------------------------------------------------------------------------------------------------
; Here is where we start our program, creating the players

;clearing the registers we are going to use
	and r0, r0, #0         ; Clear R0
	and r1, r1, #0         ; Clear R1
	and r2, r2, #0         ; Clear R2
	and r3, r3, #0         ;clear R3
    	and r4,r4, #0          ;clear R4
    	and r5,r5 , #0         ;clear R5

;loading the messages that we display at the start of our program  
     
    
	Lea r0, Welcome_message
    
	puts
	LD R0, newline
    
	OUT
	Lea r0, GetPlayer_message 
    
	puts
	LD R0, newline
    
	OUT
TryGetIntAgain:
	LD r0, Player_count ;load the address of player count that we have saved in data file (because its gonna be used longer down) and then we read the Int   
	JSR ReadInt

	LD R2, Player_count	; Here player count will be used to check how many players we want to create, 1, 2 or 3
	LDR R2, R2, 0	

; Create player 1
	LEA R0, Player1_Message
	puts
	LD R0, newline
    
	OUT

	; Get players Initials
	LD R1, Players_init
	AND R7, R7, 0
	JSR Read_2Char
	LD R0, newline
    
	OUT

	; Inistialise players money
	LD R1, Players_Money
	LD R2, Start_Money
	STR R2, R1, 0

	; Check if we want more then 1 player
	LD R2, Player_count
	LDR R2, R2, 0
	AND R3, R3, 0
	ADD R3, R2, -1
	BRz Start_Betting_Extend

	and r0, r0, #0         ; Clear R0
	and r1, r1, #0         ; Clear R1
	and r2, r2, #0         ; Clear R2
	and r3, r3, #0         ;clear R3
    	and r4,r4, #0          ;clear R4
    	and r5,r5 , #0         ;clear R5

; If wanted, Create player 2
	LEA R0, Player2_Message
	puts
	
	LD R0, newline
    
	OUT	

	LD R1, Players_init
	ADD R1, R1, 2
	AND R7, R7, 0
	JSR Read_2Char
	LD R0, newline
    
	OUT
	LD R1, Players_Money
	LD R2, Start_Money
	STR R2, R1, 1

	LD R2, Player_count	
	LDR R2, R2, 0
	; Check if we want more then 2 Players
	AND R3, R3, 0
	ADD R3, R2, -3
	BRn Start_Betting_Extend

; If wanted, Create player 3
	LEA R0, Player3_Message
	puts
	LD R0, newline
    
	OUT
	
	LD R1, Players_init
	ADD R1, R1, 4
	AND R7, R7, 0
	JSR Read_2Char
	LD R0, newline
    
	OUT
	LD R1, Players_Money
	LD R2, Start_Money
	STR R2, R1, 2

Start_Betting_Extend:
	
	BR Start_Betting_Extend_More

;--------------------------------------------------------------------------------------------------------------------------------------

DEBUG_RET	.stringz "Returned"
;--------------------------------------------------------------------------------------------------------------------------------------

WrongNumber:
	LD R0, newline
    
	OUT
	LEA R0, WrongNumber_Message
	puts
	BR TryGetIntAgain



ReadInt:
	ST R7, TEMP_R7SAVE
    	Add r1,r0, #0 ;copy the address into r1 (this step is neccesaty, cause otherwise we write both addreess and letters into r0)
	AND R0, R0, 0
    	getc
    	out
	
    	LD R2, ASCII_CONV ; R2 = -x30
        ADD R3, R0, R2        ; Convert ASCII to decimal

	
    	AND R2, R2, 0
	ADD R2, R3, -1
	BRz PlayerCount_OK
	
	AND R2, R2, 0
	ADD R2, R3, -2
	BRz PlayerCount_OK

	AND R2, R2, 0
	ADD R2, R3, -3
	BRz PlayerCount_OK
	BR WrongNumber

PlayerCount_OK:
    	STR r3,r1, #0 ;store the int (content of r0) into memory pointed by r1

	AND R0, R0, #0
	LD R0, newline
    
	OUT
	LD R7, TEMP_R7SAVE
    	RET	;returning from the subroutine

 TEMP_R7SAVE	.BLKW 1
;--------------------------------------------------------------------------------------------------------------------------------------
Welcome_message .stringz "Welcome to the wheel of fortune!"
GetPlayer_message .stringz "Please type how many players are playing using a number in the range 1-3"

;----------------------------------------
Start_Betting_Extend_More:
	BR Start_Betting
;----------------------------------------
;____________________________________________________________
; Here is all data used for creating a player




newline .FILL x000A ; ASCII value for enter, making sure we write on a new line

ASCII_CONV .FILL -48   ;
WrongNumber_Message	.stringz "This number is not valid, "
Player_count	.FILL x300D

Start_Money	.FILL 100

Players_init	.FILL x300E ; (+ x300F = Player 1) - (x3010 + x3011 = Player 2) - (x3012 + x3013 = Player 3)
Players_Money	.FILL x3014 ; ( = Player 1) - ( x3015 = Player 2) - ( x3016 = Player 3)
Players_BetAm	.FILL x3017 ; ( = Player 1) - ( x3018 = Player 2) - ( x3019 = Player 3)
Players_numb	.FILL x301A ; ( = Player 1) - ( x301B = Player 2) - ( x301C = Player 3)
Player1_Message	.stringz "Type 2 intitials of player 1"
Player2_Message	.stringz "Type 2 intitials of player 2"
Player3_Message	.stringz "Type 2 intitials of player 3"


;---------------------------------------------------

;--------------------------------------------------------------------------------------------------------------------------------------
Read_2Char:
    ST R7, TEMP_R7SAVE2
    LD R2, IO_BASE
    AND R4, R4, 0
CheckInputAvail:
    LDR R0, R2, 0   ; load IO_BASE+0  (xFE00: serial-input status register)
    BRzp CheckInputAvail

    LDR R0, R2, 2


    STR r0,r1, 0 ;store the first initial(content of r0) into memory pointed by r1
    ADD r1,r1, 1 ;move to next memory location

CheckOutputReady:
    LDR R3, R2, 4
    BRzp CheckOutputReady

    STR R0, R2, 6
    ADD R4, R4, 1
    ADD R5, R4, -2
    BRn CheckInputAvail:
    
    LD R7 TEMP_R7SAVE2
    RET
;--------------------------------------------------------------------------------------------------------------------------------------

IO_BASE	.FILL xFE00
TEMP_R7SAVE2	.BLKW 1

;-----------------------------------------------------------------------------------------------------------
WheelHistory_Start  .FILL x301D     ; Start of 10-slot buffer
WheelHistory_End    .FILL x3026     ; End of buffer
CurrentIndex        .FILL x301D     ; Tracks where next write goes
WINNING_VALUE_ADDR  .FILL x302A     ; Where final spin is stored
ASCII_0             .FILL x30       ; ASCII '0'
NEWLINE             .FILL x0A       ; ASCII newline
HISTORY_MSG	    .stringz "Here is the last 10 spins"
;-----------------------------------------------------------------------------------------------------------
; This code will only be printed after the first round since there is no reason to print a lot of 0's as no value has yet been saved
; This code was made with help from chatGTP
Start_Betting_WithWheelHistory:
	LD R0, HISTORY_MSG
	PUTS
	LD R0, CurrentIndex
    	LD R1, WINNING_VALUE_ADDR
    	LDR R1, R1, #0          ; R1 = winning number (1, 3, 5, or 9)

    	; Store the value at the current index
    	STR R1, R0, #0

    	; Increment the index
    	ADD R0, R0, #1
    	LD R2, WheelHistory_End
    	NOT R2, R2
    	ADD R2, R2, #1
    	ADD R3, R0, R2          ; R3 = R0 - WheelHistory_End
    	BRzp WrapToStart
    	BR ContinueIndex
WrapToStart:
    	LD R0, WheelHistory_Start
ContinueIndex:
    	ST R0, CurrentIndex     ; Save updated index

    ; Begin printing last 10 entries
    	LD R4, CurrentIndex     ; Start from most recent
    	AND R5, R5, 0
    	ADD R5, R5, 10          ; Loop counter is 10

PrintLoop:
    	ADD R4, R4, -1          ; Go to previous index

    ; Wrap around if before start
    	LD R2, WheelHistory_Start
    	NOT R2, R2
    	ADD R2, R2, 1
    	ADD R3, R4, R2
    	BRzp SkipWrap
    	LD R4, WheelHistory_End
SkipWrap:
    	LDR R6, R4, 0		; R6 now has the value value
    	LD R2, ASCII_0
    	ADD R0, R6, R2          ; Convert to ASCII and print
    	OUT

    	LD R0, NEWLINE
    	OUT

    	ADD R5, R5, #-1
    	BRp PrintLoop

; Done for history printout
;------------------------------------------------------
Start_Betting:

	LD R1, Players_Money_Bet
	LDR R1, R1, 0
	BRnz Skip_Player2		; Check if player still has money left, if not we skip

	; Get bet from player 1
GetBetNR1:
	LD R1, Players_init_Bet		; Display Player 1's name so they know who we are talking tooo
	LDR R0, R1, 0
	OUT
	LDR R0, R1, 1
	OUT
	
	LEA R0, Bet_message		; Tell the player what they can bet on
	Puts

	LD R0, newline_bet		; Create new line now so we dont write in the message
	OUT

	getc				; Get the number
	out
	
	AND R3, R3, 0
	JSR validBetNumber		; Check if its a valid number, The number that was written is also stored in R0 so it has to hold the value until stored
	LD R0, newline
    	OUT
	AND R3, R3, 0			; R3 will be our Variable for these functions, holding our offset so we know where to get the values
	JSR Get_Bet_Amount

	
	
Skip_Player2:
	LD R1, Player_count_bet
	LDR R0, R1, 0
	ADD R0, R0, -2
	BRn Start_Wheel_Extend2
	LD R1, Players_Money_Bet
	LDR R1, R1, 1
	BRnz Skip_Player3

GetBetNR2:
	LD R1, Players_init_Bet		; Display Player 1's name so they know who we are talking tooo
	LDR R0, R1, 2
	OUT
	LDR R0, R1, 3
	OUT
	
	LEA R0, Bet_message		; Tell the player what they can bet on
	Puts

	LD R0, newline_bet		; Create new line now so we dont write in the message
	OUT

	getc				; Get the number
	out
	
	AND R3, R3, 0
	ADD R3, R3, 1
	JSR validBetNumber		; Check if its a valid number, The number that was written is also stored in R0 so it has to hold the value until stored
	LD R0, newline
    	OUT
	AND R3, R3, 0			; R3 will be our Variable for these functions, holding our offset so we know where to get the values
	ADD R3, R3, 1
	JSR Get_Bet_Amount


Skip_Player3:
	LD R1, Player_count_bet
	LDR R0, R1, 0
	ADD R0, R0, -3
	BRn Start_Wheel_Extend2
	LD R1, Players_Money_Bet
	LDR R1, R1, 2
	BRnz Start_Wheel_Extend2

GetBetNR3:
	LD R1, Players_init_Bet		; Display Player 1's name so they know who we are talking tooo
	LDR R0, R1, 4
	OUT
	LDR R0, R1, 5
	OUT

	LEA R0, Bet_message		; Tell the player what they can bet on
	Puts

	LD R0, newline_bet		; Create new line now so we dont write in the message
	OUT

	getc				; Get the number
	out
	
	AND R3, R3, 0			; R3 will be our Variable for these functions, holding our offset so we know where to get the values
	ADD R3, R3, 2
	JSR validBetNumber		; Check if its a valid number, The number that was written is also stored in R0 so it has to hold the value until stored
	LD R0, newline_bet
    	OUT
	AND R3, R3, 0			; R3 will be our Variable for these functions, holding our offset so we know where to get the values
	ADD R3, R3, 2
	JSR Get_Bet_Amount


Start_Wheel_Extend2:
	BR Start_Wheel_Extend6
;----------------------------------------------------------------------------------------------------------
Start_BettingEX:
	BR Start_Betting_WithWheelHistory

BetNr_OK
	LD R1, Players_numb_Bet		; If ok we save and return
	ADD R1, R1, R3
	STR R0, R1, 0
	LD R7, R7RET_SAVE
	RET


Players_init_Bet	.FILL x300E ; (+ x300F = Player 1) - (x3010 + x3011 = Player 2) - (x3012 + x3013 = Player 3)
Players_Money_Bet	.FILL x3014 ; ( = Player 1) - ( x3015 = Player 2) - ( x3016 = Player 3)
Players_BetAm_Bet	.FILL x3017 ; ( = Player 1) - ( x3018 = Player 2) - ( x3019 = Player 3)
Players_numb_Bet	.FILL x301A ; ( = Player 1) - ( x301B = Player 2) - ( x301C = Player 3)
Bet_message	.stringz	", please enter the number you wanna bet on in the terminal. The number has to be one of these [1, 3, 5, 9]"
invalidbetNumber .stringz "Invalid number to bet on, please type a valid number [1, 3, 5, 9] "
newline_bet .FILL x000A

Player_count_bet	.FILL x300D



validBetNumber:
	ST R7, R7RET_SAVE
TryAgain:
	LD R2 ASCII_CONV2
	ADD R0, R0, R2
    	AND R2, R2, 0
    	Add r2, r0, -1
    	BRZ BetNr_OK
    	AND R2, R2, 0
    	Add r2, r0, #-3
    	BRZ BetNr_OK
    	AND R2, R2, 0 
    	Add r2, r0, #-5
    	BRZ BetNr_OK
    	AND R2, R2, 0
	ADD R2, R0, -9
	BRZ BetNr_OK

	LD R0, newline_bet
    	OUT

    	Lea r0, invalidbetNumber
    	puts

	LD R0, newline_bet
    	OUT

	getc				; Get the number
	out
	
	BR TryAgain

R7RET_SAVE	.BLKW 1

Start_Wheel_Extend6:
	BR Start_Wheel_Extend
;----------------------------------------------------------------------------------------------------------

ASCII_CONV2	.FILL -48

;------------------------------------------------------------------------------------------------------------------------------------------------
Next_Round_EXTEND3:
	LD R1, Players_Money_Bet
	LDR R0, R1, 0
	BRp Start_BettingEX
	LDR R0, R1, 1
	BRp Start_BettingEX
	LDR R0, R1, 2
	BRp Start_BettingEX
	LEA R0, ALL_LOST_MSG
	PUTS
	AND R0, R0, 0
	BR END_GAME			; This is the end. If all player have no money they cant play

ALL_LOST_MSG	.stringz "Everyone has 0 money left so the game has ended"

Start_Wheel_Extend:
	BR Start_Wheel_Extend3

;----------------------------------------------------------------------------------------------------------

; Converts number in R0 to string at ASCII_BUFFER ( This number to string converter has been made with help from ChatGTP)
Num_to_string:
        ; Save original number
        ADD R3, R0, #0         ; R3 = copy of number
        LEA R1, ASCII_BUFFER   ; R1 = output buffer pointer

        ; Special case: number is 0
        BRp CONTINUE
        LD R2, ASCII_ZERO
        STR R2, R1, #0
        ADD R1, R1, #1
        AND R2, R2, #0
        STR R2, R1, #0
        RET

CONTINUE:
        ; Set up for conversion
        LEA R4, DIGIT_TEMP     ; R4 = temp digit storage pointer

CONVERT_LOOP:
        AND R2, R2, #0         ; R2 = remainder
        AND R0, R0, #0

DIV10:
        ADD R0, R0, #1
        ADD R3, R3, #-10
        BRzp DIV10

        ADD R0, R0, #-1        ; fix quotient
        ADD R3, R3, #10        ; fix remainder

        LD R2, ASCII_ZERO
        ADD R2, R2, R3         ; R2 = remainder as ASCII
        STR R2, R4, #0
        ADD R4, R4, #1         ; advance digit pointer

        ADD R3, R0, #0         ; R3 = quotient
        BRp CONVERT_LOOP       ; repeat if quotient > 0

        ; Now reverse copy to output
        LEA R2, ASCII_BUFFER
        ADD R4, R4, #-1        ; point to last digit

REVERSE_COPY:
        LDR R3, R4, #0
        STR R3, R2, #0
        ADD R4, R4, #-1
        ADD R2, R2, #1
        LEA R0, DIGIT_TEMP
        NOT R0, R0
        ADD R0, R0, #1
        ADD R1, R4, R0
        BRzp REVERSE_COPY

        AND R0, R0, #0
        STR R0, R2, #0         ; null terminator
        RET

; Data
ASCII_ZERO     .FILL x30
ASCII_BUFFER   .BLKW 6         ; Holds result string
DIGIT_TEMP     .BLKW 6         ; Temp storage for digits

; Done for number to string converter
; -----------------------------------------------------------------------------------------
END_GAME:
	BR END_GAME2



DoneSaveAmount:
	LD R2, PlayersAmount_BASE
	LD R3, Temp_offsetSAVE
	ADD R2, R2, R3
	STR R5, R2, 0
	LD R0, newline3
	OUT
	LD R7, R7RET_SAVE2
	RET





Get_Bet_Amount:
	ST R7, R7RET_SAVE2
	ST R3, Temp_offsetSAVE
TryBetAgain:
	LEA R0, Total_money_MSG
	PUTS
	
	LD R0, PlayersBalance_BASE
	LD R3, Temp_offsetSAVE
	ADD R0, R0, R3
	LDR R0, R0, 0
	JSR Num_to_string

	LEA R0, ASCII_BUFFER
        PUTS

	LD R0, newline3
	OUT
	
	LEA R0, GetAmount_MSG
	PUTS

	LD R0, newline3
	OUT

	LD R2, BTN_ADDRESS
WaitForPress:
	LDR R4, R2, 0
	BRz WaitForPress
	AND R1, R1, 0
	ADD R1, R4, -1		; With our given numbers it shouldnt be possible 0 < x < 5
	BRp Not1
	AND R5, R5, 0
	ADD R5, R5, 5
	LEA R0, btn1_MSG
	PUTS

WaitForPress1:
	LDR R4, R2, 0
	BRp WaitForPress1

	BR DoneSaveAmount

;-----------------------------
Next_Round_EXTEND10:
	BR Next_Round_EXTEND3
;-----------------------------

Not1:
	AND R1, R1, 0
	ADD R1, R4, -2
	BRp Not2
	AND R5, R5, 0
	ADD R5, R5, 10

	LD R6, PlayersBalance_BASE
	LD R3, Temp_offsetSAVE
	ADD R2, R6, R3
	LDR R3, R6, 0
	NOT R4, R5	
	ADD R4, R4, 1
	ADD R4, R4, R3
	BRzp WaitForPress2:
	LEA R0, NotEnoguh_MSG
	PUTS
	LD R0, newline_Wheel
	OUT
	BR TryBetAgain:


WaitForPress2:
	LD R2, BTN_ADDRESS
	LDR R4, R2, 0
	BRp WaitForPress2
	LEA R0, btn2_MSG
	PUTS
	BR DoneSaveAmount

	

Not2:
	AND R1, R1, 0
	ADD R1, R4, -4
	BRp Not3
	AND R5, R5, 0
	ADD R5, R5, 15
	ADD R5, R5, 15
	ADD R5, R5, 15
	ADD R5, R5, 5

	LD R6, PlayersBalance_BASE
	LD R3, Temp_offsetSAVE
	ADD R6, R6, R3
	LDR R3, R6, 0
	NOT R4, R5	
	ADD R4, R4, 1
	ADD R4, R4, R3
	BRzp WaitForPress3:
	LEA R0, NotEnoguh_MSG
	PUTS
	LD R0, newline_Wheel
	OUT
	BR TryBetAgain:

WaitForPress3:
	LD R2, BTN_ADDRESS
	LDR R4, R2, 0
	BRp WaitForPress3
	LEA R0, btn3_MSG
	PUTS

	BR DoneSaveAmount
Not3:					
	LD R2, PlayersBalance_BASE	; ALL in uses all the players money so we wont need to check if excetds the amount they have
	LD R3, Temp_offsetSAVE
	ADD R2, R2, R3
	LDR R5, R2, 0
	LEA R0, btn4_MSG
	PUTS

	LD R2, BTN_ADDRESS

WaitForPress4:
	LDR R4, R2, 0
	BRp WaitForPress4


	BR DoneSaveAmount


Start_Wheel_Extend3:
	BR Start_Wheel_Extend4

R7RET_SAVE2	.BLKW 1
Total_money_MSG	.stringz "You have right now this amount of money to use: " 
;-------------------
Start_Wheel_Extend4:
	BR Start_Wheel

;----------------------
END_GAME2:
	BR END_GAME3
;----------------------

Next_Round_EXTEND9:
	BR Next_Round_EXTEND10
;-------------------
Temp_offsetSAVE	.BLKW 1
PlayersBalance_BASE	.FILL x3014
PlayersAmount_BASE	.FILL x3017
newline3 .FILL x000A
BTN_ADDRESS	.FILL xFE0F
GetAmount_MSG	.stringz "Click a button to bet. Bnt 1 = 5, Bnt 2 = 10, Bnt 3 = 50, Bnt 4 = All In"
btn1_MSG	.stringz "betted 5"
btn2_MSG	.stringz "betted 10"
btn3_MSG	.stringz "betted 50"
btn4_MSG	.stringz "All In!!"
NotEnoguh_MSG	.stringz "Not engough money, try lower amount"
;-----------------------------------------------------------------------------------------------
newline_Wheel .FILL x000A
Wheel_MSG	.stringz "Ready to spin. Press button 1 for soft spin, button 2 for medium and button 3 for hard spin"

Next_Round_EXTEND8:
	BR Next_Round_EXTEND9

;---------------------
END_GAME3:
	BR END_GAME4
;--------------------

Start_Wheel:
	LD R0, DATA_BASE
	LDR R0, R0, x0F
	BRp Start_Wheel		; Making sure any press from getting bet amount isnt interfering here
	LEA R0, Wheel_MSG
	PUTS
	LD R0, newline_Wheel 
	OUT
	LD R0, DATA_BASE     	; Load the button address
	AND R1, R1, 0        	; Counter
INT_WAIT_BTN:
	LDR R2, R0, x0F		; Read the button
	BRz PLUS_COUNTER	; If not pressed we keep counting
	BR SEED_READY		; If button is pressed we go to stop

PLUS_COUNTER:
	ADD R1, R1, 1		; +1 on counter and go back
	BR INT_WAIT_BTN

SEED_READY:
	LD R3, MASK_START	; Load mask x001F for 5-bit
	AND R1, R1, R3		; Mask to 5-bit
	ST R1, RNG_SEED		; Save seed

;WAITING:			; Normaly it would be smart to wait to ensure that we dont press a button that will react to something next
	;LD R2, DATA_BASE	; but in our case we can tell the user to press the button they want for speed and behind the scenes
	;LDR R0, R2, x0F	; we are stopping the seed counter and starting the wheel with 1 tap even if its fast. 
	;BRp WAITING

; Here is where the game actually starts
WAIT_BTN_START:
	LD R2, DATA_BASE
	LDR R0, R2, x0F		; Cheack if button is pressed
	BRz WAIT_BTN_START
	AND R1, R1, 0
	ADD R1, R1, 8		; If the 4th button was pressed we do nothing
	NOT R1, R1
	ADD R1, R1, 1
	ADD R1, R0, R1
	BRz WAIT_BTN_START	; Jump back if 4th button
	
	LD R1, IN_DELAY
	ST R1, INNER_COUNT	; We reset our "timers" inner loop


	AND R1, R1, 0
	ADD R1, R1, 2
	NOT R1, R1
	ADD R1, R1, 1
	ADD R0, R0, R1		; Having 3 buttons, each button gives 1st = 1, 2nd = 2, 3rd = 4
	BRp FAST		; Using 2 as the check we can see if its higher, equal or lower and here after choose the right speed
	BRz MID
	BRn SLOW

START:
	AND R1, R1, 0		; Here is where we return after setting the speed for the wheel
	AND R2, R2, 0
	AND R3, R3, 0
	AND R4, R4, 0
	
	LD R1, INDEX_REG	; R1 = index = 0

NEXT_SPIN:
	ST R1, INDEX_PC
	JSR SEND_PC
	LD R2, Wheel_BASE	; R2 = base address of wheel array (x3000)
	ADD R3, R2, R1		; R3 = address of current element
	LDR R4, R3, 0        	; R4 = value of current wheel slot
	ST R4, CURRENT_VALUE
	LD R2, DATA_BASE
	STR R4, R2, x12		; Display current value
	
DELAY_LOOP:

	LD R0, DEC_SPEED

	JSR DELAY_1

	LD R2, INNER_COUNT
	ADD R2, R2, R0
	ST R2, INNER_COUNT


	
	LD R3, SLOW_DOWN1
	ADD R2, R2, R3
	BRn RESUME

	LD R3, DEC_SPEED_M
	ST R3, DEC_SPEED


	LD R2, INNER_COUNT
	LD R3, SLOW_DOWN2
	ADD R2, R2, R3
	BRn RESUME

	LD R3, DEC_SPEED_S
	ST R3, DEC_SPEED
	
	LD R2, INNER_COUNT
	LD R3, SLOW_DOWN3
	ADD R2, R2, R3
	BRn RESUME

	LD R3, DEC_SPEED_S2
	ST R3, DEC_SPEED
	
	LD R2, INNER_COUNT
	LD R3, SLOW_DOWN4
	ADD R2, R2, R3
	BRn RESUME



	BR FINISH


RESUME:
	ADD R1, R1, 1		; Move to next index
	LD R5, WHEEL_SIZE	; R5 = 13
	NOT R5, R5
	ADD R5, R5, 1		; R5 = -13
	ADD R6, R1, R5		; R6 = R1 - 13
	BRn NEXT_SPIN		; If R1 < 13, spin again

	AND R1, R1, 0		; Reset index to 0
	BRnzp NEXT_SPIN		; Loop

FINISH:
	ST R1, INDEX_REG
	LD R1, CURRENT_VALUE
	LD R2, WINNING_VALUE_ADR
	STR R1, R2, 0
	

	BR Calculate_Winnings
	

Next_Round_EXTEND2:
	BR Next_Round_EXTEND8

CURRENT_VALUE	.BLKW 1		; Register to hold the current value
WINNING_VALUE_ADR	.FILL x302A	; Register to hold the value of the final and winning number



FAST:				; Here is where we set the fast speed value (Fast is more of a hard spin so long spin)
	AND R0, R0, 0
	ADD R0, R0, 11		; R0 is holding the range we want our random number to be in between
	JSR RNG			; Call RNG function to get a random number. It will be stored in R0
	ADD R0, R0, 2		; We add with 2 just to make sure it is above 0 and 1
	ST R0, DEC_SPEED_F	; Here is where we save it
	ST R0, DEC_SPEED	

	AND R0, R0, 0
	ADD R0, R0, 15		; Same thing but with a bigger range
	JSR RNG
	LD R1, FAST_M		; And also a bigger add to ensure a minimum value
	ADD R0, R0, R1 
	ST R0, DEC_SPEED_M


	AND R0, R0, 0
	ADD R0, R0, 15
	ADD R0, R0, 15		; Same thing
	JSR RNG
	LD R1, FAST_S
	ADD R0, R0, R1
	ST R0, DEC_SPEED_S

	AND R0, R0, 0
	ADD R0, R0, 15
	ADD R0, R0, 15
	ADD R0, R0, 15
	ADD R0, R0, 15		; Same thing
	JSR RNG
	LD R1, FAST_SS
	ADD R0, R0, R1
	ST R0, DEC_SPEED_S2

	BR START		; Go to the start program to spin the wheel

MID:				; This function works the exact same as fast just using different values for spinning slower
	AND R0, R0, 0
	ADD R0, R0, 6
	JSR RNG
	ADD R0, R0, 7
	ST R0, DEC_SPEED_F
	ST R0, DEC_SPEED	

	AND R0, R0, 0
	ADD R0, R0, 15
	JSR RNG
	LD R1, MID_M
	ADD R0, R0, R1 
	ST R0, DEC_SPEED_M


	AND R0, R0, 0
	ADD R0, R0, 15
	ADD R0, R0, 15
	JSR RNG
	LD R1, MID_S
	ADD R0, R0, R1
	ST R0, DEC_SPEED_S

	AND R0, R0, 0
    	ADD R0, R0, 15
	ADD R0, R0, 15
	ADD R0, R0, 15
	ADD R0, R0, 15
    	JSR RNG
	LD R1, MID_SS
	ADD R0, R0, R1
	ST R0, DEC_SPEED_S2

	BR START

SLOW:				; Works the same as Fast and Mid but runs way slower
	AND R0, R0, 0
	ADD R0, R0, 15
	JSR RNG
	ADD R0, R0, 10
	ST R0, DEC_SPEED_F
	ST R0, DEC_SPEED	

	AND R0, R0, 0
	ADD R0, R0, 15
	JSR RNG
	LD R1, SLOW_M
	ADD R0, R0, R1 
	ST R0, DEC_SPEED_M


	AND R0, R0, 0
	ADD R0, R0, 15
	ADD R0, R0, 15
	ADD R0, R0, 3
	JSR RNG
	LD R1, SLOW_S
	ADD R0, R0, R1
	ST R0, DEC_SPEED_S

	AND R0, R0, 0
	ADD R0, R0, 15
	ADD R0, R0, 15
	ADD R0, R0, 15
	ADD R0, R0, 15
	ADD R0, R0, 3
	JSR RNG
	LD R1, SLOW_SS
	ADD R0, R0, R1
	ST R0, DEC_SPEED_S2

	BR START


RNG_SEED  	.FILL x0053

MASK 		.FILL x00FF
MASK_START	.FILL x001F

WHEEL_SIZE 	.FILL 13
Wheel_BASE	.FILL x3000
DATA_BASE	.FILL xFE00


;---------------------------------------------------------------
; Here is where we create a random number (This part of the code was made with the help of ChatGTP)
RNG:				
	LD R1, RNG_SEED		; R1 = seed

	; LCG formula: seed = (a * seed + c) mod 256
	ADD R2, R1, R1		; 2 * seed
	ADD R2, R2, R1		; 3 * seed
	ADD R2, R2, R2		; 6 * seed
	ADD R2, R2, R1		; 7 * seed (a * seed) a=7
	ADD R2, R2, 15
	ADD R2, R2, 8		; c = 23

	LD R1, MASK		; Load the mask "x00FF" into R1 to 8 bit mask
	AND R2, R2, R1		; AND R2 with R1 creating a new seed
	ST R2, RNG_SEED		; Save the new seed

	; R2 = raw random (0-255), reduce to range 0-(R0-1)
	AND R3, R3, 0
	ADD R3, R3, R2		; R3 = raw random

MOD_LOOP:
	NOT R4, R0
	ADD R4, R4, 1		; R4 = -R0
	ADD R3, R3, R4		; R3 -= max
	BRn DONE_MOD
	BRnzp MOD_LOOP

DONE_MOD:
	ADD R3, R3, R0		; Back to last valid
	ADD R0, R3, 0		; Push resualt in to R0
	RET

; Done For Random Number Generator
;---------------------------------------------------------------

SEND_PC:
	LD R2, PC_BASE		; UART base (xFE20)

	LD R0, HEADER
WAIT:
	LDR R3, R2, 4
	BRzp WAIT
	STR R0, R2, 6

	LD R0, CMD
WAIT2:
	LDR R3, R2, 4
	BRzp WAIT2
	STR R0, R2, 6
	
	LD R0, INDEX_PC
WAIT3:
	LDR R3, R2, 4
	BRzp WAIT3
	STR R0, R2, 6

	RET

; ----------------------------------------
Next_Round_EXTEND:
	BR Next_Round_EXTEND2

END_GAME4:
	BR END_GAME5
;----------------------------------------

DELAY_1:
	LD R3, DELAY_COUNT
DELAY_OUTER:
	LD R4, INNER_COUNT
DELAY_INNER:
	ADD R4, R4, -1
	BRp DELAY_INNER
	ADD R3, R3, -1
	BRp DELAY_OUTER
	RET



IN_DELAY	.FILL 111	; Initialsing the delay so we can restart every time

INNER_COUNT	.FILL 111

DELAY_COUNT	.FILL 1700	; 2900 is close to being 1 sec


SLOW_DOWN1	.FILL -1000
SLOW_DOWN2	.FILL -1400
SLOW_DOWN3	.FILL -2300
SLOW_DOWN4	.FILL -4000

DEC_SPEED	.FILL 1

DEC_SPEED_F	.FILL 0
DEC_SPEED_M	.FILL 0
DEC_SPEED_S	.FILL 0
DEC_SPEED_S2	.FILL 0


FAST_F		.FILL 3
FAST_M		.FILL 11
FAST_S		.FILL 193
FAST_SS		.FILL 422

MID_F		.FILL 7
MID_M		.FILL 33
MID_S		.FILL 233
MID_SS		.FILL 453

SLOW_F		.FILL 11
SLOW_M		.FILL 39
SLOW_S		.FILL 247
SLOW_SS		.FILL 472


INDEX_REG	.FILL 0		; Save current value of the wheel


PC_BASE 	.FILL xFE20
HEADER 		.FILL x55  ; 0x55 = ASCII 'U'
CMD    		.FILL x01
INDEX_PC	.FILL 0

;---------------------------------------------------------------

Win_NR_MSG	.stringz "The wheel landed on the number: "
newline_CAL 	.FILL x000A

END_GAME5:
	BR END_GAME6

Calculate_Winnings:
	LEA R0, Win_NR_MSG
	PUTS
	LD R0, Final_Value
	LDR R0, R0, 0
	LD R2, Conver2ASCII	
	ADD R0, R0, R2
	OUT
	LD R0, newline_CAL
	OUT
	LD R2, Final_Value
	LDR R2, R2, 0
	NOT R2, R2
	ADD R2, R2, 1		; R2 will hold the negative value of the number the wheel landed on
	ST R2, WinningNeg
; Check player 1

	LD R0, Players_balance
	LDR R0, R0, 0
	BRz CheckPla2:

	LD R5, Players_BetAmount
	LDR R5, R5, 0
	LD R2, Players_balance
	LDR R3, R2, 0
	NOT R5, R5
	ADD R5, R5, 1
	ADD R5, R3, R5
	LD R2, Players_balance
	STR R5, R2, 0


	LD R3, Players_Names
	LDR R0, R3, 0
	OUT
	LDR R0, R3, 1
	OUT
	LEA R0, YouHave_MSG
	PUTS
	LD R3, Players_BetNumber
	LDR R3, R3, 0
	LD R4, Players_balance
	LD R5, Players_BetAmount
	JSR CheckForWin

CheckPla2:

	LD R0, Players_balance
	LDR R0, R0, 1
	BRz CheckPla3:

	LD R5, Players_BetAmount
	LDR R5, R5, 1
	LD R2, Players_balance
	LDR R3, R2, 1
	NOT R5, R5
	ADD R5, R5, 1
	ADD R5, R3, R5
	LD R2, Players_balance
	STR R5, R2, 1


	LD R3, Players_Names
	LDR R0, R3, 2
	OUT
	LDR R0, R3, 3
	OUT
	LEA R0, YouHave_MSG
	PUTS
	LD R3, Players_BetNumber
	LDR R3, R3, 1
	LD R4, Players_balance
	ADD R4, R4, 1
	LD R5, Players_BetAmount
	ADD R5, R5, 1
	JSR CheckForWin

CheckPla3:

	LD R0, Players_balance
	LDR R0, R0, 2
	BRz Next_Round_EXTEND

	
	LD R5, Players_BetAmount
	LDR R5, R5, 2
	LD R2, Players_balance
	LDR R3, R2, 2
	NOT R5, R5
	ADD R5, R5, 1
	ADD R5, R3, R5
	LD R2, Players_balance
	STR R5, R2, 2

	LD R3, Players_Names
	LDR R0, R3, 4
	OUT
	LDR R0, R3, 5
	OUT
	LEA R0, YouHave_MSG
	PUTS
	LD R3, Players_BetNumber
	LDR R3, R3, 2
	LD R4, Players_balance
	ADD R4, R4, 2
	LD R5, Players_BetAmount
	ADD R5, R5, 2
	JSR CheckForWin
	
	BR Next_Round_EXTEND

; R3 = number bet on, R4 = Address of players balance, R5 = ADDRESS of How much they bettet
CheckForWin:
	ST R7, CheckR7Save
	LD R2, WinningNeg	; R2 = -WinningNR
	ADD R3, R3, R2
	BRz PlayerWon
	LEA R0 LostMSG		; Player lost
	PUTS
	LD R0, newline_CAL
	OUT
	LD R7, CheckR7Save
	RET
PlayerWon:
	LEA R0, WonMSG
	PUTS
	LD R0, newline_CAL
	OUT
	ADD R6, R2, 1
	BRn NRnot1
	LDR R6, R5, 0
	ADD R6, R6, R6
	LDR R1, R4, 0
	ADD R6, R1, R6
	STR R6, R4, 0
	LD R7, CheckR7Save
	RET 
NRnot1:
	ADD R3, R2, 3
	BRn NRnot3
	LDR R6, R5, 0
	ADD R6, R6, R6
	ADD R6, R6, R6
	LDR R1, R4, 0
	ADD R6, R1, R6
	STR R6, R4, 0
	LD R7, CheckR7Save
	RET
NRnot3:
	ADD R3, R2, 5
	BRn NRnot5
	LDR R6, R5, 0
	ADD R2, R6, R6
	ADD R6, R6, R2
	ADD R6, R6, R6
	LDR R1, R4, 0
	ADD R6, R1, R6
	STR R6, R4, 0
	LD R7, CheckR7Save
	RET

NRnot5:
	LDR R6, R5, 0
	ADD R2, R6, R6
	ADD R0, R2, R2
	ADD R6, R0, R6
	ADD R6, R6, R6
	LDR R1, R4, 0
	ADD R6, R1, R6
	STR R6, R4, 0
	LD R7, CheckR7Save
	RET
	
Final_Value		.FILL x302A
Players_BetNumber	.FILL x301A
Players_Names		.FILL x300E
Players_balance		.FILL x3014
Players_BetAmount	.FILL x3017
WinningNeg		.BLKW 1

CheckR7Save	.BLKW 1
Conver2ASCII	.FILL 48

YouHave_MSG		.stringz " you have gueesed "
WonMSG			.stringz "Correctly and won money!"
LostMSG			.stringz "Wrong and lost your money"

END_GAME6:
	AND R0, R0, 0
	HALT
.END