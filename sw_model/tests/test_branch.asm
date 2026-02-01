    # Test BEQ + JAL (loop + function call simulation)
    addi x1, x0, 0       # counter = 0
    addi x2, x0, 5       # limit = 5
    addi x3, x0, 1       # increment = 1

LOOP: add  x1, x1, x3    # x1++
      beq  x1, x2, DONE  # if x1 == 5 -> DONE
      jal  x0, LOOP      # jump back

DONE: addi x4, x0, 99    # marker value
      # End (infinite loop)
      jal  x0, DONE
