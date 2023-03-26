# Final Project 
# CMPEN 351 
# Andrew Darby 
# "Hangman" Word Game

.data

# CircleTable contains info in pairs of values for drawing a circle 
# The first value of each pair is an offset from the original X coordinate, this will determine where the current line will start 
# second value of each pair is the line length
# the table has values to print out a circle consisting of 50 lines, at a maximum length of 50 at the widest part of the circle
CircleTable: 
 .word 0, 10, -4, 18, -6, 22, -8, 26, -9, 28, -11, 32, -12, 34, -13, 36, -14, 38, -15, 40, -15, 40, -16, 42, -17, 44
 .word -17, 44, -18, 46, -18, 46, -19, 48, -19, 48, -19, 48, -19, 48, -20, 50, -20, 50, -20, 50, -20, 50, -20, 50
 .word -20, 50, -20, 50, -20, 50, -20, 50, -20, 50, -19, 48, -19, 48, -19, 48, -19, 48, -18, 46, -18, 46, -17, 44
 .word -17, 44, -16, 42, -15, 40, -15, 40, -14, 38, -13, 36, -12, 34, -11, 32, -9, 28, -8, 26, -6, 22 -4, 18, 0, 10 

ColorTable:					# color table for hex values for each color
 .word 0xFFFF00				        # 0 Yellow 
 .word 0x0000FF 			        # 1 Blue   
 .word 0xFF0000 				# 2 Red   
 .word 0x00FF00 				# 3 Green  
 .word 0xFFFFFF 				# 4 White
 .word 0x000000 				# 5 Black

# X, Y, color num 
ColorsMore:					#X, Y, Color Number, Pitch
 .word 115, 40, 0, 25				#[0] Yellow 1
 .word 180, 100, 1, 50				#[1] Blue 2
 .word 115, 160, 2, 75				#[2] Red 3
 .word 40, 100, 3, 100				#[3] Green 4

# stores whole words to be guessed         
WordTable:  .word word1, word2, word3, word4


char: .byte 0:2

bufferForGuess: .space 20		# user's guessed word

word1: .ascii "mars" 			# 1st word in bank
word2: .ascii "game" 			# 2nd word in bank
word3: .ascii "list"			# 3rd word in bank
word4: .ascii "loop"			# 4th word in bank
gWord: .asciiz "w" 			# user to guess word
gLetter: .asciiz "l" 			# user to guess letter
backUp: .asciiz "b"			# user wants to back up to beginning of choices
quit: .asciiz "q" 			# user wants to quit game
yes: .asciiz "y"			# y for yes
no: .asciiz "n" 			# n for no
underScore: .asciiz "_"		# _ for blank in word
newLine: .asciiz "\n"			# new line 

instruction1: .asciiz "\nWelcome to hangman! Your objective is to guess a four letter word.\n"
instruction2: .asciiz "You can choose to guess a single letter or the entire word.\n" 
instruction3: .asciiz "We will keep track of your guessed letters for you.\n" 
instruction4: .asciiz "Interface with the game will be completed through the console.\n"
instruction5: .asciiz "Please open the Bitmap Display, set to pixel height 1 and 1, width and height to 256, and base address to heap.\n"

guessType: .asciiz 	"\nDo you wish to guess the word or a single letter? Enter w/l..\n"		
wordGuess: .asciiz 	"\n Please enter your guess for the word, 0 to guess letter instead:\n" 
letterGuess: .asciiz   "\n Please enter your letter guess or press 0 to guess word instead: \n"
wrong: .asciiz 		"\nYour guess was incorrect, try again.\n" 
newGame: .asciiz 	"Would you like to play another game? Enter y/n:\n"
badInput: .asciiz 	"User input failed, please enter y for new game, n to quit.\n"
winner: .asciiz "You have correctly guessed the word!!!!! Congratulations!\n"
loser: .asciiz "You failed to guess the word int the allotted guesses! GAME OVER!!!\n"
display: .asciiz "\nYour guess is correct and the letter is at the position shown :"
missed: .asciiz "\n Your guess was incorrect!!!"
# stores the four letters in the word to guess 
Word: .asciiz "_ _ _ _"
	
.text

Initialize: 
	li $s0, 0 			# counter for game number of games played
	li $s4, 0			# counter for moving thru the WordTable

