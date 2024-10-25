/*
 * Macros: Expression Macros
 */
///A value indicating the parser currently expects a binary operator.
#define OPERATOR 1
///A value indicating the parser currently expects a value.
#define VALUE 2
///Tells the parser to push the current operator onto the stack.
#define SHIFT 0
///Tells the parser to reduce the stack.
#define REDUCE 1

/datum/n_Parser/nS_Parser
	///A variable which keeps track of whether an operator or value is expected.
	///It should be either <OPERATOR> or <VALUE>. See <ParseExpression()> for more information.
	var/expecting = VALUE

///Compares two operators, decides which is higher in the order of operations, and returns <SHIFT> or <REDUCE>.
/datum/n_Parser/nS_Parser/proc/Precedence(datum/node/expression/expression_operator/top, datum/node/expression/expression_operator/input)
	if(istype(top))
		top = top.precedence
	if(istype(input))
		input = input.precedence
	if(top >= input)
		return REDUCE
	return SHIFT

///Takes a token expected to represent a value and returns an <expression> node.
/datum/n_Parser/nS_Parser/proc/GetExpression(datum/token/T) as /datum/node/expression
	if(!T)
		return
	if(istype(T, /datum/node/expression))
		return T
	switch(T.type)
		if(/datum/token/word)
			return new /datum/node/expression/value/variable(T.value, T)
		if(/datum/token/number, /datum/token/string)
			return new /datum/node/expression/value/literal(T.value, T)

/*
 * GetOperator
 * Gets a path related to a token or string and returns an instance of the given type.
 * This is used to get an instance of either a binary or unary operator from a token.
 *
 * Arguments:
 * O - The input value. If this is a token, O is reset to the token's value.
 * When O is a string and is in L, its associated value is used as the path to instantiate.
 * type - The desired type of the returned object.
 * L - The list in which to search for O.
 *
 * See Also:
 * - <GetBinaryOperator()>
 * - <GetUnaryOperator()>
 */
/datum/n_Parser/nS_Parser/proc/GetOperator(O, type = /datum/node/expression/expression_operator, L[])
	var/datum/token/input_token
	if(istype(O, type))
		return O
	if(istype(O, /datum/token))
		input_token = O
		O = input_token.value
	if(istext(O))
		if(L.Find(O))
			O = L[O]
		else
			return null
	if(input_token)
		O = new O(input_token)
	else
		return null
	return O

/*
 * GetBinaryOperator
 * Uses <GetOperator()> to search for an instance of a binary operator type with which the given string is associated. For example, if
 * O is set to "+", an <Add> node is returned.
 *
 * See Also:
 * - <GetOperator()>
 * - <GetUnaryOperator()>
 */
/datum/n_Parser/nS_Parser/proc/GetBinaryOperator(O)
	return GetOperator(O, /datum/node/expression/expression_operator/binary, options.binary_operators)

/*
 * Proc: GetUnaryOperator
 * Uses <GetOperator()> to search for an instance of a unary operator type with which the given string is associated. For example, if
 * O is set to "!", a <LogicalNot> node is returned.
 *
 * See Also:
 * - <GetOperator()>
 * - <GetBinaryOperator()>
 */
/datum/n_Parser/nS_Parser/proc/GetUnaryOperator(O)
	return GetOperator(O, /datum/node/expression/expression_operator/unary, options.unary_operators)

/*
 * Reduce
 * Takes the operator on top of the opr stack and assigns its operand(s). Then this proc pushes the value of that operation to the top
 * of the val stack.
 */
/datum/n_Parser/nS_Parser/proc/Reduce(datum/stack/opr, datum/stack/val, check_assignments = 1)
	var/datum/node/expression/expression_operator/O = opr.Pop()
	if(!O) return
	if(!istype(O))
		errors += new /datum/scriptError("Error reducing expression - invalid operator.")
		return
	//Take O and assign its operands, popping one or two values from the val stack
	//depending on whether O is a binary or unary operator.
	if(istype(O, /datum/node/expression/expression_operator/binary))
		var/datum/node/expression/expression_operator/binary/B = O
		B.exp2 = val.Pop()
		B.exp = val.Pop()
		val.Push(B)
		if(check_assignments && istype(B, /datum/node/expression/expression_operator/binary/Assign) && !istype(B.exp, /datum/node/expression/value/variable) && !istype(B.exp, /datum/node/expression/member))
			errors += new /datum/scriptError/InvalidAssignment()
	else
		O.exp = val.Pop()
		val.Push(O)

