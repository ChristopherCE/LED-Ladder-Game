.equ INPUT,  0			// to set pins as input
.equ OUTPUT, 1			// to set pins as output

.equ LOW,  0			// low  state for LEDs
.equ HIGH, 1			// high state for LEDs

.equ RED_ONE, 22		// there are 4 colors of LED:
.equ RED_TWO, 21		// RED, YELLOW, GREEN, BLUE
.equ YLW_ONE, 13		// there are 2 of each, 8 total
.equ YLW_TWO, 12
.equ GRN_ONE, 3			// I used wiringPi and its pin numbers
.equ GRN_TWO, 2
.equ BLU_ONE, 0
.equ BLU_TWO, 7

.equ BTN_PIN, 6			// the pin for the button

.equ PAUSE_ONE,   1000		// pause for 1.0  second
.equ PAUSE_HALF,  500		// pause for 0.5  seconds
.equ PAUSE_QTR,   250		// pause for 0.25 seconds
.equ PAUSE_TWEN,  200		// pause for 0.20 seconds
.equ PAUSE_FIFT,  150		// pause for 0.15 seconds
.equ PAUSE_TENTH, 100		// pause for 0.10 seconds

.global main
.text
main:
	push {lr}

	bl wiringPiSetup	// using wiringPiSetup for the pin numbers

	bl setup		// call setup function

	bl allOff		// turn off all the LEDs

	bl startLoop		// start the game

// this function moves each led pin into r0
// then calls the function that will set it
// as either an output for the LEDs
// or an input for the button
setup:
	push {lr}

	mov r0, #RED_ONE
	bl setPinOutput

	mov r0, #RED_TWO
	bl setPinOutput

	mov r0, #YLW_ONE
	bl setPinOutput

	mov r0, #YLW_TWO
	bl setPinOutput

	mov r0, #GRN_ONE
	bl setPinOutput

	mov r0, #GRN_TWO
	bl setPinOutput

	mov r0, #BLU_ONE
	bl setPinOutput

	mov r0, #BLU_TWO
	bl setPinOutput

	mov r0, #BTN_PIN
	bl setPinInput

	pop {pc}

// this function moves each LED pin into r0
// then calls a function to turn that individual LED on
allOn:
	push {lr}

	mov r0, #RED_ONE
	bl pinOn

	mov r0, #RED_TWO
	bl pinOn

	mov r0, #YLW_ONE
	bl pinOn

	mov r0, #YLW_TWO
	bl pinOn

	mov r0, #GRN_ONE
	bl pinOn

	mov r0, #GRN_TWO
	bl pinOn

	mov r0, #BLU_ONE
	bl pinOn

	mov r0, #BLU_TWO
	bl pinOn

	pop {pc}

// this function moves each LED pin into r0
// then calls a function to turn that individual LED off
allOff:
	push {lr}

	mov r0, #RED_ONE
	bl pinOff

	mov r0, #RED_TWO
	bl pinOff

	mov r0, #YLW_ONE
	bl pinOff

	mov r0, #YLW_TWO
	bl pinOff

	mov r0, #GRN_ONE
	bl pinOff

	mov r0, #GRN_TWO
	bl pinOff

	mov r0, #BLU_ONE
	bl pinOff

	mov r0, #BLU_TWO
	bl pinOff

	mov r0, #BTN_PIN
	bl pinOff

	pop {pc}

// this function sets a pin as an input
setPinInput:
	push {lr}
	mov r1, #INPUT
	bl pinMode
	pop {pc}

// this function sets a pin as an output
setPinOutput:
	push {lr}
	mov r1, #OUTPUT
	bl pinMode
	pop {pc}

// this function turns a pin on
pinOn:
	push {lr}
	mov r1, #HIGH
	bl digitalWrite
	pop {pc}

// this function turns a pin off
pinOff:
	push {lr}
	mov r1, #LOW
	bl digitalWrite
	pop {pc}

// this function will read the button pin
// for either on or off, 1 or 0
readButton:
	push {lr}
	mov r0, #BTN_PIN
	bl digitalRead
	pop {pc}

// this is the start of the game, or level1
// it will loop through and blink the first LED on and off
startLoop:
	mov r0, #RED_ONE		// turn LED on
	bl pinOn

	ldr r0, =#PAUSE_QTR		// pause quarter of a second
	bl delay

	bl readButton			// read to see if button is pressed
	cmp r0, #HIGH			// if button is pressed
	bleq level2			// go to level2

	ldr r0, =#PAUSE_QTR		// pause quarter of a second
	bl delay

	bl readButton			// read to see if button is pressed
	cmp r0, #HIGH			// if button is pressed
	bleq level2			// go to level2

	ldr r0, =#PAUSE_QTR		// pause quarter of a second
	bl delay

	bl readButton			// read to see if button is pressed
	cmp r0, #HIGH			// if button is pressed
	bleq level2			// go to level2

	ldr r0, =#PAUSE_QTR		// pause quarter of a second
	bl delay

	mov r0, #RED_ONE		// turn LED off
	bl pinOff

	ldr r0, =#PAUSE_ONE		// pause a second
	bl delay

	bl startLoop			// recursively call itself

