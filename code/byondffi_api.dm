var/byondffi_initialized = FALSE

/datum/promise
	var/completed = FALSE
	var/result = ""

/datum/promise/proc/resolve()
	while(!completed)
		stoplag(1) //replace with your version of sleep
	return result

//Example: call_async("name.dll", "do_work", "Hello", "world")
/proc/call_async()
	var/list/arguments = args.Copy()
	var/datum/promise/P = new
	if(!byondffi_initialized)
		var/dllname = arguments[1]
		var/funcname = arguments[2]
		arguments.Cut(1,3)
		P.result = call(dllname, funcname)(arglist(arguments))
		P.completed = TRUE
		return P
	arguments.Insert(1, "\ref[P]")
	call("byondffi.dll", "call_async")(arglist(arguments))
	return P

//same syntax as call_async
/proc/call_wait()
	return call_async(arglist(args)).resolve()

/proc/byondffi_initialize()
	if(!fexists("byondffi.dll"))
		world << "BYONDFFI DLL NOT FOUND"
		world.log << "BYONDFFI DLL NOT FOUND"
		return FALSE
	var/result = call("byondffi.dll", "initialize")()
	world << result
	world.log << result
	if(findtext(result, "ERROR"))
		return FALSE
	return TRUE

/proc/byondffi_shutdown()
	call("byondffi.dll", "cleanup")()