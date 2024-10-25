GLOBAL_LIST_EMPTY(ntsl_methods)

/datum/n_Interpreter/proc/get_property(object, key, datum/scope/scope, node) //fun fact: node is always null here.
	if(islist(object))
		var/list/L = object
		switch(key)
			if("len")
				return length(L)
			if("Copy")
				return ntsl_method(/list, /datum/n_function/list_copy)
			if("Cut")
				return ntsl_method(/list, /datum/n_function/list_cut)
			if("Find")
				return ntsl_method(/list, /datum/n_function/list_find)
			if("Insert")
				return ntsl_method(/list, /datum/n_function/list_insert)
			if("Join")
				return ntsl_method(/list, /datum/n_function/list_join)
			if("Remove")
				return ntsl_method(/list, /datum/n_function/list_remove)
			if("Swap")
				return ntsl_method(/list, /datum/n_function/list_swap)
	else if(istext(object))
		if(key == "len")
			return length(object)
	else if(istype(object, /datum))
		var/datum/D = object
		return D.ntsl_get(key, scope, src, node)
	RaiseError(new /datum/runtimeError/UndefinedVariable("[object].[key]"), scope, node)

/datum/n_Interpreter/proc/set_property(object, key, val, datum/scope/scope, node)
	if(istype(object, /datum))
		var/datum/D = object
		D.ntsl_set(key, val, scope, src, node)
		return
	RaiseError(new /datum/runtimeError/UndefinedVariable("[object].[key]"), scope, node)

/datum/n_Interpreter/proc/get_index(object, index, datum/scope/scope, node)
	if(islist(object))
		var/list/L = object
		if(!isnum(index) || (index <= length(L) && index >= 1))
			return L[index]
	else if(istext(object))
		if(isnum(index) && index >= 1 && index <= length(object))
			return object[index]
	RaiseError(new /datum/runtimeError/IndexOutOfRange(object, index), scope, node)

/datum/n_Interpreter/proc/set_index(object, index, val, datum/scope/scope, node)
	if(islist(object))
		var/list/L = object
		if(!isnum(index) || (index <= length(L) && index >= 1))
			L[index] = val
			return
	RaiseError(new /datum/runtimeError/IndexOutOfRange(object, index), scope, node)

/datum/proc/ntsl_get(key, datum/scope/scope, datum/n_Interpreter/interp, node) //fun fact: node is always null here.
	interp.RaiseError(new /datum/runtimeError/UndefinedVariable("[src].[key]"), scope, node)
	return

/datum/proc/ntsl_set(key, val, datum/scope/scope, datum/n_Interpreter/interp, node)
	interp.RaiseError(new /datum/runtimeError/UndefinedVariable("[src].[key]"), scope, node)
	return

/datum/n_enum
	var/list/entries

/datum/n_enum/New(list/entry_list)
	src.entries = entry_list

/datum/n_enum/ntsl_get(key, datum/scope/scope, datum/n_Interpreter/interp, node)
	if(entries.Find(key))
		return entries[key]
	return ..()

/datum/n_struct
	var/list/properties

/datum/n_struct/New(list/property_list)
	src.properties = property_list

/datum/n_struct/proc/get_clean_property(name, compare)
	var/x = properties[name]
	if(istext(x) && compare && x != compare) // Was changed
		x = sanitize(x)
		if(isnotpretty(x)) // Pretty filter stuff
			var/log_message = "An NTSL script just tripped the pretty filter, setting variable [name] from [compare] to value [x]!"
			message_admins(log_message)
			logger.Log(LOG_NTSL, "[key_name(src)] [log_message] [loc_name(src)]")
			return FALSE
	return x

/datum/n_struct/ntsl_get(key, datum/scope/scope, datum/n_Interpreter/interp, node)
	if(properties.Find(key))
		return properties[key]
	return ..()

/datum/n_struct/ntsl_set(key, val)
	if(properties.Find(key))
		properties[key] = val
		return
	return ..()

/datum/n_function
	var/name = ""

/datum/n_function/proc/execute(this_obj, list/params, datum/scope/scope, datum/n_Interpreter/interp)
	return

/datum/n_function/defined
	var/datum/n_Interpreter/context
	var/datum/scope/closure
	var/datum/node/statement/FunctionDefinition/function_def

