/n_Interpreter/proc/get_property(object, key, scope/scope)
	if(islist(object))
		var/list/L = object
		if(key == "len")
			return L.len
	else if(isdatum(object))
		var/datum/D = object
		return D.ntsl_get(key, scope, src)
	interp.RaiseError(new/runtimeError/UndefinedVariable("[object].[key]"))

/n_Interpreter/proc/set_property(object, key, val, scope/scope)
	if(isdatum(object))
		var/datum/D = object
		D.ntsl_set(key, val, scope, src)
		return
	interp.RaiseError(new/runtimeError/UndefinedVariable("[object].[key]"))

/datum/ntsl_get(key, scope/scope, n_Interpreter/interp)
	interp.RaiseError(new/runtimeError/UndefinedVariable("[src].[key]"))
	return

/datum/ntsl_set(key, val, scope/scope, n_Interpreter/interp)
	interp.RaiseError(new/runtimeError/UndefinedVariable("[src].[key]"))
	return

/datum/n_function
	var/name = ""

/datum/n_function/proc/execute(this_obj, list/params, scope/scope, n_Interpreter/interp)
	return

/datum/n_function/defined
	var/n_Interpreter/context
	var/scope/closure
	var/node/statement/FunctionDefinition/def

/datum/n_function/defined/New(node/statement/FunctionDefinition/D, scope/S, n_Interpreter/C)
	def = D
	closure = S
	context = C

/datum/n_function/defined/execute(this_obj, list/params, scope/scope, n_Interpreter/interp)
	if(scope.recursion >= 10)
		interp.AlertAdmins()
		interp.RaiseError(new/runtimeError/RecursionLimitReached())
		return 0
	scope = scope.push(def.block, closure, RESET_STATUS | RETURNING)
	scope.recursion++
	scope.function = def
	for(var/i=1 to def.parameters.len)
		var/val
		if(params.len>=i)
			val = params[i]
		//else
		//	unspecified param
		scope.init_var(def.parameters[i], val)
	scope.init_var("src", this_obj);
	interp.RunBlock(def.block, scope)
	//Handle return value
	. = scope.return_val
	scope = scope.pop(0) // keep nothing

/datum/n_function/default
	// functions included on compilation
	var/interp_type = /n_Interpreter // include this function in this kind of interpreter.
	var/list/aliases // in case you want to give it multiple "names"
