GLOBAL_LIST_EMPTY(NTPDAs)
GLOBAL_LIST_EMPTY(NTPDAMessages)

/// NTOS recreation of the PDA Messenger from HTML PDAs
/// Designed to always be active, even if the computer is off, until the program is either deleted or destroyed
/// New features: Easy renaming, blocking, and global message monitoring
/datum/computer_file/program/pdamessager
	filename = "pda_client"
	filedesc = "PDA Messaging"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "command"
	extended_desc = "This program allows for direct messaging with other modular computers"
	size = 3
	// Doesn't require NTNet, because if it did, traitors can't access uplink with NTNet down
	network_destination = "NTPDA server"
	ui_header = "ntnrc_idle.gif"
	available_on_ntnet = 1
	tgui_id = "NtosPdaMsg"
	program_icon = "comment-alt"

	var/showing_messages = FALSE
	var/username = "ERRORNAME"
	var/ringtone = "beep"
	var/receiving = FALSE
	var/silent = FALSE
	var/next_message = 0
	var/next_keytry = 0
	var/authed = FALSE
	var/authkey
	var/list/message_history = list()
	var/list/blocked_users = list()

/datum/computer_file/program/pdamessager/New()
	. = ..()
	username = "NewUser[rand(100, 999)]"
	GLOB.NTPDAs += src
	GLOB.NTPDAs = sortUsernames(GLOB.NTPDAs)
	for (var/obj/machinery/telecomms/message_server/preset/server in GLOB.telecomms_list)
		if (server.decryptkey)
			authkey = server.decryptkey
			break

/datum/computer_file/program/pdamessager/Destroy()
	GLOB.NTPDAs -= src
	return ..()

/// Proc that finds a computer because this program is expected to work without having being launched (which sets computer)
/datum/computer_file/program/pdamessager/proc/set_computer()
	if(istype(holder?.loc, /obj/item/modular_computer))
		computer = holder.loc

/datum/computer_file/program/pdamessager/proc/explode() // Why does NT have bombs in their modular tablets?
	var/obj/source
	if(computer)
		source = computer
	else if(istype(holder.loc, /obj/item/modular_computer))
		source = holder.loc
	else
		source = holder

	if(source)
		explosion(source, -1, 0, 3, 4)
		if(!QDELETED(source) && source.obj_integrity > source.integrity_failure) // Ensure the screen breaks
			source.take_damage(source.obj_integrity - source.integrity_failure, armour_penetration = 100)
	else
		throw EXCEPTION("No computer or hard drive to detonate!")
	
	qdel(src)

/datum/computer_file/program/pdamessager/proc/send_message(message, datum/computer_file/program/pdamessager/recipient, mob/user)
	if(user.shared_ui_interaction(computer) < UI_INTERACTIVE) //no replying if you're incapacitated
		return
	if(!istype(user, /mob/living/silicon/ai) && user.physical_can_use_topic(computer) < UI_INTERACTIVE) //no replying if you're too far away
		return
	set_computer()
	computer.visible_message(span_notice("Sending message to [recipient.username]:"), null, null, 1)
	computer.visible_message(span_notice("\"[message]\""), null, null, 1) // in case the message fails, they can copy+paste from here
	
	if(src == recipient)
		computer.visible_message(span_danger("Your message could not be delivered."), null, null, 1)
		computer.visible_message(span_danger("You are the recipient!"), null, null, 1)
		return FALSE

	if(src in recipient.blocked_users)
		computer.visible_message(span_danger("Your message could not be delivered."), null, null, 1)
		computer.visible_message(span_danger("Recipient has you blocked."), null, null, 1)
		return FALSE
	
	if(recipient in blocked_users)
		computer.visible_message(span_danger("Your message could not be delivered."), null, null, 1)
		computer.visible_message(span_danger("You have recipient blocked."), null, null, 1)
		return FALSE
	
	if(!recipient.receiving)
		computer.visible_message(span_danger("Your message could not be delivered."), null, null, 1)
		computer.visible_message(span_danger("Recipient is no longer accepting messages."), null, null, 1)
		return FALSE
	
	var/fakemob = "ERROR"
	var/fakejob = "ERROR"
	var/language = /datum/language/common
	if(user)
		fakemob = user
		fakejob = user.job
		language = user.get_selected_language()

	var/datum/signal/subspace/messaging/ntospda/signal = new(src, list(
		"name" = "[fakemob]",
		"job" = "[fakejob]",
		"message" = message,
		"language" = language,
		"targets" = list(recipient),
		"program" = src,
		"logged" = FALSE
	))
	signal.send_to_receivers()

	if (!signal.data["done"])
		computer.visible_message(span_danger("ERROR: Your message could not be processed by a broadcaster."), null, null, 1)
		return FALSE

	if (!signal.data["logged"])
		computer.visible_message(span_danger("ERROR: Your message could not be processed by a messaging server."), null, null, 1)
		return FALSE
	
	// Show ghosts (and admins)
	deadchat_broadcast(" sent an <b>NTPDA Message</b> ([username] --> [recipient.username]): [span_message(message)]", user, user, speaker_key = user.ckey)
	computer.visible_message(span_notice("Message sent!"), null, null, 1)
	message_history += list(list(username, message, REF(src), signal))
	return TRUE

