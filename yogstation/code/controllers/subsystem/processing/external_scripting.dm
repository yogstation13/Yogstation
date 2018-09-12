//Calls an external DLL to take instructions to run.
//It's set to fire 100 times a second but in practice only fires around 20/s.
//Somehow takes almost no resources to run at all.

#define RETURN(x) call("ss13script.dll","return_data")(x)

SUBSYSTEM_DEF(exscript)
	name = "External Scripting"
	wait = 0.1
	priority = 800
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING
	var/instruction_delimiter
	var/type_value_delimiter
	var/proc_args_delimiter
	var/instruction_group_delimiter
	var/editing_script = FALSE
	var/emergency_brake = FALSE
	var/last_editor
	var/datum/cached_object
	var/missed_calls = 0
	var/rapid_fire = FALSE
	var/init_success = TRUE

/datum/controller/subsystem/exscript/Initialize(start_timeofday)
	if(!fexists("ss13script.dll") || call("ss13script.dll","initialize")() != "OK") //fuck travis lol
		message_admins("Failed to initialize external scripting.")
		flags |= SS_NO_FIRE
		init_success = FALSE
		return ..()
	instruction_delimiter = ascii2text(1)
	type_value_delimiter = ascii2text(2)
	proc_args_delimiter = ascii2text(3)
	instruction_group_delimiter = ascii2text(4)
	return ..()

/datum/controller/subsystem/exscript/Destroy()
	disconnect()
	return ..()

/datum/controller/subsystem/exscript/Shutdown()
	disconnect()

/datum/controller/subsystem/exscript/proc/disconnect()
	if(!init_success)
		return
	call("ss13script.dll","destroy")()
	sleep(50)

/datum/controller/subsystem/exscript/proc/serialize(data)
	var/list/return_value[2] //1 - type, 2 - value
	if(istext(data))
		return_value[1] = "text"
		return_value[2] = data
	else if(isnull(data))
		return_value[1] = "null"
		return_value[2] = "null"
	else if(isnum(data))
		return_value[1] = "number"
		return_value[2] = num2text(data)
	else if(islist(data))
		return_value[1] = "list"
		var/list/L = list()
		for(var/V in data)
			if(isloc(V) || istype(V, /client) || istype(V, /datum)) //if it's a datum that needs a reference
				L["[REF(V)]"] = data[V]
			else
				L[V] = data[V]
		return_value[2] = json_encode(L)
	else
		return_value[1] = "object"
		return_value[2] = "[REF(data)]"
	return return_value.Join(type_value_delimiter)

/datum/controller/subsystem/exscript/proc/deserialize(data)
	var/list/tv = splittext(data, type_value_delimiter) //list of type and value
	var/final_value
	switch(tv[1])
		if("text")
			final_value = tv[2]
		if("number")
			final_value = text2num(tv[2])
		if("object")
			final_value = to_object(tv[2])
		if("list")
			final_value = list()
			var/intermediate = json_decode(tv[2])
			for(var/V in intermediate)
				if(findtext(V, "\[", 1, 2) && findtext(V, "]", lentext(V)) && (findtext(V, "0x") || findtext(V, "mob_")))
					var/datum/thing = to_object(V)
					if(thing)
						final_value += thing
					else
						final_value += V
				else
					final_value += V
		if("null")
			final_value = null
	return final_value

/datum/controller/subsystem/exscript/proc/edit_script()
	if(!init_success)
		to_chat(usr, "<span class='danger'>Subsystem not initialized.</span>")
		return
	if(editing_script)
		to_chat(usr, "<span class='danger'>The script is being edited by someone else!</span>")
		return
	last_editor = key_name(usr)
	editing_script = TRUE
	var/current_script = file2text("external_script.py")
	var/new_script = input(usr, "Enter your Python script here:", "External script input", current_script) as message|null
	if(!new_script || new_script == current_script)
		reconnect()
		editing_script = FALSE
		return
	fdel("external_script.py")
	text2file(new_script, "external_script.py")
	reconnect()
	editing_script = FALSE

