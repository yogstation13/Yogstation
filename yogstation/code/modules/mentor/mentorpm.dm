//shows a list of clients we could send PMs to, then forwards our choice to cmd_Mentor_pm
/client/proc/cmd_mentor_pm_panel()
	set category = "Mentor"
	set name = "Mentor PM"

	if(!is_mentor())
		to_chat(src, "<font color='red'>Error: Mentor-PM-Panel: Only Mentors and Admins may use this command.</font>", confidential=TRUE)
		return

	var/list/client/targets[0]
	for(var/client/T)
		targets["[T]"] = T

	var/list/sorted = sortList(targets)
	var/target = input(src,"To whom shall we send a message?","Mentor PM",null) in sorted|null
	cmd_mentor_pm(targets[target],null)
	SSblackbox.record_feedback("tally", "Mentor_verb", 1, "APM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_mentor_pm_context(mob/M in GLOB.mob_list)
	set category = null
	set name = "Mentor PM Mob"

	if(!is_mentor())
		return
	if(!ismob(M))
		return
	if(M.client)
		cmd_mentor_pm(M, null)

//takes input from cmd_mentor_pm_context, cmd_Mentor_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed. src is the sender and C is the target client
/client/proc/cmd_mentor_pm(whom, msg, discord_id)
	var/client/C
	if(prefs.muted & MUTE_MENTORHELP)
		to_chat(src,span_danger("Error: Mentor-PM: You are unable to use Mentor PM (muted)."), confidential = TRUE)
		return
	if(ismob(whom))
		var/mob/M = whom
		C = M.client

	else if(istext(whom) && !discord_id)
		C = GLOB.directory[whom]

	else if(istype(whom,/client))
		C = whom

	if(QDELETED(C) && !discord_id)
		if(is_mentor())
			to_chat(src, "<font color='red'>Error: Mentor-PM: Client not found.</font>", confidential=TRUE)
		else
			mhelp(msg, FALSE)	//Mentor we are replying to left. Mentorhelp instead(check below)
		return

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		if(is_mentor())
			to_chat((GLOB.admins - GLOB.deadmins) | GLOB.mentors, "<b><span class='purple mentor'>[key_name_mentor(src)] has started answering [key_name_mentor(C)]'s mentorhelp.</span></b>", confidential=TRUE)
		msg = input(src,"Message:", "Private message") as text|null

		if(!msg)
			if(is_mentor())
				to_chat((GLOB.admins - GLOB.deadmins) | GLOB.mentors, "<b><span class='purple mentor'>[key_name_mentor(src)] has decided not to answer [key_name_mentor(C)]'s mentorhelp.</span></b>", confidential=TRUE)
			return

		// Neither party is a mentor, they shouldn't be PMing!
		if (C && !C.is_mentor() && !is_mentor())
			return

	if(discord_id)
		webhook_send_mhelp("[key_name_mentor(src)]-><@[discord_id]>", msg)
	else
		webhook_send_mhelp("[key_name_mentor(src)]->[key_name_mentor(C)]", msg)

	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg)
		return

	log_mentor("Mentor PM: [key_name(src)]->[discord_id ? discord_id : key_name(C)]: [msg]")

	if(mentor_datum && isnotpretty(msg)) // If this is, specifically, a mentor, and not an admin nor a normal player
		to_chat(src,"<span class='danger mentor'>You cannot send bigoted language as a mentor.</span>", confidential=TRUE)
		var/log_message = "[discord_id ? discord_id : key_name(src)] just tripped the pretty filter in a mentorpm: [msg]"
		message_admins(log_message)
		log_mentor(log_message)
		return
	msg = emoji_parse(msg)
	if(C)
		send_mentor_sound(C)
	var/show_char = CONFIG_GET(flag/mentors_mobname_only)
	if(!C || C.is_mentor())
		if(C)
			to_chat(C, "<span class='purple mentor'>Reply PM from-<b>[key_name_mentor(src, C, 1, 0, show_char)]</b>: [msg]</span>", confidential=TRUE)
		if(discord_id)
			to_chat(src, "<font color='green mentor'>Mentor PM to-<b>[discord_mentor_link(whom, discord_id)]</b>: [msg]</font>", confidential=TRUE)
		else
			to_chat(src, "<font color='green mentor'>Mentor PM to-<b>[key_name_mentor(C, C, 1, 0, 0)]</b>: [msg]</font>", confidential=TRUE)
		if(ckey in SSYogs.mentortickets)
			var/datum/mentorticket/T = SSYogs.mentortickets[ckey]
			T.log += "<b>[key]:</b> [msg]"

	else
		if(is_mentor())	//sender is an mentor but recipient is not.
			if(C)
				to_chat(C, "<span class='purple mentor'>Mentor PM from-<b>[key_name_mentor(src, C, 1, 0, 0)]</b>: [msg]</span>", confidential=TRUE)
			to_chat(src, "<font color='green mentor'>Mentor PM to-<b>[key_name_mentor(C, C, 1, 0, show_char)]</b>: [msg]</font>", confidential=TRUE)
			if(C.ckey in SSYogs.mentortickets)
				var/datum/mentorticket/T = SSYogs.mentortickets[C.ckey]
				T.log += "<b>[key]:</b> [msg]"

	webhook_send_mres(C, src, msg)

	//we don't use message_Mentors here because the sender/receiver might get it too
	var/show_char_sender = !is_mentor() && CONFIG_GET(flag/mentors_mobname_only)
	var/show_char_recip = C && !C.is_mentor() && CONFIG_GET(flag/mentors_mobname_only)
	for(var/client/X in GLOB.mentors | (GLOB.admins - GLOB.deadmins))
		if(X.key != key && (!C || X.key != C.key))	//check client/X is an Mentor and isn't the sender or recipient
			if(discord_id)
				to_chat(X, "<B><font color='green mentor'>Mentor PM: [key_name_mentor(src, X, 0, 0, show_char_sender)]-&gt;[discord_mentor_link(whom, discord_id)]:</B> <span class='blueteamradio mentor'> [msg]</span>", confidential=TRUE) //inform X
			else
				to_chat(X, "<B><font color='green mentor'>Mentor PM: [key_name_mentor(src, X, 0, 0, show_char_sender)]-&gt;[key_name_mentor(C, X, 0, 0, show_char_recip)]:</B> <span class='blueteamradio mentor'> [msg]</span>", confidential=TRUE) //inform X
