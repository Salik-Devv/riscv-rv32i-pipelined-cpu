#include <iostream>
#include <fstream>
#include <iomanip>
#include "../include/processor_state.h"
#include "../include/decoder.h"
#include "../include/executor.h"

// Load hex program into instruction memory
void load_program(Processor_State &cpu, const std::string &filename) {
    std::ifstream file(filename);
    std::string line;
    uint32_t addr = 0;

    while (std::getline(file, line)) {
        if (line.empty()) continue;
        cpu.imem[addr++] = std::stoul(line, nullptr, 16);
    }
}

// Dump FINAL golden output (NO 0x prefix)
void dump_golden_output(const Processor_State &cpu,
                        const std::string &filename) {
    std::ofstream out(filename);

    out << "# FINAL REGISTER STATE (32-bit Hex)\n";
    out << "PC: "
        << std::uppercase << std::hex
        << std::setw(8) << std::setfill('0')
        << cpu.pc << "\n";

    for (int i = 0; i < 32; i++) {
        out << "x" << std::dec << i << ": "
            << std::uppercase << std::hex
            << std::setw(8) << std::setfill('0')
            << cpu.regs[i] << "\n";
    }

    out << "\n# FINAL DATA MEMORY STATE (Address: Data)\n";

    bool wrote = false;
    for (size_t i = 0; i < cpu.dmem.size(); i++) {
        if (cpu.dmem[i] != 0) {
            out << std::uppercase << std::hex
                << std::setw(8) << std::setfill('0') << (i * 4)
                << ": "
                << std::setw(8) << std::setfill('0') << cpu.dmem[i]
                << "\n";
            wrote = true;
        }
    }

    if (!wrote) {
        out << "# (no writes)\n";
    }

    out.close();
}

// Dump TRACE step 
void dump_trace_step(std::ofstream &trace,
                     int step,
                     uint32_t pc,
                     uint32_t instr,
                     uint32_t rd,
                     uint32_t val) {

    trace << std::dec << step << "\t"
          << "0x" << std::setw(8) << std::setfill('0') << std::hex << pc << "\t"
          << "0x" << std::setw(8) << std::setfill('0') << instr << "\t";

    if (rd != 0) {
        trace << "x" << std::dec << rd << "\t"
              << "0x" << std::setw(8) << std::setfill('0') << std::hex << val;
    } else {
        trace << "-\t-";
    }

    trace << "\n";
}

// Main
int main() {
    Processor_State cpu;
    cpu.pc = 0;   

    load_program(cpu, "../tests/test_add.hex");

    std::ofstream trace("../tests/test_add_trace.txt");
    trace << "Step\tPC\t\tInstr\t\tRd\tValue\n";

    for (int step = 0; step < 50; step++) {
        uint32_t pc_before = cpu.pc;
        uint32_t instr = cpu.imem[pc_before / 4];

        DecodedInstr d = fetch_and_decode(cpu);
        execute_instruction(cpu, d);

        dump_trace_step(
            trace,
            step,
            pc_before,
            instr,
            d.rd,
            (d.rd != 0) ? cpu.regs[d.rd] : 0
        );

        if (cpu.pc == pc_before) {
            break;
        }
    }

    dump_golden_output(cpu, "../tests/test_add_golden.txt");

    trace.close();
    return 0;
}