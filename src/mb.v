module main

struct Mb {
pub mut:
	ram &Ram
	cpu &Cpu
}

fn Mb.new() &Mb {
	mut r := &Mb{ram: &Ram{}, cpu: &Cpu{}}
	r.cpu.ram = r.ram
	return r
}

fn (mut m Mb) tick() {
	m.cpu.tick()
}

// fn (m Mb) get_byte(addr u32) i8 {
// 	return m.ram.a
// }
