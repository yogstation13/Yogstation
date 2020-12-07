GLOBAL_LIST_INIT(mentor_verbs, list(
	/client/proc/cmd_mentor_say,
	/client/proc/show_mentor_memo,
	/client/proc/show_mentor_tickets,
	/client/proc/cmd_mentor_pm_context,
	/client/proc/dementor
	))
GLOBAL_PROTECT(mentor_verbs)

/client/proc/add_mentor_verbs()
	if(mentor_datum)
		add_verb(src, GLOB.mentor_verbs)

/client/proc/remove_mentor_verbs()
	remove_verb(src, GLOB.mentor_verbs)

/client/proc/show_mentors()
	set name = "Show Mentors"
	set category = "Mentor"

	if(!check_rights(R_ADMIN))
		return

	if(!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>", confidential=TRUE)
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

	to_chat(src, msg, confidential=TRUE)

/client/verb/mentorwho()
	set name = "Mentorwho"
	set category = "Mentor"

	var/msg = "<b>Current Mentors:</b>\n"
	if(holder)
		for(var/client/C in GLOB.mentors)
			msg += "\t[C] is a mentor"

			if(C.holder && C.holder.fakekey)
				msg += " <i>(as [C.holder.fakekey])</i>"

			if(isobserver(C.mob))
				msg += " - Observing"
			else if(isnewplayer(C.mob))
				msg += " - Lobby"
			else
				msg += " - Playing"

			if(C.is_afk())
				msg += " (AFK)"
			msg += "\n"
	else
		for(var/client/C in GLOB.mentors)
			if(C.holder && C.holder.fakekey)
				msg += "\t[C.holder.fakekey] is a mentor"
			else
				msg += "\t[C] is a mentor"
			msg += "\n"
		msg += "<span class='info'>Mentorhelps are also seen by admins. If no mentors are available in game adminhelp instead and an admin will see it and respond.</span>"
	to_chat(src, msg, confidential=TRUE)

/client/proc/dementor()
	set name = "Dementor"
	set category = "Mentor"
	set desc = "Shed your mentor powers."
	if(GLOB.mentors.len <= 2)
		to_chat(src, "<span class='notice'>There are not enough mentors on for you to De-Mentor yourself!</span>", confidential=TRUE)
		return
	remove_mentor_verbs()
	mentor_datum = null
	GLOB.mentors -= src
	add_verb(src, /client/proc/rementor)
	to_chat(src, "<span class='interface'>You are now a normal player.</span>", confidential=TRUE)
	log_admin("[src] dementored themself.")
	message_admins("[src] dementored themself.")

/client/proc/rementor()
	set name = "Rementor"
	set category = "Mentor"
	set desc = "Gain your mentor powers."
	remove_verb(src, /client/proc/rementor)
	spawn(20) // Now UselessTheremin being a shit too.
		new /datum/mentors(ckey)
		to_chat(src, "<span class='interface'>You are now a Mentor again.</span>", confidential=TRUE)
		log_admin("[src] rementored themself.")
		message_admins("[src] rementored themself.")