/datum/controller/subsystem/exscript/proc/run_script()
	if(!init_success)
		to_chat(usr, "<span class='danger'>Subsystem not initialized.</span>")
		return
	RETURN("Let's go!")

/datum/controller/subsystem/exscript/proc/reconnect()
	if(!init_success)
		return
	call("ss13script.dll","initialize")()

/datum/controller/subsystem/exscript/proc/call_proc(procname, arguments, object=null)
	var/list/final_args = list()
	for(var/PA in arguments)
		final_args += deserialize(PA)
	if(object)
		return call(object, procname)(arglist(final_args))
	else
		return call(procname)(arglist(final_args))

/datum/controller/subsystem/exscript/proc/to_object(ref)
	return ((ref == "CACHED") ? cached_object : locate(ref))

/datum/controller/subsystem/exscript/fire(resumed = 0)
	var/instruction = call("ss13script.dll","get_instruction")()
	if(!instruction)
		missed_calls += 1
		return
	missed_calls = 0
	var/list/instr_args = splittext(instruction, instruction_delimiter)
	var/instr = instr_args[1]
	var/list/iargs = instr_args.Copy(2)
	switch(instr)
		if("GET_WORLD") //get ref to world
			RETURN("[REF(world)]")
		if("GET_GLOB") //get ref to global variables
			RETURN("[REF(GLOB)]")
		if("GET_SELF") //get ref to this subsystem for stop checking
			RETURN("[REF(src)]")
		if("CHECK_GLOBAL_CALL") //check if a global proc exists
			var/procname = iargs[1]
			if(!text2path(procname))
				RETURN("0")
			else
				RETURN("1")
		if("CALL_GLOBAL") //call a global proc
			var/procname = iargs[1]
			var/list/proc_args = splittext(iargs[2], proc_args_delimiter) //list of type and value
			var/ret = iargs[3]
			var/result = call_proc(procname, proc_args)
			if(ret == "RETURN")
				result = serialize(result)
				RETURN(result)
		if("GET_VAR")
			var/datum/object = to_object(iargs[1])
			var/proc_or_varname = iargs[2]
			if(!object)
				RETURN("ERROR: OBJECT NOT FOUND")
				return
			var/data
			try
				data = object.vars[proc_or_varname]
			catch()
				if(!hascall(object, proc_or_varname))
					RETURN("ERROR: NO SUCH VAR")
					return
				RETURN("IT'S A PROC!")
				return
			data = serialize(data)
			RETURN(data)
		if("SET_VAR")
			var/datum/object = to_object(iargs[1])
			var/varname = iargs[2]
			var/new_value = deserialize(iargs[3])
			if(!object)
				//RETURN("ERROR: OBJECT NOT FOUND")
				return
			try
				var/current_value = object.vars[varname]
				pass(current_value) //suppress warning
			catch()
				//RETURN("ERROR: NO SUCH VAR")
				return

			object.vv_edit_var(varname, new_value)
		if("CALL_PROC")
			var/datum/object = to_object(iargs[1])
			var/procname = iargs[2]
			var/list/proc_args = splittext(iargs[3], proc_args_delimiter) //list of type and value
			var/ret = iargs[4]
			var/result = call_proc(procname, proc_args, object)
			if(ret == "RETURN")
				result = serialize(result)
				RETURN(result)
		if("WARN")
			var/warning = "SCRIPT MESSAGE: [iargs[1]]"
			message_admins(warning)
		if("NEW_OBJECT")
			var/tpath = iargs[1]
			var/ret = iargs[2]
			var/path = text2path(tpath)
			if(!path)
				RETURN("ERROR: OBJECT NOT FOUND")
				return
			cached_object = new path
			if(ret == "RETURN")
				RETURN(serialize(cached_object))
	if(MC_TICK_CHECK)
		return
	if(rapid_fire)
		fire()