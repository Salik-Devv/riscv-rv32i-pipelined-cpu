#include "../include/decoder.h"

// Helper function: sign extension
static int32_t sign_extend(uint32_t value, int bits) {
    int32_t mask = 1 << (bits - 1);
    return (value ^ mask) - mask;
}

// Fetch + Decode function
DecodedInstr fetch_and_decode(const Processor_State &cpu) {
    DecodedInstr d;
    d.instr  = cpu.imem[cpu.pc >> 2];   // PC is word-aligned
    d.opcode = d.instr & 0x7F;
    d.rd     = (d.instr >> 7) & 0x1F;
    d.funct3 = (d.instr >> 12) & 0x07;
    d.rs1    = (d.instr >> 15) & 0x1F;
    d.rs2    = (d.instr >> 20) & 0x1F;
    d.funct7 = (d.instr >> 25) & 0x7F;

    // Immediate decode based on instruction type
    switch (d.opcode) {
        case 0x13: // I-type (ADDI, LW)
            if (d.funct3 == 0x0) { // ADDI
                d.imm = sign_extend(d.instr >> 20, 12);
            } else if (d.funct3 == 0x2 || d.funct3 == 0x3) { // LW
                d.imm = sign_extend(d.instr >> 20, 12);
            }
            break;

        case 0x03: // Load (LW)
            d.imm = sign_extend(d.instr >> 20, 12);
            break;

        case 0x23: // S-type (SW)
            d.imm = ((d.instr >> 7) & 0x1F) | ((d.instr >> 25) << 5);
            d.imm = sign_extend(d.imm, 12);
            break;

        case 0x63: // B-type (BEQ)
            d.imm = ((d.instr >> 8) & 0x0F) << 1;
            d.imm |= ((d.instr >> 25) & 0x3F) << 5;
            d.imm |= ((d.instr >> 7) & 0x01) << 11;
            d.imm |= ((d.instr >> 31) & 0x01) << 12;
            d.imm = sign_extend(d.imm, 13);
            break;

        case 0x6F: // J-type (JAL)
            d.imm = ((d.instr >> 21) & 0x3FF) << 1;
            d.imm |= ((d.instr >> 20) & 0x01) << 11;
            d.imm |= ((d.instr >> 12) & 0xFF) << 12;
            d.imm |= ((d.instr >> 31) & 0x01) << 20;
            d.imm = sign_extend(d.imm, 21);
            break;

        default:
            d.imm = 0; // Default
    }

    return d;
}


