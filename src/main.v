module main

fn main() {
	// println('Hello World!')
	mut mb := Mb.new()
	// mb.cpu.execute()
	mb.cpu.tick()
	mb.cpu.tick()
	mb.cpu.tick()
	mb.cpu.tick()
}
