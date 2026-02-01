    # Test LW, SW
    addi x1, x0, 100     # base address = 100
    addi x2, x0, 42      # data = 42
    sw   x2, 0(x1)       # MEM[100] = 42
    lw   x3, 0(x1)       # x3 = MEM[100] = 42

    addi x4, x0, 84
    sw   x4, 4(x1)       # MEM[104] = 84
    lw   x5, 4(x1)       # x5 = MEM[104] = 84

    # End (infinite loop)
LOOP: jal x0, LOOPo