/datum/n_function/defined/New(datum/node/statement/FunctionDefinition/function_def, datum/scope/closure, datum/n_Interpreter/context)
	src.function_def = function_def
	src.closure = closure
	src.context = context

/datum/n_function/defined/Destroy()
	function_def = null
	closure = null
	context = null
	return ..()

/datum/n_function/defined/execute(this_obj, list/params, datum/scope/scope, datum/n_Interpreter/interp, datum/node/node)
	if(scope.recursion >= 10)
		interp.AlertAdmins()
		interp.RaiseError(new /datum/runtimeError/RecursionLimitReached(), scope, node)
		return FALSE
	scope = scope.push(function_def.block, closure, RESET_STATUS | RETURNING)
	scope.recursion++
	scope.function = function_def
	if(node)
		scope.call_node = node
	for(var/i = 1 to length(function_def.parameters))
		var/val
		if(length(params) >= i)
			val = params[i]
		//else
		//	unspecified param
		scope.init_var(function_def.parameters[i], val, interp, node)
	scope.init_var("src", this_obj, interp, node);
	interp.RunBlock(function_def.block, scope)
	//Handle return value
	. = scope.return_val
	scope = scope.pop(0) // keep nothing

/datum/n_function/default
	// functions included on compilation
	var/interp_type = /datum/n_Interpreter // include this function in this kind of interpreter.
	var/list/aliases // in case you want to give it multiple "names"

/proc/ntsl_method(path, proc_ref, N)
	var/list/path_methods = GLOB.ntsl_methods[path]
	if(!path_methods)
		path_methods = list()
		GLOB.ntsl_methods[path] = path_methods
	var/datum/n_function/func = path_methods[proc_ref]
	if(func)
		return func
	if(ispath(proc_ref, /datum/n_function) && !ispath(path, /datum/n_function))
		func = new proc_ref()
	else
		func = new /datum/n_function/default_method(path, proc_ref, N)
	path_methods[proc_ref] = func
	return func

/datum/n_function/default_method
	var/obj_type
	var/proc_ref

/datum/n_function/default_method/New(path, ref, name)
	src.obj_type = path
	src.proc_ref = ref
	src.name = name

/datum/n_function/default_method/execute(this_obj, list/params, datum/scope/scope, datum/n_Interpreter/interp)
	if(!istype(this_obj, obj_type))
		return
	return call(this_obj, proc_ref)(params, scope, interp)

/datum/n_function/list_add
	name = "Add"

/datum/n_function/list_add/execute(list/this_obj, list/params)
	for(var/param in params)
		this_obj.Add(param)

/datum/n_function/list_copy
	name = "Copy"

/datum/n_function/list_copy/execute(list/this_obj, list/params)
	return this_obj.Copy(length(params) >= 1 ? params[1] : 1, length(params) >= 2 ? params[2] : 0)

/datum/n_function/list_cut
	name = "Cut"

/datum/n_function/list_cut/execute(list/this_obj, list/params)
	this_obj.Cut(length(params) >= 1 ? params[1] : 1, length(params) >= 2 ? params[2] : 0)

/datum/n_function/list_find
	name = "Find"

/datum/n_function/list_find/execute(list/this_obj, list/params)
	return this_obj.Find(params[1], length(params) >= 2 ? params[2] : 1, length(params) >= 3 ? params[3] : 0)

/datum/n_function/list_insert
	name = "Insert"

/datum/n_function/list_insert/execute(list/this_obj, list/params)
	if(length(params) >= 2)
		if(params[1] == 0)
			for(var/I in 2 to length(params))
				this_obj.Add(params[I])
		else
			for(var/I = length(params); I >= 2; I--)
				this_obj.Insert(params[1], params[I])

/datum/n_function/list_join
	name = "Join"

/datum/n_function/list_join/execute(list/this_obj, list/params)
	return this_obj.Join(params[1], length(params) >= 2 ? params[2] : 1, length(params) >= 3 ? params[3] : 0)

/datum/n_function/list_remove
	name = "Remove"

/datum/n_function/list_remove/execute(list/this_obj, list/params)
	for(var/param in params)
		this_obj.Remove(param)

/datum/n_function/list_swap
	name = "Swap"

/datum/n_function/list_swap/execute(list/this_obj, list/params)
	this_obj.Swap(params[1], params[2])
