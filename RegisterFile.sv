module RegisterFile (
	input 	Clock, 					// Input signal used to synchronize all register 
											// write operations
	
	input 	[5:0] AddressA, 		// Indicates the register to be accessed for 
											// port A reads and writes
	
	input 	[15:0] WriteData, 	// Written to the register indicated by AddressA 
											// on every cycle (given WriteEnable is active high)
	
	input 	WriteEnable, 			// If set to logic 1 (active high), WriteData is 
											// written to the register 
	
	input 	[5:0] AddressB, 		// Indicates the register to be accessed for port A 
											// reads and writes
	
	output 	[15:0] ReadDataA, 	// Asynchronously provided the value of the register 
											// indicated by AddressA
	
	output 	[15:0] ReadDataB 		// Asynchronously provided the value of the register 
											// indicated by AddressB
	
);


// Creating 64 registers that are each 16 bits long
logic [15:0] Registers [64]; 

// Assigning the value of the register indicated by AddressA to ReadDataA		
assign ReadDataA = Registers[AddressA];	

// Assigning the value of the register indicated by AddressB to ReadDataB		
assign ReadDataB = Registers[AddressB];	

// Implementing the register write logic
always_ff @(posedge Clock, ReadDataA, ReadDataB)
begin
	// Using an if statement to determine whether 
	// or not WriteData is written to the register 
	// indicated by AddressA
	if (WriteEnable)
		Registers[AddressA] = WriteData;
end

endmodule
