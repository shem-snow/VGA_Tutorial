/*
	The input switches are used to map 8 pre-defined colors.
	The currently selected color is output as three 8-bit vectors for the R, G, and B values.
*/
module bitgen_color(
	input bright,
	input [9:0] hcount,
	input [9:0] vcount,
	input [2:0] switches,
	output reg[7:0] VGA_R,
	output reg[7:0] VGA_G,
	output  reg[7:0] VGA_B
);

// Parameters used to encode 8 colors.
parameter BLACK = 3'b000;
parameter BLUE = 3'b001;
parameter GREEN = 3'b010;
parameter LIGHTBLUE = 3'b011;
parameter RED = 3'b100;
parameter PINK = 3'b101;
parameter YELLOW = 3'b110;
parameter WHITE = 3'b111;

always@(*)
begin
	// If in the display region of the screen and "bright" is enabled then display the color that's indicated on the switches.
	if(10'd144 <= hcount && hcount < 10'd783)
	begin
		if(~bright)
		begin
				VGA_R <= 8'b00000000;
				VGA_G <= 8'b00000000;
				VGA_B <= 8'b00000000;
		end
		else
			case(switches)
				BLACK: begin
					VGA_R <= 8'b00111100;
					VGA_G <= 8'b00111100;
					VGA_B <= 8'b00111100;
				end
				
				BLUE: begin
					VGA_R <= 8'b00000000;
					VGA_G <= 8'b00000000;
					VGA_B <= 8'b10000000;
				end
				
				GREEN: begin
					VGA_R <= 8'b00000000;
					VGA_G <= 8'b10000000;
					VGA_B <= 8'b00000000;
				end
				
				LIGHTBLUE: begin
					VGA_R <= 8'b10000111;
					VGA_G <= 8'b11001110;
					VGA_B <= 8'b11101011;
				end
				
				RED: begin
					VGA_R <= 8'b10000000;
					VGA_G <= 8'b00000000;
					VGA_B <= 8'b00000000;
				end
				
				PINK: begin
					VGA_R <= 8'b11101110;
					VGA_G <= 8'b10000010;
					VGA_B <= 8'b11101110;
				end
				
				YELLOW: begin
					VGA_R <= 8'b11111111;
					VGA_G <= 8'b11111111;
					VGA_B <= 8'b00000000;
				end
				
				WHITE: begin
					VGA_R <= 8'b11111111;
					VGA_G <= 8'b11111111;
					VGA_B <= 8'b11111111;
				end
			endcase
	end
	else
		begin
				VGA_R <= 8'b10000000;
				VGA_G <= 8'b00000000;
				VGA_B <= 8'b00000000;
		end
end

endmodule