// ArithmeticLogicUnit
// This is a basic implementation of the essential operations needed
// in the ALU. Adding futher instructions to this file will increase 
// your marks.

// Load information about the instruction set. 
import InstructionSetPkg::*;

// Define the connections into and out of the ALU.
module ArithmeticLogicUnit
(
	// The Operation variable is an example of an enumerated type and
	// is defined in InstructionSetPkg.
	input eOperation Operation,
	
	// The InFlags and OutFlags variables are examples of structures
	// which have been defined in InstructionSetPkg. They group together
	// all the single bit flags described by the Instruction set.
	input  sFlags    InFlags,
	output sFlags    OutFlags,
	
	// All the input and output busses have widths determined by the 
	// parameters defined in InstructionSetPkg.
	input  signed [ImmediateWidth-1:0] InImm,
	
	// InSrc and InDest are the values in the source and destination
	// registers at the start of the instruction.
	input  signed [DataWidth-1:0] InSrc,
	input  signed [DataWidth-1:0]	InDest,
	
	// OutDest is the result of the ALU operation that is written 
	// into the destination register at the end of the operation.
	output logic signed [DataWidth-1:0] OutDest
);
	
	
	// This block allows each OpCode to be defined. Any opcode not
	// defined outputs a zero. The names of the operation are defined 
	// in the InstructionSetPkg. 
	always_comb
	begin
	
		// By default the flags are unchanged. Individual operations
		// can override this to change any relevant flags.
		OutFlags  = InFlags;
		
		// The basic implementation of the ALU only has the NAND and
		// ROL operations as examples of how to set ALU outputs 
		// based on the operation and the register / flag inputs.
		case(Operation)		
		
			ROL:     {OutFlags.Carry,OutDest} = {InSrc,InFlags.Carry};	
			
			NAND:    OutDest = ~(InSrc & InDest);

			// ***** ONLY CHANGES BELOW THIS LINE ARE ASSESSED *****
			// Put your instruction implementations here.
			
			// Copying the contents of register Src to register Dest.
			MOVE: 	OutDest = InSrc; 
			
			// Setting register Dest to the bitwise logical NOR of the 
			// contents of register Dest and register Src.
			NOR: 		OutDest = ~(InSrc | InDest);
			
			// Setting register Dest to the contents of regist Src after 
			// shifting the value of the latter to the right by 1 bit by
			// concatenating it with the value in the Carry flag. This sets 
			// the most significant bit of Dest to said value and, after 
			// the operation is complete, the Carry flag contains the least 
			// significant bit of Src.
			ROR: 		{OutDest,OutFlags.Carry} = {InFlags.Carry,InSrc};
			
			// Setting the contents of register Dest to the sign extended 
			// copy of the immediate value.
			LIL: 		OutDest = 16'(signed'(InImm[5:0]));
			
			// Setting the upper bits of register Dest based upon the 
			// immediate value.
			LIU: 		begin
						// Using an if-else statement to determine what the 
						// contents of register Dest should be set to.
							if (InImm[5])
								OutDest = {InImm[4:0], InDest[10:0]};
							else
								OutDest = 16'(signed'({InImm[4:0],InDest[5:0]}));
						end
			
			// Setting the value of register Dest to the sum of the contents 
			// of registers Src and Dest and the Carry flag.
			ADC: 		begin
			
						// Concatenating the Carry flag with the sum value to 
						// determine whether or not the function produces a carry.
						{OutFlags.Carry,OutDest} = InSrc + InDest + InFlags.Carry;
						
						// Determining whether the result of the operation is
						// zero and, hence, if the Zero flag should be set. 
						OutFlags.Zero = (16'(signed'(OutDest[15:0])) == '0) ? '1:'0;
						
						// Determining whether the result of the operation is 
						// negative and, hence, if the Negative flag should be set. 
						OutFlags.Negative = (16'(signed'(OutDest[15:0])) < '0) ? '1:'0;
						
						// Determining whether the result of the operation is
						//  even and, hence, if the Parity flag should be set. 
						OutFlags.Parity = ~(^OutDest);
						
						// Determining whether or not the operation flows  
						// based on given conditions and setting the flag 
						// based on the result.
						OutFlags.Overflow = (~InDest[DataWidth-1] & ~InSrc[DataWidth-1] & OutDest[DataWidth-1]) | (InDest[DataWidth-1] & InSrc[DataWidth-1] & ~OutDest[DataWidth-1]);
						
						end
			
			// Setting the value of register Dest to the sum of the contents  
			// of register Dest and the negative of the sum of the contents  
			// of register Src and the value of the Carry flag.
			SUB:		begin
			
						// Calculating the value of register Dest.
						OutDest = InDest - (InSrc + InFlags.Carry);
						
						// Determining whether the operation produces a borrow 
						// and ,hence, if the Carry flag should be set. 
						OutFlags.Carry = (InDest < (InSrc + InFlags.Carry));
						
						// Determining whether the result of the operation is  
						// zero and, hence, if the Zero flag should be set. 
						OutFlags.Zero = (OutDest == '0) ? '1:'0;
						
						// Determining whether the result of the operation is  
						// negative and, hence, if the Negative flag should be set. 
						OutFlags.Negative = (16'(signed'(OutDest[15:0])) < '0) ? '1:'0;
						
						// Determining whether the result of the operation is 
						// even and, hence, if the Parity flag should be set. 
						OutFlags.Parity = ~(^OutDest);
						
						// Determining whether or not the operation flows  
						// based on given conditions and setting the flag 
						// based on the result.
						OutFlags.Overflow = (~InDest[DataWidth-1] & InSrc[DataWidth-1] & OutDest[DataWidth-1]) | (InDest[DataWidth-1] & ~InSrc[DataWidth-1] & ~OutDest[DataWidth-1]);
						
						end
			
			// Setting the value of register Dest to the result of the signed  
			// integer division of the contents of registers Dest and Src.  			
			DIV: 		begin
			
						// Calculating the value of register Dest.
						OutDest = 16'(signed'(InDest))/16'(signed'(InSrc));
						
						// Determining whether the result of the operation is 
						// zero and, hence, if the Zero flag should be set. 
						OutFlags.Zero = (16'(signed'(OutDest[15:0])) == 0) ? '1:'0;
						
						// Determining whether the result of the operation is 
						// negative and, hence, if the Negative flag should be set. 
						OutFlags.Negative = (16'(signed'(OutDest[15:0])) < 0) ? '1:'0;
						
						// Determining whether the result of the operation is 
						// even and, hence, if the Parity flag should be set. 
						OutFlags.Parity = ~(^OutDest);
						
						end
			
				
			// Setting the value of register Dest to remainder of the signed 
			// integer division of the contents of registers Dest and Src.  		
			MOD: 		begin
			
						// Calculating the value of register Dest.
						OutDest = 16'(signed'(InDest)%signed'(InSrc));
						
						// Determining whether the result of the operation is 
						// zero and, hence, if the Zero flag should be set. 
						OutFlags.Zero = (OutDest == 0) ? '1:'0;
						
						// Determining whether the result of the operation is 
						// negative and, hence, if the Negative flag should be set.
						OutFlags.Negative = (OutDest < 0) ? '1:'0;
						
						// Determining whether the result of the operation is 
						// even and, hence, if the Parity flag should be set. 
						OutFlags.Parity = ~(^OutDest);
						
						end
			
			// Setting the value of register Dest to the lower half (bottom 
			// 16 bits) of the signed integer product of the contact of 
			// registers Dest and Src.
			MUL:		begin
			
						// Calculating the value of register Dest.
						OutDest = 16'(signed'(InDest)*signed'(InSrc));
						
						// Determining whether the result of the operation is 
						// zero and, hence, if the Zero flag should be set. 
						OutFlags.Zero = (OutDest == 0) ? '1:'0;
						
						// Determining whether the result of the operation is 
						// negative and, hence, if the Negative flag should be set.
						OutFlags.Negative = (OutDest < 0) ? '1:'0;
						
						// Determining whether the result of the operation is 
						// even and, hence, if the Parity flag should be set. 
						OutFlags.Parity = ~(^OutDest);
						
						end
			
			// Setting the value of register Dest to the upper half (top 
			// 16 bits) of the signed integer product of the contact of 
			// registers Dest and Src.
			MUH:		begin
			
						// Concatenating the upper 16 bits of OutDest with the 
						// lower 16 bits, which sets the value of OutDest to the upper bits
						{OutDest,OutDest} = (signed'(InDest)*signed'(InSrc));
						
						// Determining whether the result of the operation is 
						// zero and, hence, if the Zero flag should be set. 
						OutFlags.Zero = (OutDest == 0) ? '1:'0;
						
						// Determining whether the result of the operation is 
						// negative and, hence, if the Negative flag should be set.
						OutFlags.Negative = (OutDest < 0) ? '1:'0;
						
						// Determining whether the result of the operation is 
						// even and, hence, if the Parity flag should be set. 
						OutFlags.Parity = ~(^OutDest);
						
						end
						
			
			// ***** ONLY CHANGES ABOVE THIS LINE ARE ASSESSED	*****		
			
			default:	OutDest = '0;
			
		endcase;
	end

endmodule
