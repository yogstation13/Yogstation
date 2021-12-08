/mob/living/silicon/examine(mob/user) //Displays a silicon's laws to ghosts
	. = ..()
	if(laws && isobserver(user))
		. += "<b>[src] has the following laws:</b>"
		for(var/law in laws.get_law_list(include_zeroth = TRUE))
			. += law

/obj/machinery/ai/data_core/examine(mob/user)
	. = ..()
	if(!isobserver(user))
		return
	. += "<b>AIs located in [src]:</b>"
	for(var/mob/living/silicon/ai/AI in contents)
		. += "<b>[AI] has the following laws:</b>"
		for(var/law in AI.laws.get_law_list(include_zeroth = TRUE))
			. += law
