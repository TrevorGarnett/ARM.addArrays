@ Filename: Lab1.s
@ Author:   Trevor Garnett
@ Class: CS 413-01
@ Term: Spring 2021
@ Objective: The objecive of this lab is to have the students use ARM Auto-Indexing to access array elements
@	and to do nested subroutine calls.
@ History:
@	Created 02/06, adding comments when necessary
@
@ Use these commands to assemble, link, run and debug this program:
@    as -o Lab1.o Lab1.s
@    gcc -o Lab1 Lab1.o
@    ./Lab1 ;echo $?
@    gdb --args ./Lab1

@ ****************************************************
@ The = (equal sign) is used in the ARM Assembler to get the address of a
@ label declared in the .data section. This takes the place of the ADR
@ instruction used in the textbook. 
@ ****************************************************

.equ READERROR, 0 @Used to check for scanf read error. 

.global main @ Have to use main because of C library uses. 

main:

@*******************
prompt:				@ Prompt user for input
@*******************

@ Ask the user to enter a number.
   ldr r0, =welcomeMessage	@ Put the address of my string into the first parameter
   bl  printf              	@ Call the C printf to display input prompt.

   mov r4, #10
   ldr r5, =arrTwo		@ Load the address of array 2 into r5.
   add r5,r5,#40		@ Increment register to second half of the array, which has no values

@*******************
input_loop:			@ This is the loop that will retrieve user input.
@*******************

@ Set up r0 with the address of input pattern
@ scanf puts the input value at the address stored in r1. We are going
@ to use the address for our declared variable in the data section - intInput. 
@ After the call to scanf the input is at the address pointed to by r1 which in this
@ case will be intInput. 

   ldr r0, =numInputPattern 	@ Setup to read in one number.
   ldr r1, =intInput        	@ load r1 with the address of where the
                            	@ input value will be stored.
   bl  scanf                	@ scan the keyboard.
   cmp r0, #READERROR       	@ Check for a read error.
   beq readerror            	@ If there was a read error go handle it. 
   ldr r1, =intInput        	@ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             	@ Read the contents of intInput so we can use it
   str r1, [r5],#4		@ Store the input into array and autoindex to next value.
   subs r4, r4, #1		@ Subtract 1 from r4, to note that one input as been read in.
   bne input_loop               @ If r4 currently = 0

   @ If it hits here, it has left the "input_loop" for loop. Starting conditions for sum_Arrays
   ldr r1,=arrOne		@ Set r1 to point to head of array one
   ldr r2,=arrTwo		@ Set r1 to point to head of array two
   ldr r3,=arrThree		@ Set r1 to point to head of array three
   mov r0, #20			@ Let r0 represent i, the iterator
   b sum_Arrays 		@ Go to sum_Arrays to sum elements of arrOne and arrTwo and place sum in arrThree


@*******************
sum_Arrays:			@ Loop that sums elements of arrOne and arrTwo and submits result into corresponding
				@ element of arrThree.
@*******************

   ldr r4, [r1], #4		@ Load value of index i of arrOne into r4, then increment to element i+1
   ldr r5, [r2], #4		@ Load value of index i of arrTwo into r5, then increment to element i+1
   add r6,r4,r5			@ r6 <- arrOne[i] + arrTwo[i]
   str r6,[r3], #4		@ arrThree[i] <- r6, then autoincrement to next element in arrThree
   subs r0, r0, #1		@ Subtract 1 from r0 to note one element of r3 has been set
   bne sum_Arrays               @ If r0 doesn't = 0, go to top of sum_Array loop. Else, exit loop.
   b continue			@ If arrThree full,go to continue to print the arrays 



@*******************
continue:			@ Calls the function that prints an array
@*******************
   mov r5,#20			@ Tells print_Array function the number of elements to be printed
   ldr r4, =arrOne		@ Load the address of first element of array one
   ldr r0, =arrayOne		@ Load address of string stating "array one will be printed" into r0
   bl printf			@ Print
   bl print_Array		@ Go to print_Array subroutine to print the actual array whose first element
				@ is pointed to by r4.

   mov r5,#20			@ Tells print_Array function the number of elements to be printed
   ldr r4, =arrTwo		@ Load the address of first element of array two
   ldr r0, =arrayTwo		@ Load address of string stating "array two will be printed" into r0
   bl printf			@ Print
   bl print_Array		@ Go to print_Array subroutine to print the actual array whose first element
				@ is pointed to by r4.

   mov r5,#20			@ Tells print_Array function the number of elements to be printed
   ldr r4, =arrThree		@ Load the address of first element of array three
   ldr r0, =arrayThree		@ Load address of string stating "array three will be printed" into r0
   bl printf			@ Print
   bl print_Array		@ Go to print_Array subroutine to print the actual array whose first element
				@ is pointed to by r4.
   b myexit	@ exit program

