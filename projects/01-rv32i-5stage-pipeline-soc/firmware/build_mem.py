#!/usr/bin/env python3
"""
RV32I + CSR/Trap Machine-Mode Assembler for Bare-metal ROM (.mem) generation
Project: hazard_with_csr_interrupt
"""

import re
import os
import sys

REG_MAP = {
    'zero': 0, 'ra': 1, 'sp': 2, 'gp': 3, 'tp': 4,
    't0': 5, 't1': 6, 't2': 7, 's0': 8, 'fp': 8, 's1': 9,
    'a0': 10, 'a1': 11, 'a2': 12, 'a3': 13, 'a4': 14, 'a5': 15, 'a6': 16, 'a7': 17,
    's2': 18, 's3': 19, 's4': 20, 's5': 21, 's6': 22, 's7': 23, 's8': 24, 's9': 25, 's10': 26, 's11': 27,
    't3': 28, 't4': 29, 't5': 30, 't6': 31,
    'x0': 0, 'x1': 1, 'x2': 2, 'x3': 3, 'x4': 4, 'x5': 5, 'x6': 6, 'x7': 7,
    'x8': 8, 'x9': 9, 'x10': 10, 'x11': 11, 'x12': 12, 'x13': 13, 'x14': 14, 'x15': 15,
    'x16': 16, 'x17': 17, 'x18': 18, 'x19': 19, 'x20': 20, 'x21': 21, 'x22': 22, 'x23': 23,
    'x24': 24, 'x25': 25, 'x26': 26, 'x27': 27, 'x28': 28, 'x29': 29, 'x30': 30, 'x31': 31
}

CSR_MAP = {
    'mstatus': 0x300,
    'mie':     0x304,
    'mtvec':   0x305,
    'mepc':    0x341,
    'mcause':  0x342
}

def parse_reg(r):
    r = r.strip()
    if r in REG_MAP:
        return REG_MAP[r]
    if r.startswith('x') and r[1:].isdigit():
        return int(r[1:])
    raise ValueError(f"Unknown register: '{r}'")

def parse_csr(c):
    c = c.strip().lower()
    if c in CSR_MAP:
        return CSR_MAP[c]
    return int(c, 0)

def parse_imm(val_str):
    val_str = val_str.strip()
    return int(val_str, 0)

# Instruction Formats
def enc_r(opcode, funct3, funct7, rd, rs1, rs2):
    return ((funct7 & 0x7F) << 25) | ((rs2 & 0x1F) << 20) | ((rs1 & 0x1F) << 15) | ((funct3 & 0x7) << 12) | ((rd & 0x1F) << 7) | (opcode & 0x7F)

def enc_i(opcode, funct3, rd, rs1, imm):
    return ((imm & 0xFFF) << 20) | ((rs1 & 0x1F) << 15) | ((funct3 & 0x7) << 12) | ((rd & 0x1F) << 7) | (opcode & 0x7F)

def enc_s(opcode, funct3, rs1, rs2, imm):
    imm11_5 = (imm >> 5) & 0x7F
    imm4_0 = imm & 0x1F
    return (imm11_5 << 25) | ((rs2 & 0x1F) << 20) | ((rs1 & 0x1F) << 15) | ((funct3 & 0x7) << 12) | (imm4_0 << 7) | (opcode & 0x7F)

def enc_b(opcode, funct3, rs1, rs2, offset):
    imm12 = (offset >> 12) & 0x1
    imm10_5 = (offset >> 5) & 0x3F
    imm4_1 = (offset >> 1) & 0xF
    imm11 = (offset >> 11) & 0x1
    return (imm12 << 31) | (imm10_5 << 25) | ((rs2 & 0x1F) << 20) | ((rs1 & 0x1F) << 15) | ((funct3 & 0x7) << 12) | (imm4_1 << 8) | (imm11 << 7) | (opcode & 0x7F)

def enc_u(opcode, rd, imm20):
    return ((imm20 & 0xFFFFF) << 12) | ((rd & 0x1F) << 7) | (opcode & 0x7F)

def enc_j(opcode, rd, offset):
    imm20 = (offset >> 20) & 0x1
    imm10_1 = (offset >> 1) & 0x3FF
    imm11 = (offset >> 11) & 0x1
    imm19_12 = (offset >> 12) & 0xFF
    return (imm20 << 31) | (imm19_12 << 12) | (imm11 << 20) | (imm10_1 << 21) | ((rd & 0x1F) << 7) | (opcode & 0x7F)

