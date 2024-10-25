#define ascii_A 65
#define ascii_Z 90
#define ascii_a 97
#define ascii_z 122
#define ascii_DOLLAR 36 // $
#define ascii_ZERO 48
#define ascii_NINE 57
#define ascii_UNDERSCORE 95	// _

/*
 * n_scriptOptions
 */
/datum/n_scriptOptions
	///scanner - Characters that can be in symbols
	var/list/symbols = list(
		"(",
		")",
		"\[",
		"]",
		";",
		",",
		"{",
		"}",
		".",
	)
	/*
	 * Var: keywords
	 * An associative list used by the parser to parse keywords. Indices are strings which will trigger the keyword when parsed and the
	 * associated values are <nS_Keyword> types of which the <n_Keyword.Parse()> proc will be called.
	 */
	var/list/keywords = list(
		"if" = /datum/n_Keyword/nS_Keyword/kwIf,
		"else" = /datum/n_Keyword/nS_Keyword/kwElse,
		"elseif" = /datum/n_Keyword/nS_Keyword/kwElseIf,
		"while" = /datum/n_Keyword/nS_Keyword/kwWhile,
		"break"	= /datum/n_Keyword/nS_Keyword/kwBreak,
		"continue" = /datum/n_Keyword/nS_Keyword/kwContinue,
		"for" = /datum/n_Keyword/nS_Keyword/kwFor,
		"return" = /datum/n_Keyword/nS_Keyword/kwReturn,
		"def"= /datum/n_Keyword/nS_Keyword/kwDef,
	)
	var/list/unary_operators = list(
		"!" = /datum/node/expression/expression_operator/unary/LogicalNot,
		"~" = /datum/node/expression/expression_operator/unary/BitwiseNot,
		"-" = /datum/node/expression/expression_operator/unary/Minus,
	)

	var/list/binary_operators = list(
		"==" = /datum/node/expression/expression_operator/binary/Equal,
		"!=" = /datum/node/expression/expression_operator/binary/NotEqual,
		">" = /datum/node/expression/expression_operator/binary/Greater,
		"<"= /datum/node/expression/expression_operator/binary/Less,
		">=" = /datum/node/expression/expression_operator/binary/GreaterOrEqual,
		"<=" = /datum/node/expression/expression_operator/binary/LessOrEqual,
		"&&" = /datum/node/expression/expression_operator/binary/LogicalAnd,
		"||" = /datum/node/expression/expression_operator/binary/LogicalOr,
		"&" = /datum/node/expression/expression_operator/binary/BitwiseAnd,
		"|"= /datum/node/expression/expression_operator/binary/BitwiseOr,
		"`" = /datum/node/expression/expression_operator/binary/BitwiseXor,
		"+"= /datum/node/expression/expression_operator/binary/Add,
		"-" = /datum/node/expression/expression_operator/binary/Subtract,
		"*"= /datum/node/expression/expression_operator/binary/Multiply,
		"/" = /datum/node/expression/expression_operator/binary/Divide,
		"^"= /datum/node/expression/expression_operator/binary/Power,
		"%" = /datum/node/expression/expression_operator/binary/Modulo,
		"=" = /datum/node/expression/expression_operator/binary/Assign,
		"&=" = /datum/node/expression/expression_operator/binary/Assign/BitwiseAnd,
		"|=" = /datum/node/expression/expression_operator/binary/Assign/BitwiseOr,
		"`=" = /datum/node/expression/expression_operator/binary/Assign/BitwiseXor,
		"+=" = /datum/node/expression/expression_operator/binary/Assign/Add,
		"-=" = /datum/node/expression/expression_operator/binary/Assign/Subtract,
		"*=" = /datum/node/expression/expression_operator/binary/Assign/Multiply,
		"/=" = /datum/node/expression/expression_operator/binary/Assign/Divide,
		"^=" = /datum/node/expression/expression_operator/binary/Assign/Power,
		"%=" = /datum/node/expression/expression_operator/binary/Assign/Modulo,
	)

/datum/n_scriptOptions/New()
	. = ..()
	for(var/operators in binary_operators + unary_operators)
		if(!symbols.Find(operators))
			symbols += operators

///Returns TRUE if the character can start a variable, function, or keyword name (by default letters or an underscore)
/datum/n_scriptOptions/proc/CanStartID(char)
	if(!isnum(char))
		char = text2ascii(char)
	return (char in ascii_A to ascii_Z) || (char in ascii_a to ascii_z) || char == ascii_UNDERSCORE || char == ascii_DOLLAR

///Returns TRUE if the character can be in the body of a variable, function, or keyword name (by default letters, numbers, and underscore)
/datum/n_scriptOptions/proc/IsValidIDChar(char)
	if(!isnum(char))
		char = text2ascii(char)
	return CanStartID(char) || IsDigit(char)

/datum/n_scriptOptions/proc/IsDigit(char)
	if(!isnum(char))
		char = text2ascii(char)
	return char in ascii_ZERO to ascii_NINE

///Returns TRUE if all the characters in the string are okay to be in an identifier name.
/datum/n_scriptOptions/proc/IsValidID(id)
	if(!CanStartID(id)) //don't need to grab first char in id, since text2ascii does it automatically
		return FALSE
	if(length(id) == 1)
		return TRUE
	for(var/i = 2 to length(id))
		if(!IsValidIDChar(copytext(id, i, i+1)))
			return FALSE
	return TRUE

#undef ascii_A
#undef ascii_Z
#undef ascii_a
#undef ascii_z
#undef ascii_DOLLAR
#undef ascii_ZERO
#undef ascii_NINE
#undef ascii_UNDERSCORE
