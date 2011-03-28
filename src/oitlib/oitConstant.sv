// ============================================================================
// Takes the logorithm of the given base on the given power.
// base:   The base of the logorithm
// power:  The power of the logorithm
// return: The result of the logorithm rounded down
// Author: Keith Majhor
// Updated: Thomas Suckow
// ============================================================================
function integer oitLog;
  input integer base;
  input integer power;

	for ( oitLog = 0, power = power; power > 1; power = power / base )
		oitLog = oitLog + 1;

endfunction

// ============================================================================
// Determines the number of bits required to encode the given number of states.
// count:  The number of states
// return: The number of bits required
// Author: Keith Majhor
// Updated: Thomas Suckow
// ============================================================================
function integer oitBits;
  input integer count;

	oitBits = oitLog( 2, count - 1 ) + 1;
	
endfunction

// ============================================================================
// Takes the given base to the given power.
// base:   The base of the powerial
// power:  The power of the powerial
// return: The result of the powerial
// Author: Keith Majhor
// Updated: Thomas Suckow
// ============================================================================
function integer oitPow;
	input integer base;
    input integer power;

	for ( oitPow = 1, power = power; power > 0; power = power - 1 )
		oitPow = oitPow * base;
		
endfunction

// ============================================================================
// Determines the maximum of two given inputs.
// x:      A value
// y:      A value
// return: The maximum of the two given values
// Author: Keith Majhor
// Updated: Thomas Suckow
// ============================================================================
function integer oitMax;
	input integer x;
	input integer y;

	oitMax = (x > y) ? x : y;
	
endfunction

// ============================================================================
// Determines the minimum of two given inputs.
// x:      A value
// y:      A value
// return: The minimum of the two given values
// Author: Keith Majhor
// Updated: Thomas Suckow
// ============================================================================
function integer oitMin;
	input integer x;
	input integer y;

	oitMin = x < y ? x : y;
	
endfunction
/* Filetype tags for editors.
* vim: set filetype=verilog : 
*/
