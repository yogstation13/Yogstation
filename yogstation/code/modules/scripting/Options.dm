/*
File: Options
*/
#define ascii_A 65
#define ascii_Z 90
#define ascii_a 97
#define ascii_z 122
#define ascii_DOLLAR 36 // $
#define ascii_ZERO 48
#define ascii_NINE 57
#define ascii_UNDERSCORE 95	// _

/*
	Class: n_scriptOptions
*/
n_scriptOptions
/*
	Class: nS_Options
	An implementation of <n_scriptOptions> for the n_Script language.
*/
	nS_Options
		var/list/symbols = list("(", ")", "\[", "]", ";", ",", "{", "}", ".")  //scanner - Characters that can be in symbols
/*
	Var: keywords
	An associative list used by the parser to parse keywords. Indices are strings which will trigger the keyword when parsed and the
	associated values are <nS_Keyword> types of which the <n_Keyword.Parse()> proc will be called.
*/
		var/list/keywords	= list(	"if" = /n_Keyword/nS_Keyword/kwIf,  "else"  = /n_Keyword/nS_Keyword/kwElse, "elseif" = /n_Keyword/nS_Keyword/kwElseIf, \
											"while"	  = /n_Keyword/nS_Keyword/kwWhile,		"break"	= /n_Keyword/nS_Keyword/kwBreak, \
											"continue" = /n_Keyword/nS_Keyword/kwContinue, "for"	  = /n_Keyword/nS_Keyword/kwFor,\
											"return" = /n_Keyword/nS_Keyword/kwReturn, 		"def"   = /n_Keyword/nS_Keyword/kwDef)
		var/list/unary_operators = list(	"!"  = /node/expression/oper/unary/LogicalNot,	 "~"  = /node/expression/oper/unary/BitwiseNot,
													"-"  = /node/expression/oper/unary/Minus)

		var/list/binary_operators=list(	"==" = /node/expression/oper/binary/Equal, 			   "!="	= /node/expression/oper/binary/NotEqual,
													">"  = /node/expression/oper/binary/Greater, 			"<" 	= /node/expression/oper/binary/Less,
													">=" = /node/expression/oper/binary/GreaterOrEqual,	"<=" = /node/expression/oper/binary/LessOrEqual,
													"&&" = /node/expression/oper/binary/LogicalAnd,  		"||"	= /node/expression/oper/binary/LogicalOr,
													"&"  = /node/expression/oper/binary/BitwiseAnd,  		"|" 	= /node/expression/oper/binary/BitwiseOr,
													"`"  = /node/expression/oper/binary/BitwiseXor,  		"+" 	= /node/expression/oper/binary/Add,
													"-"  = /node/expression/oper/binary/Subtract, 			"*" 	= /node/expression/oper/binary/Multiply,
													"/"  = /node/expression/oper/binary/Divide, 			"^" 	= /node/expression/oper/binary/Power,
													"%"  = /node/expression/oper/binary/Modulo,
													"="  = /node/expression/oper/binary/Assign, 					 "&=" = /node/expression/oper/binary/Assign/BitwiseAnd,
													"|=" = /node/expression/oper/binary/Assign/BitwiseOr,					 	 "`=" = /node/expression/oper/binary/Assign/BitwiseXor,
													"+=" = /node/expression/oper/binary/Assign/Add,						 "-=" = /node/expression/oper/binary/Assign/Subtract,
													"*=" = /node/expression/oper/binary/Assign/Multiply,						 "/=" = /node/expression/oper/binary/Assign/Divide,
													"^=" = /node/expression/oper/binary/Assign/Power,
													"%=" = /node/expression/oper/binary/Assign/Modulo)
		New()
			.=..()
			for(var/O in binary_operators+unary_operators)
				if(!symbols.Find(O)) symbols+=O

n_scriptOptions/proc/CanStartID(char) //returns true if the character can start a variable, function, or keyword name (by default letters or an underscore)
	if(!isnum(char))
		char=text2ascii(char)
	return (char in ascii_A to ascii_Z) || (char in ascii_a to ascii_z) || char==ascii_UNDERSCORE || char==ascii_DOLLAR

n_scriptOptions/proc/IsValidIDChar(char) //returns true if the character can be in the body of a variable, function, or keyword name (by default letters, numbers, and underscore)
	if(!isnum(char))
		char=text2ascii(char)
	return CanStartID(char) || IsDigit(char)

n_scriptOptions/proc/IsDigit(char)
	if(!isnum(char))
		char=text2ascii(char)
	return char in ascii_ZERO to ascii_NINE

n_scriptOptions/proc/IsValidID(id)    //returns true if all the characters in the string are okay to be in an identifier name
	if(!CanStartID(id)) //don't need to grab first char in id, since text2ascii does it automatically
		return 0
	if(length(id)==1)
		return 1
	for(var/i=2 to length(id))
		if(!IsValidIDChar(copytext(id, i, i+1)))
			return 0
	return 1
#undef ascii_A
#undef ascii_Z
#undef ascii_a
#undef ascii_z
#undef ascii_DOLLAR
#undef ascii_ZERO
#undef ascii_NINE
#undef ascii_UNDERSCORE