Main: 
	jal Instructions		# jump to procedure to display user intsructions
	
	StartOver: 
	
	ResetDone:
		jal DrawLetterLines		# draw lines on board 
		addiu $s0, $s0, 1		# increment counter for game number
		addiu $s1, $s1, 0		# initialize counter for guesses to 0	
		jal UserChoice 			# jump to UserChoice get input from user for guessing word or letter

# Procedure: Instructions:
# no input
# outputs user intro and instructions
#prints series of user instructions. 
Instructions: 	
	li $v0, 4			# print string syscall
	la $a0, instruction1		# choose string
	syscall				# print string 
	la $a0, instruction2		# choose string
	syscall				# print string 
	la $a0, instruction3		# choose string
	syscall				# print string 
	la $a0, instruction4		# choose string 
	syscall				# print string
	la $a0, instruction5		# choose string
	syscall				# print string
	jr $ra 				# return to calling procedure
	
# Procedure: UserChoice
# output selection is the user's choice to guess a word or letter
# procedure prompts user to enter a choice for guessing a word "w" or guessing a letter "l", "b" to restart or "q" to quit

UserChoice:
	la $t8, Word
	li $v0, 4			# print string syscall
	la $a0, guessType		# string to choose letter or word guess
	syscall				# print string
	li $v0, 12 			# read in character syscall
	syscall				# read the character
	lb $t0, gWord			# load gWord into $t0 == w
	lb $t1, gLetter			# load gLetter into $t1 == l
	lb $t2, backUp			# load backUp into $t2 == b
	lb $t3, quit			# load quit into $t3 == q	
	beq $v0, $t0, GuessWord		# if entered letter == w jump to GuessWord procedure     --- text version working
	beq $v0, $t1, GuessLetter	# if entered letter == l jump to GuessLetter procedure	
	beq $v0, $t2, UserChoice	# if user enters b, return to prompt again 		--- works properly
	beq $v0, $t3, Exit		# if user enters q, jump to program end/exit		-- works properly
	
	
#Procedure GuessWord
# input $a0 is the word that must be guessed
# will jump to win if word is guessed correctly, if incorrect, increment guess counter, if <= 0, jump to UserChoice proc

GuessWord: 
	la $s3, WordTable 		# load address of WordTable array into $s3 
	add $s3, $s3, $s4		# increment to proper place in WordTable array
	lw $t0, 0($s3)			# load the goal word into $t0
	li $v0, 4 			# print string syscall ask user for guess 
	la $a0, wordGuess		# address of string to print asking for guess
	syscall				# print string 
	li $v0, 8 			# read string syscall
	la $a0, bufferForGuess		# load address of place to store guessed word
	li $a1, 20			# max number of characters to read
	syscall				# read user input (the user has guessed a word at this spot)
	la $t1,($a0)			# load address of string read in into $t1
	# do the comparison here, loaded word is in $t0, guess should be in bufferForGuess, compare the two 
	Compare: 
		li $s2, 0		# set loop counter to zero
		li $t6, 0		# reset $t6 to zero for comparisons
		   loop:
        		lb $t3, 0($t1)		# load character from guess into $t3    
        		sb $t3, char
       			lb $t4, 0($t0)		# load character from goal word into $t4
        		sub $t6, $t3, $t4	# subtract value of each character to test for equality, if equal keep looping otherwise exit loop
        		addiu $s2, $s2, 1	# increment counter by 1
        		beqz $t6, continue	# $t6 == 0 then keep looping
        		j endCompare		# jump out of loop if not equal
        		
        	continue: 
        		beq $s2, 4, Win 	# if counter == 4 then comparison is done and word is correct
        		addi $t1, $t1, 1	# move to next char in guessed word
        		addi $t0, $t0, 1	# move to next char in goal word
       			 j loop			# jump back to win if counter < 4
		endCompare:	
			j WrongGuess		# if guess wrong and guesses < 10, jump to WrongGUess procedure
# procedure GuessLetter
# input $a0 is the goal word

