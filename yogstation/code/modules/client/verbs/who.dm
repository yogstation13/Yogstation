/client/verb/mentorwho()
	set category = "Mentor"
	set name = "Mentorwho"
	var/msg = "<b>Current Mentors:</b>\n"
	for(var/X in GLOB.mentors)
		var/client/C = X
		if(!C)
			GLOB.mentors -= C
			continue // weird runtime that happens randomly
		var/suffix = ""
		if(C.holder)
			continue
		if(holder)
			if(isobserver(C.mob))
				suffix += " - Observing"
			else if(istype(C.mob,/mob/dead/new_player))
				suffix += " - Lobby"
			else
				suffix += " - Playing"

			if(C.is_afk())
				suffix += " (AFK)"
		msg += "\t[C][suffix]\n"
	to_chat(src, msg)

/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = ""

	var/list/Lines = list()
	if(length(GLOB.admins))
		Lines += "<b>Admins:</b>"
		for(var/X in GLOB.admins)
			var/client/C = X
			if(C && C.holder && !C.holder.fakekey)
				Lines += "\t <font color='#FF0000'>[C.key]</font>[show_admin_info(C)] ([round(C.avgping, 1)]ms)"
	if(length(GLOB.mentors))
		Lines += "<b>Mentors:</b>"
		for(var/X in GLOB.mentors)
			var/client/C = X
			if(C)
				Lines += "\t <font color='#0033CC'>[C.key]</font>[show_admin_info(C)] ([round(C.avgping, 1)]ms)"

	Lines += "<b>Players:</b>"
	for(var/X in sortList(GLOB.clients))
		var/client/C = X
		if(!C) continue
		var/key = C.key
		if(C.holder && C.holder.fakekey)
			key = C.holder.fakekey
		Lines += "\t [key][show_admin_info(C)] ([round(C.avgping, 1)]ms)"

	for(var/line in Lines)
		msg += "[line]\n"

	msg += "<b>Total Players: [length(GLOB.clients)]</b>"
	to_chat(src, msg)