/*
 * EndOfExpression
 * Returns true if the current token represents the end of an expression.
 *
 * Arguments:
 * end - A list of values to compare the current token to.
 */
/datum/n_Parser/nS_Parser/proc/EndOfExpression(end[])
	if(!curToken)
		return TRUE
	if(istype(curToken, /datum/token/symbol) && end.Find(curToken.value))
		return TRUE
	if(istype(curToken, /datum/token/end) && end.Find(/datum/token/end))
		return TRUE
	return FALSE

/*
 * ParseExpression
 * Uses the Shunting-yard algorithm to parse expressions.
 *
 * Notes:
 * - When an opening parenthesis is found, then <ParseParenExpression()> is called to handle it.
 * - The <expecting> variable helps distinguish unary operators from binary operators (for cases like the - operator, which can be either).
 *
 * Articles:
 * - <http://epaperpress.com/oper/>
 * - <http://en.wikipedia.org/wiki/Shunting-yard_algorithm>
 *
 * See Also:
 * - <ParseFunctionExpression()>
 * - <ParseParenExpression()>
 * - <ParseParamExpression()>
 */
/datum/n_Parser/nS_Parser/proc/ParseExpression(list/end = list(/datum/token/end), list/ErrChars = list("{", "}"), check_functions = 0, check_assignments = 1)
	var/datum/stack/opr = new
	var/datum/stack/val = new

	expecting = VALUE
	var/loop = 0
	while(TRUE)
		loop++
		if(loop > 800)
			errors += new /datum/scriptError("Too many nested tokens.")
			return

		if(EndOfExpression(end))
			break
		if(istype(curToken, /datum/token/symbol) && ErrChars.Find(curToken.value))
			errors += new /datum/scriptError/BadToken(curToken)
			break


		if(index > length(tokens)) //End of File
			errors += new /datum/scriptError/EndOfFile()
			break
		var/datum/token/ntok
		if(index + 1 <= length(tokens))
			ntok = tokens[index + 1]

		if(istype(curToken, /datum/token/symbol) && curToken.value == "(") //Parse parentheses expression
			if(expecting == VALUE)
				val.Push(ParseParenExpression())
			else
				// you can call *anything*! You can even call "2()". It'll runtime though so just don't please.
				val.Push(ParseFunctionExpression(val.Pop()))
				expecting = OPERATOR
		else if(istype(curToken, /datum/token/symbol) && curToken.value == "." && ntok && istype(ntok, /datum/token/word))
			if(expecting == VALUE)
				errors += new /datum/scriptError/ExpectedToken("expression", curToken)
				NextToken()
				continue
			var/datum/node/expression/member/dot/E = new(curToken)
			E.object = val.Pop()
			NextToken()
			E.id = new(curToken.value, curToken)
			val.Push(E)
		else if(istype(curToken, /datum/token/symbol) && curToken.value == "\[")
			if(expecting == VALUE)
				errors += new /datum/scriptError/ExpectedToken("expression", curToken)
				NextToken()
				continue
			var/datum/node/expression/member/brackets/B = new(curToken)
			B.object = val.Pop()
			NextToken()
			B.index = ParseExpression(list("]"))
			val.Push(B)
		else if(istype(curToken, /datum/token/symbol)) //Operator found.
			var/datum/node/expression/expression_operator/curOperator //Figure out whether it is unary or binary and get a new instance.
			if(expecting == OPERATOR)
				curOperator = GetBinaryOperator(curToken)
				if(!curOperator)
					errors += new /datum/scriptError/ExpectedToken("operator", curToken)
					NextToken()
					continue
			else
				curOperator = GetUnaryOperator(curToken)
				if(!curOperator) //given symbol isn't a unary operator
					errors += new /datum/scriptError/ExpectedToken("expression", curToken)
					NextToken()
					continue

			if(opr.Top() && Precedence(opr.Top(), curOperator)== REDUCE) //Check order of operations and reduce if necessary
				Reduce(opr, val, check_assignments)
				continue
			opr.Push(curOperator)
			expecting = VALUE
		else if(istype(curToken, /datum/token/word) && curToken.value == "list" && ntok && ntok.value == "(" && expecting == VALUE)
			val.Push(ParseListExpression())
		else if(istype(curToken, /datum/token/keyword)) //inline keywords
			var/datum/n_Keyword/kw = options.keywords[curToken.value]
			kw = new kw(inline = 1)
			if(kw)
				if(!kw.Parse(src))
					return
			else
				errors += new /datum/scriptError/BadToken(curToken)

		else if(istype(curToken, /datum/token/end)) //semicolon found where it wasn't expected
			errors += new /datum/scriptError/BadToken(curToken)
			NextToken()
			continue
		else
			if(expecting != VALUE)
				errors += new /datum/scriptError/ExpectedToken("operator", curToken)
				NextToken()
				continue
			val.Push(GetExpression(curToken))
			expecting = OPERATOR

		NextToken()

	while(opr.Top())
		Reduce(opr, val, check_assignments) //Reduce the value stack completely
	. = val.Pop() //Return what should be the last value on the stack
	if(val.Top())
		var/datum/node/N = val.Pop()
		errors += new /datum/scriptError("Error parsing expression. Unexpected value left on stack: [N.ToString()].")
		return null

