module main

import os

struct Ram {
pub mut:
	// cart_fixed []u8 = [u8(0x31), u8(0xFE), u8(0xFF), u8(0x0)]
	// cart_fixed []u8 = [u8(0x1), u8(0x34), u8(0x12), u8(0x0)]
	memory [0xFFFF]u8
	// memory [0x100]u8
}

fn (mut r Ram) load_boot_rom() {
	rom := os.read_file_array[u8]("./assets/DMG_ROM.bin")
	for index, byte in rom {
		r.memory[index] = byte
	}
}

fn (r &Ram) foo() {
	println("Foo called in ram")
}

fn (r &Ram) read(addr u16) u8 {
	return r.memory[addr]
}

fn (mut r Ram) write(addr u16, data u8) {
	r.memory[addr] = data
}
