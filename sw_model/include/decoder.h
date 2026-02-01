// decoder.h
// RV32I Instruction Decoder
// Author: M Salik Dev | Date: 30-09-2025

#ifndef DECODER_H
#define DECODER_H

#include <cstdint>
#include "processor_state.h"

// Instruction structure after decoding
struct DecodedInstr {
    uint32_t instr;   // Raw 32-bit instruction
    uint32_t opcode;
    uint32_t rd;
    uint32_t rs1;
    uint32_t rs2;
    uint32_t funct3;
    uint32_t funct7;
    int32_t imm;      // Sign-extended immediate
};

// Function prototypes
DecodedInstr fetch_and_decode(const Processor_State &cpu);

#endif // DECODER_H