def assemble_file(src_path):
    with open(src_path, "r", encoding="utf-8") as f:
        content = f.read()

    lines = content.split('\n')
    clean_instructions = []
    labels = {}
    pc = 0

    # Pass 1: Parse labels, .org directives, instructions
    for line in lines:
        line = re.sub(r'#.*', '', line)
        line = re.sub(r'//.*', '', line).strip()
        if not line:
            continue
        if line.startswith('.org'):
            parts = line.split()
            target_pc = int(parts[1], 0)
            while pc < target_pc:
                clean_instructions.append((pc, 'nop'))
                pc += 4
            continue
        if line.startswith('.'):
            continue
        if line.endswith(':'):
            lbl = line[:-1].strip()
            labels[lbl] = pc
        else:
            if ':' in line:
                parts = line.split(':', 1)
                lbl = parts[0].strip()
                labels[lbl] = pc
                line = parts[1].strip()
            if line:
                clean_instructions.append((pc, line))
                pc += 4

    # Pass 2: Assemble instructions to 32-bit machine code
    hex_words = []
    annotated_listing = []

    for cur_pc, inst_str in clean_instructions:
        tokens = [t.strip() for t in re.split(r'[\s,]+', inst_str) if t.strip()]
        mnemonic = tokens[0].lower()
        args = tokens[1:]

        code = 0
        if mnemonic == 'nop':
            code = 0x00000013
        elif mnemonic == 'mret':
            code = 0x30200073
        elif mnemonic in ['csrw', 'csrrw']:
            csr = parse_csr(args[0])
            rs1 = parse_reg(args[1])
            code = enc_i(0x73, 0x1, 0, rs1, csr)
        elif mnemonic in ['csrs', 'csrrs']:
            csr = parse_csr(args[0])
            rs1 = parse_reg(args[1])
            code = enc_i(0x73, 0x2, 0, rs1, csr)
        elif mnemonic in ['csrc', 'csrrc']:
            csr = parse_csr(args[0])
            rs1 = parse_reg(args[1])
            code = enc_i(0x73, 0x3, 0, rs1, csr)
        elif mnemonic == 'lui':
            rd = parse_reg(args[0])
            imm = parse_imm(args[1])
            code = enc_u(0x37, rd, imm)
        elif mnemonic == 'addi':
            rd = parse_reg(args[0])
            rs1 = parse_reg(args[1])
            imm = parse_imm(args[2])
            code = enc_i(0x13, 0x0, rd, rs1, imm)
        elif mnemonic == 'slli':
            rd = parse_reg(args[0])
            rs1 = parse_reg(args[1])
            shamt = parse_imm(args[2]) & 0x1F
            code = enc_i(0x13, 0x1, rd, rs1, shamt)
        elif mnemonic == 'srli':
            rd = parse_reg(args[0])
            rs1 = parse_reg(args[1])
            shamt = parse_imm(args[2]) & 0x1F
            code = enc_i(0x13, 0x5, rd, rs1, shamt)
        elif mnemonic == 'sub':
            rd = parse_reg(args[0])
            rs1 = parse_reg(args[1])
            rs2 = parse_reg(args[2])
            code = enc_r(0x33, 0x0, 0x20, rd, rs1, rs2)
        elif mnemonic == 'or':
            rd = parse_reg(args[0])
            rs1 = parse_reg(args[1])
            rs2 = parse_reg(args[2])
            code = enc_r(0x33, 0x6, 0x00, rd, rs1, rs2)
        elif mnemonic == 'lw':
            rd = parse_reg(args[0])
            m = re.match(r'(-?\d+)\((.+)\)', args[1])
            offset = parse_imm(m.group(1))
            rs1 = parse_reg(m.group(2))
            code = enc_i(0x03, 0x2, rd, rs1, offset)
        elif mnemonic == 'sw':
            rs2 = parse_reg(args[0])
            m = re.match(r'(-?\d+)\((.+)\)', args[1])
            offset = parse_imm(m.group(1))
            rs1 = parse_reg(m.group(2))
            code = enc_s(0x23, 0x2, rs1, rs2, offset)
        elif mnemonic in ['beq', 'bne', 'blt', 'bge', 'bltu', 'bgeu', 'bgtu', 'bleu', 'ble']:
            if mnemonic == 'bgtu':
                rs1 = parse_reg(args[1])
                rs2 = parse_reg(args[0])
                funct3 = 0x6
            elif mnemonic == 'bleu':
                rs1 = parse_reg(args[1])
                rs2 = parse_reg(args[0])
                funct3 = 0x7
            elif mnemonic == 'ble':
                # a <= b <=> b >= a (bge b, a)
                rs1 = parse_reg(args[1])
                rs2 = parse_reg(args[0])
                funct3 = 0x5
            else:
                rs1 = parse_reg(args[0])
                rs2 = parse_reg(args[1])
                f_map = {'beq': 0x0, 'bne': 0x1, 'blt': 0x4, 'bge': 0x5, 'bltu': 0x6, 'bgeu': 0x7}
                funct3 = f_map[mnemonic]

            target_label = args[2]
            target_pc = labels[target_label]
            offset = target_pc - cur_pc
            code = enc_b(0x63, funct3, rs1, rs2, offset)
        elif mnemonic in ['j', 'jal']:
            if mnemonic == 'j':
                rd = 0
                target_label = args[0]
            else:
                rd = parse_reg(args[0])
                target_label = args[1]
            target_pc = labels[target_label]
            offset = target_pc - cur_pc
            code = enc_j(0x6F, rd, offset)
        else:
            raise ValueError(f"Unsupported mnemonic: '{mnemonic}' at PC 0x{cur_pc:04x}")

        hex_str = f"{code:08x}"
        hex_words.append(hex_str)
        annotated_listing.append(f"0x{cur_pc:04x}: {hex_str}   # {inst_str}")

    return hex_words, annotated_listing

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    src_file = os.path.join(script_dir, "src", "firmware.s")

    hex_words, listing = assemble_file(src_file)

    # Pad to 1024 words (4KB ROM) with NOP (00000013)
    full_mem = hex_words[:]
    while len(full_mem) < 1024:
        full_mem.append("00000013")

    targets = [
        os.path.join(script_dir, "test.mem"),
        os.path.join(project_root, "test.mem")
    ]

    for t in targets:
        with open(t, "w", encoding="utf-8") as f:
            f.write("\n".join(full_mem) + "\n")
        print(f"[build_mem.py] Generated: {t}")

    print(f"\n[build_mem.py] Assembled {len(hex_words)} instructions successfully.")
    print("--- First 15 Instructions ---")
    for l in listing[:15]:
        print(l)
    print("--- ISR Handler Instructions (0x0100) ---")
    for l in listing[64:75]:
        print(l)

if __name__ == "__main__":
    main()
