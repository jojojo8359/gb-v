module no_main

import sdl
import sdl.callbacks

import core

fn init() {
	callbacks.on_init(app_init)
	callbacks.on_quit(app_quit)
	callbacks.on_event(app_event)
	callbacks.on_iterate(app_iterate)
}

struct SDLApp {
mut:
	window &sdl.Window = unsafe { nil }
	renderer &sdl.Renderer = unsafe { nil }
	texture &sdl.Texture = unsafe { nil }
	mb &core.Mb = unsafe { nil }
	ticks u64
	scale int = 4
}

const lcd_x_res = 160
const lcd_y_res = 144

fn app_init(appstate &voidptr, argc int, argv &&char) sdl.AppResult {
	mut app := &SDLApp{}
	app.mb = core.Mb.new()
	for i in 0..lcd_y_res {
		app.mb.ppu.lcd[i * lcd_x_res] = 0xff0000ff
		app.mb.ppu.lcd[(i * lcd_x_res) + (lcd_x_res - 1)] =  0xff0000ff
	}

	unsafe {
		*appstate = app
	}

	if !sdl.init(sdl.init_video) {
		error_msg := unsafe { cstring_to_vstring(sdl.get_error()) }
		eprintln("Couldn't initialize SDL: ${error_msg}")
		return .failure
	}

	if !sdl.create_window_and_renderer(c'Hello SDL3', app.scale * lcd_x_res, app.scale * lcd_y_res, sdl.WindowFlags(0), &app.window, &app.renderer) {
		error_msg := unsafe { cstring_to_vstring(sdl.get_error()) }
		panic("Could not create SDL window and renderer. SDL error:\n${error_msg}")
	}

	if !sdl.set_render_v_sync(app.renderer, 1) {
		error_msg := unsafe { cstring_to_vstring(sdl.get_error()) }
		eprintln('notice: SDL could not enable vsync for the renderer:\n${error_msg}\nSee also docs for `set_render_v_sync`.')
	}

	app.texture = sdl.create_texture(app.renderer, .rgba8888, .streaming, app.scale * lcd_x_res, app.scale * lcd_y_res)
	if app.texture == sdl.null {
		error_msg := unsafe { cstring_to_vstring(sdl.get_error()) }
		eprintln("Couldn't create streaming texture: ${error_msg}")
		return .failure
	}

	app.ticks = sdl.get_ticks_ns()

	return .continue
}

pub fn app_iterate(appstate voidptr) sdl.AppResult {
	mut app := unsafe { &SDLApp(appstate) }

	surface := &sdl.Surface(sdl.null)

	if sdl.lock_texture_to_surface(app.texture, sdl.null, &surface) {
		mut r := sdl.Rect{}
		for line in 0..lcd_y_res {
			for x in 0..lcd_x_res {
				r.x = x * app.scale
				r.y = line * app.scale
				r.w = app.scale
				r.h = app.scale

				sdl.fill_surface_rect(surface, &r, app.mb.ppu.lcd[x + (line * lcd_x_res)])
			}
		}
		sdl.unlock_texture(app.texture)
	} else {
		error_msg := unsafe { cstring_to_vstring(sdl.get_error()) }
		eprintln("Couldn't lock texture to suface: ${error_msg}")
		return .failure
	}

	mut dst_rect := sdl.FRect{}
	dst_rect.x = 0
	dst_rect.y = 0
	dst_rect.w = app.scale * lcd_x_res
	dst_rect.h = app.scale * lcd_y_res

	sdl.set_render_draw_color(app.renderer, 0, 0, 0, sdl.alpha_opaque)
	sdl.render_clear(app.renderer)
	sdl.render_texture(app.renderer, app.texture, sdl.null, &dst_rect)

	current_ticks := sdl.get_ticks_ns()
	fps := f32(1) / (f32(current_ticks - app.ticks) / f32(1000000000))
	app.ticks = current_ticks

	sdl.set_render_draw_color(app.renderer, 0, 255, 0, sdl.alpha_opaque) // light blue, full alpha
	sdl.render_debug_text(app.renderer, 2, 2, "${fps:.1f}".str)

	sdl.render_present(app.renderer)
	return .continue
}

pub fn app_event(appstate voidptr, event &sdl.Event) sdl.AppResult {
	// mut app := unsafe { &SDLApp(appstate) }
	match event.type {
		.quit {
			return .success
		}
		else {}
	}
	return .continue
}

pub fn app_quit(appstate voidptr, result sdl.AppResult) {
	mut app := unsafe { &SDLApp(appstate) }
	sdl.destroy_texture(app.texture)
}
