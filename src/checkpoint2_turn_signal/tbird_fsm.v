/*
	Thunderbird turn-signal FSM.

	Six lights, three per side:   [5] [4] [3]   [2] [1] [0]
	                                  left          right
	A turn signal lights the side from the inside out (3, 3-4, 3-4-5), then
	turns off. Once a sequence starts it finishes, even if the button is released,
	and it repeats for as long as the button is held.
	Hazard flashes all six lights on and off while it is held.

	The FSM only changes state on a tick from slow_tick, so it is slow enough
	to see. Written as three blocks: next state, state register, outputs.
*/
module tbird_fsm (
	input clk,
	input reset,	// active high
	input tick,		// one-clock pulse, sets the blink speed
	input left,		// active high
	input right,	// active high
	input hazard,	// active high
	output reg [5:0] lights
);

	localparam OFF = 3'd0;
	localparam L1  = 3'd1;	// one left light
	localparam L2  = 3'd2;	// two left lights
	localparam L3  = 3'd3;	// three left lights
	localparam R1  = 3'd4;	// one right light
	localparam R2  = 3'd5;	// two right lights
	localparam R3  = 3'd6;	// three right lights
	localparam ALL = 3'd7;	// hazard: every light on

	reg [2:0] state, next_state;

	// 1: Next state logic
	always @(*) begin
		case (state)
			L1:      next_state = L2;
			L2:      next_state = L3;
			R1:      next_state = R2;
			R2:      next_state = R3;
			L3:      next_state = OFF;
			R3:      next_state = OFF;
			default: begin	// OFF or ALL: start whatever is pressed
				if      (hazard) next_state = (state == ALL) ? OFF : ALL;
				else if (left)   next_state = L1;
				else if (right)  next_state = R1;
				else             next_state = OFF;
			end
		endcase
	end

	// 2: State progression register
	always @(posedge clk) begin
		if (reset)
			state <= OFF;
		else if (tick)
			state <= next_state;
	end

	// 3: Output driving
	always @(*) begin
		case (state)
			L1:      lights = 6'b001_000;
			L2:      lights = 6'b011_000;
			L3:      lights = 6'b111_000;
			R1:      lights = 6'b000_100;
			R2:      lights = 6'b000_110;
			R3:      lights = 6'b000_111;
			ALL:     lights = 6'b111_111;
			default: lights = 6'b000_000;
		endcase
	end

endmodule