/datum/computer_file/program/pdamessager/proc/send_message_everyone(message, mob/user)
	computer.visible_message(span_notice("Sending message to everyone:"), null, null, 1)
	computer.visible_message(span_notice("\"[message]\""), null, null, 1)

	var/list/targets = list()
	for(var/datum/computer_file/program/pdamessager/P in GLOB.NTPDAs)
		if(src == P)
			continue

		if(src in P.blocked_users)
			continue
		
		if(P in blocked_users)
			continue
		
		if(!P.receiving)
			continue
		
		targets += P
	
	if(targets.len <= 0)
		computer.visible_message(span_danger("Your message could not be delivered."), null, null, 1)
		computer.visible_message(span_danger("There were no valid recipients to deliver the message to."), null, null, 1)
		return FALSE
	
	var/fakemob = "ERROR"
	var/fakejob = "ERROR"
	var/language = /datum/language/common
	if(user)
		fakemob = user
		fakejob = user.job
		language = user.get_selected_language()

	var/datum/signal/subspace/messaging/ntospda/signal = new(src, list(
		"name" = "[fakemob]",
		"job" = "[fakejob]",
		"message" = message,
		"language" = language,
		"targets" = targets,
		"program" = src,
		"logged" = FALSE
	))
	signal.send_to_receivers()

	if (!signal.data["done"])
		computer.visible_message(span_danger("ERROR: Your message could not be processed by a broadcaster."), null, null, 1)
		return FALSE

	if (!signal.data["logged"])
		computer.visible_message(span_danger("ERROR: Your message could not be processed by a messaging server."), null, null, 1)
		return FALSE
	
	// Show ghosts (and admins)
	deadchat_broadcast(" sent an <b>NTPDA Message</b> ([username] --> <b>Everyone</b>): [span_message(message)]", user, user, speaker_key = user.ckey)
	computer.visible_message(span_notice("Message sent!"), null, null, 1)
	message_history += list(list(username, message, REF(src), signal))
	return TRUE

/datum/computer_file/program/pdamessager/proc/receive_message(datum/signal/subspace/messaging/ntospda/signal)
	var/datum/computer_file/program/pdamessager/sender = signal.data["program"]
	var/message = signal.data["message"]

	if(blocked_users.Find(sender))
		return 2
	
	if(!receiving)
		return 3

	message_history += list(list(sender.username, message, REF(sender), signal))

	if(!silent && istype(holder, /obj/item/computer_hardware/hard_drive))
		if(HAS_TRAIT(SSstation, STATION_TRAIT_PDA_GLITCHED))
			playsound(holder, pick('sound/machines/twobeep_voice1.ogg', 'sound/machines/twobeep_voice2.ogg'), 50, FALSE)
		else
			playsound(holder, 'sound/machines/twobeep_high.ogg', 50, FALSE)
		set_computer()
		computer.audible_message("[icon2html(computer, hearers(computer))] *[ringtone]*", null, 3)
		var/msg = "<b>Message from [sender.username], \"[message]\"</b>"
		if(istype(computer, /obj/item/modular_computer/tablet))
			msg += " (<a href='byond://?src=[REF(src)];target=[REF(signal.data["program"])]'>Reply</a>)"
		computer.visible_message(span_notice(msg), null, null, 1)
	
	return TRUE

/datum/computer_file/program/pdamessager/Topic(href, list/href_list)
	. = ..()
	if(usr.shared_ui_interaction(computer) < UI_INTERACTIVE) //no replying if you're incapacitated
		return
	if(!istype(usr, /mob/living/silicon/ai) && usr.physical_can_use_topic(computer) < UI_INTERACTIVE) //no replying if you're too far away
		return
	var/msg = input("Send a message?") as null|text
	msg = sanitizeinput(msg, computer)
	if(msg)
		var/datum/computer_file/program/pdamessager/recipient = locate(href_list["target"]) in GLOB.NTPDAs
		if(istype(recipient))
			send_message(msg, recipient, usr)
		else
			computer.visible_message(span_danger("Your message could not be delivered."), null, null, 1)
			computer.visible_message(span_danger("Recipient does not exist!"), null, null, 1)

