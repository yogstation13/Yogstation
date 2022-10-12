/client/verb/mentorhelp(msg as text)
	set category = "Mentor"
	set name = "Mentorhelp"
	mhelp(msg, FALSE)

/client/proc/mhelp(msg as text, fromadmins as num)
	//clean the input msg
	if(!msg)	return

	//handle muting and automuting
	if(prefs.muted & MUTE_MENTORHELP)
		to_chat(src, span_danger("Error: Mentorhelp: You cannot send mentorhelps (Muted)."), confidential=TRUE)
		return
	if(handle_spam_prevention(msg,MUTE_MENTORHELP))
		return

	//remove out mentorhelp verb temporarily to prevent spamming of mentors.
	remove_verb(src, /client/verb/mentorhelp)
	spawn(300)
		add_verb(src, /client/verb/mentorhelp)	// 30 second cool-down for mentorhelp

	webhook_send_mhelp(key_name_mentor(src), msg)

	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg)	return
	if(!mob)	return						//this doesn't happen

	var/admininfo = "MENTORHELP:"
	if(fromadmins)
		admininfo = "MENTORHELP (From Admins):"
	var/show_char = CONFIG_GET(flag/mentors_mobname_only)
	var/mentor_msg = "<span class='mentornotice purple'><b>[admininfo]</b> <b>[key_name_mentor(src, 1, 0, 1, show_char)]</b>: [msg]</span>"
	log_mentor("[admininfo] [key_name_mentor(src, 0, 0, 0, 0)]: [msg]")

	for(var/client/X in GLOB.mentors | GLOB.permissions.admins)
		if(X.prefs.toggles & SOUND_ADMINHELP)
			send_mentor_sound(X)
		to_chat(X, mentor_msg, confidential=TRUE)

	to_chat(src, "<span class='mentornotice purple'>PM to-<b>Mentors</b>: [msg]</span>", confidential=TRUE)

	var/datum/mentorticket/mt
	if(ckey in SSYogs.mentortickets)
		mt = SSYogs.mentortickets[ckey]

	if(!mt)
		mt = new(src)
	mt.log += "<b>[src.key]:</b> [msg]"

/proc/get_mentor_counts()
	. = list("total" = 0, "afk" = 0, "present" = 0)
	for(var/X in GLOB.mentors)
		var/client/C = X
		.["total"]++
		if(C.is_afk())
			.["afk"]++
		else
			.["present"]++

/proc/key_name_mentor(var/whom, var/include_link = null, var/include_name = 0, var/include_follow = 0, var/char_name_only = 0)
	var/mob/M
	var/client/C
	var/key
	var/ckey

	if(!whom)	return "*null*"
	if(istype(whom, /client))
		C = whom
		M = C.mob
		key = C.key
		ckey = C.ckey
	else if(ismob(whom))
		M = whom
		C = M.client
		key = M.key
		ckey = M.ckey
	else if(istext(whom))
		key = whom
		ckey = ckey(whom)
		C = GLOB.directory[ckey]
		if(C)
			M = C.mob
	else
		return "*invalid*"

	. = ""

	if(!ckey)
		include_link = 0

	if(key)
		if(include_link)
			if(CONFIG_GET(flag/mentors_mobname_only))
				. += "<a href='?_src_=mentor;mentor_msg=[REF(M)];[MentorHrefToken(TRUE)]'>"
			else
				. += "<a href='?_src_=mentor;mentor_msg=[ckey];[MentorHrefToken(TRUE)]'>"

		if(C && C.holder && C.holder.fakekey)
			. += "Administrator"
		else if (char_name_only && CONFIG_GET(flag/mentors_mobname_only))
			if(istype(C.mob,/mob/dead/new_player) || istype(C.mob, /mob/dead/observer)) //If they're in the lobby or observing, display their ckey
				. += key
			else if(C && C.mob) //If they're playing/in the round, only show the mob name
				. += C.mob.name
			else //If for some reason neither of those are applicable and they're mentorhelping, show ckey
				. += key
		else
			. += key
		if(!C)
			. += "\[DC\]"

		if(include_link)
			. += "</a>"
	else
		. += "*no key*"

	if(include_follow)
		. += " (<a href='?_src_=mentor;mentor_follow=[REF(M)];[MentorHrefToken(TRUE)]'>F</a>)"

	return .

/proc/discord_mentor_link(var/display_name, var/id)
	return "<a href='?_src_=mentor;mentor_msg=[list2params(list(display_name))];mentor_discord_id=[id];[MentorHrefToken(TRUE)]'>[display_name]</a>"