GuessLetter: 
	la $s3, WordTable 		# load address of WordTable array into $s3 
	li $t9, 0			# load in 0 to $t9
	add $s3, $s3, $s4		# increment to proper place in WordTable array
	lw $t0, 0($s3)			# load the goal word into $t0
	li $v0, 4 			# print string syscall ask user for guess 
	la $a0, letterGuess		# address of string to print asking for guess
	syscall				# print string 
	li $v0, 8 			# read char syscall
	la $a0, bufferForGuess		# load address of place to store guessed word
	li $a1, 2			# max number of characters to read
	syscall				# read user input (the user has guessed a letter at this spot)
	la $t1,($a0)			# load address of char read in into $t1
	li $v0, 4			# print string syscall
	la $a0, newLine			# load in newLine
	syscall				# skip to next line
	# do the comparison here, loaded word is in $t0, guess should be in bufferForGuess, compare the two 
	CompareLetter: 
		li $s2, 0		# set loop counter to zero
		li $t6, 0		# reset $t6 to zero for comparisons
		li $s5, 0		# boolean for match found 
		   charLoop:
        		lb $t3, 0($t1)		# load character from guess into $t3   	 
       			lb $t4, 0($t0)		# load character from goal word into $t4
        		sub $t6, $t3, $t4	# subtract value of each character to test for equality, if equal keep looping otherwise exit loop
        		addiu $s2, $s2, 1	# increment counter by 1
        		beqz $t6, DisplayCorrect  # $t6 == 0 a match was found
        		j DisplayMiss
        				
       		guessCheck: 
       			beq $s5, 0, WrongGuess	# if no letters matched, $s5 will equal zero, go to wrong guess add end of word
       			j UserChoice		# if letter was found to be a match go back to user choice
       				
	DisplayCorrect: 
		li $v0, 4			# print char syscall
		la $a0, display			# load value from current char into $a0, this will be the spot the correct guess is located
		syscall				# print the char
		addiu $s5, $s5, 1		# increment $s5 to show a good guess was found
		sb $t3, ($t8)			# store the guessed char at curr position in $t8
		addi $t0, $t0, 1		# move to next char in goal word
		addi, $t8, $t8, 2		# increment position of pointer to word stored in $t8
		beq $s2, 4, DisplayCurrWord	# if counter is at 4(ie word done) move back to procedure UserChoice
		j charLoop			# counter not finished, loop again
		
	DisplayMiss: 
		addi $t0, $t0, 1	# move to next char in goal word 
		addi $t8, $t8, 2	# increment the position of the word to display
		beq $s2, 4, DisplayCurrWord	# if counter == 4 jump to DisplayCurrWord
		j charLoop 		# counter != 4 loop again
		
	DisplayCurrWord: 
		li, $v0, 4		# print string syscall
		la $a0, Word		# load in address for Word to print
		syscall			# print Word
		la $a0, newLine		# load in address for newLine
		syscall			# print newLine
		beqz $s5, WrongGuess	# if no match jump to WrongGuess
		j UserChoice		# otherwise jump to UserChoice
		


# Procedure: DrawPart1
# procedure called to display 1st part of hangman on Bitmap when a guess is wrong

DrawPart1: 
	li $a0, 160			# load in coord for X 
	li $a1, 180			# load in coord for Y
	li $a2, 4			# color for line is red
	li $a3, 60			# line length = 60
	li $t0, 0			# counter for line thickness 
	lineLoop1: 
		addiu $sp, $sp, -20	# make room on stack
		#store all relevant values to stack
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		sw $a3, 12($sp)
		sw $t0, 16($sp)
		
		jal DrawH		# call DrawH to draw horizontal line
		# restore values from stack
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		lw $a3, 12($sp)
		lw $t0, 16($sp)
		
		addiu $sp, $sp, 20	# restore the stack
		addi $t0, $t0, 1	# increment counter
		bne  $t0, 2, lineLoop1	# if counter != 5, draw another line
		j UserChoice		# jump back to user choice	
		
	

# Procedure: DrawPart2
# procedure called to display 2nd part of hangman on Bitmap when a guess is wrong

DrawPart2: 
	li $a0, 190			# load in coord for X 
	li $a1, 20			# load in coord for Y
	li $a2, 4			# color for line is red
	li $a3, 2			# line length = 2
	li $t0, 0			# counter for line thickness 
	lineLoop2: 
		addiu $sp, $sp, -20	# make room on stack
		#store values on stack
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		sw $a3, 12($sp)
		sw $t0, 16($sp)
		
		jal DrawH		# call DrawH to draw horizontal line
		# retrieve values from stack
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		lw $a3, 12($sp)
		lw $t0, 16($sp)
		
		addiu $sp, $sp, 20	# restore the stack
		addi $t0, $t0, 1	# increment counter
		addi $a1, $a1, 1	# increment Y position
		bne  $t0, 160, lineLoop2	# if counter != , draw another line
		j UserChoice


