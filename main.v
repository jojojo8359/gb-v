import time
import readline { read_line }

import core

fn main() {
	mut sw := time.new_stopwatch()
	mut mb := core.Mb.new()
	println("Init took ${sw.elapsed().nanoseconds()}ns")
	sw = time.new_stopwatch()
	for _ in 0..8 {
		mb.cpu.tick(false)
	}
	println("running loop...")
	// (8191 * 7) + 4
	for _ in 0..(8191*7)+4 {
		mb.cpu.tick(false)
	}
	for _ in 0..35 {
		mb.cpu.tick(false)
	}
	// Two call functions - 0x27-0x2d
	for _ in 0..175 {
		mb.cpu.tick(false)
	}
	for _ in 0..174 {
		mb.cpu.tick(false)
	}
	for _ in 0..8376 {
		mb.cpu.tick(false)
	}
	for _ in 0..241 {
		mb.cpu.tick(false)
	}
	// Ready to scroll logo on screen
	elapsed := sw.elapsed().nanoseconds()
	println("Ticks took ${elapsed}ns")
	mut input := ""
	mut loops := 0
	mut inst_done := true
	mut breakpoints := []u16{}
	mut step := true
	// TODO: Add breakpoint command
	for {
		if inst_done && step {
			input = read_line("") or { continue }
			if input.trim_space().to_lower() in ["q", "quit"] {
				println("Quitting...")
				break
			} else if input.trim_space().to_lower() == "dump" {
				mb.ram.dump_memory()
				println("Memory dumped to dump.bin.")
				continue
			} else if input.trim_space_left().to_lower().starts_with("b") {
				addr := input.trim_space_left().trim_space_right().split_by_space()[1].u16()
				breakpoints << addr
				println("Breakpoint added at 0x${addr:04x}")
				continue
			} else if input.trim_space().to_lower().starts_with("c") {
				if breakpoints.len != 0 {
					step = false
				} else {
					println("No breakpoints set! Cannot continue.")
				}
				continue
			} else if input.trim_space().to_lower().is_hex() {
				addr := input.trim_space().to_lower().u16()
				println("RAM at address 0x${addr:04x}: 0x${mb.ram.read(addr):04x}")
				continue
			}
			if mb.cpu.pc == 0xfe {
				println("end of boot rom reached")
				break
			}
		}
		loops++
		print("${loops}: ")
		mb.cpu.tick(true)
		inst_done = mb.cpu.m == 1
		if mb.cpu.pc in breakpoints {
			println("Breakpoint hit: 0x${mb.cpu.pc:04x}")
			step = true
		}
	}
}
