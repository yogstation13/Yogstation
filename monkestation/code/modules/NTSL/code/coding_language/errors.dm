/datum/scriptError
	///A message describing the problem.
	var/message

/datum/scriptError/New(msg)
	if(msg)
		message = msg

/datum/scriptError/BadToken
	message = "Unexpected token: "
	var/datum/token/token

/datum/scriptError/BadToken/New(datum/token/token)
	src.token = token

	if(token && token.line)
		message = "[token.line]: [message]"
	if(istype(token))
		message += "[token.value]"
	else
		message += "[token]"

/datum/scriptError/InvalidID
	parent_type = /datum/scriptError/BadToken
	message = "Invalid identifier name: "

/datum/scriptError/ReservedWord
	parent_type = /datum/scriptError/BadToken
	message = "Identifer using reserved word: "

/datum/scriptError/BadNumber
	parent_type = /datum/scriptError/BadToken
	message = "Bad number: "

/datum/scriptError/BadReturn
	message = "Unexpected return statement outside of a function."
	var/datum/token/token

/datum/scriptError/BadReturn/New(datum/token/token)
	src.token = token

/datum/scriptError/EndOfFile
	message = "Unexpected end of file."

/datum/scriptError/ExpectedToken
	message = "Expected: "

/datum/scriptError/ExpectedToken/New(id, datum/token/token)
	if(token)
		message = "[token.line ? token.line : "???"]: [message]'[id]'. Found '[token.value]'."
	else
		message = "???: [message]'[id]'. Token did not exist!"

/datum/scriptError/UnterminatedComment
	message = "Unterminated multi-line comment statement: expected */"

/datum/scriptError/DuplicateFunction

/datum/scriptError/DuplicateFunction/New(name, datum/token/token)
	message = "Function '[name]' defined twice."

/datum/scriptError/ParameterFunction
	message = "You cannot use a function inside a parameter."

/datum/scriptError/ParameterFunction/New(datum/token/token)
	var/line = "???"
	if(token)
		line = token.line
	message = "[line]: [message]"

/datum/scriptError/InvalidAssignment
	message = "Left side of assignment cannot be assigned to."

/datum/scriptError/OutdatedScript
	message = "Your script looks like it was for an older version of NTSL! Your script may not work as intended. See documentation for new syntax and API."

/*
 * Runtime Error
 * An error thrown by the interpreter in running the script.
 */
/datum/runtimeError
	var/name
	///A basic description as to what went wrong.
	var/message
	var/datum/scope/scope
	var/datum/token/token

///Returns a description of the error suitable for showing to the user.
/datum/runtimeError/proc/ToString()
	. = "[name]: [message]"
	if(!scope)
		return
	var/last_line
	var/last_col
	if(token)
		last_line = token.line
		last_col = token.column
	var/datum/scope/cur_scope = scope
	while(cur_scope)
		if(cur_scope.function)
			. += "\n\tat [cur_scope.function.func_name]([last_line]:[last_col])"
			if(cur_scope.call_node && cur_scope.call_node.token)
				last_line = cur_scope.call_node.token.line
				last_col = cur_scope.call_node.token.column
			else
				last_line = null
				last_col = null
		cur_scope = cur_scope.parent
	if(last_line)
		. += "\n\tat \[global]([last_line]:[last_col])"
	else
		. += "\n\tat \[internal]"

/datum/runtimeError/TypeMismatch
	name = "TypeMismatchError"

/datum/runtimeError/TypeMismatch/New(op, a, b)
	if(isnull(a))
		a = "NULL"
	if(isnull(b))
		b = "NULL"
	message = "Type mismatch: '[a]' [op] '[b]'"

/datum/runtimeError/UnexpectedReturn
	name = "UnexpectedReturnError"
	message = "Unexpected return statement."

/datum/runtimeError/UnknownInstruction
	name = "UnknownInstructionError"

/datum/runtimeError/UnknownInstruction/New(datum/node/op)
	message = "Unknown instruction type '[op.type]'. This may be due to incompatible compiler and interpreter versions or a lack of implementation."

/datum/runtimeError/UndefinedVariable
	name = "UndefinedVariableError"

/datum/runtimeError/UndefinedVariable/New(variable)
	message = "Variable '[variable]' has not been declared."

/datum/runtimeError/IndexOutOfRange
	name = "IndexOutOfRangeError"

/datum/runtimeError/IndexOutOfRange/New(obj, idx)
	message = "Index [obj]\[[idx]] is out of range."

/datum/runtimeError/UndefinedFunction
	name = "UndefinedFunctionError"

/datum/runtimeError/UndefinedFunction/New(function)
	message = "Function '[function]()' has not been defined."

/datum/runtimeError/DuplicateVariableDeclaration
	name = "DuplicateVariableError"

/datum/runtimeError/DuplicateVariableDeclaration/New(variable)
	message = "Variable '[variable]' was already declared."

/datum/runtimeError/IterationLimitReached
	name = "MaxIterationError"
	message = "A loop has reached its maximum number of iterations."

/datum/runtimeError/RecursionLimitReached
	name = "MaxRecursionError"
	message = "The maximum amount of recursion has been reached."

/datum/runtimeError/DivisionByZero
	name = "DivideByZeroError"
	message = "Division by zero (or a NULL value) attempted."

/datum/runtimeError/InvalidAssignment
	message = "Left side of assignment cannot be assigned to."

/datum/runtimeError/MaxCPU
	name = "MaxComputationalUse"

/datum/runtimeError/MaxCPU/New(maxcycles)
	message = "Maximum amount of computational cycles reached (>= [maxcycles])."

/datum/runtimeError/Internal
	name = "InternalError"

/datum/runtimeError/Internal/New(exception/exception_message)
	message = exception_message.name
