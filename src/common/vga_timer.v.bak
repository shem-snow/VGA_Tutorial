/*
	This module uses two counting variables "hcount" and "vcount" to keep track of a 'current pixel' locations.
	It also controls the enable signal "bright" that dictates wether or not the screen will be active at the current pixel's location.

	The logic is taht the 'current pixel' will start at the top-left position of the display at location (0,0) and 
	progress one pixel at a time right-to-left and top-to-bottom until it gets to the bottom-right position at (799, 480).

	The active/diplay portion of the screen is in the box with corners (144, 0) and (783, 480).
	
	The hsync and vsync signals are active-low and indicate that a new row or column has started.
	When they are active (zero) then the FPGA will not move in their direction.
	When they are inactive (one) then the FPGA will move in their direction.
*/
module VGAtimer (
	input clk,
	input clear,
	// h and v sync are fed into the FPGA. They are active-low and when they pulse then the board knows that the current row or column has ended.
	output reg hsync, 
	output reg vsync,
	output reg bright, // Boolean value for "display to the screen"
	output reg [9:0] hcount, // Horizontal position
	output reg [9:0] vcount // Vertical position
);

// Progress hcount and vcount
always@(posedge clk) begin

	// Can be manually reset
	if(clear == 1'b0)
	begin
		hcount <= 0;
		vcount <= 0;
	end
	
	// Pulse the vsync signal active at the start of each new column.
	if(vcount < 1'b1)
		vsync <= 1'b0;
	// Hold it inactive while columns are being traversed. 
	else
		vsync <= 1'b1;
	
	// If in front porch, 
	if(hcount < 10'd96)
		begin

		// If vcount is at the end then reset it to indicate the start of a new column.
		if(vcount == 10'd479)
			vcount <= 10'b0000000000;
		
		// Pulse/activate hsync to indicate the start of a new row
		hsync <= 1'b0;
		
		// Progress hcount and don't display to the screen.
		hcount <= hcount + 1'b1;
		bright <= 0;
		end
		
	// If in back porch,
	else if(hcount < 10'd144)
		begin
		
			// Disable h sync to indicate that a row is still being traversed.
			hsync <= 1'b1;
			
			// Progress hcount and don't don't display.
			hcount <= hcount + 1'b1;
			bright <= 1'b0;
		end
		
	// If in the display region
	else if(hcount < 10'd784)
		begin
			// Progress hcount and display to the screen
			hcount <= hcount + 1'b1;
			bright <= 1'b1;
		end
		
	// If past the display region
	else if (hcount < 10'd800)
		begin
			
			// Stop displaying onto the screen
			bright <= 1'b0;
			
			// If the horizontal edge was reached then reset it and progress vcount, otherwise progress hcount.
			if(hcount == 10'd799)
				begin
					hcount <= 10'b0000000000;
					vcount <= vcount + 1'b1;
				end
			else
				begin
					hcount <= hcount + 1'b1;
				end
end
end
endmodule 