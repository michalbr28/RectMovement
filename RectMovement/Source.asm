.486
.model flat, stdcall
option casemap : none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\msvcrt.inc
includelib msvcrt.lib

include drd.inc
includelib drd.lib


.data
	STime SYSTEMTIME{}; at: proc Random

;Variables for the Random:

	;The rundom number - the starting Y value of the ball.
	random_num DWORD 0

	;The minimal Y value.
	mini DWORD 1

	;The maximal Y value.
	maxi DWORD 557

	;The size of the window.
	windowWidth DWORD 1000
	windowHeight DWORD 600

    ;The limits of the window.
	limitX DWORD windowWidth
	limitY DWORD windowHeight

	;Stopping position on the Y direction.
	borderY DWORD 0
	borderY2 DWORD 0

	;The delay between the movements.  
	turn DWORD 0
	turnBall DWORD 0

;The settings of the background.
pong BYTE "Pong.bmp",0
Back struct
	info Img<>

	;backgroung starting positon.
	x DWORD 0
	y DWORD 0

	;the size of the background.
	widthBack DWORD 1000
	heightBack DWORD 600

Back ends
bg Back<>


;The settings of the ball.
tennis BYTE "Tennis.bmp",0
Ball struct
	info Img<>

	;The ball's starting position.
	x DWORD 480
	y DWORD 250

	;The starting direction of the ball.
	dirx DWORD 1
	diry DWORD 1

	;The size of the ball.
	widthBall DWORD 43
	heightBall DWORD 43

Ball ends
tnn Ball<>


;The setting of the player1 - purple racket.
rect BYTE "Player.bmp",0
Player1 struct

	info Img<>

	;Player1's starting directions.
	dirx DWORD 1
	diry DWORD 1

	;Player1's starting position.
	x DWORD 100
	y DWORD 200

	;The size of Player1's racket.
	widthRect DWORD 30
	heightRect DWORD 150

Player1 ends
rec Player1<>


;The settings of player2 - red racket.
rect2 BYTE "Player2.bmp",0
Player2 struct

	info Img<>

	;Player2's starting directions.
	dirx DWORD 1
	diry DWORD 1

	;Player2's starting position.
	x DWORD 870
	y DWORD 200

	;The size of Player2's racket.
	widthRect DWORD 30
	heightRect DWORD 150

Player2 ends
rec2 Player2<>


;The settings of Win.
winner BYTE "Win.bmp",0
WinImg struct

	info Img<>

	;Win starting position.
	x DWORD 500
	x1 DWORD 0
	y DWORD 0

	;The size of win image.
	widthRect DWORD 500
	heightRect DWORD 600

WinImg ends
winn WinImg<>


;The settings of Lose.
lose BYTE "Lose.bmp",0
LoseImg struct

	info Img<>

	;Lose starting position.
	x1 DWORD 500
	x DWORD 0
	y DWORD 0

	;The size of lose image.
	widthRect DWORD 500
	heightRect DWORD 600

LoseImg ends
looser WinImg<>


.code

X macro args : VARARG
	asm_txt TEXTEQU <>
	FORC char, <&args>
	IFDIF <&char>, <!\>
	asm_txt CATSTR asm_txt, <&char>
	ELSE
	asm_txt
	asm_txt TEXTEQU <>
	ENDIF
	ENDM
	asm_txt
endm

;Random Y value for the ball.
Random PROC min:DWORD, max:DWORD
	; "A pseudo-random number generator (PRNG) is a program that takes a starting number (called a seed), 
	; and performs mathematical operations on it to transform it into some other number that appears to be 
	; unrelated to the seed." - learncpp.com
	; 
	; random = (seed * some big number) % (max - min + 1) + min
	;
	; by ohad gitzelter 0546677598
	pusha
	
	; calculates max - min + 1
	mov eax, max
	sub eax, min
	mov max, eax
	inc max
	
	; gets a always changing seed
	invoke GetSystemTime ,addr STime

	; moves to ax the current clock miliseconds and moves the bx the current clock seconds,
	; the two values that changes most frequently

	mov ax, STime.wMilliseconds
	mov bx, STime.wSecond

	; multiplies eax by the current miliseconds and seconds (ax and bx)
	; (seed * some big number)
	mul ax
	mul bx

	; reset edx to prevent integer overflow (you shouldnt care about why)
	xor edx, edx

	; divides the value in eax by the max value (reminder will be in edx)
	; (seed * some big number) % (max - min + 1)

	div max
	
	; add min to the final result 
	; + min
	add edx, min

	; move the random number in edx to your desired variable
	mov random_num, edx

	popa
	ret
Random ENDP


;This is the movement of the ball along the X direction.
BallX PROC
pusha

	;Checks what direction the ball is haeding to (Left or Right).
	cmp tnn.dirx, 0
	jg right
	jl left

