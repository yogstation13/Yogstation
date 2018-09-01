//Calls an external DLL to take instructions to run.
//It's set to fire 100 times a second but in practice only fires around 20/s.
//Somehow takes almost no resources to run at all.

#define RETURN(x) call("ss13script.dll","return_data")(x)

SUBSYSTEM_DEF(exscript)
	name = "External Scripting"
	wait = 0.1
	priority = FIRE_PRIORITY_PROCESS
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING
	var/instruction_delimiter
	var/type_value_delimiter
	var/proc_args_delimiter
	var/instruction_group_delimiter
	var/editing_script = FALSE
	var/emergency_brake = FALSE

/datum/controller/subsystem/exscript/Initialize(start_timeofday)
	instruction_delimiter = ascii2text(1)
	type_value_delimiter = ascii2text(2)
	proc_args_delimiter = ascii2text(3)
	instruction_group_delimiter = ascii2text(4)
	call("ss13script.dll","initialize")()
	return ..()

/datum/controller/subsystem/exscript/Destroy()
	call("ss13script.dll","destroy")()
	return ..()

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
			final_value = locate(tv[2])
		if("list")
			final_value = json_decode(tv[2]) //TODO: LOCATE BYOND OBJECTS
		if("null")
			final_value = null
	return final_value

/datum/controller/subsystem/exscript/proc/edit_script()
	if(editing_script)
		to_chat(usr, "<span class='danger'>The script is being edited by someone else!</span>")
		return
	editing_script = TRUE
	var/current_script = file2text("external_script.py")
	var/new_script = input(usr, "Enter your Python script here:", "External script input", current_script) as message|null
	if(!new_script || new_script == current_script)
		//reconnect()
		editing_script = FALSE
		return
	fdel("external_script.py")
	text2file(new_script, "external_script.py")
	//reconnect()
	editing_script = FALSE

/datum/controller/subsystem/exscript/proc/run_script()
	RETURN("Let's go!")

/datum/controller/subsystem/exscript/proc/reconnect()
	call("ss13script.dll","initialize")()

/datum/controller/subsystem/exscript/fire(resumed = 0)
	var/instruction = call("ss13script.dll","get_instruction")()
	if(!instruction)
		return
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
			var/list/final_args = list()
			for(var/PA in proc_args)
				final_args += deserialize(PA)
			var/result = call(procname)(arglist(final_args))
			result = serialize(result)
			RETURN(result)
		if("GET_VAR")
			var/datum/object = locate(iargs[1])
			var/varname = iargs[2]
			if(!object)
				RETURN("ERROR: OBJECT NOT FOUND")
				return
			var/data
			try
				data = object.vars[varname]
			catch()
				RETURN("ERROR: NO SUCH VAR")
				return
			data = serialize(data)
			RETURN(data)
		if("SET_VAR")
			var/datum/object = locate(iargs[1])
			var/varname = iargs[2]
			var/new_value = deserialize(iargs[3])
			if(!object)
				RETURN("ERROR: OBJECT NOT FOUND")
				return
			try
				var/current_value = object.vars[varname]
				pass(current_value) //suppress warning
			catch()
				RETURN("ERROR: NO SUCH VAR")
				return

			if(object.vv_edit_var(varname, new_value))
				RETURN("1")
			else
				RETURN("0")
		if("CHECK_CALL")
			var/datum/object = locate(iargs[1])
			var/procname = iargs[2]
			if(!object)
				RETURN("0")
				return
			if(!hascall(object, procname))
				RETURN("1")
			else
				RETURN("2")
		if("CALL_PROC")
			var/datum/object = locate(iargs[1])
			var/procname = iargs[2]
			var/list/proc_args = splittext(iargs[3], proc_args_delimiter) //list of type and value
			var/list/final_args = list()
			for(var/PA in proc_args)
				final_args += deserialize(PA)
			var/result = call(object, procname)(arglist(final_args))
			result = serialize(result)
			RETURN(result)
		if("DELETE")
			var/datum/object = locate(iargs[1])
			if(!object)
				RETURN("ERROR: OBJECT NOT FOUND")
				return
			qdel(object)
			RETURN("1")
		if("WARN")
			var/warning = iargs[1]
			message_admins(warning)
		if("NEW_OBJECT")
			var/tpath = iargs[1]
			var/path = text2path(tpath)
			if(!path)
				RETURN("ERROR: OBJECT NOT FOUND")
			var/object = serialize(new path)
			RETURN(object)