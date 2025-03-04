module core

// 0x00 NOP
fn test_nop_00() {
	// 1 machine cycle, 1 byte
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = u8(0x00) // opcode: 0x00
	// Given a NOP...
	assert cpu.pc == 0
	cpu.tick(false)
	// ... nothing should happen.
	// TODO: Add more nothing detection (check registers/flags??)
	assert cpu.pc == 1
	assert cpu.cycles == 1
}

// 0x01 LD BC,D16
fn test_ld_bc_d16_01() {
	// 3 machine cycles, 3 bytes
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = u8(0x01) // opcode: 0x01
	// Given a direct value of 0x1234 (4660)...
	ram.memory[0] = u8(0x34) // lsb of d16: 0x34 (52)
	ram.memory[1] = u8(0x12) // msb of d16: 0x12 (18)
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
fn test_ld_m_bc_a_02() {
	// 2 machine cycles, 1 byte
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = u8(0x02) // opcode: 0x02
	// This instruction will load the data from register A and load it into memory at address in
	// registers BC.
	// Given BC = 0xBEEF and A = 0x42...
	cpu.b = u8(0xBE)
	cpu.c = u8(0xEF)
	cpu.a = u8(0x42)
	assert cpu.pc == 0
	cpu.tick(false)
	cpu.tick(false)
	assert cpu.pc == 1
	// ... mem[0xBEEF] should equal 0x42.
	assert ram.read(0xBEEF) == 0x42
	assert cpu.cycles == 2
}

// 0x03 INC BC
fn test_inc_bc_03() {
	// 2 machine cycles, 1 byte
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = u8(0x03) // opcode: 0x03
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

fn test_inc_bc_03_between_bytes() {
	// 2 machine cycles, 1 byte
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = u8(0x03) // opcode: 0x03
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

fn test_inc_bc_03_wrap() {
	// 2 machine cycles, 1 byte
	mut ram := &core.Ram{}
	mut cpu := &core.Cpu{ram: ram}
	cpu.ir = u8(0x03) // opcode: 0x03
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
