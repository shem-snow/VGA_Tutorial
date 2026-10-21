/*
	Produces a one-clock-wide pulse ("tick") every COUNT clock cycles.

	Used to slow things down without making a new clock: logic that should run
	slowly stays on the 50 MHz clock and only does something when tick = 1.
	At 50 MHz, COUNT = 25_000_000 gives one tick every 0.5 s.
*/
module slow_tick #(parameter COUNT = 25_000_000) (
	input clk,
	input reset, // active high
	output tick
);

	reg [31:0] counter;

	always @(posedge clk) begin
		if (reset || counter == COUNT - 1)
			counter <= 0;
		else
			counter <= counter + 1;
	end

	assign tick = (counter == COUNT - 1);

endmodule