// levels 2 through 7 are very similar
//they all turn on the next LED
// check if the button has been pressed in the time limit
// then it either moves to the next level, or it ends
level2:
	ldr r0, =#PAUSE_HALF		// pause 0.5 second, give player time to get ready
	bl delay

	bl readButton			// if just holding the button down
	cmp r0, #HIGH
	bleq timedOff			// end the program

	mov r0, #RED_ONE		// turn on the first red LED
	bl pinOn

	ldr r0, =#PAUSE_QTR		// pause 0.25 second, give player time to get ready
	bl delay

	mov r0, #RED_TWO		// turn on second LED
	bl pinOn

	ldr r0, =#PAUSE_QTR		// pause a quarter of a second
	bl delay

	bl readButton			// read the button
	cmp r0, #HIGH			// if it is pressed
	bleq level3			// move on to level 3

	ldr r0, =#PAUSE_QTR		// pause a quarter of a second
	bl delay

	bl readButton			// read the button
	cmp r0, #HIGH			// if it is pressed
	bleq level3			// move on to level 3

	ldr r0, =#PAUSE_QTR		// pause a quarter of asecond
	bl delay

	bl readButton			// read the button
	cmp r0, #HIGH			// if it is pressed
	bleq level3			// move on to level 3

	ldr r0, =#PAUSE_QTR		// pause a quarter of a second
	bl delay

	mov r0, #RED_TWO		// flash the missed LED on/off 3 times
	bl flashOff
	mov r0, #RED_TWO
	bl flashOn
	mov r0, #RED_TWO
	bl flashOff
	mov r0, #RED_TWO
	bl flashOn
	mov r0, #RED_TWO
	bl flashOff
	mov r0, #RED_TWO
	bl flashOn

	bl timedOff			// call the end function

level3:
	ldr r0, =#PAUSE_HALF
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq timedOff

	mov r0, #RED_TWO
	bl pinOn

	ldr r0, =#PAUSE_QTR
	bl delay

	mov r0, #YLW_ONE
	bl pinOn

	ldr r0, =#PAUSE_TWEN
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq level4

	ldr r0, =#PAUSE_TWEN
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq level4

	ldr r0, =#PAUSE_TWEN
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq level4

	ldr r0, =#PAUSE_TWEN
	bl delay

	mov r0, #YLW_ONE
	bl flashOff
	mov r0, #YLW_ONE
	bl flashOn
	mov r0, #YLW_ONE
	bl flashOff
	mov r0, #YLW_ONE
	bl flashOn
	mov r0, #YLW_ONE
	bl flashOff
	mov r0, #YLW_ONE
	bl flashOn

	bl timedOff

level4:
	ldr r0, =#PAUSE_HALF
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq timedOff

	mov r0, #YLW_ONE
	bl pinOn

	ldr r0, =#PAUSE_QTR
	bl delay

	mov r0, #YLW_TWO
	bl pinOn

	ldr r0, =#PAUSE_TWEN
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq level5

	ldr r0, =#PAUSE_TWEN
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq level5

	ldr r0, =#PAUSE_TWEN
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq level5

	ldr r0, =#PAUSE_TWEN
	bl delay

	mov r0, #YLW_TWO
	bl flashOff
	mov r0, #YLW_TWO
	bl flashOn
	mov r0, #YLW_TWO
	bl flashOff
	mov r0, #YLW_TWO
	bl flashOn
	mov r0, #YLW_TWO
	bl flashOff
	mov r0, #YLW_TWO
	bl flashOn

	bl timedOff

level5:
	ldr r0, =#PAUSE_HALF
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq timedOff

	mov r0, #YLW_TWO
	bl pinOn

	ldr r0, =#PAUSE_QTR
	bl delay

	mov r0, #GRN_ONE
	bl pinOn

	ldr r0, =#PAUSE_FIFT
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq level6

	ldr r0, =#PAUSE_FIFT
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq level6

	ldr r0, =#PAUSE_FIFT
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq level6

	ldr r0, =#PAUSE_FIFT
	bl delay

	mov r0, #GRN_ONE
	bl flashOff
	mov r0, #GRN_ONE
	bl flashOn
	mov r0, #GRN_ONE
	bl flashOff
	mov r0, #GRN_ONE
	bl flashOn
	mov r0, #GRN_ONE
	bl flashOff
	mov r0, #GRN_ONE
	bl flashOn

	bl timedOff

