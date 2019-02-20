/*
	Class: scope
	A runtime instance of a block. Used internally by the interpreter.
*/
/scope
	var/scope/parent
	var/scope/variables_parent
	var/node/BlockDefinition/block
	var/list/functions
	var/list/variables
	var/status = 0
	var/allowed_status = 0
	var/recursion = 0
	var/node/statement/FunctionDefinition/function
	var/node/expression/FunctionCall/call_node
	var/return_val

/scope/New(node/BlockDefinition/B, scope/parent, scope/variables_parent, allowed_status = 0)
	src.block = B
	src.parent = parent
	src.variables_parent = variables_parent || parent
	if(B)
		src.variables = B.initial_variables.Copy()
		src.functions = B.functions.Copy()
	else
		src.variables = list()
		src.functions = list()
	if(parent)
		src.status = parent.status
		recursion = parent.recursion

	if(allowed_status & RESET_STATUS || !parent)
		src.allowed_status = allowed_status & ~RESET_STATUS
	else
		src.allowed_status = allowed_status | parent.allowed_status
	.=..()

/scope/proc/get_scope(name)
	var/scope/S = src
	while(S)
		if(S.variables.Find(name))
			return S
		S = S.variables_parent

/scope/proc/push(node/BlockDefinition/B, scope/variables_parent = src, allowed_status = 0)
	return new /scope(B, src, variables_parent, allowed_status)

/scope/proc/pop(keep_status = (BREAKING | CONTINUING | RETURNING)) // keep_status is which flags you want to copy to the parent.
	parent.status = (parent.status & ~keep_status) | (status & keep_status)
	if(parent.status & RETURNING)
		parent.return_val = return_val
	return parent

/scope/proc/get_var(name, n_Interpreter/interp)
	var/scope/S = get_scope(name)
	if(S)
		return S.variables[name]
	else if(interp)
		interp.RaiseError(new/runtimeError/UndefinedVariable(name))

/scope/proc/get_function(name)
	var/scope/S = src
	while(S)
		. = S.functions[name]
		if(.)
			return
		S = S.variables_parent

/scope/proc/set_var(name, val)
	var/scope/S = get_scope(name)
	if(S)
		S.variables[name] = val
	else
		init_var(name, val)
	return val

/scope/proc/init_var(name, val, n_Interpreter/interp)
	if(variables.Find(name) && interp)
		interp.RaiseError(new/runtimeError/DuplicateVariableDeclaration(name))
	variables[name] = val
