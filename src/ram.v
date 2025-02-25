module main

struct Ram {
pub:
	a i8
}

fn (r &Ram) foo() {
	println("Foo called in ram")
}
