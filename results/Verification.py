#!/usr/bin/env python3
"""
CPU Testbench Output Verification Script
Compares simulation outputs with golden reference files
"""

import sys
import re
from pathlib import Path
from typing import Dict, List, Tuple

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    BOLD = '\033[1m'
    END = '\033[0m'

def parse_final_output(filepath: str) -> Dict:
    data = {
        'pc': None,
        'registers': {},
        'memory': {}
    }
    
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    for line in lines:
        line = line.strip()
        
        # Parse PC
        if line.startswith('PC:'):
            data['pc'] = line.split(':')[1].strip().upper()
        
        # Parse registers (x0-x31)
        elif line.startswith('x'):
            match = re.match(r'x(\d+):\s*([0-9A-Fa-f]+)', line)
            if match:
                reg_num = int(match.group(1))
                reg_val = match.group(2).upper()
                data['registers'][reg_num] = reg_val
        
        # Parse memory (format: 0xADDRESS: 0xDATA)
        elif line.startswith('0x') and ':' in line:
            parts = line.split(':')
            if len(parts) == 2:
                addr = parts[0].strip().upper()
                value = parts[1].strip().upper()
                data['memory'][addr] = value
    
    return data

def parse_trace_output(filepath: str, max_steps: int = None) -> List[Dict]:
    trace = []
    
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    for line in lines:
        line = line.strip()
        
        # Skip comments and header
        if line.startswith('#') or line.startswith('Step'):
            continue
        
        if not line:
            continue
        
        # Parse trace line: Step  PC  Instr  Rd  Value
        parts = line.split()
        if len(parts) >= 5:
            step = {
                'step': int(parts[0]),
                'pc': parts[1].upper(),
                'instr': parts[2].upper(),
                'rd': parts[3],
                'value': parts[4].upper()
            }
            trace.append(step)
            
            # Stop if we've reached max_steps
            if max_steps is not None and len(trace) >= max_steps:
                break
    
    return trace

def compare_final_outputs(output_file: str, golden_file: str) -> Tuple[bool, List[str]]:
    errors = []
    
    print(f"\n{Colors.BLUE}{Colors.BOLD}=== Comparing Final Outputs ==={Colors.END}")
    print(f"Output: {output_file}")
    print(f"Golden: {golden_file}\n")
    
    # Parse both files
    output_data = parse_final_output(output_file)
    golden_data = parse_final_output(golden_file)
    
    all_match = True
    
    # Compare PC
    print(f"{Colors.BOLD}Program Counter:{Colors.END}")
    if output_data['pc'] == golden_data['pc']:
        print(f"  {Colors.GREEN}✓{Colors.END} PC: {output_data['pc']}")
    else:
        print(f"  {Colors.RED}✗{Colors.END} PC mismatch!")
        print(f"    Expected: {golden_data['pc']}")
        print(f"    Got:      {output_data['pc']}")
        errors.append(f"PC mismatch: expected {golden_data['pc']}, got {output_data['pc']}")
        all_match = False
    
    # Compare registers
    print(f"\n{Colors.BOLD}Registers:{Colors.END}")
    reg_errors = 0
    for i in range(32):
        output_val = output_data['registers'].get(i, 'MISSING')
        golden_val = golden_data['registers'].get(i, 'MISSING')
        
        if output_val != golden_val:
            print(f"  {Colors.RED}✗{Colors.END} x{i}: expected {golden_val}, got {output_val}")
            errors.append(f"Register x{i} mismatch: expected {golden_val}, got {output_val}")
            reg_errors += 1
            all_match = False
    
    if reg_errors == 0:
        print(f"  {Colors.GREEN}✓{Colors.END} All 32 registers match")
    else:
        print(f"  {Colors.RED}✗{Colors.END} {reg_errors} register(s) mismatch")
    
    # Compare memory
    print(f"\n{Colors.BOLD}Data Memory:{Colors.END}")
    all_addrs = set(output_data['memory'].keys()) | set(golden_data['memory'].keys())
    
    if len(all_addrs) == 0:
        print(f"  {Colors.GREEN}✓{Colors.END} No memory writes (as expected)")
    else:
        mem_errors = 0
        for addr in sorted(all_addrs):
            output_val = output_data['memory'].get(addr, 'NOT WRITTEN')
            golden_val = golden_data['memory'].get(addr, 'NOT WRITTEN')
            
            if output_val != golden_val:
                print(f"  {Colors.RED}✗{Colors.END} {addr}: expected {golden_val}, got {output_val}")
                errors.append(f"Memory {addr} mismatch: expected {golden_val}, got {output_val}")
                mem_errors += 1
                all_match = False
        
        if mem_errors == 0:
            print(f"  {Colors.GREEN}✓{Colors.END} All memory locations match")
        else:
            print(f"  {Colors.RED}✗{Colors.END} {mem_errors} memory location(s) mismatch")
    
    return all_match, errors

