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
	sp u16
	pc u16
	cycles u64
}

fn (mut c Cpu) execute() {
	mut ram := c.ram or { panic("Can't access RAM from CPU!") }

	opcode := ram.get(c.pc)
	len := op_len[opcode] or { panic("Couldn't find opcode ${opcode} in list of ops") }
	// do check for prefix

	// get length of rest of operation, gather additional values
	mut v := u16(0)
	if len == 2 {
		v = u16(ram.get(c.pc + 1))
	} else if len == 3 {
		v = (u16(ram.get(c.pc + 2)) << 8) + ram.get(c.pc + 1)
	}

	match opcode {
		0 {
			c.noop()
		}
		1 {
			c.ld_bc_n16(v)
		}
		2 {
			c.ld_d_bc_a(mut ram)
		}
		else {}
	}

	// Access something from ram
	// r := c.ram or { panic("Ram doesn't exist!") }
	// r.foo()
}
