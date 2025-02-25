module main

struct Cpu {
mut:
	ram ?&Ram
	// ops []fn
pub mut:
	a i8
	f i8
	b i8
	c i8
	d i8
	e i8
	h i8
	l i8
	sp i16
	pc i16
}

fn (c Cpu) execute(opcode i8) {
	// do check for prefix
	// get length of rest of operation, gather additional values
	// call function for operation
	r := c.ram or { panic("Ram doesn't exist!") }
	r.foo()
}
