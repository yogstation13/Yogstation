/**
 * Tool behavior procedure. Redirects to tool-specific procs by default.
 *
 * You can override it to catch all tool interactions, for use in complex deconstruction procs.
 *
 * Must return  parent proc ..() in the end if overridden
 */
/atom/proc/tool_act(mob/living/user, obj/item/tool, tool_type, params)
	var/act_result
	var/signal_result

	signal_result = SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT(tool_type), user, tool, params)
	if(signal_result & COMPONENT_BLOCK_TOOL_ATTACK) // The COMSIG_ATOM_TOOL_ACT signal is blocking the act
		return TOOL_ACT_SIGNAL_BLOCKING
	if(QDELETED(tool))
		return TRUE
	
	var/list/modifiers = params2list(params)

	switch(tool_type)
		if(TOOL_CROWBAR)
			act_result = crowbar_act(user, tool, modifiers)
		if(TOOL_MULTITOOL)
			act_result = multitool_act(user, tool, modifiers)
		if(TOOL_SCREWDRIVER)
			act_result = screwdriver_act(user, tool, modifiers)
		if(TOOL_WRENCH)
			act_result = wrench_act(user, tool, modifiers)
		if(TOOL_WIRECUTTER)
			act_result = wirecutter_act(user, tool, modifiers)
		if(TOOL_WELDER)
			act_result = welder_act(user, tool, modifiers)
		if(TOOL_ANALYZER)
			act_result = analyzer_act(user, tool, modifiers)
	if(!act_result)
		return
	
	if(. && tool.toolspeed < 1) //nice tool bro
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "nice_tool", /datum/mood_event/nice_tool)

	// A tooltype_act has completed successfully
//	log_tool("[key_name(user)] used [tool] on [src] at [AREACOORD(src)]")
	SEND_SIGNAL(tool, COMSIG_TOOL_ATOM_ACTED_PRIMARY(tool_type), src)
	return TOOL_ACT_TOOLTYPE_SUCCESS


//! Tool-specific behavior procs. To be overridden in subtypes.
///

///Crowbar act
/atom/proc/crowbar_act(mob/living/user, obj/item/tool, modifiers)
	SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT(TOOL_CROWBAR), user, tool, modifiers)

///Multitool act
/atom/proc/multitool_act(mob/living/user, obj/item/tool, modifiers)
	SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), user, tool, modifiers)

///Check if the multitool has an item in it's data buffer
/atom/proc/multitool_check_buffer(user, obj/item/tool, silent = FALSE)
	if(istype(tool, /obj/item/multitool))
		return TRUE
	if(istype(tool, /obj/item/holotool))
		return TRUE
	if(user && !silent)
		to_chat(user, span_warning("[tool] has no data buffer!"))
	return FALSE

/atom/proc/multitool_get_buffer(user, obj/item/tool, silent = FALSE)
	if(istype(tool, /obj/item/multitool))
		var/obj/item/multitool/multi = tool
		return multi.buffer
	if(istype(tool, /obj/item/holotool))
		var/obj/item/holotool/holo = tool
		return holo.buffer
	CRASH("called multitool_get_buffer on [tool] which has no data buffer!")

/atom/proc/multitool_set_buffer(user, obj/item/tool, buffer_value, silent = FALSE)
	if(istype(tool, /obj/item/multitool))
		var/obj/item/multitool/multi = tool
		multi.buffer = buffer_value
		return TRUE
	if(istype(tool, /obj/item/holotool))
		var/obj/item/holotool/holo = tool
		holo.buffer = buffer_value
		return TRUE
	CRASH("called multitool_set_buffer on [tool] which has no data buffer!")

///Screwdriver act
/atom/proc/screwdriver_act(mob/living/user, obj/item/tool, modifiers)
	SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), user, tool, modifiers)

///Wrench act
/atom/proc/wrench_act(mob/living/user, obj/item/tool, modifiers)
	SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT(TOOL_WRENCH), user, tool, modifiers)

///Wirecutter act
/atom/proc/wirecutter_act(mob/living/user, obj/item/tool, modifiers)
	SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT(TOOL_WIRECUTTER), user, tool, modifiers)

///Welder act
/atom/proc/welder_act(mob/living/user, obj/item/tool, modifiers)
	SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), user, tool, modifiers)

///Analyzer act
/atom/proc/analyzer_act(mob/living/user, obj/item/tool, modifiers)
	SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT(TOOL_ANALYZER), user, tool, modifiers)
