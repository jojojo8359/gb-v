module core

// 0x00 NOP
fn test_00_nop() {
	// 1 machine cycle, 1 byte
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x00 // opcode: 0x00
	// Given a NOP...
	assert cpu.pc == 0
	cpu.tick(false)
	// ... nothing should happen.
	// TODO: Add more nothing detection (check registers/flags??)
	assert cpu.pc == 1
	assert cpu.cycles == 1
}

// 0x01 LD BC,D16
fn test_01_ld_bc_d16() {
	// 3 machine cycles, 3 bytes
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x01 // opcode: 0x01
	// Given a direct value of 0x1234 (4660)...
	ram.memory[0] = 0x34 // lsb of d16: 0x34 (52)
	ram.memory[1] = 0x12 // msb of d16: 0x12 (18)
	assert cpu.pc == 0
	cpu.tick(false)
	cpu.tick(false)
	cpu.tick(false)
	assert cpu.pc == 3
	// ... BC should equal 0x1234.
	assert cpu.b == 0x12
	assert cpu.c == 0x34
	assert cpu.cycles == 3
}

// 0x02 LD [BC],A
fn test_02_ld_m_bc_a() {
	// 2 machine cycles, 1 byte
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x02 // opcode: 0x02
	// This instruction will load the data from register A and load it into memory at address in
	// registers BC.
	// Given BC = 0xBEEF and A = 0x42...
	cpu.b = 0xBE
	cpu.c = 0xEF
	cpu.a = 0x42
	assert cpu.pc == 0
	cpu.tick(false)
	cpu.tick(false)
	assert cpu.pc == 1
	// ... mem[0xBEEF] should equal 0x42.
	// TODO: Change to raw RAM read
	assert ram.read(0xBEEF) == 0x42
	assert cpu.cycles == 2
}

// 0x03 INC BC
fn test_03_inc_bc() {
	// 2 machine cycles, 1 byte
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x03 // opcode: 0x03
	// Given BC = 0...
	assert cpu.b == 0
	assert cpu.c == 0
	assert cpu.pc == 0
	cpu.tick(false)
	cpu.tick(false)
	assert cpu.pc == 1
	// ... BC should equal 1.
	assert cpu.b == 0
	assert cpu.c == 1
	assert cpu.cycles == 2
}

fn test_03_inc_bc_between_bytes() {
	// 2 machine cycles, 1 byte
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x03 // opcode: 0x03
	cpu.c = 0xFF
	// Given BC = 0x00FF...
	assert cpu.b == 0x00
	assert cpu.c == 0xFF
	assert cpu.pc == 0
	cpu.tick(false)
	cpu.tick(false)
	assert cpu.pc == 1
	// ... BC should equal 0x0100.
	assert cpu.b == 0x01
	assert cpu.c == 0x00
	assert cpu.cycles == 2
}

fn test_03_inc_bc_wrap() {
	// 2 machine cycles, 1 byte
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x03 // opcode: 0x03
	cpu.b = 0xFF
	cpu.c = 0xFF
	// Given BC = 0xFFFF...
	assert cpu.b == 0xFF
	assert cpu.c == 0xFF
	assert cpu.pc == 0
	cpu.tick(false)
	cpu.tick(false)
	assert cpu.pc == 1
	// ... BC should equal 0x0000.
	assert cpu.b == 0x00
	assert cpu.c == 0x00
	assert cpu.cycles == 2
}

// 0x04 INC B
fn test_04_inc_b() {
	// 1 machine cycle, 1 byte
	// Z/H set by operation, N = 0
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x04 // opcode: 0x04
	// Given B = 0x00...
	assert cpu.b == 0x00
	assert cpu.pc == 0
	cpu.tick(false)
	assert cpu.pc == 1
	// ... B should equal 0x01.
	assert cpu.b == 0x01
	assert cpu.get_z() == false
	assert cpu.get_h() == false
	assert cpu.get_n() == false
	assert cpu.cycles == 1
}

fn test_04_inc_b_wrap_to_zero() {
	// 1 machine cycle, 1 byte
	// Z/H set by operation, N = 0
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x04 // opcode: 0x04
	cpu.b = 0xFF
	// Given B = 0xFF...
	assert cpu.b == 0xFF
	assert cpu.pc == 0
	cpu.tick(false)
	assert cpu.pc == 1
	// ... B should equal 0x00.
	assert cpu.b == 0x00
	assert cpu.get_z() == true
	assert cpu.get_h() == true
	assert cpu.get_n() == false
	assert cpu.cycles == 1
}

