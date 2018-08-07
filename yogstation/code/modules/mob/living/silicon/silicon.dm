/mob/living/silicon
	var/list/law_history = list()

/mob/living/silicon/proc/update_law_history()
	var/new_entry = ""
	var/list/printable_laws = laws.get_law_list(include_zeroth = TRUE)
	for(var/law in printable_laws)
		new_entry += "[law]<br>"
	law_history += new_entry