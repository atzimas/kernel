const builtin = @import("builtin");

const MultibootHeader = extern struct {
	magic: i32,
	flags: i32,
	checksum: i32,
};

const MAGIC = 0x1badb002;
const FLAGS = 1 << 0 | 1 << 1;

export const multiboot align(4) linksection(".multiboot") = MultibootHeader{
	.magic = MAGIC,
	.flags = FLAGS,
	.checksum = -(MAGIC + FLAGS),
};

export var stack_bytes: [4096]u8 align(16) linksection(".bss") = undefined;
const stack_bytes_slice = stack_bytes[0..];

export fn _start() noreturn {
	@call(.auto, kernel_start, .{});
}

fn kernel_start() noreturn {
	kprint("kernel is booting...");
	while (true) {}
}

const VgaColor = u8;
const VGA_COLOR_BLACK = 0;
const VGA_COLOR_BLUE = 1;
const VGA_COLOR_GREEN = 2;
const VGA_COLOR_CYAN = 3;
const VGA_COLOR_RED = 4;
const VGA_COLOR_MAGENTA = 5;
const VGA_COLOR_BROWN = 6;
const VGA_COLOR_LIGHT_GREY = 7;
const VGA_COLOR_DARK_GREY = 8;
const VGA_COLOR_LIGHT_BLUE = 9;
const VGA_COLOR_LIGHT_GREEN = 10;
const VGA_COLOR_LIGHT_CYAN = 11;
const VGA_COLOR_LIGHT_RED = 12;
const VGA_COLOR_LIGHT_MAGENTA = 13;
const VGA_COLOR_LIGHT_BROWN = 14;
const VGA_COLOR_WHITE = 15;

fn vgaEntryColor(fg: VgaColor, bg: VgaColor) u8 {
	return fg | (bg << 4);
}

fn vgaEntry(ch: u8, color: u8) u16 {
	const c: u16 = color;
	return ch | (c << 8);
}

const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;
const cons = struct {
	var row: usize = 0;
	var col: usize = 0;
	var color = vgaEntryColor(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
	const buffer: [*]volatile u16 = @ptrFromInt(0xb8000);

	fn init() void {
		var y: usize = 0;
		while (y < VGA_HEIGHT) : (y += 1) {
			var x: usize = 0;
			while (x < VGA_WIDTH) : (x += 1) {
				putCharAt(' ', color, x, y);
			}
		}
	}
	
	fn setColor(new_color: u8) void {
		color = new_color;
	}

	fn putCharAt(ch: u8, new_color: u8, x: usize, y: usize) void {
		const idx = y * VGA_WIDTH + x;
		buffer[idx] = vgaEntry(ch, new_color);
	}

	fn putChar(ch: u8) void {
		putCharAt(ch, color, col, row);
		col += 1;
		if (col == VGA_WIDTH) {
			col = 0;
			row += 1;
			if (row == VGA_HEIGHT)
				row = 0;
		}
	}
};

pub fn kprint(s: []const u8) void {
	for (s) |ch|
		cons.putChar(ch);
}

