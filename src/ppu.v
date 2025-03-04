module src

pub struct Ppu {
pub mut:
	ram ?&Ram
	lcd [lcd_x_res * lcd_y_res]u32
}

@[inline]
fn (p &Ppu) read_memory(addr u16) u8 {
	ram := p.ram or { panic("RAM isn't accessible to PPU!") }
	return ram.read(addr)
}

@[inline]
fn (p &Ppu) write_memory(addr u16, data u8) {
	mut ram := p.ram or { panic("RAM isn't accessible to PPU!") }
	ram.write(addr, data)
}

// LCDC

@[inline]
fn (p &Ppu) read_lcdc() u8 {
	return p.read_memory(0xff40)
}

fn (p &Ppu) get_lcd_ppu_enable() bool {
	return bit(p.read_lcdc(), 7)
}

fn (p &Ppu) get_window_tile_map_area() bool {
	return bit(p.read_lcdc(), 6)
}

fn (p &Ppu) get_window_enable() bool {
	return bit(p.read_lcdc(), 5)
}

fn (p &Ppu) get_bg_window_tile_data_area() bool {
	return bit(p.read_lcdc(), 4)
}

fn (p &Ppu) get_bg_tile_map_area() bool {
	return bit(p.read_lcdc(), 3)
}

fn (p &Ppu) get_obj_size() bool {
	return bit(p.read_lcdc(), 2)
}

fn (p &Ppu) get_obj_enable() bool {
	return bit(p.read_lcdc(), 1)
}

fn (p &Ppu) get_bg_window_enable_priority() bool {
	return bit(p.read_lcdc(), 0)
}

// OTHER CONTROL REGISTERS

@[inline]
fn (p &Ppu) get_ly() u8 {
	return p.read_memory(0xff44)
}

@[inline]
fn (p &Ppu) set_ly(value u8) {
	p.write_memory(0xff44, value)
}
