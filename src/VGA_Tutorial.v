/*
    Top level for the VGA tutorial.

    SW[9:8] pick which program drives the screen:
        00 = off
        01 = stage 1, solid color (SW[2:0] pick the color)
        10 = stage 2, turn signal  (not built yet: black)
        11 = stage 3, Mario        (not built yet: black)

    All programs share one vga_timer.
	 Each stage has its own bit generator, and the case statement below picks whose color goes to the screen.
*/
module VGA_Tutorial (
    input clock, // 50 MHz from the board.
    input [9:8] mode_select, // slide switches [9:8].
    input [2:0] color_select, // slide switches [2:0].
    input reset, // push buttons on the board are active low.

    output VGA_CLK,
    output VGA_HS,
    output VGA_VS,
    output VGA_BLANK_N,
    output VGA_SYNC_N,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B
);
	localparam MODE_OFF   = 2'b00;
	localparam MODE_COLOR = 2'b01;
	localparam MODE_TBIRD  = 2'b10;
	localparam MODE_MARIO = 2'b11;
	
	wire pix_en, hsync, vsync, bright;
	wire [9:0] hcount, vcount;
	
	// VGA outputs
	assign VGA_HS = hsync;
	assign VGA_VS = vsync;
	assign VGA_CLK = pix_en;
	assign {VGA_R, VGA_G, VGA_B} = rgb;
	assign VGA_BLANK_N = bright && (mode_select != MODE_OFF);
	assign VGA_SYNC_N = 1'b0; // Not used
	
	// VGA controller/timer
	vga_timer timer (
		.clk(clock),
		.reset(~reset), // active low
		.pix_en(pix_en),
		.hcount(hcount),
		.vcount(vcount),
		.hsync(hsync),
		.vsync(vsync),
		.bright(bright)
	);
	
	// Pick which stage drives the screen
	reg [23:0] rgb;
	
	always @(*) begin
		case (mode_select)
			MODE_COLOR: rgb = rgb_color;
			default:    rgb = 24'h000000;
		endcase
	end
	
	// Stage 1: changing the entire screen to a solid color.
	wire [23:0] rgb_color;
	
	bitgen_color mode1 (
		.bright(bright),
		.color_sel(color_select),
		.rgb(rgb_color)
	);
	
	
endmodule