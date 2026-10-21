/*
	Stage 2 bit generator: draws the six turn-signal lights.

	Each light is a 40x40 square in a row across the middle of the screen:

	      [5]  [4]  [3]        [2]  [1]  [0]
	x:  80  160  240        360  440  520   (left edge of each light)
	y:  220 to 259 for all of them

	A light is yellow when its bit in "lights" is 1 and gray when it is 0.
	Everything else in the visible area is blue.
*/
module bitgen_tbird (
	input bright,
	input [9:0] hcount,		// x
	input [9:0] vcount,		// y
	input [5:0] lights,		// from the FSM, 1 = on
	output reg [7:0] VGA_R,
	output reg [7:0] VGA_G,
	output reg [7:0] VGA_B
);

	localparam SIZE = 40;	// each light is SIZE x SIZE pixels
	localparam TOP  = 220;	// top edge of every light (centered on y = 240)

	// Is the beam inside light i?  (left edges listed in the comment above)
	wire in_row = (vcount >= TOP) && (vcount < TOP + SIZE);
	wire [5:0] at_light;
	assign at_light[5] = in_row && (hcount >=  80) && (hcount <  80 + SIZE);
	assign at_light[4] = in_row && (hcount >= 160) && (hcount < 160 + SIZE);
	assign at_light[3] = in_row && (hcount >= 240) && (hcount < 240 + SIZE);
	assign at_light[2] = in_row && (hcount >= 360) && (hcount < 360 + SIZE);
	assign at_light[1] = in_row && (hcount >= 440) && (hcount < 440 + SIZE);
	assign at_light[0] = in_row && (hcount >= 520) && (hcount < 520 + SIZE);

	wire on_any_light = |at_light;				// beam is on some light
	wire on_lit_light = |(at_light & lights);	// ...and that light is on

	always @(*) begin
		if (~bright) begin				// outside the visible area: black
			VGA_R = 8'h00; VGA_G = 8'h00; VGA_B = 8'h00;
		end
		else if (on_lit_light) begin	// light on: yellow
			VGA_R = 8'hFF; VGA_G = 8'hFF; VGA_B = 8'h00;
		end
		else if (on_any_light) begin	// light off: gray
			VGA_R = 8'hB2; VGA_G = 8'hBE; VGA_B = 8'hB5;
		end
		else begin						// background: blue
			VGA_R = 8'h00; VGA_G = 8'h00; VGA_B = 8'h80;
		end
	end

endmodule