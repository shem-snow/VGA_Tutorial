/*
	Stage 3: Mario walking across the screen.

	This module bundles everything Mario needs so the top level only sees one
	more bit generator. Based on Kris Wolff's vga_glyph project.

	  movement      : stand-in for a CPU. Every 0.25 s it reads Mario's x position
	                  and animation frame from memory, updates them, and writes
	                  them back (port A of the RAM).
	  bram          : dual-port memory. Mario's state lives at
	                  0x1000 = x, 0x1001 = y, 0x1002 = animation frame.
	  glyph_addr_gen: during vsync, reads x, y and frame from memory (port B).
	                  Then, for every pixel inside Mario's 17x32 box, computes
	                  which ROM address holds that pixel's color.
	  glyph_rom     : the 21 Mario sprites, loaded from glyphs/glyphs.hex.
	  bitgen_mario  : outputs the sprite pixel, or the background color when
	                  outside the sprite or on a transparent (black) pixel.
*/
module mario (
	input clk,
	input reset,			// active high
	input bright,
	input hsync,
	input vsync,
	input [9:0] hcount,		// x
	input [9:0] vcount,		// y
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B
);

	localparam SYS_DATA_WIDTH   = 16;	// memory word size
	localparam SYS_ADDR_WIDTH   = 16;	// memory address size
	localparam GLYPH_DATA_WIDTH = 24;	// one RGB pixel
	localparam GLYPH_ADDR_WIDTH = 14;	// 21 sprites x 544 pixels fits in 2^14

	// Port A: movement (the "CPU") reads and writes Mario's state
	wire [SYS_ADDR_WIDTH-1:0] addr_a;
	wire [SYS_DATA_WIDTH-1:0] data_a, q_a;
	wire we_a;

	// Port B: the VGA side only reads
	wire [SYS_ADDR_WIDTH-1:0] addr_b;
	wire [SYS_DATA_WIDTH-1:0] q_b;

	bram #(.DATA_WIDTH(SYS_DATA_WIDTH), .ADDR_WIDTH(SYS_ADDR_WIDTH)) ram (
		.data_a(data_a), .data_b({SYS_DATA_WIDTH{1'b0}}),
		.addr_a(addr_a), .addr_b(addr_b),
		.we_a(we_a),     .we_b(1'b0),
		.clk(clk),
		.q_a(q_a),       .q_b(q_b)
	);

	movement #(.DATA_WIDTH(SYS_DATA_WIDTH), .ADDR_WIDTH(SYS_ADDR_WIDTH)) cpu (
		.clk(clk),
		.reset(reset),
		.data_in(q_a),
		.addr(addr_a),
		.data_out(data_a),
		.we(we_a)
	);

	// Which ROM pixel to show, and whether the beam is inside Mario's box
	wire [GLYPH_ADDR_WIDTH-1:0] glyph_addr;
	wire [23:0] bg_color;
	wire in_sprite;

	glyph_addr_gen #(
		.GLYPH_DATA_WIDTH(GLYPH_DATA_WIDTH), .SYS_DATA_WIDTH(SYS_DATA_WIDTH),
		.SYS_ADDR_WIDTH(SYS_ADDR_WIDTH),     .GLYPH_ADDR_WIDTH(GLYPH_ADDR_WIDTH)
	) addr_gen (
		.clk(clk),
		.reset(reset),
		.bright(bright),
		.vsync(vsync),
		.hsync(hsync),
		.hcount(hcount),
		.vcount(vcount),
		.sys_data(q_b),
		.glyph_addr(glyph_addr),
		.sys_addr(addr_b),
		.bg_color(bg_color),
		.pix_en(in_sprite)
	);

	// The ROM takes one clock to return a pixel...
	wire [GLYPH_DATA_WIDTH-1:0] pixel;

	glyph_rom #(.DATA_WIDTH(GLYPH_DATA_WIDTH), .ADDR_WIDTH(GLYPH_ADDR_WIDTH)) rom (
		.addr(glyph_addr),
		.clk(clk),
		.q(pixel)
	);

	// ...so delay "in_sprite" by one clock to line it up with that pixel.
	reg in_sprite_d;
	always @(posedge clk)
		in_sprite_d <= in_sprite;

	bitgen_mario #(.DATA_WIDTH(GLYPH_DATA_WIDTH)) bitgen (
		.bright(bright),
		.pix_en(in_sprite_d),
		.pixel(pixel),
		.bg_color(bg_color),
		.rgb({VGA_R, VGA_G, VGA_B})
	);

endmodule