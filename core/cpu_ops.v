module core

enum AddressMode as u8 {
	imp
	r_d16
	r_r
	mr_r
	r
	r_d8
	r_mr
	r_hli
	r_hld
	hli_r
	hld_r
	r_a8
	a8_r
	hl_spr
	d16
	d8
	d16_r
	mr_d8
	mr
	a16_r
	r_a16
}

enum RegisterType as u8 {
	none
	a
	f
	b
	c
	d
	e
	h
	l
	af
	bc
	de
	hl
	sp
	pc
}

const register_lookup := [
	RegisterType.b,
	RegisterType.c,
	RegisterType.d,
	RegisterType.e,
	RegisterType.h,
	RegisterType.l,
	RegisterType.hl,
	RegisterType.a
]

enum InstructionType as u8 {
	none
	nop
	ld
	inc
	dec
	rlca
	add
	rrca
	stop
	rla
	jr
	rra
	daa
	cpl
	scf
	ccf
	halt
	adc
	sub
	sbc
	and
	xor
	or
	cp
	pop
	jp
	push
	ret
	cb
	call
	reti
	ldh
	jphl
	di
	ei
	rst
	err
}

enum ConditionType as u8 {
	none
	nz
	z
	nc
	c
}

struct Instruction {
	in_type InstructionType
	mode AddressMode
	reg_1 RegisterType
	reg_2 RegisterType
	cond ConditionType
	param u8
}

