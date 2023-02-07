*-----------------------------------------------------------
* Title      :
* Written by :Khaoula HARCHANE
* Date       :15/09/2021
* Description:
*-----------------------------------------------------------
    ORG    $1000
    *------------------------------------------------------------------------------
    ******************************************************************************|
    *****************************x means x-axis***********************************|
    *****************************y means y-axis***********************************|
    ******************************************************************************|
    *------------------------------------------------------------------------------  
  
START:                  ; first instruction of program
        move.l #100,A5 ;the x position our protons will be located in
        move.l #80,A4  ;the y position our protons will be located in
        move.b #1,d5   ;d5 contains 0 or 1 :1 player1;0 player2
        move.b #20,d7  ;the d7 contains the num of protons that will be painted
init:
        ;Set pen color
        move.l  #red,d1       
        move.b  #80,d0
        trap    #15     

        ;Set fill color
        move.l  #black,d1
        move.b  #81,d0  
        trap    #15     
        
        ;Set pen width
        move.b  #3,d1   
        move.b  #93,d0
        trap    #15     
        
        ;Set drawing mode
        move.b  #17,d1 
        move.b  #92,d0
        trap    #15     
        
        ;draw a border 
        move.w  #0,d1    
        move.w  #0,d2             
        move.w  #640,d3            
        move.w  #480,d4      
      
        move.b  #87,d0    
        trap    #15 

while:*the program will end when this loop ends
        cmp.b #0,TOTAL_PROTONS
        beq fin ;if total(protons)==0 then we must stop
        blt fin ;if total(protons)<0 then we must stop
        
forLines:*loop to draw the protons   
        cmp.b #10,d7
        beq  newLine ;if d7==10 then we must draw a new line (chaque ligne contient 10 allumettes)
        bra nextColumn ;otherwise we draw a new proton

newLine:
        add.w #70,a4 we add to y(a4) 70. So the next position will be {content(a4)+70} (the 70 can be changed )
        move.w #110,a5  we set x(a5) to the position 110
        sub.b #1,d7     we decrement 1 from the number of protons painted
        JSR draw
        
nextColumn:
         add.w #10,a5   we add to x(a5) 10. So the next position will be {content(a5)+10} (the 10 can be changed )
         sub.b #1,d7    we decrement 1 from the number of protons painted
         JSR draw
         
draw:   ;to draw a line we need 2 points
        ;point 1
        move.w    a5,d1    x       
        move.w    a4,d2    y
        
        add.w     #50,a4   we add 50 to a4 for the painting of Second point (x must stay the same but y must differ so we can draw a line)
        ;point 2
        move.w    a5,d3 x
        move.w    a4,d4 y
        
        sub.w     #50,a4  we sub the 50 from a4 so the next point(beginning of protons will be alligned with other protons)
        ;draw
        move.b    #84,d0        
        trap      #15    
        
        add.w     #30,a5 we will draw the next protons in the position {content(a5)+30}
        
        cmp       #0,d7
        beq text        we have nothing left to draw then we jump to text 
        bra forLines    reloop if the d7 is greater than 0

text:   
        *Code to repaint (re-draw the element to console)
        move.b  #94,d0
        trap    #15
        
        LEA INTROD,A1 ;Load the INTRO into adress register A1
        *to position  Introd in a specific position
        move.w  #200,d1 x
        move.w  #10,d2  y
        move.b  #95,d0              
        trap    #15
        
        LEA INTROD2,A1 ;Load the INTRO into adress register A1
        *to position  Introd2 in a specific position
        move.w  #150,d1 x
        move.w  #30,d2  y
        move.b  #95,d0              
        trap    #15
        
        LEA MESSAGE,A1 ;Load the message into adress register A1
        move.w  #10,d1
        move.w  #240,d2
        move.b  #95,d0              
        trap    #15
                
saisie:
      *check which player
      cmp #1,d5 ;this test used to know which player can play
      beq Player_1Sec  if d5==1 player1              
      bra Player_2Sec  otherwise player2
      
wp:   
      *set the cursor to the position mentioned in d1
      move.L    #9746,D1
	  MOVE.B	#11,D0
	  TRAP	#15
	  *--------to read user input
      move.b #4,d0 ;4 is used with 15 TRAP to read a number from the keyboard into D1
      TRAP    #15    
      
      cmp.b #0,d1 ;compare 0 to the entered value
      beq wp  ;if it's 0 reloop
      
      cmp.b #4,d1 ;compare the entered value to 4
      blt done    ;if the value <4 :complete the work
      bra wp  ;otherwise reloop
      
done:
    MOVE.B	TOTAL_PROTONS,D3 
    SUB.b d1,D3 ;the entered value is stored in d1 so d3=d3-d1
    MOVE.B	D3,TOTAL_PROTONS
    move.b d3,d7 ;d7 the num of protons to draw
    
    move.l #100,A5 ;the x position our protons will be located in
    move.l #80,A4  ;the y position our protons will be located in
    
    JSR      init
    
Player_1Sec:
      LEA PLAYER_1,A1 ;Load the message to into adress register A1
      move.w  #225,d1
      move.w  #270,d2
      move.b  #95,d0              place win message on screen
      trap    #15
      *SET THE REGISTER D5 TO FALSE SO THE PLAYER 2 CAN PLAY
      move.b #0,d5
      *Code to repaint
      move.b  #94,d0
      trap    #15 
      
      jsr wp
      
Player_2Sec:
      LEA PLAYER_2,A1 ;Load the message to into adress register A1
      move.w  #225,d1
      move.w  #270,d2
      move.b  #95,d0             
      trap    #15
      
      *SET THE REGISTER D5 TO TRUE SO THE PLAYER 1 CAN PLAY
      move.b #1,d5
      
      *Code to repaint
      move.b  #94,d0
      trap    #15 
      
      jsr wp
fin:    
      cmp #1,d5 ;this test used to know which player won
      beq PLAYER2_WINS              
      bra PLAYER1_WINS


PLAYER1_WINS:
      LEA P1_WINS,A1 ;Load the P1_WINS into adress register A1
      move.w  #10,d1
      move.w  #20,d2
      move.b  #95,d0             
      trap    #15
      *Code to repaint
      move.b  #94,d0
      trap    #15 
      
      JSR end
PLAYER2_WINS:    
      LEA P2_WINS,A1 ;Load the P1_WINS into adress register A1
      move.w  #10,d1
      move.w  #20,d2
      move.b  #95,d0             
      trap    #15
      *Code to repaint
      move.b  #94,d0
      trap    #15 
      
      JSR end             ; halt simulator
end:
    SIMHALT  
     
* Put variables and constants here
CR  EQU  $0A ;ASCII code for carriage return
LF  EQU  $0D ;ASCII code for line feed
HT  EQU  $09 ;ASCII code for TAB
red   equ     $000000FF
black     equ     $00000000 ;216*$10000+233*$100+236 
INTROD   DC.B HT,HT,HT,HT,HT,HT,'The Nim Number Game',CR,LF,0
INTROD2  DC.B HT,HT,HT,HT,'   Whoever takes the last proton wins!',CR,LF,CR,LF,CR,LF,0
MESSAGE  DC.B 'How many protons would you like to take (choose a number between 1-3):',CR,LF,0
PLAYER_1 DC.B 'player 1: ',0
PLAYER_2 DC.B 'player 2: ',0
P1_WINS  DC.B CR,LF,'Congratulations!Player 1 you did a good job',CR,LF,0
P2_WINS  DC.B CR,LF,'Congratulations!Player 2 you did a good job',0
TOTAL_PROTONS DC.b 20  
RL DC.B CR,LF,0
    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
