// processor_state.h
// Core data structures for RV32I Golden Reference Model
// Author: M Salik Dev | Date: 30-09-2025

#ifndef PROCESSOR_STATE_H
#define PROCESSOR_STATE_H

#include <cstdint>
#include <array>

// RV32I Processor State Definition

struct Processor_State {
    // 32 General Purpose Registers (x0–x31)
    // x0 is hardwired to 0 (writes ignored)
    std::array<uint32_t, 32> regs;

    //Program counter 
    uint32_t pc;

    // Instruction Memory (IMEM)
    // Example: 4 KB = 1024 words of 32 bits each
    std::array<uint32_t, 1024> imem;
    
    // Data Memory (DMEM)
    // Example: 4 KB = 1024 words of 32 bits each
    std::array<uint32_t, 1024> dmem;

    // Constructor: initialize all state to zero
    Processor_State(){
        regs.fill(0);
        pc = 0;
        imem.fill(0);
        dmem.fill(0);
    }
    
};

#endif // PROCESSOR_STATE_H
