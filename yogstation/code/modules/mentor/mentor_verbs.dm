GLOBAL_PROTECT(mentor_verbs)
GLOBAL_LIST_INIT(mentor_verbs, list(
	/client/proc/cmd_mentor_say,
	/client/proc/show_mentor_memo,
	/client/proc/show_mentor_tickets
	))

/client/proc/add_mentor_verbs()
	if(mentor_datum)
		verbs += GLOB.mentor_verbs

/client/proc/remove_mentor_verbs()
	verbs -= GLOB.mentor_verbs

/client/proc/show_mentors()
	set name = "Show Mentors"
	set category = "Mentor"

	if(!check_rights(R_ADMIN))
		return

	if(!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return

	var/msg = "<b>Current Mentors:</b>\n"
	var/datum/DBQuery/query_load_mentors = SSdbcore.NewQuery("SELECT `ckey` FROM `[format_table_name("mentor")]`")
	if(!query_load_mentors.Execute())
		qdel(query_load_mentors)
		return

	while(query_load_mentors.NextRow())
		var/ckey = query_load_mentors.item[1]
		msg += "\t[ckey]"
	qdel(query_load_mentors)

	to_chat(src, msg)
