/**
 * Unary Operators
 * 
 * Class: Unary
 * Represents a Unary operator in the AST.
 * Unary operators take a single operand (referred to as 'x' below) and returns a value.
 */
/datum/node/expression/expression_operator/unary
	precedence = OOP_UNARY

/**
 * Class: LogicalNot
 * Returns !x
 * 
 * Ex: !TRUE = FALSE and !FALSE = TRUE
 */
/datum/node/expression/expression_operator/unary/LogicalNot
	name = "logical not"

/**
 * Class: BitwiseNot
 * Returns the value of a bitwise not operation performed on x
 * 
 * Ex: ~10 (decimal 2) = 01 (decimal 1)
 */
/datum/node/expression/expression_operator/unary/BitwiseNot
	name = "bitwise not"

/**
 * Class: Minus
 * Returns -x
 */
/datum/node/expression/expression_operator/unary/Minus
	name = "minus"

/**
 * Class: Group
 * A special unary operator representing a value in parentheses.
 */
/datum/node/expression/expression_operator/unary/group
	precedence = OOP_GROUP
