/*
 * binary
 * Represents a binary operator in the AST. A binary operator takes two operands (ie x and y) and returns a value.
 */
/datum/node/expression/expression_operator/binary
	var/datum/node/expression/exp2

/**
 * Equal
 * Returns TRUE if x == y
 */
/datum/node/expression/expression_operator/binary/Equal
	precedence = OOP_EQUAL

/**
 * NotEqual
 * 
 * Returns TRUE if x != y
 */
/datum/node/expression/expression_operator/binary/NotEqual
	precedence = OOP_EQUAL

/**
 * Greater
 * Returns TRUE if x > y
 */
/datum/node/expression/expression_operator/binary/Greater
	precedence = OOP_COMPARE

/**
 * Less
 * Returns TRUE if x < y
 */
/datum/node/expression/expression_operator/binary/Less
	precedence = OOP_COMPARE

/**
 * GreaterOrEqual
 * Returns TRUE if x >= y
 */
/datum/node/expression/expression_operator/binary/GreaterOrEqual
	precedence = OOP_COMPARE

/**
 * LessOrEqual
 * Returns TRUE if x <= y
 */
/datum/node/expression/expression_operator/binary/LessOrEqual
	precedence = OOP_COMPARE


/**
 * LogicalAnd
 * Returns TRUE if x and y are TRUE
 */
/datum/node/expression/expression_operator/binary/LogicalAnd
	precedence = OOP_AND

/**
 * LogicalOr
 * Returns TRUE if x and/or y are TRUE
 */
/datum/node/expression/expression_operator/binary/LogicalOr
	precedence = OOP_OR

/**
 * LogicalXor
 * Returns TRUE if either x or y are TRUE, but not both.
 * Not implemented in nS
 */
/datum/node/expression/expression_operator/binary/LogicalXor
	precedence = OOP_OR


/**
 * BitwiseAnd
 * Performs a Bitwise operation
 * 
 * Example: 011 & 110 = 010
 */
/datum/node/expression/expression_operator/binary/BitwiseAnd
	precedence = OOP_BIT

/**
 * BitwiseOr
 * Performs a bitwise or operation
 * 
 * Example: 011 | 110 = 111
 */
/datum/node/expression/expression_operator/binary/BitwiseOr
	precedence = OOP_BIT

/**
 * BitwiseXor
 * Performs a bitwise exclusive or operation
 * 
 * Example: 011 xor 110 = 101
 */
/datum/node/expression/expression_operator/binary/BitwiseXor
	precedence = OOP_BIT

/**
 * Add
 * Returns the sum of x and y
 */
/datum/node/expression/expression_operator/binary/Add
	precedence = OOP_ADD

/**
 * Substract
 * Returns the difference of x and y
 */
/datum/node/expression/expression_operator/binary/Subtract
	precedence = OOP_ADD

/**
 * Multiply
 * Returns the product of x and y
 */
/datum/node/expression/expression_operator/binary/Multiply
	precedence = OOP_MULTIPLY

/**
 * Divide
 * Returns the quotient of x and y
 */
/datum/node/expression/expression_operator/binary/Divide
	precedence = OOP_MULTIPLY

/**
 * Power
 * Returns x raised to the power of y
 */
/datum/node/expression/expression_operator/binary/Power
	precedence = OOP_POW

/**
 * Modulo
 * Returns the remainder of x / y
 */
/datum/node/expression/expression_operator/binary/Modulo
	precedence = OOP_MULTIPLY

/**
 * Assign
 */
/datum/node/expression/expression_operator/binary/Assign
	precedence = OOP_ASSIGN

/datum/node/expression/expression_operator/binary/Assign/BitwiseAnd

/datum/node/expression/expression_operator/binary/Assign/BitwiseOr

/datum/node/expression/expression_operator/binary/Assign/BitwiseXor

/datum/node/expression/expression_operator/binary/Assign/Add

/datum/node/expression/expression_operator/binary/Assign/Subtract

/datum/node/expression/expression_operator/binary/Assign/Multiply

/datum/node/expression/expression_operator/binary/Assign/Divide

/datum/node/expression/expression_operator/binary/Assign/Power

/datum/node/expression/expression_operator/binary/Assign/Modulo
