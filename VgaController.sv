module VgaController (

	input 					Clock, 		// The input used to synchronize all 
												// signals
	
	input 					Reset, 		// Synchronous reset signal
	
	output logic 			blank_n, 	// Signal that is high in the visible region 
												// of the VGA display (low in all other regions)
	
	output logic  			sync_n, 		// Signal that is low in the horizontal and 
												// vertical sync regions   
	
	output logic 			hSync_n, 	// Signal that is low in the horizontal 
												// sync region
	
	output logic 			vSync_n, 	// Signal that is low in the vertical 
												// sync region
	
	output logic [10:0] 	nextX,		// The 11 bit horizontal number of clock 
												// cycles
	
	output logic [9:0] 	nextY			// The 10 bit vertical number of lines
	
);

	logic 					hBlank_n;	// Signal that is low in all horizontal regions 
												// apart from the horizontal visible region
												
	logic 					vBlank_n;	// Signal that is low in all vertical regions 
												// apart from the vertical visible region

// Instantiating the counter
VgaCounter #(1040,666) Position (.Clock(Clock),.Reset(Reset),.NextCounterX(nextX),.NextCounterY(nextY));

// Instantiating the two state machines 
VgaStateMachine #(800,856,976,1040,10) EmmaStone1 (.Clock(Clock), .Reset(Reset), .nextValue(nextX), .blank_n(hBlank_n), .sync_n(hSync_n)); // State machine for horizontal states
VgaStateMachine #(600,637,643,666,9) EmmaStone2 (.Clock(Clock), .Reset(Reset), .nextValue(nextY), .blank_n(vBlank_n), .sync_n(vSync_n)); // State machine for vertical states

// Assigning the value of the blank signal based 
// on the horizontal and vertical blank signals
assign blank_n = (hBlank_n & vBlank_n);
	
// Assigning the value of the sync signal based 
// on the horizontal and vertical sync signals
assign sync_n = (hSync_n & vSync_n);

endmodule

// Counter module
module VgaCounter #(

	parameter 				TOTAL_X = 1040,	// The total number of clock cycles before reset
	
	parameter 				TOTAL_Y = 666		// The total number of vertical lines before reset

)
(
	
	input 					Clock, 				// The input used to synchronize all 
														// signals
											
	input 					Reset, 				// Synchronous reset signal
	
	output logic [10:0] 	NextCounterX,		// The 11 bit clock cycle for each horizontal 
														// line
	
	output logic [9:0]	NextCounterY		// The 10 bit line number
	
);

// Implementing the counter
always_ff @(posedge Clock)
begin
	// Synchronous reset
	if (Reset)
		begin
		// Reset the local clock cycle and line number values to 1
		NextCounterX = 1;
		NextCounterY = 1;
		end
	// Executes at rightmost pixel of the display
	else if (NextCounterX == TOTAL_X) 
		begin
		// Reset the local clock cycle to 1
		NextCounterX = 1;
		// Executes at the bottommost pixel of the display
		if (NextCounterY == TOTAL_Y) // Reaches the bottom of the display
			begin
			// Reset the line number to 1
			NextCounterY = 1;
			end
		else
			// Increment the number of lines by 1
			NextCounterY = NextCounterY + 1;
		end
	else 
		// Increment the clock cycle for the current horizontal line by 1
		NextCounterX = NextCounterX + 1;
end

endmodule


// State machine module
module VgaStateMachine #(
	
	parameter 							END_VIS = 799, 			// The total number of cycles/lines at the end
																			// of the horizontal/vertical visible region
																			
	parameter				 			END_FRONTPORCH = 855, 	// The total number of cycles/lines at the end
																			// the horizontal/vertical front porch region
																			
	parameter 							END_SYNC = 975,			// The total number of cycles/lines at the end
																			// the horizontal/vertical sync region
																			
	parameter 							END_BACKPORCH = 1039, 	// The total number of cycles/lines at the end
																			// the horizontal/vertical back porch region
																			
	parameter 							DATA_WIDTH = 10			// Determines the data width of the nextValue input
)

(
	
	input 								Clock, 		// The input used to synchronize all signals
											
	input 								Reset, 		// Synchronous reset signal
	 
	input logic [DATA_WIDTH:0] 	nextValue, 	// The variable-width input used to determine the 
															// next horizontal/vertical state
	
	output logic 						blank_n, 	// Signal that is high in the horizontal/vertical 
															// visible region of the VGA display (low in all 
															// other regions)
	
	output logic  						sync_n 		// Signal that is low in the horizontal/vertical 
															// sync regions   

);
	
// Defining the states
typedef enum {Visible, FrontPorch, Sync, BackPorch} eState; // Using enumerated variables to improve 
																				// code readability	
eState CurrentState, NextState;
	
// Implementing the state register
always_ff @(posedge Clock) CurrentState <= NextState;

// Implementing the logic for the state transitions
always_comb
begin
	
	case (CurrentState)

	Visible: 
	begin
	// Blank and sync signals are set to high
		blank_n = '1;
		sync_n  = '1;
		begin
		// State transitions to FrontPorch when END_VIS 
		// (end of visible region) is reached
			if (nextValue == END_VIS)
				NextState = FrontPorch;
			else
				NextState = CurrentState;
		end
	end
	
	FrontPorch: 
	begin
	// Blank signal is set to low and sync signal is set 
	// to high
		blank_n = '0;
		sync_n  = '1;
		begin
		// State transitions to Sync when END_FRONTPORCH 
		// (end of front porch region) is reached
			if (nextValue == END_FRONTPORCH)
				NextState = Sync;
			else
				NextState = CurrentState;
		end
	end
	
	Sync: 
	begin
	// Blank and sync signals are set to high
		blank_n = '0;
		sync_n  = '0;
		begin
		// State transitions to BackPorch when END_SYNC 
		// (end of sync region) is reached
			if (nextValue == END_SYNC)
				NextState = BackPorch;
			else
				NextState = CurrentState;
		end
	end
	
	BackPorch: 
	begin
	// Blank signal is set to low and sync signal is set 
	// to high
		blank_n = '0;
		sync_n  = '1;
		begin
		// State transitions to Visible when END_BACKPORCH 
		// (end of back porch region) is reached
			if (nextValue == END_BACKPORCH)
				NextState = Visible;
			else
				NextState = CurrentState;
		end
	end
	
	// Default state (visible)
	default:
	begin
	// Blank and sync signals are set to high
		blank_n = '1;
		sync_n  = '1;
		begin
		// State transitions to FrontPorch when END_VIS 
		// (end of visible region) is reached
			if (nextValue == END_VIS)
				NextState = FrontPorch;
			else
				NextState = CurrentState;
		end
	end

endcase;
end

endmodule



