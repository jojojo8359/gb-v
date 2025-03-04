module src

pub struct Mb {
pub mut:
	ram &Ram
	cpu &Cpu
	ppu &Ppu
}

pub fn Mb.new() &Mb {
	mut r := &Mb{ram: &Ram{}, cpu: &Cpu{}, ppu: &Ppu{}}
	r.ram.load_boot_rom()
	r.cpu.ram = r.ram
	r.ppu.ram = r.ram
	return r
}

pub fn (mut m Mb) tick() {
	m.cpu.tick(false)
}

// fn (m Mb) get_byte(addr u32) i8 {
// 	return m.ram.a
// }
