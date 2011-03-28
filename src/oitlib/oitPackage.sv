// ============================================================================
// Package oit
//
// Author: Thomas Suckow
// ============================================================================
package oit;

// ============================================================================
// Takes the logorithm of the given base on the given power.
// base:   The base of the logorithm
// power:  The power of the logorithm
// return: The result of the logorithm rounded down
// Author: Keith Majhor
// Updated: Thomas Suckow
// ============================================================================
function integer log;
  input integer base;
  input integer power;

	for ( log = 0, power = power; power > 1; power = power / base )
		log = log + 1;

endfunction

// ============================================================================
// Determines the number of bits required to encode the given number of states.
// count:  The number of states
// return: The number of bits required
// Author: Keith Majhor
// Updated: Thomas Suckow
// ============================================================================
function integer bits;
  input integer count;

	bits = log( 2, count - 1 ) + 1;
	
endfunction

// ============================================================================
// Takes the given base to the given power.
// base:   The base of the powerial
// power:  The power of the powerial
// return: The result of the powerial
// Author: Keith Majhor
// Updated: Thomas Suckow
// ============================================================================
function integer pow;
	input integer base;
    input integer power;

	for ( pow = 1, power = power; power > 0; power = power - 1 )
		pow = pow * base;
		
endfunction

// ============================================================================
// Determines the maximum of two given inputs.
// x:      A value
// y:      A value
// return: The maximum of the two given values
// Author: Keith Majhor
// Updated: Thomas Suckow
// ============================================================================
function integer max;
	input integer x;
	input integer y;

	max = (x > y) ? x : y;
	
endfunction

// ============================================================================
// Determines the minimum of two given inputs.
// x:      A value
// y:      A value
// return: The minimum of the two given values
// Author: Keith Majhor
// Updated: Thomas Suckow
// ============================================================================
function integer min;
	input integer x;
	input integer y;

	min = x < y ? x : y;
	
endfunction

endpackage
