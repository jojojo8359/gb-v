module main

const op_len = [1, 3]

fn (mut c Cpu) ld(r16 u8, n16 u16) {
	match r16 {
		0 {
			c.b = u8(n16 >> 8)
			c.c = u8(n16)
		}
		1 {
			c.d = u8(n16 >> 8)
			c.e = u8(n16)
		}
		2 {
			c.h = u8(n16 >> 8)
			c.l = u8(n16)
		}
		3 {
			c.sp = n16
		}
		else {}
	}
}

fn (mut c Cpu) ld_d(r16 u8, r8 u8) {

}

// NOP
fn (mut c Cpu) noop() {
	c.pc++
	c.cycles += 4
}

// LD BC,n16
fn (mut c Cpu) ld_bc_n16(v u16) {
	c.ld(0, v)
	c.pc += 3
	c.cycles += 12
}

// LD (BC),A
fn (mut c Cpu) ld_d_bc_a(mut ram &Ram) {
	// c.ld_d(r16: 0, r8: 7)
}
