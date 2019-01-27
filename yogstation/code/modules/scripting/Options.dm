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
		var/list/symbols = list("(", ")", "\[", "]", ";", ",", "{", "}")  //scanner - Characters that can be in symbols
/*
	Var: keywords
	An associative list used by the parser to parse keywords. Indices are strings which will trigger the keyword when parsed and the
	associated values are <nS_Keyword> types of which the <n_Keyword.Parse()> proc will be called.
*/
		var/list/keywords	= list(	"if" = /n_Keyword/nS_Keyword/kwIf,  "else"  = /n_Keyword/nS_Keyword/kwElse, "elseif" = /n_Keyword/nS_Keyword/kwElseIf, \
											"while"	  = /n_Keyword/nS_Keyword/kwWhile,		"break"	= /n_Keyword/nS_Keyword/kwBreak, \
											"continue" = /n_Keyword/nS_Keyword/kwContinue, \
											"return" = /n_Keyword/nS_Keyword/kwReturn, 		"def"   = /n_Keyword/nS_Keyword/kwDef)

		var/list/assign_operators = list(	"="  = null, 					 "&=" = "&",
												 		"|=" = "|",					 	 "`=" = "`",
														"+=" = "+",						 "-=" = "-",
														"*=" = "*",						 "/=" = "/",
														"^=" = "^",
														"%=" = "%")

		var/list/unary_operators = list(	"!"  = /node/expression/operator/unary/LogicalNot,	 "~"  = /node/expression/operator/unary/BitwiseNot,
													"-"  = /node/expression/operator/unary/Minus)

		var/list/binary_operators=list(	"==" = /node/expression/operator/binary/Equal, 			   "!="	= /node/expression/operator/binary/NotEqual,
													">"  = /node/expression/operator/binary/Greater, 			"<" 	= /node/expression/operator/binary/Less,
													">=" = /node/expression/operator/binary/GreaterOrEqual,	"<=" = /node/expression/operator/binary/LessOrEqual,
													"&&" = /node/expression/operator/binary/LogicalAnd,  		"||"	= /node/expression/operator/binary/LogicalOr,
													"&"  = /node/expression/operator/binary/BitwiseAnd,  		"|" 	= /node/expression/operator/binary/BitwiseOr,
													"`"  = /node/expression/operator/binary/BitwiseXor,  		"+" 	= /node/expression/operator/binary/Add,
													"-"  = /node/expression/operator/binary/Subtract, 			"*" 	= /node/expression/operator/binary/Multiply,
													"/"  = /node/expression/operator/binary/Divide, 			"^" 	= /node/expression/operator/binary/Power,
													"%"  = /node/expression/operator/binary/Modulo)
		New()
			.=..()
			for(var/O in assign_operators+binary_operators+unary_operators)
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
	if(lentext(id)==1) 
		return 1
	for(var/i=2 to lentext(id))
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