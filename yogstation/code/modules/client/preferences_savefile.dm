/datum/preferences/update_character(current_version, savefile/S)
	.=..()
	var/value = 0
	for(var/V in all_quirks)
		var/datum/quirk/T
		for(var/datum/quirk/T2 in subtypesof(/datum/quirk)) //SSquirks may not have loaded yet so we have to find the quirks manually
			if(T2.name != V)
				continue
			T = T2
		if(initial(T.mood_quirk) && CONFIG_GET(flag/disable_human_mood))
			all_quirks -= V
		else
			value += initial(T.value)

	if(value < 0)
		to_chat(parent, span_userdanger("Your quirks have been reset due to an insufficient balance because certain quirks have been disabled."))
		to_chat(parent, span_notice("Your previously selected quirks:"))
		for(var/V in all_quirks)
			to_chat(parent, span_notice("[V]"))
		all_quirks = list()
