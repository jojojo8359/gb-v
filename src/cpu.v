module main

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
	// temp IDC registers?
	z u8
	w u8
}

fn combine_u8(a u8, b u8) u16 {
	return (u16(a) << 8) + b
}

fn (mut c Cpu) tick() {
	mut next_inst := instructions[c.ir]
	match next_inst.in_type {
		.none {
			println("Invalid instruction!")
			// Lock CPU
		}
		.nop {
			println("nop called")
			c.ir = c.fetch_cycle(c.pc)
			c.pc++
			c.m = 0
		}
		.ld {
			println("ld called")
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

				}
				.r_d8 {

				}
				.a16_r {

				}
				.r_mr {

				}
				.hli_r {

				}
				else {

				}
			}
		}
		.inc {
			println("inc called")
		}
		.dec {
			println("dec called")
		}
		.rlca {
			println("rlca called")
		}
		.add {
			println("add called")
		}
		.rrca {
			println("rrca called")
		}
		.stop {
			println("stop called")
		}
		.rla {
			println("rla called")
		}
		.jr {
			println("jr called")
		}
		.rra {
			println("rra called")
		}
		.daa {
			println("daa called")
		}
		.cpl {
			println("cpl called")
		}
		.scf {
			println("scf called")
		}
		.ccf {
			println("ccf called")
		}
		.halt {
			println("halt called")
		}
		.adc {
			println("adc called")
		}
		.sub {
			println("sub called")
		}
		.sbc {
			println("sbc called")
		}
		.and {
			println("and called")
		}
		.xor {
			println("xor called")
		}
		.or {
			println("or called")
		}
		.cp {
			println("cp called")
		}
		.pop {
			println("pop called")
		}
		.jp {
			println("jp called")
		}
		.push {
			println("push called")
		}
		.ret {
			println("ret called")
		}
		.cb {
			println("cb called")
		}
		.call {
			println("call called")
		}
		.reti {
			println("reti called")
		}
		.ldh {
			println("ldh called")
		}
		.jphl {
			println("jphl called")
		}
		.di {
			println("di called")
		}
		.ei {
			println("ei called")
		}
		.rst {
			println("rst called")
		}
		.err {
			println("err called")
		}
		// CB
		.rlc {
			println("rlc called")
		}
		.rrc {
			println("rrc called")
		}
		.rl {
			println("rl called")
		}
		.rr {
			println("rr called")
		}
		.sla {
			println("sla called")
		}
		.sra {
			println("sra called")
		}
		.swap {
			println("swap called")
		}
		.srl {
			println("srl called")
		}
		.bit {
			println("bit called")
		}
		.res {
			println("res called")
		}
		.set {
			println("set called")
		}
	}
	c.m++
	dump(c)
}

fn (mut c Cpu) fetch_cycle(addr u16) u8 {
	// TODO: Do something with interrupts?
	return c.read_memory(addr)
}

fn (mut c Cpu) read_memory(addr u16) u8 {
	mut ram := c.ram or { panic("Can't access RAM from CPU!") }
	return ram.read(addr)
}

// fn (mut c Cpu) execute() {
	// mut ram := c.ram or { panic("Can't access RAM from CPU!") }


	// Access something from ram
	// r := c.ram or { panic("Ram doesn't exist!") }
	// r.foo()
// }