# Procedure: DrawPart3
# procedure called to display 3rd part of hangman on Bitmap when a guess is wrong

DrawPart3:
	li $a0, 120			# load in coord for X 
	li $a1, 20			# load in coord for Y
	li $a2, 4			# color for line is white
	li $a3, 80			# line length = 80
	li $t0, 0			# counter for line thickness 
	lineLoop3: 
		addiu $sp, $sp, -20	# make room on stack
		# store values to stack 
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		sw $a3, 12($sp)
		sw $t0, 16($sp)
		jal DrawH		# call DrawH to draw horizontal line
		
		#restore values from stack
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		lw $a3, 12($sp)
		lw $t0, 16($sp)
		addiu $sp, $sp, 20	# restore the stack
		addi $t0, $t0, 1	# increment counter
		bne  $t0, 2, lineLoop3	# if counter != 5, draw another line
		j UserChoice
	

	
# Procedure: DrawPart4
# procedure called to display 4th part of hangman on Bitmap when a guess is wrong

DrawPart4: 
	li $a0, 130			# load in coord for X 
	li $a1, 20			# load in coord for Y
	li $a2, 4			# color for line is red
	li $a3, 2			# line length = 2
	li $t0, 0			# counter for line thickness 
	lineLoop4: 
		addiu $sp, $sp, -20	#make room on stack 
		# store values to stack
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		sw $a3, 12($sp)
		sw $t0, 16($sp)
		jal DrawH		# call DrawH to draw horizontal line
		# restore values from stack
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		lw $a3, 12($sp)
		lw $t0, 16($sp)
		addiu $sp, $sp, 20	# restore the stack pointer
		addi $t0, $t0, 1	# increment counter
		addi $a1, $a1, 1	# increment Y position
		bne  $t0, 30, lineLoop4	# if counter != , draw another line
		j UserChoice
	
# Procedure: DrawPart5
# procedure called to display 5th part of hangman on Bitmap when a guess is wrong(draws circle for head)

DrawPart5: 	
	
	addiu $sp, $sp, -28 	# make room for 7 words
	li $a0, 125		# load in X coord
	li $a1, 50		# load in Y coord
	li $a2, 4		# load in color #
	
	# save $ra, $s0, $a0, and $a2 to the stack
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $a0, 12($sp)
	sw $a2, 8($sp)
	li $t0, 0		# initialize counter
	
CircleLoop:
	la $t1, CircleTable	# load address of CircleTable into $t1
	addi $t2, $t0, 0	# counter for table CircleTable
	mul $t2, $t2, 8		# counter value shifted to account for 2 data values per occurrence in table
	add $t2, $t1, $t2	# get the offset for X for array index 
	lw $t3, ($t2)		# load the offset into $t3
	add $a0, $a0, $t3	# add the X offset to current offset
	
	addi $t2, $t2, 4	# iterate in array to the value for the horizontal line
	lw $a3, ($t2)		# load the line length into $a3
	sw $a1, 4($sp)		# save $a1 to the stack
	sw $a3, 0($sp)		# save $a3 to the stack
	sw $t0, 24($sp)		# save counter to the stack
	jal DrawH		# jump and link to DrawH procedure to draw a horizontal line
	
	# restore values of $a0 to $a3 that are stored on stack
	lw $a3, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $a0, 12($sp)
	lw $t0, 24($sp)
	
	addi $a1, $a1, 1	# increment Y coord
	addi $t0, $t0, 1	# increment X coord
	bne $t0, 50, CircleLoop	# loop until circle is complete
	
	# restore $ra, $s0, $sp
	lw $ra, 20($sp)
	lw $s0, 16($sp)
	addiu $sp, $sp, 28	# reset the stack 
	j UserChoice
		
# Procedure: DrawPart6
# procedure called to display 6th part of hangman on Bitmap when a guess is wrong