level6:
	ldr r0, =#PAUSE_HALF
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq timedOff

	mov r0, #GRN_ONE
	bl pinOn

	ldr r0, =#PAUSE_QTR
	bl delay

	mov r0, #GRN_TWO
	bl pinOn

	ldr r0, =#PAUSE_FIFT
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq level7

	ldr r0, =#PAUSE_FIFT
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq level7

	ldr r0, =#PAUSE_FIFT
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq level7

	ldr r0, =#PAUSE_FIFT
	bl delay

	mov r0, #GRN_TWO
	bl flashOff
	mov r0, #GRN_TWO
	bl flashOn
	mov r0, #GRN_TWO
	bl flashOff
	mov r0, #GRN_TWO
	bl flashOn
	mov r0, #GRN_TWO
	bl flashOff
	mov r0, #GRN_TWO
	bl flashOn

	bl timedOff

level7:
	ldr r0, =#PAUSE_HALF
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq timedOff

	mov r0, #GRN_TWO
	bl pinOn

	ldr r0, =#PAUSE_QTR
	bl delay

	mov r0, #BLU_ONE
	bl pinOn

	ldr r0, =#PAUSE_TENTH
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq level8

	ldr r0, =#PAUSE_TENTH
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq level8

	ldr r0, =#PAUSE_TENTH
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq level8

	ldr r0, =#PAUSE_TENTH
	bl delay

	mov r0, #BLU_ONE
	bl flashOff
	mov r0, #BLU_ONE
	bl flashOn
	mov r0, #BLU_ONE
	bl flashOff
	mov r0, #BLU_ONE
	bl flashOn
	mov r0, #BLU_ONE
	bl flashOff
	mov r0, #BLU_ONE
	bl flashOn

	bl timedOff

level8:
	ldr r0, =#PAUSE_HALF
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq timedOff

	mov r0, #BLU_ONE
	bl pinOn

	ldr r0, =#PAUSE_QTR
	bl delay

	mov r0, #BLU_TWO
	bl pinOn

	ldr r0, =#PAUSE_TENTH
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq youWin

	ldr r0, =#PAUSE_TENTH
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq youWin

	ldr r0, =#PAUSE_TENTH
	bl delay

	bl readButton
	cmp r0, #HIGH
	bleq youWin

	ldr r0, =#PAUSE_TENTH
	bl delay

	mov r0, #BLU_TWO
	bl flashOff
	mov r0, #BLU_TWO
	bl flashOn
	mov r0, #BLU_TWO
	bl flashOff
	mov r0, #BLU_TWO
	bl flashOn
	mov r0, #BLU_TWO
	bl flashOff
	mov r0, #BLU_TWO
	bl flashOn

	bl timedOff

// this function turns off the LED and waits for 0.1 seconds
flashOff:
	push {lr}

	bl pinOff			// turn off LED
	ldr r0, =#PAUSE_TENTH
	bl delay

	pop {pc}

// this function turns on the LED and waits for 0.1 seconds
flashOn:
	push {lr}

	bl pinOn			// turn on LED
	ldr r0, =#PAUSE_TENTH
	bl delay

	pop {pc}

// this function occurs when you have made it through all of the LEDs
// it flashes all the LEDs on and off before ending
youWin:
	ldr r0, =#PAUSE_TENTH
	bl delay
	bl allOff

	ldr r0, =#PAUSE_TENTH
	bl delay
	bl allOn

	ldr r0, =#PAUSE_TENTH
	bl delay
	bl allOff

	ldr r0, =#PAUSE_TENTH
	bl delay
	bl allOn

	ldr r0, =#PAUSE_TENTH
	bl delay
	bl allOff

	ldr r0, =#PAUSE_TENTH
	bl delay
	bl allOn

	ldr r0, =#PAUSE_TENTH
	bl delay
	bl allOff

	ldr r0, =#PAUSE_TENTH
	bl delay
	bl allOn

	bl end

// this function turns off all the LEDs with a delay
// starting with the last to the first
timedOff:
	mov r0, #BLU_TWO
	bl pinOff

	ldr r0, =#PAUSE_TENTH
	bl delay

	mov r0, #BLU_ONE
	bl pinOff

	ldr r0, =#PAUSE_TENTH
	bl delay

	mov r0, #GRN_TWO
	bl pinOff

	ldr r0, =#PAUSE_TENTH
	bl delay

	mov r0, #GRN_ONE
	bl pinOff

	ldr r0, =#PAUSE_TENTH
	bl delay

	mov r0, #YLW_TWO
	bl pinOff

	ldr r0, =#PAUSE_TENTH
	bl delay

	mov r0, #YLW_ONE
	bl pinOff

	ldr r0, =#PAUSE_TENTH
	bl delay

	mov r0, #RED_TWO
	bl pinOff

	ldr r0, =#PAUSE_TENTH
	bl delay

	mov r0, #RED_ONE
	bl pinOff

	bl allOff

	bl startLoop

// this function ends the program by turning all of the LEDs off
// it also calls the original function to set up the game again
end:
	bl allOff		// turn all the LEDs off

	pop {pc}
