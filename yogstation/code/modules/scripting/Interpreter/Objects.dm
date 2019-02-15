GLOBAL_LIST_EMPTY(ntsl_methods)

/n_Interpreter/proc/get_property(object, key, scope/scope)
	if(islist(object))
		var/list/L = object
		if(key == "len")
			return L.len
	else if(istype(object, /datum))
		var/datum/D = object
		return D.ntsl_get(key, scope, src)
	RaiseError(new/runtimeError/UndefinedVariable("[object].[key]"))

/n_Interpreter/proc/set_property(object, key, val, scope/scope)
	if(istype(object, /datum))
		var/datum/D = object
		D.ntsl_set(key, val, scope, src)
		return
	RaiseError(new/runtimeError/UndefinedVariable("[object].[key]"))

/datum/proc/ntsl_get(key, scope/scope, n_Interpreter/interp)
	interp.RaiseError(new/runtimeError/UndefinedVariable("[src].[key]"))
	return

/datum/proc/ntsl_set(key, val, scope/scope, n_Interpreter/interp)
	interp.RaiseError(new/runtimeError/UndefinedVariable("[src].[key]"))
	return

/datum/n_enum
	var/list/entries
/datum/n_enum/New(list/E)
	entries = E
/datum/n_enum/ntsl_get(key)
	if(entries.Find(key))
		return entries[key]
	return ..()

/datum/n_struct
	var/list/properties
/datum/n_struct/New(list/P)
	properties = P
/datum/n_struct/proc/get_clean_property(name, compare)
	var/x = properties[name]
	if(istext(x) && compare && x != compare) // Was changed
		x = sanitize(x)
		if(isnotpretty(x)) // Pretty filter stuff
			message_admins("An NTSL script just tripped the pretty filter, setting variable [name] to value [x]!")
			return FALSE
	return x
/datum/n_struct/ntsl_get(key)
	if(properties.Find(key))
		return properties[key]
	return ..()
/datum/n_struct/ntsl_set(key, val)
	if(properties.Find(key))
		properties[key] = val
		return
	..()

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

/proc/ntsl_method(path, proc_ref, N)
	var/list/path_methods = GLOB.ntsl_methods[path]
	if(!path_methods)
		path_methods = list()
		GLOB.ntsl_methods[path] = path_methods
	path_methods[proc_ref] = new /datum/n_function/default_method(path, proc_ref, N)

/datum/n_function/default_method
	var/obj_type
	var/proc_ref

/datum/n_function/default_method/New(path, ref, N)
	obj_type = path
	proc_ref = ref
	name = N

/datum/n_function/default_method/execute(this_obj, list/params, scope/scope, n_Interpreter/interp)
	if(!istype(this_obj, obj_type))
		return
	return call(this_obj, proc_ref)(params, scope, interp)