DrawPart6: 				
	li $a0, 130			# load in coord for X 
	li $a1, 100			# load in coord for Y
	li $a2, 4			# color for line is white
	li $a3, 2			# line length = 2
	li $t0, 0			# counter for line thickness 
	lineLoop6: 
		addiu $sp, $sp, -20	# make room on stack
		#store values to stack
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		sw $a3, 12($sp)
		sw $t0, 16($sp)
		jal DrawH		# call DrawH to draw horizontal line
		#load values from stack
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		lw $a3, 12($sp)
		lw $t0, 16($sp)
		addiu $sp, $sp, 20	# restore the stack
		addi $t0, $t0, 1	# increment counter
		addi $a1, $a1, 1	# increment Y position
		bne  $t0, 50, lineLoop6	# if counter != , draw another line
		j UserChoice
														
# Procedure: DrawPart7
# procedure called to display 7th part of hangman on Bitmap when a guess is wrong

DrawPart7: 
	li $a0, 105  			# load in coord for X 
	li $a1, 120			# load in coord for Y
	li $a2, 4			# color for line is red
	li $a3, 25			# line length = 25
	li $t0, 0			# counter for line thickness 
	lineLoop7: 
		addiu $sp, $sp, -20	#make space on stack
		# store values to stack
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		sw $a3, 12($sp)
		sw $t0, 16($sp)
		jal DrawH		# call DrawH to draw horizontal line
		#restore values from stack
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		lw $a3, 12($sp)
		lw $t0, 16($sp)
		addiu $sp, $sp, 20	# restore the stack
		addi $t0, $t0, 1	# increment counter
		bne  $t0, 2, lineLoop7	# if counter != 5, draw another line
		j UserChoice
																														
# Procedure: DrawPart8
# procedure called to display 8th part of hangman on Bitmap when a guess is wrong

DrawPart8: 
	li $a0, 130  			# load in coord for X 
	li $a1, 120			# load in coord for Y
	li $a2, 4			# color for line is red
	li $a3, 25			# line length = 25
	li $t0, 0			# counter for line thickness 
	lineLoop8: 
		addiu $sp, $sp, -20	# make space on stack
		# store values on stack to save 
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		sw $a3, 12($sp)
		sw $t0, 16($sp)
		jal DrawH		# call DrawH to draw horizontal line
		# reload values from stack
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		lw $a3, 12($sp)
		lw $t0, 16($sp)
		addiu $sp, $sp, 20	# restore the stack
		addi $t0, $t0, 1	# increment counter
		bne  $t0, 2, lineLoop8	# if counter != 5, draw another line
		j UserChoice

# Procedure: DrawPart9
# procedure called to display 9th part of hangman on Bitmap when a guess is wrong

DrawPart9: 
	li $t0, 0			# initialize counter 
	loop9:
		li $a0, 130 	        # X value = 130
		add $a0, $a0, $t0	# increment X value by counter
		li $a1, 150		# Y value = 150
		add $a1, $a1, $t0	# increment Y value by counter
		li $a2, 4		# color will be white
		li $a3, 3		# full width of screen
		sw $t0, 0($sp)		# save $t0 to the stack
		jal DrawH		# jump and link to DrawH procedure		
		lw $t0, 0($sp)		# load value at stack(0) to $t0
		addi $t0, $t0, 1	# increment counter
		bne $t0, 20, loop9	# if not equal to 20(length) continue looping
		j UserChoice
	
# Procedure: DrawPart10
# procedure called to display 10th part of hangman on Bitmap when a guess is wrong

DrawPart10: 
	li $t0, 0		#initialize counter
	loop10:
		li $a0, 110 		# X = 110
		add $a0, $a0, $t0	# increment X by counter value in $t0
		li $a1, 170		# Y = 170
		sub $a1, $a1, $t0 	# decrement Y value by counter value in $t0
		li $a2, 4		# color is white
		li $a3, 3		# full width of screen
		sw $t0, 0($sp)		# store coord value in $t0 at stack (0)
		jal DrawH		# jump and link to procedure DrawH
		lw $t0, 0($sp)		# load value at stack(0) into $t0
		addi $t0, $t0, 1	# increment counter
		bne $t0, 20, loop10	# if not equal to 20, continue looping
		bgtz $s0, Lose		# jump to lose since this is the last guess
		
																																																																																																