;Moves the ball 1 pixel to the left.
left:
	mov eax, tnn.x
	dec eax
	mov tnn.x, eax
	jmp continue

;Moves the ball 1 pixel to the right.
right:
	mov eax, tnn.x
	inc eax
	mov tnn.x, eax

;Keeps the ball in the window.
continue: 

	;Subtracts the ball's width from the window width.
	mov eax, windowWidth
	sub eax, tnn.widthBall
	cmp tnn.x, eax

	popa
	jge goLeft

	cmp tnn.x, 5
	jl goRight

jmp exit

;Changes the balls direction. 
goLeft:
	mov tnn.dirx, -1
	jmp exit

;Changes the balls direction. 
goRight:
	mov tnn.dirx, 1
	jmp exit
	
	exit: 
		ret
BallX ENDP


;This is the movement of the ball along the Y direction.
BallY PROC
pusha

	;Checks what direction the ball is haeding to (Up or Down).
	cmp tnn.diry, 0
	jg up
	jl down

;Moves the ball 1 pixel down. 
down:
	mov eax, tnn.y
	dec eax
	mov tnn.y, eax
	jmp continue

;Moves the ball 1 pixel up.
up:
	mov eax, tnn.y
	inc eax
	mov tnn.y, eax

;Keeps the ball in the window.
continue: 

	;Subtracts the ball's width from the window width.
	mov eax, windowHeight
	sub eax, tnn.heightBall
	cmp tnn.y, eax

	popa
	jge goUp

	cmp tnn.y, 5
	jl goDown

jmp exit

;Changes the balls direction. 
goUp:
	mov tnn.diry, -1
	jmp exit

;Changes the balls direction.
goDown:
	mov tnn.diry, 1
	jmp exit
	
	exit: 
		ret
BallY ENDP


BallManager PROC	
	pusha
		add turnBall,1
	popa

	;turn is like the speed. The bigger the number that I compare to gets, the slower the ball moves.
	cmp turnBall, 4 
	je doTurn	
	jmp exit

	;Does the movement. 
	doTurn:
		mov turnBall, 0			 
		invoke BallX
		invoke BallY

	exit:
		ret
BallManager ENDP


;This is the movement of player1 along the Y direction.
MoveY1 PROC
	pusha
		;Moves player1 1 pixle.
		mov eax, rec.y 
		add eax, rec.diry 
		mov rec.y, eax			 
		
		;Checks if player1 reached the bottom limit of the window.
		mov eax, limitY 
		cmp rec.y, eax 
		mov borderY, eax 
		jg stop
		
		;Jumps to stop when player2 is on Y = 4.
		cmp rec.y, 4
		mov borderY, 4
		jl stop

		jmp exit

	;Stops player1 in Y = borderY.
	stop:
		mov eax, borderY 
		mov rec.y, eax
		
	exit: 
		popa
		ret
MoveY1 ENDP


;Activates MoveY1.
MovementManager1 PROC	
	pusha
		;Increases turn by one.
		mov eax, turn 
		inc eax 
		mov turn, eax
		
		;The delay between the movements.
		cmp turn, 5 
		je doTurn
		popa
jmp exit

	doTurn:
	popa
		mov turn, 0	

			;Checks if the "W" key pressed.
			invoke GetAsyncKeyState, VK_W 
			cmp eax, 0
			
			;Changes the direction and goes to the movement. 
			mov rec.diry, -1 
			jne MoveY1
			

			;Checks if the "S" key pressed.
			invoke GetAsyncKeyState, VK_S 
			cmp eax, 0 

			;Changes the direction and goes to the movement.
			mov rec.diry, 1 
			jne MoveY1	 	
	exit:		
		ret
MovementManager1 ENDP


;This is the movement of player2 along the Y direction.
MoveY2 PROC
	pusha
		;Moves player2 1 pixle.
		mov eax, rec2.y 
		add eax, rec2.diry 
		mov rec2.y, eax			 
		
		;Checks if player2 reached the bottom limit of the window.
		mov eax, limitY 
		cmp rec2.y, eax 
		mov borderY2, eax 
		jg stop
		
		;Jumps to stop when player2 is on Y = 4.
		cmp rec2.y, 4
		mov borderY2, 4
		jl stop

		jmp exit

	;Stops player2 in Y = borderY2.
	stop:
		mov eax, borderY2
		mov rec2.y, eax
		
	exit: 
		popa
		ret
MoveY2 ENDP


;Activates MoveY2.
MovementManager2 PROC	
	pusha
		;Increases turn by one.
		mov eax, turn 
		inc eax 
		mov turn, eax
		
		;The delay between the movements.
		cmp turn, 5
		je doTurn
		popa
