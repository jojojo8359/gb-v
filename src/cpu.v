module main

import math

struct Cpu {
mut:
	ram ?&Ram
pub mut:
	a u8
	f u8
	b u8
	c u8
	d u8
	e u8
	h u8
	l u8
	ir u8
	ie u8
	sp u16
	pc u16
	cycles u64
	m u8 = 1
	cb u8
	// temp IDC registers?
	z u8
	w u8
}

pub fn (c Cpu) str() string {
	return '{a=${c.a}, f=${c.f}, b=${c.b}, c=${c.c}, d=${c.d}, e=${c.e}, h=${c.h}, l=${c.l}, ir=${c.ir}/0x${c.ir:x}, ie=${c.ie}, sp=${c.sp}/0x${c.sp:x}, pc=${c.pc}/0x${c.pc:x}, m=${c.m}, flags(ZNHC)=${u8(c.get_z())}${u8(c.get_n())}${u8(c.get_h())}${u8(c.get_c())}}'
}

fn combine_u8(upper u8, lower u8) u16 {
	return (u16(upper) << 8) + lower
}

fn split_u16(v u16) (u8, u8) {
	return u8(v >> 8), u8(v)
}

const z_bit := 7
const n_bit := 6
const h_bit := 5
const c_bit := 4

@[inline]
fn (c Cpu) get_z() bool {
	return (c.f & (1 << z_bit)) > 0
}

@[inline]
fn (c Cpu) get_n() bool {
	return (c.f & (1 << n_bit)) > 0
}

@[inline]
fn (c Cpu) get_h() bool {
	return (c.f & (1 << h_bit)) > 0
}

@[inline]
fn (c Cpu) get_c() bool {
	return (c.f & (1 << c_bit)) > 0
}

@[inline]
fn (mut c Cpu) set_flag(v bool, n u8) {
	if v { c.f |= (1 << n) } else { c.f &= ~(1 << n) }
}

@[inline]
fn (mut c Cpu) set_z(v bool) {
	c.set_flag(v, z_bit)
}

@[inline]
fn (mut c Cpu) set_n(v bool) {
	c.set_flag(v, n_bit)
}

@[inline]
fn (mut c Cpu) set_h(v bool) {
	c.set_flag(v, h_bit)
}

@[inline]
fn (mut c Cpu) set_c(v bool) {
	c.set_flag(v, c_bit)
}

@[inline]
fn (mut c Cpu) set_hl(v u16) {
	c.h, c.l = split_u16(v)
}

fn (c Cpu) read_reg8(rt RegisterType) u8 {
	match rt {
		.a { return c.a }
		.b { return c.b }
		.c { return c.c }
		.d { return c.d }
		.e { return c.e }
		.f { return c.f }
		.h { return c.h }
		.l { return c.l }
		else {
			panic("Given register type ${rt} is not 8-bit!")
		}
	}
}

fn (mut c Cpu) set_reg8(rt RegisterType, v u8) {
	match rt {
		.a { c.a = v }
		.b { c.b = v }
		.c { c.c = v }
		.d { c.d = v }
		.e { c.e = v }
		.f { c.f = v }
		.h { c.h = v }
		.l { c.l = v }
		else {
			panic("Given register type ${rt} is not 8-bit!")
		}
	}
}

fn (c Cpu) read_reg16(rt RegisterType) u16 {
	match rt {
		.af { return combine_u8(c.a, c.f) }
		.bc { return combine_u8(c.b, c.c) }
		.de { return combine_u8(c.d, c.e) }
		.hl { return combine_u8(c.h, c.l) }
		.sp { return c.sp }
		.pc { return c.pc }
		else {
			panic("Given register type ${rt} is not 16-bit!")
		}
	}
}

fn (mut c Cpu) set_reg16(rt RegisterType, v u16) {
	match rt {
		.af { c.a, c.f = split_u16(v) }
		.bc { c.b, c.c = split_u16(v) }
		.de { c.d, c.e = split_u16(v) }
		.hl { c.h, c.l = split_u16(v) }
		.sp { c.sp = v }
		.pc { c.pc = v }
		else {
			panic("Given register type ${rt} is not 16-bit!")
		}
	}
}

fn (c Cpu) cond_true(ct ConditionType) bool {
	match ct {
		.nz { return c.get_z() == false }
		.z { return c.get_z() == true }
		.nc { return c.get_c() == false }
		.c { return c.get_c() == true }
		else {
			panic("Given condition type ${ct} is not valid for checking flags in non-cb instructions!")
		}
	}
}