#Procedure: Draw LetterLines
# input is null, always drawn the same
# output is 4 lines on Bitmap that will serve as place where guesses/word will be displayed
DrawLetterLines:
	li $a0, 75			# load in coord for X 
	li $a1, 220			# load in coord for Y
	li $a2, 4			# color for line is red
	li $a3, 20			# line length = 20
	li $s2, 0			# counter for line thickness 
	li $t0, 0			# counter for number of letter lines
	j lineLoop			
	
OuterLoop: 
	addi, $t0, $t0, 1		# increment outer loop counter 
	li $s2, 0			# reset counter for line thickness to 0
	
	
	lineLoop: 
		addiu $sp, $sp, -24	# make space on stack
		# store values to stack
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		sw $a3, 12($sp)
		sw $s2, 16($sp)
		sw $t0, 20($sp)
		sw $ra, 24($sp)
		jal DrawH		# call DrawH to draw horizontal line
		# restore values from stack
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		lw $a3, 12($sp)
		lw $s2, 16($sp)
		lw $t0, 20($sp)
		lw $ra, 24($sp)
		addi $s2, $s2, 1	# increment counter
		bne  $s2, 2, lineLoop	# if counter != 5, draw another line
		addi $a0, $a0, 25	# increment X coord to next line to be drawn
		bne  $t0, 4, OuterLoop  # if counter != 4, loop to outer loop
		addiu $sp, $sp, 24	# restore stack position 
		jr $ra			# return to calling procedure

#Procedure: DrawDot
# input $a0 is X coord
# input $a1 is Y coord
# input $a2 is number for color
# procedure draws a dot on the Bitmap 
DrawDot:
	addiu $sp, $sp, -8	# make space for 2 words on the stack
	
	# save $ra and a2 to the stack
	sw $ra, 4($sp)
	sw $a2, 0($sp)
	jal CalcAddress		# jump and link to CalcAddress procedure
	lw $a2, 0($sp)		# load value of $a2 from stack
	sw $v0, 0($sp)		# save value of $v0 to stack
	jal GetColor		# get the hex value for color
	lw $v0, 0($sp)		# restore value of $v0
	#sw $t1, lineColor	
	sw $v1, 0($v0)		# write the color value to the address
	lw $ra, 4($sp)		# restore $ra from stack
	addiu $sp, $sp, 8	# reset stack
	jr $ra			# return to callling procedure

# Procedure: CalcAddress
# input $a0 is X coord
# input $a1 is Y coord
# output $v0 is address where to draw a dot
CalcAddress:
	sll $a0, $a0, 2			# shift left value for X 
	sll $a1, $a1, 10		# shift left value for Y 
	add $v0, $a0, $a1		# add value for X and Y together and store in $v0
	addi $v0, $v0, 0x10040000	# add the  base (heap value)
	jr $ra				# return to calling procedure
	

#Procedure: DrawH
# input $a0 is X coord
# input $a1 is Y coord
# input $a2 is number for color
# input $a3 is length of the line to draw
# procedure uses drawdot to draw a horizontal line
DrawH:
	addiu $sp, $sp, -20	# make space for 5 words on stack
	
	# save $ra, $a1, $a2 to the stack
	sw $ra, 16($sp)
	sw $a1, 12($sp)
	sw $a2, 8($sp)
	
HorzLoop:
	# save $a0, $a3 to the stack 
	sw $a0, 4($sp)
	sw $a3, 0($sp)
	jal DrawDot		# jump and link to DrawDot procedure
	
	# restore all values from stack except $ra
	lw $a0, 4($sp)
	lw $a1, 12($sp)
	lw $a2, 8($sp)
	lw $a3, 0($sp)	
	addi $a3, $a3, -1	# decrement the width
	addi $a0, $a0, 1	# increase X value
	bnez $a3, HorzLoop	# if width > 0, keep looping	
	lw $ra, 16($sp)		# restore $ra from stack
	addiu $sp, $sp, 20	# restore the stack
	jr $ra			# return to calling procedure
	
# Procedure: GetColor
# input $a2 is the color to get 
# output $v1 is the HEX value for the color 
# procedure returns the hex value of requested color
GetColor:
	la $t0, ColorTable	# load color table
	sll $a2, $a2, 2		# shift left by 2 (4 bytes)
	add $a2, $a2, $t0	# add the base to the value
	lw $v1, ($a2)		# load value for color into $v1
	jr $ra			# return to calling procedure
	
