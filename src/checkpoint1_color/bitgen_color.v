/*
	Stage 1 bit generator: fills the visible screen with one of 8 colors.

	The color is picked by three slide switches. Outside the visible area
	(bright = 0) the output is black. The timer's bright signal already covers
	both the horizontal and vertical blanking, so no hcount/vcount checks are needed.
*/
module bitgen_color(
	input bright,
	input [2:0] switches,
	output reg [7:0] VGA_R,
	output reg [7:0] VGA_G,
	output reg [7:0] VGA_B
);

	// Switch encodings for the 8 colors.
	localparam DARK_GRAY  = 3'b000;
	localparam BLUE       = 3'b001;
	localparam GREEN      = 3'b010;
	localparam LIGHT_BLUE = 3'b011;
	localparam RED        = 3'b100;
	localparam PINK       = 3'b101;
	localparam YELLOW     = 3'b110;
	localparam WHITE      = 3'b111;

	always @(*) begin
		if (~bright) begin	// outside the visible area: black
			VGA_R = 8'h00;
			VGA_G = 8'h00;
			VGA_B = 8'h00;
		end
		else
			case (switches)
				DARK_GRAY:  begin VGA_R = 8'h3C; VGA_G = 8'h3C; VGA_B = 8'h3C; end
				BLUE:       begin VGA_R = 8'h00; VGA_G = 8'h00; VGA_B = 8'h80; end
				GREEN:      begin VGA_R = 8'h00; VGA_G = 8'h80; VGA_B = 8'h00; end
				LIGHT_BLUE: begin VGA_R = 8'h87; VGA_G = 8'hCE; VGA_B = 8'hEB; end
				RED:        begin VGA_R = 8'h80; VGA_G = 8'h00; VGA_B = 8'h00; end
				PINK:       begin VGA_R = 8'hEE; VGA_G = 8'h82; VGA_B = 8'hEE; end
				YELLOW:     begin VGA_R = 8'hFF; VGA_G = 8'hFF; VGA_B = 8'h00; end
				WHITE:      begin VGA_R = 8'hFF; VGA_G = 8'hFF; VGA_B = 8'hFF; end
			endcase
	end

endmodule