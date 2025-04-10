#define IRCREPLYCOUNT 2


//allows right clicking mobs to send an admin PM to their client, forwards the selected mob's client to cmd_admin_pm
/client/proc/cmd_admin_pm_context(mob/M in GLOB.mob_list)
	set category = null
	set name = "Admin PM Mob"
	if(!holder)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Context: Only administrators may use this command."),
			confidential = TRUE)
		return
	if(!ismob(M)) //yogs start
		return
	if(M.client)
		cmd_admin_pm(M.client,null)
	else if(M.oobe_client)
		cmd_admin_pm(M.oobe_client,null)
	else
		return //yogs end
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin PM Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_panel()
	set category = "Admin"
	set name = "Admin PM"
	if(!holder)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Panel: Only administrators may use this command."),
			confidential = TRUE)
		return
	var/list/client/targets[0]
	for(var/client/T)
		if(T.mob)
			if(isnewplayer(T.mob))
				targets["(New Player) - [T]"] = T
			else if(isobserver(T.mob))
				targets["[T.mob.name](Ghost) - [T]"] = T
			else
				targets["[T.mob.real_name](as [T.mob.name]) - [T]"] = T
		else
			targets["(No Mob) - [T]"] = T
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) as null|anything in sortList(targets)
	cmd_admin_pm(targets[target],null)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin PM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_ahelp_reply(whom)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM: You are unable to use admin PM-s (muted)."),
			confidential = TRUE)
		return
	var/client/C
	if(istext(whom))
		if(whom[1] == "@")
			whom = findStealthKey(whom)
		C = GLOB.directory[whom]
	else if(istype(whom, /client))
		C = whom
	if(!C)
		if(holder)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM: Client not found."),
				confidential = TRUE)
		return

	var/datum/admin_help/AH = C.current_ticket

	if(AH)
		message_admins("[key_name_admin(src)] has started replying to [key_name_admin(C, 0, 0)]'s admin help.")
		if(!AH.handling_admin_ckey)
			AH.Administer(TRUE)
	var/msg = input(src,"Message:", "Private message to [C.holder?.fakekey ? "an Administrator" : key_name(C, 0, 0)].") as message|null
	if (!msg)
		message_admins("[key_name_admin(src)] has cancelled their reply to [key_name_admin(C, 0, 0)]'s admin help.")
		return
	cmd_admin_pm(whom, msg)

