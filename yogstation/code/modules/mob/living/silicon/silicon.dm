/mob/living/silicon
	var/list/law_history = list()

/mob/living/silicon/proc/update_law_history(mob/uploader = null)
	var/ai_law_sync = "UNKNOWN/Innate laws"
	if(!uploader && iscyborg(src))
		var/mob/living/silicon/robot/R = src
		if(R.connected_ai)
			ai_law_sync = "law sync with [key_name(R.connected_ai)]"
	var/new_entry = "Uploaded by [uploader ? key_name(uploader) : ai_law_sync] at [worldtime2text()]<br>"
	var/list/printable_laws = laws.get_law_list(include_zeroth = TRUE)
	for(var/law in printable_laws)
		new_entry += "[law]<br>"
	if(law_history.len && new_entry == law_history[law_history.len])
		return
	law_history += new_entry