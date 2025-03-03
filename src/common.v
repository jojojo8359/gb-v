module main

@[inline]
fn bit(a u8, n u8) bool {
	return a & (1 << n) > 0
}

@[inline]
fn set_bit(a u8, n u8, v bool) u8 {
	return if v { a | (1 << n) } else { a & ~(1 << n) }
}