/datum/computer_file/program/pdamessager/proc/sanitizeinput(unsanitized, obj/item/modular_computer/computer)
	if(!unsanitized)
		return
	
	if(isnotpretty(unsanitized))
		if(usr.client.prefs.muted & MUTE_IC)
			return
		usr.client.handle_spam_prevention("PRETTY FILTER", MUTE_ALL) // Constant message mutes someone faster for not pretty messages
		to_chat(usr, "<span class='notice'>Your fingers slip. <a href='https://forums.yogstation.net/help/rules/#rule-0_1'>See rule 0.1</a>.</span>")
		var/log_message = "[key_name(usr)] just tripped a pretty filter: '[unsanitized]'."
		message_admins(log_message)
		log_say(log_message)
		return

	unsanitized = reject_bad_text(unsanitized, max_length = 280)
	if(!unsanitized)
		computer.visible_message(span_danger("Your message could not be delivered."), null, null, 1)
		computer.visible_message(span_danger("Your message is too long/has bad text!"), null, null, 1)
		return
	return unsanitized
		
	

/datum/computer_file/program/pdamessager/ui_act(action, params)
	if(..())
		return

	computer.play_interact_sound()
	switch(action)
		if("PRG_sendmsg")
			if(next_message > world.time)
				return
			
			var/unsanitized = params["message"]
			var/message = sanitizeinput(unsanitized, computer)
			if(!message)
				return

			if(params["recipient"] != "EVERYONE")
				var/datum/computer_file/program/pdamessager/recipient = locate(params["recipient"]) in GLOB.NTPDAs
				if(!istype(recipient))
					computer.visible_message(span_danger("Your message could not be delivered."), null, null, 1)
					computer.visible_message(span_danger("Recipient does not exist!"), null, null, 1)
					return

				next_message = world.time + 1 SECONDS
				send_message(message, recipient, usr)
				var/mob/living/user = usr
				user.log_talk(message, LOG_CHAT, tag="as [username] to user [recipient.username]")
				return TRUE
			else // @everyone
				if(!(ACCESS_LAWYER in computer.GetAccess()))
					return
				next_message = world.time + 10 SECONDS
				send_message_everyone(message, usr)
				var/mob/living/user = usr
				user.log_talk(message, LOG_CHAT, tag="as [username] to everyone")
				return TRUE

		
		if("PRG_keytry")
			if(next_keytry > world.time)
				return
			if(authed)
				return
			next_keytry = world.time + 5 SECONDS
			if(params["message"] != authkey)
				computer.visible_message(span_danger("Monitor key incorrect. Please try again."), null, null, 1)
			else
				computer.visible_message(span_notice("Monitor key accepted. Welcome, administrator."), null, null, 1)
				authed = TRUE
			return TRUE
		
		if("PRG_logout")
			authed = FALSE
			return TRUE
		
		if("PRG_block")
			var/datum/computer_file/program/pdamessager/recipient = locate(params["recipient"]) in GLOB.NTPDAs
			if(!istype(recipient))
				computer.visible_message(span_danger("Block failed."), null, null, 1)
				computer.visible_message(span_danger("User does not exist!"), null, null, 1)
				return
			
			computer.visible_message(span_danger("Blocked [recipient.username]."), null, null, 1)
			blocked_users += recipient
			return TRUE
		
		if("PRG_unblock")
			var/datum/computer_file/program/pdamessager/recipient = locate(params["recipient"]) in GLOB.NTPDAs
			if(!istype(recipient))
				computer.visible_message(span_danger("Unblock failed."), null, null, 1)
				computer.visible_message(span_danger("User does not exist!"), null, null, 1)
				return
			
			computer.visible_message(span_notice("Unblocked [recipient.username]."), null, null, 1)
			blocked_users.Remove(recipient)
			return TRUE
		
		if("PRG_silence")
			computer.visible_message(span_danger("Status set to Do Not Disturb."), null, null, 1)
			silent = TRUE
			return TRUE

		if("PRG_audible")
			computer.visible_message(span_notice("Status set to Online."), null, null, 1)
			silent = FALSE
			return TRUE
		
		if("PRG_namechange")

			if(computer.GetID())
				computer.visible_message(span_danger("Username is ID-locked!"), null, null, 1)
				return

			var/unsanitized = params["name"]

			if(isnotpretty(unsanitized))
				if(usr.client.prefs.muted & MUTE_IC)
					return
				usr.client.handle_spam_prevention("PRETTY FILTER", MUTE_ALL) // Constant message mutes someone faster for not pretty messages
				to_chat(usr, "<span class='notice'>Your fingers slip. <a href='https://forums.yogstation.net/help/rules/#rule-0_1'>See rule 0.1</a>.</span>")
				var/log_message = "[key_name(usr)] just tripped a pretty filter: '[unsanitized]'."
				message_admins(log_message)
				log_say(log_message)
				return

			var/newname = reject_bad_text(unsanitized, max_length = 55)
			if(!newname)
				computer.visible_message(span_danger("Your username is too long/has bad text!"), null, null, 1)
				return
			
			for(var/datum/computer_file/program/pdamessager/P in GLOB.NTPDAs)
				if(newname == P.username)
					computer.visible_message(span_danger("Someone already has the username \"[newname]\"!"), null, null, 1)	
					return

			username = newname
			GLOB.NTPDAs = sortUsernames(GLOB.NTPDAs)
			computer.visible_message(span_notice("Username set to [newname]."), null, null, 1)
			return TRUE

		if("PRG_clearhistory")
			message_history = list()
			computer.visible_message(span_notice("Message history cleared."), null, null, 1)
			return TRUE
		
		if("PRG_ringtone")
			if(computer.uplink_check(usr, params["name"]))
				return TRUE
			else
				var/unsanitized = params["name"]

				if(isnotpretty(unsanitized))
					if(usr.client.prefs.muted & MUTE_IC)
						return
					usr.client.handle_spam_prevention("PRETTY FILTER", MUTE_ALL) // Constant message mutes someone faster for not pretty messages
					to_chat(usr, "<span class='notice'>Your fingers slip. <a href='https://forums.yogstation.net/help/rules/#rule-0_1'>See rule 0.1</a>.</span>")
					var/log_message = "[key_name(usr)] just tripped a pretty filter: '[unsanitized]'."
					message_admins(log_message)
					log_say(log_message)
					return
				
				var/newring = reject_bad_text(unsanitized, max_length = 10)
				
				if(!newring)
					computer.visible_message(span_danger("Your ringtone is too long/has bad text!"), null, null, 1)
					return
				
				ringtone = newring
				computer.visible_message(span_notice("Ringtone set to [newring]."), null, null, 1)
			return TRUE
		
		if("PRG_norecieve")
			computer.visible_message(span_danger("Messenger offline."), null, null, 1)
			receiving = FALSE
			return TRUE
		
		if("PRG_yesrecieve")
			computer.visible_message(span_notice("Messenger online."), null, null, 1)
			receiving = TRUE
			return TRUE
		
		if("PRG_showhistory")
			showing_messages = TRUE
			return TRUE

		if("PRG_closehistory")
			showing_messages = FALSE
			return TRUE

