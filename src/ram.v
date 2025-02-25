module main

struct Ram {
pub:
	// cart_fixed []u8 = [u8(0x31), u8(0xFE), u8(0xFF)]
	cart_fixed []u8 = [u8(0x1), u8(0x34), u8(0x12)]
}

fn (r &Ram) foo() {
	println("Foo called in ram")
}

fn (r &Ram) get(addr u16) u8 {
	return r.cart_fixed[addr]
}
