.text
.globl _start

_start:
    # Address 0x04: Your original test code begins here
    addi x1, x0, 5               # x1 = 5
    addi x2, x0, 10              # x2 = 10
    add  x3, x1, x2              # x3 = 15
    sub  x4, x2, x1              # x4 = 5
    and  x5, x1, x2              # x5 = 0
    or   x6, x1, x2              # x6 = 15
    xor  x7, x1, x2              # x7 = 15
             

# Address 0x28: The Infinite Loop (Halt)
# This will keep the PC stable so the testbench triggers exit
LOOP: 
    jal x0, LOOP