// 0x05 DEC B
fn test_05_dec_b() {
	// 1 machine cycle, 1 byte
	// Z/H set by operation, N = 1
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x05 // opcode: 0x05
	cpu.b = 0x01
	// Given B = 0x01...
	assert cpu.b == 0x01
	assert cpu.pc == 0
	cpu.tick(false)
	assert cpu.pc == 1
	// ... B should equal 0x00.
	assert cpu.b == 0x00
	assert cpu.get_z() == true
	assert cpu.get_h() == false
	assert cpu.get_n() == true
	assert cpu.cycles == 1
}

fn test_05_dec_b_wrap() {
	// 1 machine cycle, 1 byte
	// Z/H set by operation, N = 1
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x05 // opcode: 0x05
	// Given B = 0x00...
	assert cpu.b == 0x00
	assert cpu.pc == 0
	cpu.tick(false)
	assert cpu.pc == 1
	// ... B should equal 0xFF.
	assert cpu.b == 0xFF
	assert cpu.get_z() == false
	assert cpu.get_h() == true
	assert cpu.get_n() == true
	assert cpu.cycles == 1
}

// 0x06 LD B,D8
fn test_06_ld_b_d8() {
	// 2 machine cycles, 2 bytes
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x06 // opcode: 0x06
	ram.memory[0] = 0x42 // d8 = 0x42 (66)
	// Given D8 = 0x42...
	assert cpu.pc == 0
	cpu.tick(false)
	cpu.tick(false)
	assert cpu.pc == 2
	// ... B should equal 0x42.
	assert cpu.b == 0x42
	assert cpu.cycles == 2
}

// 0x07 RLCA
fn test_07_rlca() {
	// 1 machine cycle, 1 byte
	// C set by operation, N, H, Z = 0
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x07 // opcode: 0x07
	cpu.a = 0x25
	// Given A = 0x25 (0010 0101)...
	assert cpu.a == 0x25
	assert cpu.pc == 0
	cpu.tick(false)
	assert cpu.pc == 1
	// ... A should equal 0x4A (0100 1010).
	assert cpu.a == 0x4A
	assert cpu.get_c() == false
	assert cpu.get_h() == false
	assert cpu.get_z() == false
	assert cpu.get_n() == false
	assert cpu.cycles == 1
}

fn test_07_rlca_carry() {
	// 1 machine cycle, 1 byte
	// C set by operation, N, H, Z = 0
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x07 // opcode: 0x07
	cpu.a = 0xC0
	// Given A = 0xC0 (1100 0000)...
	assert cpu.a == 0xC0
	assert cpu.pc == 0
	cpu.tick(false)
	assert cpu.pc == 1
	// ... A should equal 0x81 (1000 0001).
	assert cpu.a == 0x81
	assert cpu.get_c() == true
	assert cpu.get_h() == false
	assert cpu.get_z() == false
	assert cpu.get_n() == false
	assert cpu.cycles == 1
}

// 0x08 LD [D16],SP
fn test_08_ld_m_d16_sp() {
	// 5 machine cycles, 3 bytes
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x08 // opcode: 0x08
	ram.memory[0] = 0xEF // lsb of d16
	ram.memory[1] = 0xBE // msb of d16
	cpu.sp = 0xDEAD
	// Given D16 = 0xBEEF and SP = 0xDEAD...
	assert cpu.pc == 0
	assert cpu.sp == 0xDEAD
	cpu.tick(false)
	cpu.tick(false)
	cpu.tick(false)
	cpu.tick(false)
	cpu.tick(false)
	assert cpu.pc == 3
	// ... RAM[0xBEEF-0xBEF0] should equal 0xDEAD.
	assert ram.memory[0xBEEF] == 0xAD
	assert ram.memory[0xBEF0] == 0xDE
	assert cpu.cycles == 5
}