jmp exit

	doTurn:
	popa
		mov turn, 0	

			;Checks if the "W" key pressed.
			invoke GetAsyncKeyState, VK_UP
			cmp eax, 0 

			;Changes the direction and goes to the movement.
			mov rec2.diry, -1 
			jne MoveY2

			
			;Checks if the "S" key pressed.
			invoke GetAsyncKeyState, VK_DOWN 
			cmp eax, 0 

			;Changes the direction and goes to the movement.
			mov rec2.diry, 1 
			jne MoveY2	 	
	exit:		
		ret
MovementManager2 ENDP


;Keeps the rectangle inside the window.
init PROC	
	pusha
		;Moves the height of the window to: limitY by the register.
		mov eax, windowHeight 
		mov limitY, eax
		
		;Subtract the rectangle's height from the window height.
		mov eax, limitY 
		sub eax, rec.heightRect
		sub eax, 5
		mov limitY, eax
	popa
	ret
init ENDP


Collision PROC
	pusha

	;Checks which direction the ball moves.
	 mov eax, tnn.dirx 
	 cmp eax, 0 
	 jg right 
	 jl left

;Ckecks for a collision with player2
right:
	;Adds the width of the ball.
	mov eax, tnn.x
	add eax, tnn.widthBall

	;Checks if the ball and player2 are at the same X location.
	cmp eax, rec2.x

	jge overXr
	jmp exit

;Checks if the ball in the Y range of player2.
overXr:
	;Adds the height of playet2.
	mov eax, rec2.y
	add eax, rec2.heightRect

	;Compares the top of the ball with the bottom of player2.
	cmp tnn.y ,eax
	jg exit

	;Adds the height of the ball.
	mov eax, tnn.y
	add eax, tnn.heightBall

	;Compares the bottom of the ball with the top of player2.
	cmp eax, rec2.y
	jl exit

	;Changes the direction of the ball.
	mov tnn.dirx, -1
	jmp left


;Ckecks for a collision with player2
left:	
	;Adds the width of the player1.
	mov eax, rec.x	
	add eax, rec.widthRect

	;Checks if the ball and player1 are at the same X location.
	cmp tnn.x, eax

	jle overXl
	jmp exit

;Checks if the ball in the Y range of player1.
overXl:
	;Adds the heigth of player1.
	mov eax, rec.y
	add eax, rec.heightRect

	;Compares the top of the ball with the bottom of player1.
	cmp tnn.y, eax

	jg exit

	;Compares the top of the ball with the top of player1.
	mov eax, tnn.y
	cmp eax, rec.y

	jl exit

	;Changes the direction of the ball.
	mov tnn.dirx, 1
		
exit: 
	popa
		ret
Collision ENDP


EndGame PROC		
		invoke drd_imageDraw, offset looser.info, looser.x1, looser.y
		invoke drd_imageDraw, offset winn.info, winn.x, winn.y
	ret
EndGame ENDP


EndGame1 PROC
	invoke drd_imageDraw, offset looser.info, looser.x, looser.y
	invoke drd_imageDraw, offset winn.info, winn.x1, winn.y

  ret
EndGame1 ENDP


main PROC
	
	;Draws a window according to given size.
	invoke drd_init, bg.widthBack, bg.heightBack , 0

	;Loads all the images.
	invoke drd_imageLoadFile, offset tennis, offset tnn.info
	invoke drd_imageLoadFile, offset rect, offset rec.info
	invoke drd_imageLoadFile, offset rect2, offset rec2.info
	invoke drd_imageLoadFile, offset pong, offset bg.info
	invoke drd_imageLoadFile, offset lose, offset looser.info
	invoke drd_imageLoadFile, offset winner, offset winn.info

	invoke drd_imageSetTransparent, offset tnn.info, 0a0a0a0h

	invoke Random, mini, maxi

	;Moves the value of random_num to the stating Y position of the ball.
	mov eax, random_num
	mov tnn.y, eax

again:	
	;Checks if the ball reched the left edge.
	cmp tnn.x,6 
	jle endGame

	;Checks if the ball reched the right edge.
	mov eax, windowWidth
	sub eax, tnn.widthBall
	cmp eax, tnn.x
	jne continue

	invoke EndGame1
	jmp over

	endGame:
	invoke EndGame  
	jmp over

continue:
	;Draws the images on the screen according to the given X and Y position.
	invoke drd_imageDraw, offset bg.info, bg.x, bg.y
	invoke drd_imageDraw, offset rec.info, rec.x, rec.y
	invoke drd_imageDraw, offset rec2.info, rec2.x, rec2.y
	invoke drd_imageDraw, offset tnn.info, tnn.x, tnn.y

	invoke Collision
	invoke init
	invoke MovementManager1
	invoke MovementManager2
	invoke BallManager

over:
	invoke drd_processMessages	
	invoke drd_flip
jmp again

	ret
main ENDP
end main