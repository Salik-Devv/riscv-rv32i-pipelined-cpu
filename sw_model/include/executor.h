#ifndef EXECUTOR_H
#define EXECUTOR_H

#include <cstdint>
#include "processor_state.h"
#include "decoder.h"

// Execute single decoded instruction (functional semantics).
// Updates registers and program counter in cpu.
void execute_instruction(Processor_State &cpu, const DecodedInstr &d);

#endif // EXECUTOR_H