module ProgramCounter (

	input 	Clock, 									// The input used to synchronize all counts 
															// and inputs
	
	input 	Reset, 									// Synchronous reset
		
	input 	[15:0] LoadValue, 					// This input is loaded into CounterValue on 
															// every positive clock edge (given LoadEnable 
															// is active high)
	
	input 	LoadEnable, 							// If set to logic 1 (active high), LoadValue 
															// should be stored into the CounterValue 
	
	
	input 	signed [8:0] Offset, 				// Added to (or subtracted from) the CounterValue 
															// when OffsetEnable is active high
					
	input 	OffsetEnable, 							// If set to logic 1 (active high), an offset is 
															// applied to CounterValue 
	
	output logic signed [15:0] CounterValue 	// The 16 bit output representing the 
															// value of the Program Counter
);

logic signed [15:0] NextCounterValue; // The value of the Program Counter on the next clock cycle

// Implementing the program counter
always_ff @(posedge Clock)
begin
	CounterValue <= NextCounterValue;
end

// Implementing the counter logic
always_comb
begin
// Using if-else statements to list all possible options, 
// including a default option if none of the listed 
// conditions are met
	if (Reset)
	// Resetting the value of the counter to 0
		NextCounterValue = '0;
	else if (LoadEnable)
	// Storing the value LoadValue into the counter
		NextCounterValue = LoadValue;
	else if (OffsetEnable)
	// Incrementing the value of the counter by the offset
		NextCounterValue = CounterValue + Offset;
	else
	// Incrementing the value of the counter by 1
		NextCounterValue = CounterValue + 1;
end

endmodule