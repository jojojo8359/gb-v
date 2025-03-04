# Class Structure

- CPU: handles all CPU instructions, read from RAM
    - needs access to RAM
    - (ideally) ticked every t-cycle, but keeps track of its own m-cycles
- RAM: holds all RAM/ROM
    - will need to access cartridge data, but can be mapped directly in for simplicity (no more overhead for CPU)
    - also holds control registers (including peripherals like controls, plus PPU/LCD)
- PPU: draws data from VRAM to LCD
    - scanlines, three phases
    - needs access to RAM and LCD
    - ticked every t-cycle (might be hard to emulate every tick)
- LCD: holds all pixel data to be rendered to screen
    - hook up to SDL to draw current screen state (put in PPU?)