// 0x09 ADD HL,BC
fn test_09_add_hl_bc() {
	// 2 machine cycles, 1 byte
	// C and H set by operation, N = 0
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x09 // opcode: 0x09
	cpu.c = 0x01
	// Given HL = 0x0000 and BC = 0x0001...
	assert cpu.pc == 0
	assert cpu.h == 0x00
	assert cpu.l == 0x00
	assert cpu.b == 0x00
	assert cpu.c == 0x01
	cpu.tick(false)
	cpu.tick(false)
	assert cpu.pc == 1
	// ... HL should equal 0x0001.
	assert cpu.h == 0x00
	assert cpu.l == 0x01
	assert cpu.get_c() == false
	assert cpu.get_h() == false
	assert cpu.get_n() == false
	assert cpu.cycles == 2
}

fn test_09_add_hl_bc_between_bytes() {
	// 2 machine cycles, 1 byte
	// C and H set by operation, N = 0
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x09 // opcode: 0x09
	cpu.l = 0xF0
	cpu.c = 0x21
	// Given HL = 0x00F0 and BC = 0x0021...
	assert cpu.pc == 0
	assert cpu.h == 0x00
	assert cpu.l == 0xF0
	assert cpu.b == 0x00
	assert cpu.c == 0x21
	cpu.tick(false)
	cpu.tick(false)
	assert cpu.pc == 1
	// ... HL should equal 0x0111.
	assert cpu.h == 0x01
	assert cpu.l == 0x11
	// TODO: Check flag math
	assert cpu.get_c() == false
	assert cpu.get_h() == true
	assert cpu.get_n() == false
	assert cpu.cycles == 2
}

fn test_09_add_hl_bc_wrap() {
	// 2 machine cycles, 1 byte
	// C and H set by operation, N = 0
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x09 // opcode: 0x09
	cpu.h = 0xFF
	cpu.l = 0xFF
	cpu.c = 0x01
	// Given HL = 0xFFFF and BC = 0x0001...
	assert cpu.pc == 0
	assert cpu.h == 0xFF
	assert cpu.l == 0xFF
	assert cpu.b == 0x00
	assert cpu.c == 0x01
	cpu.tick(false)
	cpu.tick(false)
	assert cpu.pc == 1
	// ... HL should equal 0x0000.
	assert cpu.h == 0x00
	assert cpu.l == 0x00
	// TODO: Check flag math
	assert cpu.get_c() == true
	assert cpu.get_h() == true
	assert cpu.get_n() == false
	assert cpu.cycles == 2
}

// 0x0A LD A,[BC]
fn test_0a_ld_a_m_bc() {
	// 2 machine cycles, 1 byte
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x0A // opcode: 0x0A
	cpu.b = 0xBE
	cpu.c = 0xEF
	ram.memory[0xBEEF] = 0x42
	// Given BC = 0xBEEF and RAM[0xBEEF] = 0x42...
	assert cpu.pc == 0
	assert cpu.b == 0xBE
	assert cpu.c == 0xEF
	assert ram.memory[0xBEEF] == 0x42
	cpu.tick(false)
	cpu.tick(false)
	assert cpu.pc == 1
	// ... A should equal 0x42.
	assert cpu.a == 0x42
	assert cpu.cycles == 2
}

// 0x0B DEC BC
fn test_0b_dec_bc() {
	// 2 machine cycles, 1 byte
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x0B // opcode: 0x0B
	cpu.c = 0x01
	// Given BC = 1...
	assert cpu.pc == 0
	assert cpu.b == 0x00
	assert cpu.c == 0x01
	cpu.tick(false)
	cpu.tick(false)
	assert cpu.pc == 1
	// ... BC should equal 0.
	assert cpu.b == 0
	assert cpu.c == 0
	assert cpu.cycles == 2
}

fn test_0b_dec_bc_between_bytes() {
	// 2 machine cycles, 1 byte
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x0B // opcode: 0x0B
	cpu.b = 0x01
	// Given BC = 0x0100...
	assert cpu.b == 0x01
	assert cpu.c == 0x00
	assert cpu.pc == 0
	cpu.tick(false)
	cpu.tick(false)
	assert cpu.pc == 1
	// ... BC should equal 0x00FF.
	assert cpu.b == 0x00
	assert cpu.c == 0xFF
	assert cpu.cycles == 2
}

fn test_0b_dec_bc_wrap() {
	// 2 machine cycles, 1 byte
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x0B // opcode: 0x0B
	// Given BC = 0x0000...
	assert cpu.b == 0x00
	assert cpu.c == 0x00
	assert cpu.pc == 0
	cpu.tick(false)
	cpu.tick(false)
	assert cpu.pc == 1
	// ... BC should equal 0xFFFF.
	assert cpu.b == 0xFF
	assert cpu.c == 0xFF
	assert cpu.cycles == 2
}

