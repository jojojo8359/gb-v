module main

import time

fn main() {
	// println('Hello World!')

	mut sw := time.new_stopwatch()
	mut mb := Mb.new()
	println("Init took ${sw.elapsed().nanoseconds()}ns")
	sw = time.new_stopwatch()
	// 15: end of first loop
	for _ in 0..8 {
		mb.cpu.tick(true)
	}
	println("running loop...")
	// (8191 * 7) + 4
	for _ in 0..(8191*7)+2 {
		mb.cpu.tick(false)
	}
	for _ in 0..8 {
		mb.cpu.tick(true)
	}
	elapsed := sw.elapsed().nanoseconds()
	println("Ticks took ${elapsed}ns")
}
