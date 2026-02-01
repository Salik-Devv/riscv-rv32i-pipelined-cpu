# RISC-V RV32I 5-Stage Pipelined Processor

A high-performance, **FPGA-optimized** 5-stage pipelined RISC-V processor core implementing the RV32I base integer instruction set in VHDL.

[![FPGA](https://img.shields.io/badge/FPGA-Cyclone%20V-blue)](https://www.intel.com/content/www/us/en/products/details/fpga/cyclone/v.html)
[![Fmax](https://img.shields.io/badge/Core%20Fmax-104.4%20MHz-green)](results/timing_analysis.png)
[![ISA](https://img.shields.io/badge/ISA-RV32I-orange)](https://riscv.org/technical/specifications/)
[![Verified](https://img.shields.io/badge/Status-Verified-success)](results/verification.py)

---

## 🎯 Features

- **Classic 5-stage pipeline**: IF → ID → EX → MEM → WB
- **Complete hazard handling**: Load-use detection, data forwarding, and branch resolution
- **Timing-optimized design**: Registered memory interfaces and pre-computed control signals
- **Cycle-accurate verification**: Validated against C++ golden reference model
- **Industry-standard methodology**: Separate simulation and synthesis top-levels
- **Documented performance**: Timing closure at 104.4 MHz on Cyclone V FPGA

---

## 📐 Architecture

### Pipeline Stages

| Stage | Description | Key Components |
|-------|-------------|----------------|
| **IF** | Instruction Fetch | Program counter, instruction memory interface |
| **ID** | Instruction Decode | Register file read, immediate generation, control signals |
| **EX** | Execute | ALU operations, branch target calculation |
| **MEM** | Memory Access | Data memory read/write interface |
| **WB** | Write Back | Register file write |

### Hazard Mitigation

- **Data forwarding**: EX-to-EX and MEM-to-EX bypass paths
- **Load-use stalls**: Single-cycle pipeline bubble insertion
- **Branch handling**: Flush and PC update in ID stage

---

## 🗂️ Project Structure

```
.
├── docs/
│   └── ArchitecturalSpecification.pdf    # Detailed design documentation
│
├── rtl/
│   └── alu/
│       ├── cpu_top.vhd                    # Simulation top-level
│       ├── cpu_top_synth.vhd              # Synthesis top-level (timing-optimized)
│       ├── ALU.vhd                        # Arithmetic Logic Unit
│       ├── alu_control.vhd                # ALU operation decoder
│       ├── control_unit.vhd               # Main control logic
│       ├── forwarding_unit.vhd            # Data forwarding logic
│       ├── hazard_unit.vhd                # Stall and flush control
│       ├── immgen.vhd                     # Immediate generator
│       ├── pipeline_reg.vhd               # Inter-stage registers
│       ├── regfile.vhd                    # Register file
│       └── regfile_pkg.vhd                # Register file package
│
├── tb/
│   ├── riscv_tb.vhd                       # Testbench
│   ├── test_add.hex                       # Test program binary
│   ├── trace_output.txt                   # RTL execution trace
│   ├── final_output.txt                   # RTL final state
│   ├── test_add_trace.txt                 # Golden trace
│   └── test_add_golden.txt                # Golden final state
│
├── sw_model/
│   ├── include/                           # C++ model headers
│   ├── src/                               # C++ model implementation
│   └── tests/                             # Assembly test programs
│
├── results/
│   ├── report.txt                         # Full timing report
│   ├── test_result_screenshot.png         # Verification results
│   ├── timing_analysis.png                # Fmax analysis screenshot
│   └── verification.py                    # Automated verification script
│
├── project_report.pdf                     # Comprehensive project report
└── README.md                              # This file
```

---

## 🚀 Getting Started

### Prerequisites

- **ModelSim** (or compatible VHDL simulator)
- **Quartus Prime Lite** (for synthesis and timing analysis)
- **Python 3.x** (for verification scripts)
- **GCC/G++** (for C++ golden model)

### Running Simulation

1. **Compile the design**:
   ```bash
   vlib work
   vcom -2008 rtl/alu/*.vhd
   vcom -2008 tb/riscv_tb.vhd
   ```

2. **Run simulation**:
   ```bash
   vsim -c riscv_tb -do "run -all; quit"
   ```

3. **Verify results**:
   ```bash
   python3 results/verification.py
   ```

### Synthesis and Timing Analysis

1. Open `cpu_top_synth.vhd` in Quartus Prime
2. Set target device: **Cyclone V 5CGXFC7C7F23C8**
3. Run synthesis and place-and-route
4. Open Timing Analyzer and generate timing reports

---

## ✅ Verification

The design is verified using a **dual-model approach**:

### C++ Golden Model
- Cycle-accurate reference implementation
- Generates expected execution traces
- Provides golden register and memory states

### Verification Methodology
```python
# Automated verification checks:
✓ Instruction-by-instruction trace comparison
✓ Final register file contents
✓ Program counter value
✓ Data memory contents
```

**Verification Status**: ✅ All tests passing

---

## ⚡ Performance

| Metric | Value |
|--------|-------|
| **FPGA Device** | Intel Cyclone V (5CGXFC7C7F23C8) |
| **Core Fmax** | **104.4 MHz** |
| **Process Corner** | Slow (85°C, 1100 mV) |
| **Logic Utilization** | 578 registers, < 1% ALMs |
| **Critical Path** | Register file → ALU → forwarding mux |

> **Note**: Fmax represents core logic only. External memory timing is intentionally excluded via registered I/O interfaces.

---

## 🎨 Design Highlights

### Dual Top-Level Architecture

This project uses **two separate top-level modules**:

#### `cpu_top.vhd` (Simulation)
- Exposes internal signals for debugging
- Direct memory connections
- Optimized for observability

#### `cpu_top_synth.vhd` (Synthesis)  
- Registered instruction and data memory outputs
- Eliminates long combinational paths to I/O
- Enables realistic core Fmax measurement


---

## 📊 Test Programs

Included test programs demonstrate key functionality:

- `test_add.asm` - Basic ALU operations
- `test_branch.asm` - Conditional branches
- `test_mem.asm` - Load/store instructions

Each test includes:
- Assembly source (`.asm`)
- Machine code (`.hex`)
- Golden trace (`.txt`)
- Expected final state (`.txt`)

---

## 🛠️ Tools

- **VHDL** - RTL design
- **ModelSim** - Functional simulation
- **Quartus Prime** - Synthesis and timing analysis
- **Python** - Verification automation
- **C++** - Golden reference model

---

## 📈 Future Enhancements

Potential extensions for this project:

- [ ] Add instruction and data caches
- [ ] Implement CSR (Control and Status Register) support
- [ ] Extend to RV32IM (multiply/divide instructions)
- [ ] Add branch prediction
- [ ] Port to ASIC synthesis flow
- [ ] Implement supervisor mode
- [ ] Add performance counters

---

## 📄 Documentation

- **[Architectural Specification](docs/ArchitecturalSpecification.pdf)** - Detailed microarchitecture
- **[Project Report](project_report.pdf)** - Complete design documentation
- **[Timing Analysis](results/timing_analysis.png)** - Fmax analysis screenshot
- **[Verification Results](results/test_result_screenshot.png)** - Test output

---

## 📝 License

This project is provided as-is for educational purposes.

---

## 👤 Author

Mohammad Salik Dev

---

## 🙏 Acknowledgments

- RISC-V Foundation for the ISA specification
- Intel for Quartus Prime tools
- Open-source RISC-V community