// 0x0C INC C
fn test_0c_inc_c() {
	// 1 machine cycle, 1 byte
	// Z/H set by operation, N = 0
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x0C // opcode: 0x0C
	// Given C = 0x00...
	assert cpu.c == 0x00
	assert cpu.pc == 0
	cpu.tick(false)
	assert cpu.pc == 1
	// ... C should equal 0x01.
	assert cpu.c == 0x01
	assert cpu.get_z() == false
	assert cpu.get_h() == false
	assert cpu.get_n() == false
	assert cpu.cycles == 1
}

fn test_0c_inc_c_wrap_to_zero() {
	// 1 machine cycle, 1 byte
	// Z/H set by operation, N = 0
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x0C // opcode: 0x0C
	cpu.c = 0xFF
	// Given C = 0xFF...
	assert cpu.c == 0xFF
	assert cpu.pc == 0
	cpu.tick(false)
	assert cpu.pc == 1
	// ... C should equal 0x00.
	assert cpu.c == 0x00
	assert cpu.get_z() == true
	assert cpu.get_h() == true
	assert cpu.get_n() == false
	assert cpu.cycles == 1
}

// 0x0D DEC C
fn test_0d_dec_c() {
	// 1 machine cycle, 1 byte
	// Z/H set by operation, N = 1
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x0D // opcode: 0x0D
	cpu.c = 0x01
	// Given C = 0x01...
	assert cpu.c == 0x01
	assert cpu.pc == 0
	cpu.tick(false)
	assert cpu.pc == 1
	// ... C should equal 0x00.
	assert cpu.c == 0x00
	assert cpu.get_z() == true
	assert cpu.get_h() == false
	assert cpu.get_n() == true
	assert cpu.cycles == 1
}

fn test_0d_dec_c_wrap() {
	// 1 machine cycle, 1 byte
	// Z/H set by operation, N = 1
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x0D // opcode: 0x0D
	// Given C = 0x00...
	assert cpu.c == 0x00
	assert cpu.pc == 0
	cpu.tick(false)
	assert cpu.pc == 1
	// ... C should equal 0xFF.
	assert cpu.c == 0xFF
	assert cpu.get_z() == false
	assert cpu.get_h() == true
	assert cpu.get_n() == true
	assert cpu.cycles == 1
}

// 0x0E LD C,D8
fn test_0e_ld_c_d8() {
	// 2 machine cycles, 2 bytes
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x0E // opcode: 0x0E
	ram.memory[0] = 0x42 // d8 = 0x42 (66)
	// Given D8 = 0x42...
	assert cpu.pc == 0
	cpu.tick(false)
	cpu.tick(false)
	assert cpu.pc == 2
	// ... B should equal 0x42.
	assert cpu.c == 0x42
	assert cpu.cycles == 2
}

// 0x0F RRCA
fn test_0f_rrca() {
	// 1 machine cycle, 1 byte
	// C set by operation, N, H, Z = 0
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x0F // opcode: 0x0F
	cpu.a = 0x24
	// Given A = 0x24 (0010 0100)...
	assert cpu.a == 0x24
	assert cpu.pc == 0
	cpu.tick(false)
	assert cpu.pc == 1
	// ... A should equal 0x12 (0001 0010).
	assert cpu.a == 0x12
	assert cpu.get_c() == false
	assert cpu.get_h() == false
	assert cpu.get_z() == false
	assert cpu.get_n() == false
	assert cpu.cycles == 1
}

fn test_0f_rrca_carry() {
	// 1 machine cycle, 1 byte
	// C set by operation, N, H, Z = 0
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = 0x0F // opcode: 0x0F
	cpu.a = 0x81
	// Given A = 0x81 (1000 0001)...
	assert cpu.a == 0x81
	assert cpu.pc == 0
	cpu.tick(false)
	assert cpu.pc == 1
	// ... A should equal 0xC0 (1100 0000).
	assert cpu.a == 0xC0
	assert cpu.get_c() == true
	assert cpu.get_h() == false
	assert cpu.get_z() == false
	assert cpu.get_n() == false
	assert cpu.cycles == 1
}