# procedure WrongGuess
# output is a string informing the player their guess, either for a word or letter is incorrect
# this is working and counting wrong guesses correctly

WrongGuess: 
	li $v0, 4		# print string syscall
	la $a0, wrong		# load address for wrong guess string
	syscall			# print the string 
	addiu $s1, $s1, 1	# increment number of guesses used
	beq $s1, 1, DrawPart1 	# if guess == 1 draw 1st part
	beq $s1, 2, DrawPart2	# if guess == 2 draw 2nd part
	beq $s1, 3, DrawPart3	# if guess == 3 draw 3rd part
	beq $s1, 4, DrawPart4	# if guess == 4 draw 4th part
	beq $s1, 5, DrawPart5   # if guess == 5 draw 5th part
	beq $s1, 6, DrawPart6	# if guess == 6 draw 6th part
	beq $s1, 7, DrawPart7	# if guess == 7 draw 7th part
	beq $s1, 8, DrawPart8	# if guess == 8 draw 8th part
	beq $s1, 9, DrawPart9	# if guess == 9 draw 9th part
	beq $s1, 10,DrawPart10	# guess was wrong, and it was the 10th guess
	j UserChoice		# jump back for user to choose letter or word guess
	
# procedure Win
# prints out message informing user they won and prompts for new game y/n

Win: 
	li $v0, 4		# print string syscall 
	la $a0, winner		# load address for string that announces win
	syscall 		# print string
	PlayAgainW: 
		addiu $s4, $s4, 4	# increment position in WordTable to next word in array 
		la $a0, newGame		# load address of string to ask for new game or not
		syscall 		# print string 
		li $v0, 12		# load char syscall
		syscall 		# load the inputted char
		lb $t0, yes		# load value in yes to $t0
		beq $t0, $v0, StartOver   # if input is y jump to newGame procedure
		lb $t0, no		# load value in no into $t0
		beq $t0, $v0,  Exit	# if enters 'n' exit game
		li $v0, 4		# print string syscall
		la $a0, badInput	# string informing user of improper input
		syscall			# print string
		j PlayAgainW		# if the user does not enter proper input prompt again
	
# procedure Lose
#  prints out message informing user they have lost and prompts for new game y/n

Lose: 
	li $v0, 4		# print string syscall 
	la $a0, loser		# load address for string that announces loss
	syscall 		# print string
	PlayAgainL: 
		addiu $s4, $s4, 4	# increment position in WordTable to next word in array 
		la $a0, newGame		# load address of string to ask for new game or not
		syscall 		# print string 
		li $v0, 12		# load char syscall
		syscall 		# load the inputted char
		lb $t0, yes		# load value in yes to $t0
		beq $t0, $v0, StartOver   # if input is y jump to newGame procedure
		lb $t0, no		# load value in no into $t0
		beq $t0, $v0,  Exit	# if enters 'n' exit game
		li $v0, 4		# print string syscall
		la $a0, badInput	# string informing user of improper input
		syscall			# print string
		j PlayAgainL		# if the user does not enter proper input prompt again
		
		

#Procedure: DrawBox
# input $a0 is X coord
# input $a1 is Y coord
# input $a2 is number for color
# input $a3 is box width
# procedure draws box according to input values
DrawBox:
	li $a2, 5
	addiu $sp, $sp, -24 	#  make space for six words on the stack
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $a0, 12($sp)
	sw $a2, 8($sp)
	move $s0, $a3		# move value $a3(width) into $s0 for later use
	
BoxLoop:
	sw $a1, 4($sp)		# store $a1 to stack
	sw $a3, 0($sp)		# store $a3 to stack
	jal DrawH		# jump and link  to DrawH to draw horizontal divider
	
	# restore values from stack for $a0 thru $a3
	lw $a3, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $a0, 12($sp)
	addi $a1, $a1, 1	# increment Y value
	addi $s0, $s0, -1	# decrement the width 
	bne $zero, $s0, BoxLoop	# loop until counnter = 0
	
	# restore $ra, $s0, $sp
	lw $ra, 20($sp)
	lw $s0, 16($sp)
	addiu $sp, $sp, 24	# reset the stack
	jr $ra			# return to calling procedure
	
# Procedure: Exit 
# procedure exits program when called

Exit: 
	li $v0, 10		# exit program syscall 
	syscall 		# exit the program



  
