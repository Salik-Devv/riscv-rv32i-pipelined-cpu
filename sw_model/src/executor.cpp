#include <cstdint>
#include <iostream>
#include "../include/executor.h"

static bool mem_read_word(Processor_State &cpu, uint32_t addr, uint32_t &out_word) {
    if (addr % 4 != 0) {
        std::cerr << "Unaligned memory read at addr 0x" << std::hex << addr << std::dec << "\n";
        return false;
    }
    uint32_t idx = addr >> 2;
    if (idx >= cpu.dmem.size()) {
        std::cerr << "Memory read out-of-bounds at index " << idx << "\n";
        return false;
    }
    out_word = cpu.dmem[idx];
    return true;
}

static bool mem_write_word(Processor_State &cpu, uint32_t addr, uint32_t word) {
    if (addr % 4 != 0) {
        std::cerr << "Unaligned memory write at addr 0x" << std::hex << addr << std::dec << "\n";
        return false;
    }
    uint32_t idx = addr >> 2;
    if (idx >= cpu.dmem.size()) {
        std::cerr << "Memory write out-of-bounds at index " << idx << "\n";
        return false;
    }
    cpu.dmem[idx] = word;
    return true;
}

// Execute single decoded instruction 
void execute_instruction(Processor_State &cpu, const DecodedInstr &d) {
    uint32_t old_pc = cpu.pc;
    uint32_t next_pc = cpu.pc + 4;

    switch (d.opcode) {
        // R-type (0x33): ADD, SUB, AND, OR, XOR
        case 0x33:
            switch (d.funct3) {
                case 0x0: // ADD / SUB
                    if (d.funct7 == 0x20) {
                        cpu.regs[d.rd] = cpu.regs[d.rs1] - cpu.regs[d.rs2]; // SUB
                    } else {
                        cpu.regs[d.rd] = cpu.regs[d.rs1] + cpu.regs[d.rs2]; // ADD
                    }
                    break;
                case 0x7: cpu.regs[d.rd] = cpu.regs[d.rs1] & cpu.regs[d.rs2]; break;
                case 0x6: cpu.regs[d.rd] = cpu.regs[d.rs1] | cpu.regs[d.rs2]; break;
                case 0x4: cpu.regs[d.rd] = cpu.regs[d.rs1] ^ cpu.regs[d.rs2]; break;
                default: std::cerr << "Unsupported R-type funct3 = " << d.funct3 << "\n";
            }
            break;

        // I-type arithmetic (ADDI) and others
        case 0x13:
            if (d.funct3 == 0x0) {
                cpu.regs[d.rd] = cpu.regs[d.rs1] + static_cast<uint32_t>(d.imm); // ADDI
            } else {
                std::cerr << "Unsupported I-type funct3 = " << d.funct3 
                          << " at PC=0x" << std::hex << old_pc << std::dec << "\n";
            }
            break;

        // Load (LW)
        case 0x03:
            if (d.funct3 == 0x2) {
                uint32_t addr = cpu.regs[d.rs1] + static_cast<int32_t>(d.imm);
                uint32_t word = 0;
                if (mem_read_word(cpu, addr, word)) {
                    cpu.regs[d.rd] = word;
                } else {
                    std::cerr << "LW failed at PC=0x" << std::hex << old_pc << std::dec << "\n";
                }
            } else {
                std::cerr << "Unsupported LOAD funct3 = " << d.funct3 << "\n";
            }
            break;

        // Store (SW)
        case 0x23:
            if (d.funct3 == 0x2) {
                uint32_t addr = cpu.regs[d.rs1] + static_cast<int32_t>(d.imm);
                if (!mem_write_word(cpu, addr, cpu.regs[d.rs2])) {
                    std::cerr << "SW failed at PC=0x" << std::hex << old_pc << std::dec << "\n";
                }
            } else {
                std::cerr << "Unsupported STORE funct3 = " << d.funct3 << "\n";
            }
            break;

        // Branch (BEQ)
        case 0x63:
            if (d.funct3 == 0x0) {
                if (cpu.regs[d.rs1] == cpu.regs[d.rs2]) {
                    next_pc = static_cast<uint32_t>(static_cast<int32_t>(cpu.pc) + d.imm);
                }
            } else {
                std::cerr << "Unsupported BRANCH funct3 = " << d.funct3 << "\n";
            }
            break;

        // JAL
        case 0x6F:
            cpu.regs[d.rd] = cpu.pc + 4;
            next_pc = static_cast<uint32_t>(static_cast<int32_t>(cpu.pc) + d.imm);
            break;

        default:
            std::cerr << "Unsupported opcode 0x" << std::hex << d.opcode 
                      << " at PC=0x" << cpu.pc << std::dec << "\n";
    }

    // Enforce x0 = 0
    cpu.regs[0] = 0;

    // Update program counter
    cpu.pc = next_pc;
}
