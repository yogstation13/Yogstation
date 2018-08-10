/mob/living/silicon
	var/list/law_history = list()

/mob/living/silicon/proc/update_law_history(mob/uploader = null)
	var/ai_law_sync = "UNKNOWN/Innate laws"
	if(!uploader && iscyborg(src))
		var/mob/living/silicon/robot/R = src
		if(R.connected_ai)
			ai_law_sync = "law sync with [key_name(R.connected_ai)]"
	var/new_entry = list("Uploaded by [uploader ? key_name(uploader) : ai_law_sync] at [worldtime2text()]")
	var/list/current_laws = laws.get_law_list(include_zeroth = TRUE)
	new_entry += current_laws
	if(law_history.len)
		var/list/last_laws = law_history[law_history.len].Copy()
		last_laws.Cut(1,2)
		if(compare_lists(current_laws, last_laws))
			return
	law_history += list(new_entry)