module core

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

@[inline]
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
	return bit(c.f, z_bit)
}

@[inline]
fn (c Cpu) get_n() bool {
	return bit(c.f, n_bit)
}

@[inline]
fn (c Cpu) get_h() bool {
	return bit(c.f, h_bit)
}

@[inline]
fn (c Cpu) get_c() bool {
	return bit(c.f, c_bit)
}

@[inline]
fn (mut c Cpu) set_flag(v bool, n u8) {
	c.f = set_bit(c.f, n, v)
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

@[inline]
fn msb(v u16) u8 {
	return u8(v >> 8)
}

@[inline]
fn lsb(v u16) u8 {
	return u8(v)
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
		.none { return true }
	}
}

pub fn (mut c Cpu) tick(pr bool) {
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
			match next_inst.mode {
				.r_d16 {
					if pr { println("ld r,d16 called (m=${c.m})") }
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
								.de {
									c.d = c.w
									c.e = c.z
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
					if pr { println("ld: mr,r called (m=${c.m})") }
					match c.m {
						1 {
							c.write_memory(c.read_reg16(next_inst.reg_1), c.read_reg8(next_inst.reg_2))
						}
						2 {
							c.ir = c.fetch_cycle(c.pc)
							c.pc++
							c.m = 0
						}
						else {
							println("ld: mr,r mode: invalid cycle ${c.m}")
						}
					}
				}
				.r_d8 {
					if pr { println("ld r,d8 called (m=${c.m})") }
					match c.m {
						1 {
							c.z = c.read_memory(c.pc)
							c.pc++
						}
						2 {
							c.ir = c.fetch_cycle(c.pc)
							c.pc++
							c.set_reg8(next_inst.reg_1, c.z)
							c.m = 0
						}
						else {
							println("ld: r,d8 mode: invalid cycle ${c.m}")
						}
					}
				}
				.a16_r {
					if pr { println("ld: a16,r called (m=${c.m})") }
					match next_inst.reg_2 {
						.a, .b, .c, .d, .e, .h, .l {
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
									c.write_memory(combine_u8(c.w, c.z), c.read_reg8(next_inst.reg_2))
								}
								4 {
									c.ir = c.fetch_cycle(c.pc)
									c.pc++
									c.m = 0
								}
								else {
									println("ld: a16,r mode: invalid cycle ${c.m}")
								}
							}
						}
						.sp {
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
									c.write_memory(combine_u8(c.w, c.z), lsb(c.sp))
								}
								4 {
									c.write_memory(combine_u8(c.w, c.z) + 1, msb(c.sp))
								}
								5 {
									c.ir = c.fetch_cycle(c.pc)
									c.pc++
									c.m = 0
								}
								else {
									println("ld: a16,r mode: invalid cycle ${c.m}")
								}
							}
						}
						else {
							println("ld: a16,r mode: invalid register ${next_inst.reg_2}")
						}
					}
				}
				.r_mr {
					if pr { println("ld r,mr called (m=${c.m})") }
					match c.m {
						1 {
							c.z = c.read_memory(c.read_reg16(next_inst.reg_2))
						}
						2 {
							c.ir = c.fetch_cycle(c.pc)
							c.pc++
							c.set_reg8(next_inst.reg_1, c.z)
							c.m = 0
						}
						else {
							println("ld: r,mr mode: invalid cycle ${c.m}")
						}
					}
				}
				.hli_r {
					if pr { println("ld: hli,r called (m=${c.m})") }
					match c.m {
						1 {
							c.write_memory(c.read_reg16(RegisterType.hl), c.a)
							c.set_hl(c.read_reg16(RegisterType.hl) + 1)
						}
						2 {
							c.ir = c.fetch_cycle(c.pc)
							c.pc++
							c.m = 0
						}
						else {
							println("ld: hli,r mode: invalid cycle ${c.m}")
						}
					}
				}
				.hld_r {
					if pr { println("ld hld,r called (m=${c.m})") }
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
				.r_r {
					if pr { println("ld r,r called") }
					c.ir = c.fetch_cycle(c.pc)
					c.pc++
					c.set_reg8(next_inst.reg_1, c.read_reg8(next_inst.reg_2))
					c.m = 0
				}
				else {
					println("ld: invalid mode ${next_inst.mode}")
				}
			}
		}
		.inc {
			match next_inst.mode {
				.r {
					match next_inst.reg_1 {
						.a, .b, .c, .d, .e, .f, .h, .l {
							if pr { println("inc r (8-bit) called") }
							result := c.read_reg8(next_inst.reg_1) + 1
							c.set_reg8(next_inst.reg_1, result)
							c.set_z(result == 0)
							c.set_n(false)
							c.set_h((result & 0x0f) == 0)
							c.ir = c.fetch_cycle(c.pc)
							c.pc++
							c.m = 0
						}
						.af, .bc, .de, .hl, .sp, .pc {
							if pr { println("inc r (16-bit) called (m=${c.m})") }
							match c.m {
								1 {
									result := c.read_reg16(next_inst.reg_1) + 1
									c.set_reg16(next_inst.reg_1, result)
								}
								2 {
									c.ir = c.fetch_cycle(c.pc)
									c.pc++
									c.m = 0
								}
								else {
									println("inc: r mode (16-bit): invalid cycle ${c.m}")
								}
							}

						}
						else {
							println("inc: r mode: invalid register ${next_inst.reg_1}")
						}
					}

				}
				.mr {
					println("inc: mr mode: not implemented")
				}
				else {
					println("inc: invalid mode ${next_inst.mode}")
				}
			}
		}
		.dec {
			match next_inst.mode {
				.r {
					match next_inst.reg_1 {
						.a, .b, .c, .d, .e, .f, .h, .l {
							if pr { println("dec r (8-bit) called") }
							result := c.read_reg8(next_inst.reg_1) - 1
							c.set_reg8(next_inst.reg_1, result)
							c.set_z(result == 0)
							c.set_n(true)
							c.set_h((result & 0x0f) == 0x0f)
						}
						// TODO: Make 16-bit register dec perform 2 machine cycles
						.af, .bc, .de, .hl, .sp, .pc {
							if pr { println("dec r (16-bit) called") }
							result := c.read_reg16(next_inst.reg_1) - 1
							c.set_reg16(next_inst.reg_1, result)
						}
						else {
							println("dec: r mode: invalid register ${next_inst.reg_1}")
						}
					}
					c.ir = c.fetch_cycle(c.pc)
					c.pc++
					c.m = 0
				}
				.mr {
					println("dec: mr mode: not implemented")
				}
				else {
					println("dec: invalid mode ${next_inst.mode}")
				}
			}
		}
		.rlca {
			if pr { println("rlca called") }
			carry := u8(bit(c.a, 7))
			c.a = (c.a << 1) | carry
			c.set_c(carry == 1)
			c.set_h(false)
			c.set_n(false)
			c.set_z(false)
			c.ir = c.fetch_cycle(c.pc)
			c.pc++
			c.m = 0
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
			if pr { println("rla called") }
			v := (c.a >> 7) & 1
			c.a = (v << 1) | u8(c.get_c())
			c.set_z(false)
			c.set_n(false)
			c.set_h(false)
			c.set_c(v != 0)
			c.ir = c.fetch_cycle(c.pc)
			c.pc++
			c.m = 0
		}
		.jr {
			if pr { println("jr called (m=${c.m})") }
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
					println("jr: invalid cycle ${c.m}")
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
			mut result := 0
			match next_inst.mode {
				.r_r {
					if pr { println("xor r,r called") }
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
					if pr { println("xor r,mr called") }
					match next_inst.reg_2 {
						.hl {
							println("xor: r,mr mode: hl not implemented")
							// TODO: do the thing
						}
						else {
							println("xor: r,mr mode: invalid register 2 (only hl supported)")
						}
					}
				}
				.r_d8 {
					println("xor: r,d8 mode: not implemented")
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
			match next_inst.mode {
				.r_r {
					if pr { println("cp r,r called") }
					v := c.read_reg8(next_inst.reg_2)
					n := i8(c.a) - i8(v)
					c.set_z(n == 0)
					c.set_n(true)
					c.set_h(((i8(c.a) & 0x0f) - (i8(v) & 0x0f)) < 0)
					c.set_c(n < 0)
					c.ir = c.fetch_cycle(c.pc)
					c.pc++
					c.m = 0
				}
				.r_mr {
					if pr { println("cp r,mr called (m=${c.m})") }
					match c.m {
						1 {
							c.z = c.read_memory(c.read_reg16(RegisterType.hl))
						}
						2 {
							n := i8(c.a) - i8(c.z)
							c.set_z(n == 0)
							c.set_n(true)
							c.set_h(((i8(c.a) & 0x0f) - (i8(c.z) & 0x0f)) < 0)
							c.set_c(n < 0)
							c.ir = c.fetch_cycle(c.pc)
							c.pc++
							c.m = 0
						}
						else {
							println("cp: r,mr mode: invalid cycle ${c.m}")
						}
					}
				}
				.r_d8 {
					if pr { println("cp r,d8 called (m=${c.m})") }
					match c.m {
						1 {
							c.z = c.read_memory(c.pc)
							c.pc++
						}
						2 {
							n := i8(c.a) - i8(c.z)
							c.set_z(n == 0)
							c.set_n(true)
							c.set_h(((i8(c.a) & 0x0f) - (i8(c.z) & 0x0f)) < 0)
							c.set_c(n < 0)
							c.ir = c.fetch_cycle(c.pc)
							c.pc++
							c.m = 0
						}
						else {
							println("cp: r,mr mode: invalid cycle ${c.m}")
						}
					}
				}
				else {
					println("cp: invalid mode ${next_inst.mode}")
				}
			}
		}
		.pop {
			if pr { println("pop called (m=${c.m})") }
			match c.m {
				1 {
					c.z = c.read_memory(c.sp)
					c.sp++
				}
				2 {
					c.w = c.read_memory(c.sp)
					c.sp++
				}
				3 {
					c.ir = c.fetch_cycle(c.pc)
					c.pc++
					c.set_reg16(next_inst.reg_1, combine_u8(c.w, c.z))
					c.m = 0
				}
				else {
					println("pop: invalid cycle ${c.m}")
				}
			}
		}
		.jp {
			if pr { println("jp called (not implemented)") }
		}
		.push {
			if pr { println("push called (m=${c.m})") }
			match c.m {
				1 {
					c.sp--
				}
				2 {
					c.write_memory(c.sp, msb(c.read_reg16(next_inst.reg_1)))
					c.sp--
				}
				3 {
					c.write_memory(c.sp, lsb(c.read_reg16(next_inst.reg_1)))
				}
				4 {
					c.ir = c.fetch_cycle(c.pc)
					c.pc++
					c.m = 0
				}
				else {
					println("push: invalid cycle ${c.m}")
				}
			}
		}
		.ret {
			if pr { println("ret called (m=${c.m})") }
			match next_inst.cond {
				.none {
					match c.m {
						1 {
							c.z = c.read_memory(c.sp)
							c.sp++
						}
						2 {
							c.w = c.read_memory(c.sp)
							c.sp++
						}
						3 {
							c.pc = combine_u8(c.w, c.z)
						}
						4 {
							c.ir = c.fetch_cycle(c.pc)
							c.pc++
							c.m = 0
						}
						else {
							println("ret: no condition: invalid cycle ${c.m}")
						}
					}
				}
				else {
					match c.m {
						1 {}
						2 {
							if c.cond_true(next_inst.cond) {
								c.z = c.read_memory(c.sp)
								c.sp++
							} else {
								c.ir = c.fetch_cycle(c.pc)
								c.pc++
								c.m = 0
							}
						}
						3 {
							c.w = c.read_memory(c.sp)
							c.sp++
						}
						4 {
							c.pc = combine_u8(c.w, c.z)
						}
						5 {
							c.ir = c.fetch_cycle(c.pc)
							c.pc++
							c.m = 0
						}
						else {
							println("ret: conditional: invalid cycle ${c.m}")
						}
					}
				}
			}
		}
		.cb {
			if next_inst.mode != AddressMode.d8 {
				println("cb: mode ${next_inst.mode} invalid")
			}
			match c.m {
				1 {
					// get cb opcode
					if pr { println("cb called (m=${c.m})") }
					c.cb = c.fetch_cycle(c.pc)
					c.pc++
				}
				2 {
					reg := register_lookup[c.cb & 0b111]
					bit_ := (c.cb >> 3) & 0b111
					bit_op := (c.cb >> 6) & 0b11
					mut reg_val := c.read_reg8(reg)
					mut done := false
					match bit_op {
						1 {
							// BIT
							if pr { println("cb: bit called (m=${c.m})") }
							c.set_z(bit(reg_val, bit_))
							c.set_n(false)
							c.set_h(true)
							done = true
						}
						2 {
							// RST
							if pr { println("cb: rst called (m=${c.m})") }
							reg_val &= ~(1 << bit_)
							c.set_reg8(reg, reg_val)
							done = true
						}
						3 {
							// SET
							if pr { println("cb: set called (m=${c.m})") }
							reg_val |= (1 << bit_)
							c.set_reg8(reg, reg_val)
							done = true
						}
						else {}
					}
					if !done {
						match bit_ {
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
								if pr { println("cb: rl called (m=${c.m})") }
								old := reg_val
								reg_val = reg_val << 1
								reg_val |= u8(c.get_c())
								c.set_reg8(reg, reg_val)
								c.set_z(reg_val == 0)
								c.set_n(false)
								c.set_h(false)
								// TODO: Verify this is the correct flag behavior
								c.set_c(old & 0x80 == 1)
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
			if pr { println("call called (m=${c.m})") }
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
					if c.cond_true(next_inst.cond) {
						c.sp--
					} else {
						c.ir = c.fetch_cycle(c.pc)
						c.pc++
						c.m = 0
					}
				}
				4 {
					c.write_memory(c.sp, msb(c.pc))
					c.sp--
				}
				5 {
					c.write_memory(c.sp, lsb(c.pc))
					c.pc = combine_u8(c.w, c.z)
				}
				6 {
					c.ir = c.fetch_cycle(c.pc)
					c.pc++
					c.m = 0
				}
				else {
					println("call: invalid cycle ${c.m}")
				}
			}
		}
		.reti {
			if pr { println("reti called (not implemented)") }
		}
		.ldh {
			match next_inst.mode {
				.a8_r {
					if pr { println("ldh a8,r called (m=${c.m})") }
					match c.m {
						1 {
							c.z = c.read_memory(c.pc)
							c.pc++
						}
						2 {
							c.write_memory(combine_u8(0xff, c.z), c.a)
						}
						3 {
							c.ir = c.fetch_cycle(c.pc)
							c.pc++
							c.m = 0
						}
						else {
							println("ldh: a8,r mode: invalid cycle ${c.m}")
						}
					}
				}
				.mr_r {
					if pr { println("ldh mr,r called (m=${c.m})") }
					match c.m {
						1 {
							c.write_memory(combine_u8(0xff, c.c), c.a)
						}
						2 {
							c.ir = c.fetch_cycle(c.pc)
							c.pc++
							c.m = 0
						}
						else {
							println("ldh: mr,r mode: invalid cycle ${c.m}")
						}
					}
				}
				.r_a8 {
					if pr { println("ldh r,a8 called (m=${c.m})") }
					match c.m {
						1 {
							c.z = c.read_memory(c.pc)
							c.pc++
						}
						2 {
							c.z = c.read_memory(combine_u8(0xff, c.z))
						}
						3 {
							c.ir = c.fetch_cycle(c.pc)
							c.pc++
							c.a = c.z
							c.m = 0
						}
						else {
							println("ldh: r,a8 mode: invalid cycle ${c.m}")
						}
					}
				}
				else {}
			}
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
	c.cycles++
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