const instructions = [
	// 0x0_
	Instruction{in_type: InstructionType.nop, mode: AddressMode.imp}, // 0x00 NOP
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_d16, reg_1: RegisterType.bc}, // 0x01 LD BC,D16
	Instruction{in_type: InstructionType.ld, mode: AddressMode.mr_r, reg_1: RegisterType.bc, reg_2: RegisterType.a}, // 0x02 LD [BC],A
	Instruction{in_type: InstructionType.inc, mode: AddressMode.r, reg_1: RegisterType.bc}, // 0x03 INC BC
	Instruction{in_type: InstructionType.inc, mode: AddressMode.r, reg_1: RegisterType.b}, // 0x04 INC B
	Instruction{in_type: InstructionType.dec, mode: AddressMode.r, reg_1: RegisterType.b}, // 0x05 DEC B
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_d8, reg_1: RegisterType.b}, // 0x06 LD B,D8
	Instruction{in_type: InstructionType.rlca}, // 0x07 RLCA
	Instruction{in_type: InstructionType.ld, mode: AddressMode.a16_r, reg_1: RegisterType.none, reg_2: RegisterType.sp}, // 0x08 LD [D16],SP
	Instruction{in_type: InstructionType.add, mode: AddressMode.r_r, reg_1: RegisterType.hl, reg_2: RegisterType.bc}, // 0x09 ADD HL,BC
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_mr, reg_1: RegisterType.a, reg_2: RegisterType.bc}, // 0x0A LD A,[BC]
	Instruction{in_type: InstructionType.dec, mode: AddressMode.r, reg_1: RegisterType.bc}, // 0x0B DEC BC
	Instruction{in_type: InstructionType.inc, mode: AddressMode.r, reg_1: RegisterType.c}, // 0x0C INC C
	Instruction{in_type: InstructionType.dec, mode: AddressMode.r, reg_1: RegisterType.c}, // 0x0D DEC C
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_d8, reg_1: RegisterType.c}, // 0x0E LD C,D8
	Instruction{in_type: InstructionType.rrca}, // 0x0F RRCA
	// 0x1_
	Instruction{in_type: InstructionType.stop}, // 0x10 STOP
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_d16, reg_1: RegisterType.de}, // 0x11 LD DE,D16
	Instruction{in_type: InstructionType.ld, mode: AddressMode.mr_r, reg_1: RegisterType.de, reg_2: RegisterType.a}, // 0x12 LD [DE],A
	Instruction{in_type: InstructionType.inc, mode: AddressMode.r, reg_1: RegisterType.de}, // 0x13 INC DE
	Instruction{in_type: InstructionType.inc, mode: AddressMode.r, reg_1: RegisterType.d}, // 0x14 INC D
	Instruction{in_type: InstructionType.dec, mode: AddressMode.r, reg_1: RegisterType.d}, // 0x15 DEC D
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_d8, reg_1: RegisterType.d}, // 0x16 LD D,D8
	Instruction{in_type: InstructionType.rla}, // 0x17 RLA
	Instruction{in_type: InstructionType.jr, mode: AddressMode.d8}, // 0x18 JR D8
	Instruction{in_type: InstructionType.add, mode: AddressMode.r_r, reg_1: RegisterType.hl, reg_2: RegisterType.de}, // 0x19 ADD HL,DE
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_mr, reg_1: RegisterType.a, reg_2: RegisterType.de}, // 0x1A LD A,[DE]
	Instruction{in_type: InstructionType.dec, mode: AddressMode.r, reg_1: RegisterType.de}, // 0x1B DEC DE
	Instruction{in_type: InstructionType.inc, mode: AddressMode.r, reg_1: RegisterType.e}, // 0x1C INC E
	Instruction{in_type: InstructionType.dec, mode: AddressMode.r, reg_1: RegisterType.e}, // 0x1D DEC E
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_d8, reg_1: RegisterType.e}, // 0x1E LD E,D8
	Instruction{in_type: InstructionType.rra}, // 0x1F RRA
	// 0x2_
	Instruction{in_type: InstructionType.jr, mode: AddressMode.d8, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.nz}, // 0x20 JR NZ,D8
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_d16, reg_1: RegisterType.hl}, // 0x21 LD HL,D16
	Instruction{in_type: InstructionType.ld, mode: AddressMode.hli_r, reg_1: RegisterType.hl, reg_2: RegisterType.a}, // 0x22 LD [HL+],A
	Instruction{in_type: InstructionType.inc, mode: AddressMode.r, reg_1: RegisterType.hl}, // 0x23 INC HL
	Instruction{in_type: InstructionType.inc, mode: AddressMode.r, reg_1: RegisterType.h}, // 0x24 INC H
	Instruction{in_type: InstructionType.dec, mode: AddressMode.r, reg_1: RegisterType.h}, // 0x25 DEC H
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_d8, reg_1: RegisterType.h}, // 0x26 LD H,D8
	Instruction{in_type: InstructionType.daa}, // 0x27 DAA
	Instruction{in_type: InstructionType.jr, mode: AddressMode.d8, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.z}, // 0x28 JR Z,D8
	Instruction{in_type: InstructionType.add, mode: AddressMode.r_r, reg_1: RegisterType.hl, reg_2: RegisterType.hl}, // 0x29 ADD HL,HL
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_hli, reg_1: RegisterType.a, reg_2: RegisterType.hl}, // 0x2A LD A,[HL+]
	Instruction{in_type: InstructionType.dec, mode: AddressMode.r, reg_1: RegisterType.hl}, // 0x2B DEC HL
	Instruction{in_type: InstructionType.inc, mode: AddressMode.r, reg_1: RegisterType.l}, // 0x2C INC L
	Instruction{in_type: InstructionType.dec, mode: AddressMode.r, reg_1: RegisterType.l}, // 0x2D DEC L
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_d8, reg_1: RegisterType.l}, // 0x2E LD L,D8
	Instruction{in_type: InstructionType.cpl}, // 0x2F CPL
	// 0x3_
	Instruction{in_type: InstructionType.jr, mode: AddressMode.d8, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.nc}, // 0x30 JR NC,D8
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_d16, reg_1: RegisterType.sp}, // 0x31 LD SP,D16
	Instruction{in_type: InstructionType.ld, mode: AddressMode.hld_r, reg_1: RegisterType.hl, reg_2: RegisterType.a}, // 0x32 LD [HL-],A
	Instruction{in_type: InstructionType.inc, mode: AddressMode.r, reg_1: RegisterType.sp}, // 0x33 INC SP
	Instruction{in_type: InstructionType.inc, mode: AddressMode.mr, reg_1: RegisterType.hl}, // 0x34 INC [HL]
	Instruction{in_type: InstructionType.dec, mode: AddressMode.mr, reg_1: RegisterType.hl}, // 0x35 DEC [Hl]
	Instruction{in_type: InstructionType.ld, mode: AddressMode.mr_d8, reg_1: RegisterType.hl}, // 0x36 LD [HL],D8
	Instruction{in_type: InstructionType.scf}, // 0x37 SCF
	Instruction{in_type: InstructionType.jr, mode: AddressMode.d8, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.c}, // 0x38 JR C,D8
	Instruction{in_type: InstructionType.add, mode: AddressMode.r_r, reg_1: RegisterType.hl, reg_2: RegisterType.sp}, // 0x39 ADD HL,SP
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_hld, reg_1: RegisterType.a, reg_2: RegisterType.hl}, // 0x3A LD A,[HL-]
	Instruction{in_type: InstructionType.dec, mode: AddressMode.r, reg_1: RegisterType.sp}, // 0x3B DEC SP
	Instruction{in_type: InstructionType.inc, mode: AddressMode.r, reg_1: RegisterType.a}, // 0x3C INC A
	Instruction{in_type: InstructionType.dec, mode: AddressMode.r, reg_1: RegisterType.a}, // 0x3D DEC A
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_d8, reg_1: RegisterType.a}, // 0x3E LD A,D8
	Instruction{in_type: InstructionType.ccf}, // 0x3F CCF
	// 0x4_
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.b, reg_2: RegisterType.b}, // 0x40 LD B,B
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.b, reg_2: RegisterType.c}, // 0x41 LD B,C
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.b, reg_2: RegisterType.d}, // 0x42 LD B,D
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.b, reg_2: RegisterType.e}, // 0x43 LD B,E
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.b, reg_2: RegisterType.h}, // 0x44 LD B,H
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.b, reg_2: RegisterType.l}, // 0x45 LD B,L
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_mr, reg_1: RegisterType.b, reg_2: RegisterType.hl}, // 0x46 LD B,[HL]
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.b, reg_2: RegisterType.a}, // 0x47 LD B,A
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.c, reg_2: RegisterType.b}, // 0x48 LD C,B
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.c, reg_2: RegisterType.c}, // 0x49 LD C,C
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.c, reg_2: RegisterType.d}, // 0x4A LD C,D
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.c, reg_2: RegisterType.e}, // 0x4B LD C,E
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.c, reg_2: RegisterType.h}, // 0x4C LD C,H
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.c, reg_2: RegisterType.l}, // 0x4D LD C,L
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_mr, reg_1: RegisterType.c, reg_2: RegisterType.hl}, // 0x4E LD C,[HL]
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.c, reg_2: RegisterType.a}, // 0x4F LD C,A
	// 0x5_
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.d, reg_2: RegisterType.b}, // 0x50 LD D,B
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.d, reg_2: RegisterType.c}, // 0x51 LD D,C
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.d, reg_2: RegisterType.d}, // 0x52 LD D,D
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.d, reg_2: RegisterType.e}, // 0x53 LD D,E
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.d, reg_2: RegisterType.h}, // 0x54 LD D,H
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.d, reg_2: RegisterType.l}, // 0x55 LD D,L
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_mr, reg_1: RegisterType.d, reg_2: RegisterType.hl}, // 0x56 LD D,[HL]
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.d, reg_2: RegisterType.a}, // 0x57 LD D,A
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.e, reg_2: RegisterType.b}, // 0x58 LD E,B
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.e, reg_2: RegisterType.c}, // 0x59 LD E,C
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.e, reg_2: RegisterType.d}, // 0x5A LD E,D
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.e, reg_2: RegisterType.e}, // 0x5B LD E,E
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.e, reg_2: RegisterType.h}, // 0x5C LD E,H
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.e, reg_2: RegisterType.l}, // 0x5D LD E,L
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_mr, reg_1: RegisterType.e, reg_2: RegisterType.hl}, // 0x5E LD E,[HL]
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.e, reg_2: RegisterType.a}, // 0x5F LD E,A
	// 0x6_
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.h, reg_2: RegisterType.b}, // 0x60 LD H,B
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.h, reg_2: RegisterType.c}, // 0x61 LD H,C
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.h, reg_2: RegisterType.d}, // 0x62 LD H,D
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.h, reg_2: RegisterType.e}, // 0x63 LD H,E
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.h, reg_2: RegisterType.h}, // 0x64 LD H,H
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.h, reg_2: RegisterType.l}, // 0x65 LD H,L
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_mr, reg_1: RegisterType.h, reg_2: RegisterType.hl}, // 0x66 LD H,[HL]
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.h, reg_2: RegisterType.a}, // 0x67 LD H,A
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.l, reg_2: RegisterType.b}, // 0x68 LD L,B
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.l, reg_2: RegisterType.c}, // 0x69 LD L,C
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.l, reg_2: RegisterType.d}, // 0x6A LD L,D
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.l, reg_2: RegisterType.e}, // 0x6B LD L,E
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.l, reg_2: RegisterType.h}, // 0x6C LD L,H
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.l, reg_2: RegisterType.l}, // 0x6D LD L,L
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_mr, reg_1: RegisterType.l, reg_2: RegisterType.hl}, // 0x6E LD L,[HL]
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.l, reg_2: RegisterType.a}, // 0x6F LD L,A
	// 0x7_
	Instruction{in_type: InstructionType.ld, mode: AddressMode.mr_r, reg_1: RegisterType.hl, reg_2: RegisterType.b}, // 0x70 LD [HL],B
	Instruction{in_type: InstructionType.ld, mode: AddressMode.mr_r, reg_1: RegisterType.hl, reg_2: RegisterType.c}, // 0x71 LD [HL],C
	Instruction{in_type: InstructionType.ld, mode: AddressMode.mr_r, reg_1: RegisterType.hl, reg_2: RegisterType.d}, // 0x72 LD [HL],D
	Instruction{in_type: InstructionType.ld, mode: AddressMode.mr_r, reg_1: RegisterType.hl, reg_2: RegisterType.e}, // 0x73 LD [HL],E
	Instruction{in_type: InstructionType.ld, mode: AddressMode.mr_r, reg_1: RegisterType.hl, reg_2: RegisterType.h}, // 0x74 LD [HL],H
	Instruction{in_type: InstructionType.ld, mode: AddressMode.mr_r, reg_1: RegisterType.hl, reg_2: RegisterType.l}, // 0x75 LD [HL],L
	Instruction{in_type: InstructionType.halt}, // 0x76 HALT
	Instruction{in_type: InstructionType.ld, mode: AddressMode.mr_r, reg_1: RegisterType.hl, reg_2: RegisterType.a}, // 0x77 LD [HL],A
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.b}, // 0x78 LD A,B
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.c}, // 0x79 LD A,C
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.d}, // 0x7A LD A,D
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.e}, // 0x7B LD A,E
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.h}, // 0x7C LD A,H
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.l}, // 0x7D LD A,L
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_mr, reg_1: RegisterType.a, reg_2: RegisterType.hl}, // 0x7E LD A,[HL]
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.a}, // 0x7F LD A,A
	// 0x8_
	Instruction{in_type: InstructionType.add, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.b}, // 0x80 ADD A,B
	Instruction{in_type: InstructionType.add, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.c}, // 0x81 ADD A,C
	Instruction{in_type: InstructionType.add, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.d}, // 0x82 ADD A,D
	Instruction{in_type: InstructionType.add, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.e}, // 0x83 ADD A,E
	Instruction{in_type: InstructionType.add, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.h}, // 0x84 ADD A,H
	Instruction{in_type: InstructionType.add, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.l}, // 0x85 ADD A,L
	Instruction{in_type: InstructionType.add, mode: AddressMode.r_mr, reg_1: RegisterType.a, reg_2: RegisterType.hl}, // 0x86 ADD A,[HL]
	Instruction{in_type: InstructionType.add, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.a}, // 0x87 ADD A,A
	Instruction{in_type: InstructionType.adc, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.b}, // 0x88 ADC A,B
	Instruction{in_type: InstructionType.adc, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.c}, // 0x89 ADC A,C
	Instruction{in_type: InstructionType.adc, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.d}, // 0x8A ADC A,D
	Instruction{in_type: InstructionType.adc, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.e}, // 0x8B ADC A,E
	Instruction{in_type: InstructionType.adc, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.h}, // 0x8C ADC A,H
	Instruction{in_type: InstructionType.adc, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.l}, // 0x8D ADC A,L
	Instruction{in_type: InstructionType.adc, mode: AddressMode.r_mr, reg_1: RegisterType.a, reg_2: RegisterType.hl}, // 0x8E ADC A,[HL]
	Instruction{in_type: InstructionType.adc, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.a}, // 0x8F ADC A,A
	// 0x9_
	Instruction{in_type: InstructionType.sub, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.b}, // 0x90 SUB A,B
	Instruction{in_type: InstructionType.sub, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.c}, // 0x91 SUB A,C
	Instruction{in_type: InstructionType.sub, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.d}, // 0x92 SUB A,D
	Instruction{in_type: InstructionType.sub, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.e}, // 0x93 SUB A,E
	Instruction{in_type: InstructionType.sub, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.h}, // 0x94 SUB A,H
	Instruction{in_type: InstructionType.sub, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.l}, // 0x95 SUB A,L
	Instruction{in_type: InstructionType.sub, mode: AddressMode.r_mr, reg_1: RegisterType.a, reg_2: RegisterType.hl}, // 0x96 SUB A,[HL]
	Instruction{in_type: InstructionType.sub, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.a}, // 0x97 SUB A,A
	Instruction{in_type: InstructionType.sbc, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.b}, // 0x98 SBC A,B
	Instruction{in_type: InstructionType.sbc, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.c}, // 0x99 SBC A,C
	Instruction{in_type: InstructionType.sbc, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.d}, // 0x9A SBC A,D
	Instruction{in_type: InstructionType.sbc, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.e}, // 0x9B SBC A,E
	Instruction{in_type: InstructionType.sbc, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.h}, // 0x9C SBC A,H
	Instruction{in_type: InstructionType.sbc, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.l}, // 0x9D SBC A,L
	Instruction{in_type: InstructionType.sbc, mode: AddressMode.r_mr, reg_1: RegisterType.a, reg_2: RegisterType.hl}, // 0x9E SBC A,[HL]
	Instruction{in_type: InstructionType.sbc, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.a}, // 0x9F SBC A,A
	// 0xA_
	Instruction{in_type: InstructionType.and, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.b}, // 0xA0 AND A,B
	Instruction{in_type: InstructionType.and, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.c}, // 0xA1 AND A,C
	Instruction{in_type: InstructionType.and, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.d}, // 0xA2 AND A,D
	Instruction{in_type: InstructionType.and, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.e}, // 0xA3 AND A,E
	Instruction{in_type: InstructionType.and, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.h}, // 0xA4 AND A,H
	Instruction{in_type: InstructionType.and, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.l}, // 0xA5 AND A,L
	Instruction{in_type: InstructionType.and, mode: AddressMode.r_mr, reg_1: RegisterType.a, reg_2: RegisterType.hl}, // 0xA6 AND A,[HL]
	Instruction{in_type: InstructionType.and, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.a}, // 0xA7 AND A,A
	Instruction{in_type: InstructionType.xor, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.b}, // 0xA8 XOR A,B
	Instruction{in_type: InstructionType.xor, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.c}, // 0xA9 XOR A,C
	Instruction{in_type: InstructionType.xor, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.d}, // 0xAA XOR A,D
	Instruction{in_type: InstructionType.xor, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.e}, // 0xAB XOR A,E
	Instruction{in_type: InstructionType.xor, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.h}, // 0xAC XOR A,H
	Instruction{in_type: InstructionType.xor, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.l}, // 0xAD XOR A,L
	Instruction{in_type: InstructionType.xor, mode: AddressMode.r_mr, reg_1: RegisterType.a, reg_2: RegisterType.hl}, // 0xAE XOR A,[HL]
	Instruction{in_type: InstructionType.xor, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.a}, // 0xAF XOR A,A
	// 0xB_
	Instruction{in_type: InstructionType.or, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.b}, // 0xB0 OR A,B
	Instruction{in_type: InstructionType.or, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.c}, // 0xB1 OR A,C
	Instruction{in_type: InstructionType.or, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.d}, // 0xB2 OR A,D
	Instruction{in_type: InstructionType.or, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.e}, // 0xB3 OR A,E
	Instruction{in_type: InstructionType.or, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.h}, // 0xB4 OR A,H
	Instruction{in_type: InstructionType.or, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.l}, // 0xB5 OR A,L
	Instruction{in_type: InstructionType.or, mode: AddressMode.r_mr, reg_1: RegisterType.a, reg_2: RegisterType.hl}, // 0xB6 OR A,[HL]
	Instruction{in_type: InstructionType.or, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.a}, // 0xB7 OR A,A
	Instruction{in_type: InstructionType.cp, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.b}, // 0xB8 CP A,B
	Instruction{in_type: InstructionType.cp, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.c}, // 0xB9 CP A,C
	Instruction{in_type: InstructionType.cp, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.d}, // 0xBA CP A,D
	Instruction{in_type: InstructionType.cp, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.e}, // 0xBB CP A,E
	Instruction{in_type: InstructionType.cp, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.h}, // 0xBC CP A,H
	Instruction{in_type: InstructionType.cp, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.l}, // 0xBD CP A,L
	Instruction{in_type: InstructionType.cp, mode: AddressMode.r_mr, reg_1: RegisterType.a, reg_2: RegisterType.hl}, // 0xBE CP A,[HL]
	Instruction{in_type: InstructionType.cp, mode: AddressMode.r_r, reg_1: RegisterType.a, reg_2: RegisterType.a}, // 0xBF CP A,A
	// 0xC_
	Instruction{in_type: InstructionType.ret, mode: AddressMode.imp, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.nz}, // 0xC0 RET NZ
	Instruction{in_type: InstructionType.pop, mode: AddressMode.r, reg_1: RegisterType.bc}, // 0xC1 POP BC
	Instruction{in_type: InstructionType.jp, mode: AddressMode.d16, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.nz}, // 0xC2 JP NZ,D16
	Instruction{in_type: InstructionType.jp, mode: AddressMode.d16}, // 0xC3 JP D16
	Instruction{in_type: InstructionType.call, mode: AddressMode.d16, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.nz}, // 0xC4 CALL NZ,D16
	Instruction{in_type: InstructionType.push, mode: AddressMode.r, reg_1: RegisterType.bc}, // 0xC5 PUSH BC
	Instruction{in_type: InstructionType.add, mode: AddressMode.r_d8, reg_1: RegisterType.a}, // 0xC6 ADD A,D8
	Instruction{in_type: InstructionType.rst, mode: AddressMode.imp, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.none, param: 0x00}, // 0xC7 RST $00
	Instruction{in_type: InstructionType.ret, mode: AddressMode.imp, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.z}, // 0xC8 RET Z
	Instruction{in_type: InstructionType.ret}, // 0xC9 RET
	Instruction{in_type: InstructionType.jp, mode: AddressMode.d16, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.z}, // 0xCA JP Z,D16
	Instruction{in_type: InstructionType.cb, mode: AddressMode.d8}, // 0xCB CB PREFIX
	Instruction{in_type: InstructionType.call, mode: AddressMode.d16, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.z}, // 0xCC CALL Z,D16
	Instruction{in_type: InstructionType.call, mode: AddressMode.d16}, // 0xCD CALL D16
	Instruction{in_type: InstructionType.adc, mode: AddressMode.r_d8, reg_1: RegisterType.a}, // 0xCE ADC A,D8
	Instruction{in_type: InstructionType.rst, mode: AddressMode.imp, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.none, param: 0x08}, // 0xCF RST $08
	// 0xD_
	Instruction{in_type: InstructionType.ret, mode: AddressMode.imp, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.nc}, // 0xD0 RET NC
	Instruction{in_type: InstructionType.pop, mode: AddressMode.r, reg_1: RegisterType.de}, // 0xD1 POP DE
	Instruction{in_type: InstructionType.jp, mode: AddressMode.d16, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.nc}, // 0xD2 JP NC,D16
	Instruction{in_type: InstructionType.none}, // 0xD3 INVALID
	Instruction{in_type: InstructionType.call, mode: AddressMode.d16, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.nc}, // 0xD4 CALL NC,D16
	Instruction{in_type: InstructionType.push, mode: AddressMode.r, reg_1: RegisterType.de}, // 0xD5 PUSH DE
	Instruction{in_type: InstructionType.sub, mode: AddressMode.r_d8, reg_1: RegisterType.a}, // 0xD6 SUB A,D8
	Instruction{in_type: InstructionType.rst, mode: AddressMode.imp, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.none, param: 0x10}, // 0xD7 RST $10
	Instruction{in_type: InstructionType.ret, mode: AddressMode.imp, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.c}, // 0xD8 RET C
	Instruction{in_type: InstructionType.reti}, // 0xD9 RETI
	Instruction{in_type: InstructionType.jp, mode: AddressMode.d16, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.c}, // 0xDA JP C,D16
	Instruction{in_type: InstructionType.none}, // 0xDB INVALID
	Instruction{in_type: InstructionType.call, mode: AddressMode.d16, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.c}, // 0xDC CALL C,D16
	Instruction{in_type: InstructionType.none}, // 0xDD INVALID
	Instruction{in_type: InstructionType.sbc, mode: AddressMode.r_d8, reg_1: RegisterType.a}, // 0xDE SBC A,D8
	Instruction{in_type: InstructionType.rst, mode: AddressMode.imp, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.none, param: 0x18}, // 0xDF RST $18
	// 0xE_
	Instruction{in_type: InstructionType.ldh, mode: AddressMode.a8_r, reg_1: RegisterType.none, reg_2: RegisterType.a}, // 0xE0 LDH [a8],A
	Instruction{in_type: InstructionType.pop, mode: AddressMode.r, reg_1: RegisterType.hl}, // 0xE1 POP HL
	Instruction{in_type: InstructionType.ldh, mode: AddressMode.mr_r, reg_1: RegisterType.c, reg_2: RegisterType.a}, // 0xE2 LDH [C],A
	Instruction{in_type: InstructionType.none}, // 0xE3 INVALID
	Instruction{in_type: InstructionType.none}, // 0xE4 INVALID
	Instruction{in_type: InstructionType.push, mode: AddressMode.r, reg_1: RegisterType.hl}, // 0xE5 PUSH HL
	Instruction{in_type: InstructionType.and, mode: AddressMode.r_d8, reg_1: RegisterType.a}, // 0xE6 AND A,D8
	Instruction{in_type: InstructionType.rst, mode: AddressMode.imp, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.none, param: 0x20}, // 0xE7 RST $20
	Instruction{in_type: InstructionType.add, mode: AddressMode.r_d8, reg_1: RegisterType.sp}, // 0xE8 ADD SP,D8
	Instruction{in_type: InstructionType.jp, mode: AddressMode.r, reg_1: RegisterType.hl}, // 0xE9 JP HL
	Instruction{in_type: InstructionType.ld, mode: AddressMode.a16_r, reg_1: RegisterType.none, reg_2: RegisterType.a}, // 0xEA DL [a16],A
	Instruction{in_type: InstructionType.none}, // 0xEB INVALID
	Instruction{in_type: InstructionType.none}, // 0xEC INVALID
	Instruction{in_type: InstructionType.none}, // 0xED INVALID
	Instruction{in_type: InstructionType.xor, mode: AddressMode.r_d8, reg_1: RegisterType.a}, // 0xEE XOR A,D8
	Instruction{in_type: InstructionType.rst, mode: AddressMode.imp, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.none, param: 0x28}, // 0xEF RST $28
	// 0xF_
	Instruction{in_type: InstructionType.ldh, mode: AddressMode.r_a8, reg_1: RegisterType.a}, // 0xF0 LDH A,[a8]
	Instruction{in_type: InstructionType.pop, mode: AddressMode.r, reg_1: RegisterType.af}, // 0xF1 POP AF
	Instruction{in_type: InstructionType.ldh, mode: AddressMode.r_mr, reg_1: RegisterType.a, reg_2: RegisterType.c}, // 0xF2 LDH A,[C]
	Instruction{in_type: InstructionType.di}, // 0xF3 DI
	Instruction{in_type: InstructionType.none}, // 0xF4 INVALID
	Instruction{in_type: InstructionType.push, mode: AddressMode.r, reg_1: RegisterType.af}, // 0xF5 PUSH AF
	Instruction{in_type: InstructionType.or, mode: AddressMode.r_d8, reg_1: RegisterType.a}, // 0xF6 OR A,D8
	Instruction{in_type: InstructionType.rst, mode: AddressMode.imp, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.none, param: 0x30}, // 0xF7 RST $30
	Instruction{in_type: InstructionType.ld, mode: AddressMode.hl_spr, reg_1: RegisterType.hl, reg_2: RegisterType.sp}, // 0xF8 LD HL,SP + D8
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_r, reg_1: RegisterType.sp, reg_2: RegisterType.hl}, // 0xF9 LD SP,HL
	Instruction{in_type: InstructionType.ld, mode: AddressMode.r_a16, reg_1: RegisterType.a}, // 0xFA LD A,[a16]
	Instruction{in_type: InstructionType.ei}, // 0xFB EI
	Instruction{in_type: InstructionType.none}, // 0xFC INVALID
	Instruction{in_type: InstructionType.none}, // 0xFD INVALID
	Instruction{in_type: InstructionType.cp, mode: AddressMode.r_d8, reg_1: RegisterType.a}, // 0xFE CP A,D8
	Instruction{in_type: InstructionType.rst, mode: AddressMode.imp, reg_1: RegisterType.none, reg_2: RegisterType.none, cond: ConditionType.none, param: 0x38}, // 0xFF RST $38
]