@*******************
print_Array:			@ Function called to print arrays of ints.
				@ Must have length of array in r5 and the array to be
				@ printed in r4.
@*******************

   push {lr}

loop:
   ldr r1,[r4],#4
   ldr r0,=element
   bl printf
   subs r5,r5,#1
   bne loop 
   pop {pc}

@***********
readerror:
@***********
@ Got a read error from the scanf routine. Clear out the input buffer then
@ branch back for the user to enter a value. 
@ Since an invalid entry was made we now have to clear out the input buffer by
@ reading with this format %[^\n] which will read the buffer until the user 
@ presses the CR. 
   ldr r0, =strInputPattern
   ldr r1, =strInputError   	@ Put address into r1 for read.
   bl scanf                	@ scan the keyboard.
@  Not going to do anything with the input. This just cleans up the input buffer.  
@  The input buffer should now be clear so get another input.

   b prompt


@*******************
myexit:
@*******************
@ End of my code. Force the exit and return control to OS
   ldr r0,=programEnding	@ Program ending message.
   bl printf			@ Print
   mov r7, #0x01 		@SVC call to exit
   svc 0         		@Make the system call. 

.data

@ Declare the strings and data needed

.balign 4
welcomeMessage: .asciz "Greetings. Please enter 10 integers one at a time, which will be entered into the second half of an array two.\n"

.balign 4
element: .asciz "%d \n"

.balign 4
programEnding: .asciz "Program is ending. Hope everything went well! \n"

.balign 4
arrayOne: .asciz "Below is the contents of array one: \n"

.balign 4
arrayTwo: .asciz "Below is the contents of array two: \n"

.balign 4
arrayThree: .asciz "Below is the contents of array three: \n"

@ Format pattern for scanf call.

.balign 4
numInputPattern: .asciz "%d"  @ integer format for read. 

.balign 4
strInputPattern: .asciz "%[^\n]" @ Used to clear the input buffer for invalid input. 

.balign 4
strInputError: .skip 100*4  @ User to clear the input buffer for invalid input. 

.balign 4
intInput: .word 0   @ Location used to store the user input.


.balign 4
arrOne: .word -78	@ Array element 0
	.word 80	@ Array element 1
	.word -83	@ Array element 2
	.word -68	@ Array element 3
	.word -29	@ Array element 4
	.word 100	@ Array element 5
	.word -3	@ Array element 6
	.word 100	@ Array element 7
	.word 29	@ Array element 8
	.word -62	@ Array element 9
	.word 47	@ Array element 10
	.word -94	@ Array element 11
	.word 42	@ Array element 12
	.word 65	@ Array element 13
	.word 54	@ Array element 14
	.word 89	@ Array element 15
	.word 0		@ Array element 16
	.word -40	@ Array element 17
	.word -4	@ Array element 18
	.word -25	@ Array element 19

.balign 4
arrTwo:	.word 100	@ Array element 0
	.word -100	@ Array element 1
	.word 83	@ Array element 2
	.word 0		@ Array element 3
	.word 58	@ Array element 4
	.word 76	@ Array element 5
	.word -5	@ Array element 6
	.word -6	@ Array element 7
	.word 50	@ Array element 8
	.word 92	@ Array element 9
	.skip 40	@ Save space for 10 elements

.balign 4
arrThree:
	.skip 80	@ Save space for 20 elements

@ Let the assembler know these are the C library functions. 

.global printf
@  To use printf:
@     r0 - Contains the starting address of the string to be printed. The string
@          must conform to the C coding standards.
@     r1 - If the string contains an output parameter i.e., %d, %c, etc. register
@          r1 must contain the value to be printed. 
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed. 

.global scanf
@  To use scanf:
@      r0 - Contains the address of the input format string used to read the user
@           input value. In this example it is numInputPattern.  
@      r1 - Must contain the address where the input value is going to be stored.
@           In this example memory location intInput declared in the .data section
@           is being used.  
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed.
@ Important Notes about scanf:
@   If the user entered an input that does NOT conform to the input pattern, 
@   then register r0 will contain a 0. If it is a valid format
@   then r0 will contain a 1. The input buffer will NOT be cleared of the invalid
@   input so that needs to be cleared out before attempting anything else. 
@

@end of code and end of file. Leave a blank line after this.