def compare_trace_outputs(output_file: str, golden_file: str, max_steps: int = 7) -> Tuple[bool, List[str]]:
    errors = []
    
    print(f"\n{Colors.BLUE}{Colors.BOLD}=== Comparing Trace Outputs ==={Colors.END}")
    print(f"Output: {output_file}")
    print(f"Golden: {golden_file}\n")
    
    # Parse both files
    output_trace = parse_trace_output(output_file, max_steps)
    golden_trace = parse_trace_output(golden_file, max_steps)
    
    all_match = True
    
    # Check if we have enough steps
    if len(output_trace) < max_steps:
        print(f"{Colors.YELLOW}⚠{Colors.END} Warning: Output trace has only {len(output_trace)} steps, expected {max_steps}")
        max_steps = min(len(output_trace), len(golden_trace))
    
    if len(golden_trace) < max_steps:
        print(f"{Colors.YELLOW}⚠{Colors.END} Warning: Golden trace has only {len(golden_trace)} steps")
        max_steps = min(len(output_trace), len(golden_trace))
    
    # Compare each step
    print(f"{Colors.BOLD}Step-by-Step Comparison:{Colors.END}")
    for i in range(max_steps):
        output_step = output_trace[i] if i < len(output_trace) else None
        golden_step = golden_trace[i] if i < len(golden_trace) else None
        
        if output_step is None:
            print(f"  {Colors.RED}✗{Colors.END} Step {i}: Missing in output")
            errors.append(f"Step {i}: Missing in output trace")
            all_match = False
            continue
        
        if golden_step is None:
            print(f"  {Colors.RED}✗{Colors.END} Step {i}: Missing in golden")
            errors.append(f"Step {i}: Missing in golden trace")
            all_match = False
            continue
        
        # Compare all fields
        step_match = True
        mismatches = []
        
        if output_step['pc'] != golden_step['pc']:
            mismatches.append(f"PC: {golden_step['pc']} vs {output_step['pc']}")
            step_match = False
        
        if output_step['instr'] != golden_step['instr']:
            mismatches.append(f"Instr: {golden_step['instr']} vs {output_step['instr']}")
            step_match = False
        
        if output_step['rd'] != golden_step['rd']:
            mismatches.append(f"Rd: {golden_step['rd']} vs {output_step['rd']}")
            step_match = False
        
        if output_step['value'] != golden_step['value']:
            mismatches.append(f"Value: {golden_step['value']} vs {output_step['value']}")
            step_match = False
        
        if step_match:
            print(f"  {Colors.GREEN}✓{Colors.END} Step {i}: PC={output_step['pc']}, Instr={output_step['instr']}, {output_step['rd']}={output_step['value']}")
        else:
            print(f"  {Colors.RED}✗{Colors.END} Step {i}: Mismatch")
            for mismatch in mismatches:
                print(f"      {mismatch}")
            errors.append(f"Step {i}: {', '.join(mismatches)}")
            all_match = False
    
    return all_match, errors

def main():
    """Main verification function"""
    # File paths
    trace_output = "../tb/trace_output.txt"
    trace_golden = "../tb/test_add_trace.txt"
    final_output = "../tb/final_output.txt"
    final_golden = "../tb/test_add_golden.txt"
    
    # Check if files exist
    missing_files = []
    for filepath in [trace_output, trace_golden, final_output, final_golden]:
        if not Path(filepath).exists():
            missing_files.append(filepath)
    
    if missing_files:
        print(f"{Colors.RED}{Colors.BOLD}Error: Missing files:{Colors.END}")
        for f in missing_files:
            print(f"  - {f}")
        sys.exit(1)
    
    print(f"{Colors.BOLD}{'='*60}{Colors.END}")
    print(f"{Colors.BOLD}  CPU Testbench Verification{Colors.END}")
    print(f"{Colors.BOLD}{'='*60}{Colors.END}")
    
    # Compare trace outputs (first 7 steps only)
    trace_match, trace_errors = compare_trace_outputs(trace_output, trace_golden, max_steps=7)
    
    # Compare final outputs
    final_match, final_errors = compare_final_outputs(final_output, final_golden)
    
    # Summary
    print(f"\n{Colors.BOLD}{'='*60}{Colors.END}")
    print(f"{Colors.BOLD}  Verification Summary{Colors.END}")
    print(f"{Colors.BOLD}{'='*60}{Colors.END}\n")
    
    if trace_match:
        print(f"{Colors.GREEN}✓ Trace Verification: PASSED{Colors.END}")
    else:
        print(f"{Colors.RED}✗ Trace Verification: FAILED ({len(trace_errors)} error(s)){Colors.END}")
    
    if final_match:
        print(f"{Colors.GREEN}✓ Final State Verification: PASSED{Colors.END}")
    else:
        print(f"{Colors.RED}✗ Final State Verification: FAILED ({len(final_errors)} error(s)){Colors.END}")
    
    # Overall result
    print(f"\n{Colors.BOLD}Overall Result:{Colors.END}")
    if trace_match and final_match:
        print(f"{Colors.GREEN}{Colors.BOLD}✓✓✓ ALL TESTS PASSED ✓✓✓{Colors.END}")
        sys.exit(0)
    else:
        print(f"{Colors.RED}{Colors.BOLD}✗✗✗ TESTS FAILED ✗✗✗{Colors.END}")
        print(f"\nTotal errors: {len(trace_errors) + len(final_errors)}")
        
        if trace_errors:
            print(f"\n{Colors.BOLD}Trace Errors:{Colors.END}")
            for err in trace_errors:
                print(f"  - {err}")
        
        if final_errors:
            print(f"\n{Colors.BOLD}Final State Errors:{Colors.END}")
            for err in final_errors:
                print(f"  - {err}")
        
        sys.exit(1)

if __name__ == "__main__":
    main()