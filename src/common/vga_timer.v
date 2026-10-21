/*
    VGA timer for 640x480 @ 60 Hz.

    Tracks where the "beam" is with two counters and generates the sync
    and bright signals from them. Counting starts at the visible area, so the
    current pixel is simply (x, y) = (hcount, vcount).

    One row  (hcount): visible 0-639 | front porch 640-655 | sync 656-751 | back porch 752-799
    One frame (vcount): visible 0-479 | front porch 480-489 | sync 490-491 | back porch 492-524

    Everything runs on the 50 MHz board clock. pix_en toggles every clock, so
    it is high every other cycle (25 MHz). The counters only advance when
    pix_en is high, and pix_en is also sent out as VGA_CLK.
*/
module vga_timer (
    input            clk,      // 50 MHz board clock (CLOCK_50)
    input            reset,    // active high, synchronous
    output reg       pix_en,   // 25 MHz tick, drives VGA_CLK
    output reg [9:0] hcount,   // 0..799, current column
    output reg [9:0] vcount,   // 0..524, current row
    output           hsync,    // active low
    output           vsync,    // active low
    output           bright    // equals 1 inside the visible (640x480) region
);

	// Horizontal timing (pixel clocks)
	localparam H_VISIBLE = 640;
	localparam H_FRONT   = 16;
	localparam H_SYNC    = 96;
	localparam H_BACK    = 48;
	localparam H_TOTAL   = H_VISIBLE + H_FRONT + H_SYNC + H_BACK; // 800
	
	// Vertical timing (rows)
	localparam V_VISIBLE = 480;
	localparam V_FRONT   = 10;
	localparam V_SYNC    = 2;
	localparam V_BACK    = 33;
	localparam V_TOTAL   = V_VISIBLE + V_FRONT + V_SYNC + V_BACK; // 525
	
	// Synchronization pulses are active low and therefore low within their synchronization regions.
	assign hsync = ~((hcount >= H_VISIBLE + H_FRONT) && (hcount <  H_VISIBLE + H_FRONT + H_SYNC));
	assign vsync = ~((vcount >= V_VISIBLE + V_FRONT) && (vcount <  V_VISIBLE + V_FRONT + V_SYNC));
	
	// Color may only be shown inside the visible area
	assign bright = (hcount < H_VISIBLE) && (vcount < V_VISIBLE);

	
	// Progress hcount and vcount
	always@(posedge clk) begin
	
		// Can be manually reset
		if(reset == 1'b0) begin
				pix_en <= 1'b0;
				hcount <= 0;
				vcount <= 0;
			end
		else begin
			// Generate a 25 MHz enable signal from the input 50 MHz clock.
			pix_en <= ~pix_en;
			
			// On each positve edge of the 25 MHz clock (because we're drawing to the entire screen every clock tick)
			if (pix_en) begin
				
				// If the horizontal count has reached its end then reset it and also check in vcount needs to be reset.
				if (hcount == H_TOTAL - 1) begin
					// Pulse/activate hsync to indicate the start of a new row.
					hcount <= 10'd0;
					// If vcount is at the end then reset it to indicate the start of a new column.
					if (vcount == V_TOTAL - 1)
						vcount <= 10'd0;
					// Otherwise increment it
					else
						vcount <= vcount + 10'd1;
				end
				// otherwise increment hcount.
				else
					hcount <= hcount + 10'd1;
		end
	end
			
endmodule 