//takes input from cmd_admin_pm_context, cmd_admin_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed. src is the sender and C is the target client
/client/proc/cmd_admin_pm(whom, msg)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM: You are unable to use admin PM-s (muted)."),
			confidential = TRUE)
		return

	if(!holder && !current_ticket)	//no ticket? https://www.youtube.com/watch?v=iHSPf6x1Fdo
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("You can no longer reply to this ticket, please open another one by using the Adminhelp verb if need be."),
			confidential = TRUE)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_notice("Message: [msg]"),
			confidential = TRUE)

		return

	var/client/recipient
	var/discord = FALSE
	var/irc = FALSE
	if(istext(whom))
		if(whom[1] == "@")
			whom = findStealthKey(whom)
		if(whom == "IRCKEY")
			irc = TRUE
		else if(whom[1] == "$")
			discord = TRUE
			whom = ckey(whom)
		else
			recipient = GLOB.directory[whom]
	else if(istype(whom, /client))
		recipient = whom


	if(irc)
		if(!ircreplyamount)	//to prevent people from spamming irc
			return
		if(!msg)
			msg = input(src,"Message:", "Private message to Administrator") as message|null

		if(!msg)
			return
		if(holder)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Use the admin IRC/Discord channel, nerd."),
				confidential = TRUE)
			return

	else if(discord) 
		if(!msg)
			msg = input(src,"Message:", "Private message to Administrator") as message|null

		if(!msg)
			return
	else
		if(!recipient)
			if(holder)
				to_chat(src, span_danger("Error: Admin-PM: Client not found."), confidential=TRUE)
				if(msg)
					to_chat(src, msg, confidential=TRUE)
				return
			else if(msg) // you want to continue if there's no message instead of returning now
				current_ticket.MessageNoRecipient(msg)
				return

		//get message text, limit it's length.and clean/escape html
		if(!msg)
			if(holder)
				message_admins("[key_name_admin(src)] has started replying to [key_name_admin(recipient, 0, 0)]'s admin help.")
				var/datum/admin_help/AH = recipient.current_ticket
				if(AH && !AH.handling_admin_ckey)
					AH.Administer(TRUE)
			msg = input(src,"Message:", "Private message to [recipient.holder?.fakekey ? "an Administrator" : key_name(recipient, 0, 0)].") as message|null
			msg = trim(msg)
			if(!msg)
				if(holder)
					message_admins("[key_name_admin(src)] has cancelled their reply to [key_name_admin(recipient, 0, 0)]'s admin help.")
				return

			if(prefs.muted & MUTE_ADMINHELP)
				to_chat(src, span_danger("Error: Admin-PM: You are unable to use admin PM-s (muted)."), confidential=TRUE)
				return

			if(!recipient)
				if(holder)
					to_chat(src,
						type = MESSAGE_TYPE_ADMINPM,
						html = span_danger("Error: Admin-PM: Client not found."),
						confidential = TRUE)
				else
					current_ticket.MessageNoRecipient(msg)
				return

	if (src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG,0)||irc||discord)//no sending html to the poor bots
		msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))
		if(!msg)
			return

	var/rawmsg = msg

	if(holder)
		msg = emoji_parse(msg)

	var/keywordparsedmsg = keywords_lookup(msg)

	if(irc)
		to_chat(src, span_notice("PM to-<b>Admins</b>: [span_linkify("[rawmsg]")]"), confidential=TRUE)
		var/datum/admin_help/AH = admin_ticket_log(src, rawmsg) // yogs - Yog Tickets
		ircreplyamount--
		send2irc("[AH ? "#[AH.id] " : ""]Reply: [ckey]", rawmsg)
	else if(discord)
		to_chat(src, span_notice("PM to-<b>Admins</b>: [span_linkify("[rawmsg]")]"), confidential=TRUE)
		current_ticket.AddInteraction(rawmsg, ckey=src.ckey)
	else
		if(recipient.holder)
			if(holder)
				to_chat(recipient, "<font color='red' size='4'><b>-- Administrator private message --</b></font>", confidential=TRUE)
				to_chat(recipient, span_adminsay("Admin PM from-<b>[key_name(src, recipient, 0)]</b>: [span_linkify("[msg]")]"), confidential=TRUE)
				to_chat(recipient, span_adminsay("<i>Click on the administrator's name to reply.</i>"), confidential=TRUE)
				to_chat(src,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_notice("Admin PM to-<b>[key_name(recipient, src, 1)]</b>: [span_linkify("[keywordparsedmsg]")]"),
					confidential = TRUE)

				//omg this is dumb, just fill in both their tickets
				// yogs start - Yog Tickets
				admin_ticket_log(src, msg, FALSE)
				if(!recipient.current_ticket && !current_ticket) // creates a ticket if there is no ticket of either user
					new /datum/admin_help(msg, recipient, TRUE) // yogs - Yog Tickets
				if(recipient.current_ticket && !recipient.current_ticket.handling_admin_ckey)
					recipient.current_ticket.Administer()
				// yogs end - Yog Tickets
				if(recipient != src)	//reeee
					admin_ticket_log(recipient, msg, FALSE) // yogs - Yog Tickets

			else		//recipient is an admin but sender is not
				//YOGS START -- Yogs Tickets
				if(!current_ticket)
					to_chat(src, span_notice("Ticket closed, please make a new one before trying to contact admins!"), confidential=TRUE)
					return
				admin_ticket_log(src, msg, FALSE)
				to_chat(recipient, span_danger("Reply PM from-<b>[key_name(src, recipient, 1)]</b>: [span_linkify("[keywordparsedmsg]")]"), confidential=TRUE)
				to_chat(src, span_notice("-- [key_name(src, null, 0)] -> <b>Admins</b>: [span_linkify("[msg]")]"), confidential=TRUE)
				//YOGS END

			//play the receiving admin the adminhelp sound (if they have them enabled)
			if(recipient.prefs.toggles & SOUND_ADMINHELP)
				SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg'))

		else
			if(holder)	//sender is an admin but recipient is not. Do BIG RED TEXT
				if(!recipient.current_ticket)
					new /datum/admin_help(msg, recipient, TRUE) // yogs - Yog Tickets
				if(!recipient.current_ticket.handling_admin_ckey)
					recipient.current_ticket.Administer() // yogs - Yog Tickets
				if(recipient.current_ticket.handling_admin_ckey != usr.ckey)
					if(tgui_alert(usr, "You are replying to a ticket administered by [recipient.current_ticket.handling_admin_ckey], are you sure you wish to continue?", "Confirm", list("Yes", "No")) != "Yes")
						return

				to_chat(recipient, "<font color='red' size='4'><b>-- Administrator private message --</b></font>", confidential=TRUE)
				to_chat(recipient, span_adminsay("Admin PM from-<b>[key_name(src, recipient, 0)]</b>: [span_linkify("[msg]")]"), confidential=TRUE)
				to_chat(recipient, span_adminsay("<i>Click on the administrator's name to reply.</i>"), confidential=TRUE)
				to_chat(src, span_notice("Admin PM to-<b>[key_name(recipient, src, 1)]</b>: [span_linkify("[msg]")]"), confidential=TRUE)

				admin_ticket_log(recipient, "PM From [src]: [msg]", FALSE)// yogs - Yog Tickets

				//always play non-admin recipients the adminhelp sound
				SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg'))

				//AdminPM popup for ApocStation and anybody else who wants to use it. Set it with POPUP_ADMIN_PM in config.txt ~Carn
				if(CONFIG_GET(flag/popup_admin_pm) || recipient.current_ticket.popups_enabled) //Yogs (or apparently Apoc I guess) -- ticket popups.
					spawn()	//so we don't hold the caller_but_not_a_byond_built_in_proc proc up
						var/sender = src
						var/sendername = key
						var/reply = input(recipient, msg,"Admin PM from-[sendername]", "") as message|null	//show message and await a reply
						if(!recipient) // User logged off
							return

						var/temp = usr
						usr = recipient.mob
						if(!reply) // User dismissed popup
							recipient.current_ticket.AddInteraction("Dismissed popup")
						else
							if(sender)
								recipient.cmd_admin_pm(sender,reply)										//sender is still about, let's reply to them
							else
								adminhelp(reply)													//sender has left, adminhelp instead
						usr = temp
						return

			else		//neither are admins
				to_chat(src,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_danger("Error: Admin-PM: Non-admin to non-admin PM communication is forbidden."),
					confidential = TRUE)
				return

	if(irc)
		log_admin_private("PM: [key_name(src)]->IRC: [rawmsg]")
		for(var/client/X in GLOB.permissions.admins)
			to_chat(X,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_notice("<B>PM: [key_name(src, X, 0)]-&gt;External:</B> [keywordparsedmsg]"),
				confidential = TRUE)
	else if(discord)
		var/logmsg = "PM: [key_name(src)]->[whom] (discord): [rawmsg]"
		log_admin_private(logmsg)
		message_admins("PM: [key_name(src)]->[whom] (discord): [rawmsg]")
	else
		window_flash(recipient, ignorepref = TRUE)
		log_admin_private("PM: [key_name(src)]->[key_name(recipient)]: [rawmsg]")
		//we don't use message_admins here because the sender/receiver might get it too
		for(var/client/X in GLOB.permissions.admins)
			if(X.key!=key && X.key!=recipient.key)	//check client/X is an admin and isn't the sender or recipientD
				to_chat(X,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_notice("<B>PM: [key_name(src, X, 0)]-&gt;[key_name(recipient, X, 0)]:</B> [keywordparsedmsg]") ,
					confidential = TRUE)

/datum/admin_help/proc/DiscordReply(ckey, message)
	if(!initiator) return "ERROR: Client not found"

	var/msg = sanitize(copytext_char(message, 1, MAX_MESSAGE_LEN))
	if(!msg)
		return "ERROR: No message"

	message_admins("Discord message from [ckey] to [key_name_admin(initiator)] : [msg]")
	log_admin_private("Discord PM: [ckey] -> [key_name(initiator)] : [msg]")
	msg = emoji_parse(msg)

	to_chat(initiator,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<font color='red' size='4'><b>-- Administrator private message --</b></font>",
		confidential = TRUE)
	to_chat(initiator,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_adminsay("Admin PM from-<b><a href='byond://?priv_msg=$[ckey]'>[ckey]</A></b>: [msg]"),
		confidential = TRUE) // yogs - Yog Tickets
	to_chat(initiator,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_adminsay("<i>Click on the administrator's name to reply.</i>"),
		confidential = TRUE) // yogs - Yog Tickets

	AddInteraction(msg, ckey=ckey) // yogs - Yog Tickets

	window_flash(initiator, ignorepref = TRUE)
	//always play non-admin recipients the adminhelp sound
	SEND_SOUND(initiator, 'sound/effects/adminhelp.ogg')

	return "Message Sent"


#define IRC_AHELP_USAGE "Usage: ticket <close|resolve|icissue|reject|reopen \[ticket #\]|list>"
/proc/IrcPm(target,msg,sender)
	target = ckey(target)
	var/client/C = GLOB.directory[target]

	var/datum/admin_help/ticket = C ? C.current_ticket : GLOB.ahelp_tickets.CKey2ActiveTicket(target)
	var/compliant_msg = trim(lowertext(msg))
	var/irc_tagged = "[sender](IRC)"
	var/list/splits = splittext(compliant_msg, " ")
	if(splits.len && splits[1] == "ticket")
		if(splits.len < 2)
			return IRC_AHELP_USAGE
		switch(splits[2])
			if("close")
				if(ticket)
					ticket.Close(irc_tagged)
					return "Ticket #[ticket.id] successfully closed"
			if("resolve")
				if(ticket)
					ticket.Resolve(irc_tagged)
					return "Ticket #[ticket.id] successfully resolved"
			if("icissue")
				if(ticket)
					ticket.ICIssue(irc_tagged)
					return "Ticket #[ticket.id] successfully marked as IC issue"
			if("reject")
				if(ticket)
					ticket.Reject(irc_tagged)
					return "Ticket #[ticket.id] successfully rejected"
			if("reopen")
				if(ticket)
					return "Error: [target] already has ticket #[ticket.id] open"
				var/fail = splits.len < 3 ? null : -1
				if(!isnull(fail))
					fail = text2num(splits[3])
				if(isnull(fail))
					return "Error: No/Invalid ticket id specified. [IRC_AHELP_USAGE]"
				var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(fail)
				if(!AH)
					return "Error: Ticket #[fail] not found"
				if(AH.initiator_ckey != target)
					return "Error: Ticket #[fail] belongs to [AH.initiator_ckey]"
				AH.Reopen()
				return "Ticket #[ticket.id] successfully reopened"
			if("list")
				var/list/tickets = GLOB.ahelp_tickets.TicketsByCKey(target)
				if(!tickets.len)
					return "None"
				. = ""
				for(var/I in tickets)
					var/datum/admin_help/AH = I
					if(.)
						. += ", "
					if(AH == ticket)
						. += "Active: "
					. += "#[AH.id]"
				return
			else
				return IRC_AHELP_USAGE
		return "Error: Ticket could not be found"

	var/static/stealthkey
	var/adminname = CONFIG_GET(flag/show_irc_name) ? irc_tagged : "Administrator"

	if(!C)
		return "Error: No client"

	if(!stealthkey)
		stealthkey = GenIrcStealthKey()

	msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))
	if(!msg)
		return "Error: No message"

	message_admins("IRC message from [sender] to [key_name_admin(C)] : [msg]")
	log_admin_private("IRC PM: [sender] -> [key_name(C)] : [msg]")
	msg = emoji_parse(msg)

	to_chat(C,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<font color='red' size='4'><b>-- Administrator private message --</b></font>",
		confidential = TRUE)
	to_chat(C,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_adminsay("Admin PM from-<b><a href='byond://?priv_msg=[stealthkey]'>[adminname]</A></b>: [msg]"),
		confidential = TRUE) // yogs - Yog Tickets
	to_chat(C,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_adminsay("<i>Click on the administrator's name to reply.</i>"),
		confidential = TRUE) // yogs - Yog Tickets

	admin_ticket_log(C, "PM From [irc_tagged]: [msg]") // yogs - Yog Tickets

	window_flash(C, ignorepref = TRUE)
	//always play non-admin recipients the adminhelp sound
	SEND_SOUND(C, 'sound/effects/adminhelp.ogg')

	C.ircreplyamount = IRCREPLYCOUNT

	return "Message Successful"

/proc/GenIrcStealthKey()
	var/num = (rand(0,1000))
	var/i = 0
	while(i == 0)
		i = 1
		for(var/P in GLOB.stealthminID)
			if(num == GLOB.stealthminID[P])
				num++
				i = 0
	var/stealth = "@[num2text(num)]"
	GLOB.stealthminID["IRCKEY"] = stealth
	return	stealth

#undef IRCREPLYCOUNT
