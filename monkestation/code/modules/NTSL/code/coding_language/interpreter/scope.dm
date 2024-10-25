/*
 * Scope
 * A runtime instance of a block. Used internally by the interpreter.
 */
/datum/scope
	var/datum/scope/parent
	var/datum/scope/variables_parent
	var/datum/node/BlockDefinition/block
	var/list/functions
	var/list/variables
	var/status = 0
	var/allowed_status = 0
	var/recursion = 0
	var/datum/node/statement/FunctionDefinition/function
	var/datum/node/expression/FunctionCall/call_node
	var/return_val

/datum/scope/New(datum/node/BlockDefinition/B, datum/scope/parent, datum/scope/variables_parent, allowed_status = 0)
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
		src.recursion = parent.recursion

	if(allowed_status & RESET_STATUS || !parent)
		src.allowed_status = allowed_status & ~RESET_STATUS
	else
		src.allowed_status = allowed_status | parent.allowed_status
	return ..()

/datum/scope/Destroy()
	parent = null
	variables_parent = null
	block = null
	functions = null
	variables = null
	function = null
	call_node = null
	return ..()

/datum/scope/proc/get_scope(name)
	var/datum/scope/S = src
	while(S)
		if(S.variables.Find(name))
			return S
		S = S.variables_parent

/datum/scope/proc/push(datum/node/BlockDefinition/B, datum/scope/variables_parent = src, allowed_status = 0) as /datum/scope
	return new /datum/scope(B, src, variables_parent, allowed_status)

/datum/scope/proc/pop(keep_status = (BREAKING | CONTINUING | RETURNING)) // keep_status is which flags you want to copy to the parent.
	parent.status = (parent.status & ~keep_status) | (status & keep_status)
	if(parent.status & RETURNING)
		parent.return_val = return_val
	return parent

/datum/scope/proc/get_var(name, datum/n_Interpreter/interp, datum/node/node)
	var/datum/scope/S = get_scope(name)
	if(S)
		return S.variables[name]
	else if(interp)
		interp.RaiseError(new /datum/runtimeError/UndefinedVariable(name), src, node)

/datum/scope/proc/get_function(name)
	var/datum/scope/S = src
	while(S)
		. = S.functions[name]
		if(.)
			return
		S = S.variables_parent

/datum/scope/proc/set_var(name, val, datum/n_Interpreter/interp, datum/node/node)
	var/datum/scope/S = get_scope(name)
	if(S)
		S.variables[name] = val
	else
		init_var(name, val, interp, node)
	return val

/datum/scope/proc/init_var(name, val, datum/n_Interpreter/interp, datum/node/node)
	if(variables.Find(name) && interp)
		interp.RaiseError(new /datum/runtimeError/DuplicateVariableDeclaration(name), src, node)
	variables[name] = val