/datum/computer_file/program/pdamessager/ui_data(mob/user)
	var/list/data = list()
	data = get_header_data()

	var/can_message = next_message <= world.time
	var/can_keytry = next_keytry <= world.time
	data["can_message"] = can_message
	data["can_keytry"] = can_keytry
	data["username"] = username
	data["receiving"] = receiving
	data["silent"] = silent
	data["authed"] = authed
	data["ringtone"] = ringtone
	data["showing_messages"] = showing_messages
	data["can_at_everyone"] = (ACCESS_LAWYER in computer.GetAccess())
	var/list/modified_history = list()
	for(var/M in message_history)
		var/datum/signal/subspace/messaging/ntospda/N = M[4]
		if(N)
			modified_history += list(list(M[1], N.format_message(user), M[3]))
		else
			modified_history += list(list(M[1], M[2], M[3]))
	data["message_history"] = modified_history
	
	var/list/pdas = list()
	for(var/datum/computer_file/program/pdamessager/P in GLOB.NTPDAs)
		if(P == src)
			continue
		if(P.receiving == FALSE)
			continue
		if(!P.holder)
			continue
		if(!istype(holder.loc, /obj/item/modular_computer))
			continue
		pdas += list(list(P.username, REF(P), blocked_users.Find(P)))
	data["pdas"] = pdas

	if(authed)
		data["all_messages"] = GLOB.NTPDAMessages
	else
		data["all_messages"] = list()

	return data
