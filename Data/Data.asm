.ORIG x3000
HjulArray	.FILL	1 ; Offset 0 (address x3000)
		.FILL	3 ; Offset 1
		.FILL	1 ; Offset 2
		.FILL	5 ; Offset 3
		.FILL	1 ; Offset 4
		.FILL	3 ; Offset 5
		.FILL	1 ; Offset 6
		.FILL	9 ; Offset 7
		.FILL	3 ; Offset 8
		.FILL	1 ; Offset 9
		.FILL	5 ; Offset 10
		.FILL	1 ; Offset 11
		.FILL	3 ; Offset 12 (address x300C)

Player_count	.BLKW	0 ; Address x300D

; Player names
Player1_init	.BLKW #2 ; Address x300E og x300F
Player2_init	.BLKW #2 ; Address x3010 og x3011
Player3_init	.BLKW #2 ; Address x3012 og x3013

; Players Money balance
Player1_balance	.FILL 0 ; Address x3014
Player2_balance	.FILL 0 ; Address x3015
Player3_balance	.FILL 0	; Address x3016

; Players Bet Amount
Player1_BetAmount	.FILL 0 ; Address x3017
Player2_BetAmount	.FILL 0 ; Address x3018
Player3_BetAmount	.FILL 0 ; Address x3019

; What number the player bet on
Player1_BetNumber	.FILL 0 ; Address x301A
Player2_BetNumber	.FILL 0 ; Address x301B
Player3_BetNumber	.FILL 0 ; Address x301C


;Wheel histroy of the last 10 spins will be stored in an array
WheelHistory 	.FILL	0 ; Offset 0 (address x301D)
		.FILL	0 ; Offset 1
		.FILL	0 ; Offset 2
		.FILL	0 ; Offset 3
		.FILL	0 ; Offset 4
		.FILL	0 ; Offset 5
		.FILL	0 ; Offset 6
		.FILL	0 ; Offset 7
		.FILL	0 ; Offset 8
		.FILL	0 ; Offset 9  (Address x3026)
		.FILL	0 ; Offset 10 (Not Used)
		.FILL	0 ; Offset 11 (Not Used)
		.FILL	0 ; Offset 12 ; Not used

WINNING_VALUE	.BLKW 1 ; Address x302A


.END