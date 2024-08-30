/obj/machinery/telecomms/get_multitool(mob/user) // Proc override, to improve compatibility with holotools and other silly multitool-like devices
	if(isAI(user)) //AIs have an internal multitool they use instead.
		var/mob/living/silicon/ai/U = user
		return U.aiMulti
	if(iscyborg(user) && !in_range(user, src)) //Cyborgs must be in range
		return
	var/obj/item/held_item = user.is_holding_tool_quality(TOOL_MULTITOOL)
	if(multitool_check_buffer(user, held_item, silent = TRUE))
		return held_item
