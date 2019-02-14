/n_Interpreter/proc/get_property(object, propertyname, scope/scope)


/n_Interpreter/proc/set_property(object, propertyname, val, scope/scope)



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
		AlertAdmins()
		interp.RaiseError(new/runtimeError/RecursionLimitReached())
		return 0
	scope = scope.push(def.block, closure, RESET_STATUS | RETURNING)
	scope.recursion++
	scope.
	for(var/i=1 to def.parameters.len)
		var/val
		if(params.len>=i)
			val = params[i]
		//else
		//	unspecified param
		scope.init_var(def.parameters[i], val)
	scope.init_var("src", this_obj);
	RunBlock(def.block, scope)
	//Handle return value
	. = scope.return_val
	scope = scope.pop(0) // keep nothing

/datum/n_function/default
	// functions included on compilation
	var/interp_type = /n_Interpreter // include this function in this kind of interpreter.
	var/list/aliases // in case you want to give it multiple "names"

