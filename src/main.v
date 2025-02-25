module main

fn main() {
	// println('Hello World!')
	mut mb := Mb.new()
	mb.cpu.execute()
	dump(mb.cpu)
}