///Parses a function call inside of an expression. (See also <ParseExpression()>)
/datum/n_Parser/nS_Parser/proc/ParseFunctionExpression(func_exp) as /datum/node/expression/FunctionCall
	var/datum/node/expression/FunctionCall/exp = new(curToken)
	exp.function = func_exp
	NextToken() //skip open parenthesis, already found
	var/loops = 0

	while(TRUE)
		loops++
		if(loops >= 800)
			errors += new /datum/scriptError("Too many nested expressions.")
			break
			//CRASH("Something TERRIBLE has gone wrong in ParseFunctionExpression ;__;")

		if(istype(curToken, /datum/token/symbol) && curToken.value == ")")
			return exp
		exp.parameters += ParseParamExpression()
		if(length(errors))
			return exp
		if(curToken.value == "," && istype(curToken, /datum/token/symbol))
			NextToken()	//skip comma
		if(istype(curToken, /datum/token/end)) //Prevents infinite loop...
			errors += new /datum/scriptError/ExpectedToken(")")
			return exp

/datum/n_Parser/nS_Parser/proc/ParseListExpression() as /datum/node/expression/value/list_init
	var/datum/node/expression/value/list_init/exp = new(curToken)
	exp.init_list = list()
	NextToken() // skip the "list" word
	NextToken() // skip the open parenthesis
	var/loops = 0
	while(TRUE)
		loops++
		if(loops >= 800)
			errors += new /datum/scriptError("Too many nested expressions.")
			break

		if(istype(curToken, /datum/token/symbol) && curToken.value == ")")
			return exp
		var/datum/node/expression/E = ParseParamExpression(check_assignments = FALSE)
		if(E.type == /datum/node/expression/expression_operator/binary/Assign)
			var/datum/node/expression/expression_operator/binary/Assign/A = E
			exp.init_list[A.exp] = A.exp2
		else
			exp.init_list += E
		if(length(errors))
			return exp
		if(curToken.value == "," && istype(curToken, /datum/token/symbol))
			NextToken() //skip comma
		if(istype(curToken, /datum/token/end)) //Prevents infinite loop...
			errors += new /datum/scriptError/ExpectedToken(")")
			return exp

/*
 * ParseParenExpression
 * Parses an expression that ends with a close parenthesis. This is used for parsing expressions inside of parentheses.
 *
 * See Also:
 * - <ParseExpression()>
 */
/datum/n_Parser/nS_Parser/proc/ParseParenExpression() as /datum/node/expression/expression_operator/unary/group
	var/group_token = curToken
	if(!CheckToken("(", /datum/token/symbol))
		return
	return new /datum/node/expression/expression_operator/unary/group(group_token, ParseExpression(list(")")))

/*
 * Proc: ParseParamExpression
 * Parses an expression that ends with either a comma or close parenthesis. This is used for parsing the parameters passed to a function call.
 *
 * See Also:
 * - <ParseExpression()>
 */
/datum/n_Parser/nS_Parser/proc/ParseParamExpression(check_functions = 0, check_assignments = 1)
	var/cf = check_functions
	var/ca = check_assignments
	return ParseExpression(list(",", ")"), check_functions = cf, check_assignments = ca)

#undef OPERATOR
#undef VALUE
#undef SHIFT
#undef REDUCE