fn (mut c Cpu) tick(pr bool) {
	mut next_inst := instructions[c.ir]
	match next_inst.in_type {
		.none {
			println("Invalid instruction!")
			// Lock CPU
		}
		.nop {
			if pr { println("nop called") }
			c.ir = c.fetch_cycle(c.pc)
			c.pc++
			c.m = 0
		}
		.ld {
			if pr { println("ld called") }
			match next_inst.mode {
				.r_d16 {
					match c.m {
						1 {
							c.z = c.read_memory(c.pc)
							c.pc++
						}
						2 {
							c.w = c.read_memory(c.pc)
							c.pc++
						}
						3 {
							c.ir = c.fetch_cycle(c.pc)
							c.pc++
							match next_inst.reg_1 {
								.bc {
									c.b = c.w
									c.c = c.z
								}
								.hl {
									c.h = c.w
									c.l = c.z
								}
								.sp {
									c.sp = combine_u8(c.w, c.z)
								}
								else {
									println("ld: r,d16 mode: cycle 3: invalid register ${next_inst.reg_1}")
								}
							}
							c.m = 0
						}
						else {
							println("ld: r,d16 mode: invalid cycle ${c.m}")
						}
					}
				}
				.mr_r {
					println("mr,r not implemented")
				}
				.r_d8 {
					println("r,d8 not implemented")
				}
				.a16_r {
					println("a16,r not implemented")
				}
				.r_mr {
					println("r,mr not implemented")
				}
				.hli_r {
					println("hli,r not implemented")
				}
				.hld_r {
					match c.m {
						1 {
							c.write_memory(c.read_reg16(RegisterType.hl), c.a)
							// println("mem[${c.get_hl():x}]=${c.a:x}")
							c.set_hl(c.read_reg16(RegisterType.hl) - 1)
						}
						2 {
							c.ir = c.fetch_cycle(c.pc)
							c.pc++
							c.m = 0
						}
						else {
							println("ld: hld,r mode: invalid cycle ${c.m}")
						}
					}
				}
				else {
					println("ld: invalid mode ${next_inst.mode}")
				}
			}
		}
		.inc {
			if pr { println("inc called (not implemented)") }
		}
		.dec {
			if pr { println("dec called (not implemented)") }
		}
		.rlca {
			if pr { println("rlca called (not implemented)") }
		}
		.add {
			if pr { println("add called (not implemented)") }
		}
		.rrca {
			if pr { println("rrca called (not implemented)") }
		}
		.stop {
			if pr { println("stop called (not implemented)") }
		}
		.rla {
			if pr { println("rla called (not implemented)") }
		}
		.jr {
			if pr { println("jr called") }
			match c.m {
				1 {
					c.z = c.read_memory(c.pc)
					c.pc++
				}
				2 {
					if c.cond_true(next_inst.cond) {
						// TODO: Make sure this math works
						offset := i8(c.z)
						if offset < 0 {
							c.w, c.z = split_u16(c.pc - u16(u8(math.abs[i8](offset))))
						} else {
							c.w, c.z = split_u16(c.pc + u16(u8(math.abs[i8](offset))))
						}
					} else {
						c.ir = c.fetch_cycle(c.pc)
						c.pc++
						c.m = 0
					}
				}
				3 {
					c.ir = c.fetch_cycle(combine_u8(c.w, c.z))
					c.pc = combine_u8(c.w, c.z) + 1
					c.m = 0
				}
				else {

				}
			}
		}
		.rra {
			if pr { println("rra called (not implemented)") }
		}
		.daa {
			if pr { println("daa called (not implemented)") }
		}
		.cpl {
			if pr { println("cpl called (not implemented)") }
		}
		.scf {
			if pr { println("scf called (not implemented)") }
		}
		.ccf {
			if pr { println("ccf called (not implemented)") }
		}
		.halt {
			if pr { println("halt called (not implemented)") }
		}
		.adc {
			if pr { println("adc called (not implemented)") }
		}
		.sub {
			if pr { println("sub called (not implemented)") }
		}
		.sbc {
			if pr { println("sbc called (not implemented)") }
		}
		.and {
			if pr { println("and called (not implemented)") }
		}
		.xor {
			if pr { println("xor called") }
			mut result := 0
			match next_inst.mode {
				.r_r {
					match next_inst.reg_2 {
						.a {
							result = c.a ^ c.a
						}
						.b {
							result = c.a ^ c.b
						}
						.c {
							result = c.a ^ c.c
						}
						.d {
							result = c.a ^ c.d
						}
						.e {
							result = c.a ^ c.e
						}
						.h {
							result = c.a ^ c.h
						}
						.l {
							result = c.a ^ c.l
						}
						else {
							println("xor: r,r mode: invalid register 2 (should be 8-bit, not flags)")
						}
					}
				}
				.r_mr {
					match next_inst.reg_2 {
						.hl {
							println("not implemented")
							// TODO: do the thing
						}
						else {
							println("xor: r,mr mode: invalid register 2 (only hl supported)")
						}
					}
				}
				.r_d8 {
					println("not implemented")
					// TODO: do the thing
				}
				else {
					println("xor: invalid mode ${next_inst.mode}")
				}
			}
			c.a = u8(result)
			c.set_z(if result == 1 { true } else { false })
			c.set_n(false)
			c.set_h(false)
			c.set_c(false)
			c.ir = c.fetch_cycle(c.pc)
			c.pc++
			c.m = 0
		}
		.or {
			if pr { println("or called (not implemented)") }
		}
		.cp {
			if pr { println("cp called (not implemented)") }
		}
		.pop {
			if pr { println("pop called (not implemented)") }
		}
		.jp {
			if pr { println("jp called (not implemented)") }
		}
		.push {
			if pr { println("push called (not implemented)") }
		}
		.ret {
			if pr { println("ret called (not implemented)") }
		}
		.cb {
			if next_inst.mode != AddressMode.d8 {
				println("cb: mode ${next_inst.mode} invalid")
			}
			match c.m {
				1 {
					// get cb opcode
					if pr { println("cb called") }
					c.cb = c.fetch_cycle(c.pc)
					c.pc++
				}
				2 {
					reg := register_lookup[c.cb & 0b111]
					bit := (c.cb >> 3) & 0b111
					bit_op := (c.cb >> 6) & 0b11
					mut reg_val := c.read_reg8(reg)
					mut done := false
					match bit_op {
						1 {
							// BIT
							if pr { println("cb: bit called") }
							// TODO: make and use bit function
							c.set_z((reg_val & (1 << bit)) == 0)
							c.set_n(false)
							c.set_h(true)
							done = true
						}
						2 {
							// RST
							if pr { println("cb: rst called") }
							reg_val &= ~(1 << bit)
							c.set_reg8(reg, reg_val)
							done = true
						}
						3 {
							// SET
							if pr { println("cb: set called") }
							reg_val |= (1 << bit)
							c.set_reg8(reg, reg_val)
							done = true
						}
						else {}
					}
					// TODO: get c flag and store it here
					if !done {
						match bit {
							0 {
								// RLC
								if pr { println("cb: rlc called (not implemented)") }
							}
							1 {
								// RRC
								if pr { println("cb: rrc called (not implemented)") }
							}
							2 {
								// RL
								if pr { println("cb: rl called (not implemented)") }
							}
							3 {
								// RR
								if pr { println("cb: rr called (not implemented)") }
							}
							4 {
								// SLA
								if pr { println("cb: sla called (not implemented)") }
							}
							5 {
								// SRA
								if pr { println("cb: sra called (not implemented)") }
							}
							6 {
								// SWAP
								if pr { println("cb: swap called (not implemented)") }
							}
							7 {
								// SRL
								if pr { println("cb: srl called (not implemented)") }
							}
							else {
								println("cb: invalid bit ${bit}")
							}
						}
					}
					c.ir = c.fetch_cycle(c.pc)
					c.pc++
					c.m = 0
				}
				else {
					println("cb: invalid cycle ${c.m}")
				}
			}
		}
		.call {
			if pr { println("call called (not implemented)") }
		}
		.reti {
			if pr { println("reti called (not implemented)") }
		}
		.ldh {
			if pr { println("ldh called (not implemented)") }
		}
		.jphl {
			if pr { println("jphl called (not implemented)") }
		}
		.di {
			if pr { println("di called (not implemented)") }
		}
		.ei {
			if pr { println("ei called (not implemented)") }
		}
		.rst {
			if pr { println("rst called (not implemented)") }
		}
		.err {
			if pr { println("err called (not implemented)") }
		}
	}
	if pr { println(c) }
	c.m++
}

fn (mut c Cpu) fetch_cycle(addr u16) u8 {
	// TODO: Do something with interrupts?
	return c.read_memory(addr)
}

fn (mut c Cpu) read_memory(addr u16) u8 {
	mut ram := c.ram or { panic("Can't access RAM from CPU!") }
	return ram.read(addr)
}

fn (mut c Cpu) write_memory(addr u16, data u8) {
	mut ram := c.ram or { panic("Can't access RAM from CPU!") }
	ram.write(addr, data)
}

// fn (mut c Cpu) execute() {
	// mut ram := c.ram or { panic("Can't access RAM from CPU!") }


	// Access something from ram
	// r := c.ram or { panic("Ram doesn't exist!") }
	// r.foo()
// }
