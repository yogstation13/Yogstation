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
	requires_ntnet = 1
	requires_ntnet_feature = NTNET_COMMUNICATION
	network_destination = "NTPDA server"
	ui_header = "ntnrc_idle.gif"
	available_on_ntnet = 1
	tgui_id = "NtosPdaMsg"
	program_icon = "comment-alt"

	var/showing_messages = FALSE
	var/username = "ERRORNAME"
	var/ringtone = "beep"
	var/receiving = TRUE
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
	for (var/obj/machinery/telecomms/message_server/preset/server in GLOB.telecomms_list)
		if (server.decryptkey)
			authkey = server.decryptkey
			break

/datum/computer_file/program/pdamessager/Destroy()
	GLOB.NTPDAs -= src
	return ..()

/datum/computer_file/program/pdamessager/proc/send_message(message, datum/computer_file/program/pdamessager/recipient)
	computer.visible_message(span_notice("Sending message to [recipient.username]:"), null, null, 1)
	computer.visible_message(span_notice("\"[message]\""), null, null, 1) // in case the message fails, they can copy+paste from here
	if(recipient.blocked_users.Find(src))
		computer.visible_message(span_danger("Your message could not be delivered."), null, null, 1)
		computer.visible_message(span_danger("Recipient has you blocked."), null, null, 1)
		return FALSE
	
	if(blocked_users.Find(recipient))
		computer.visible_message(span_danger("Your message could not be delivered."), null, null, 1)
		computer.visible_message(span_danger("You have recipient blocked."), null, null, 1)
		return FALSE
	
	if(!recipient.receiving)
		computer.visible_message(span_danger("Your message could not be delivered."), null, null, 1)
		computer.visible_message(span_danger("Recipient is no longer accepting messages."), null, null, 1)
		return FALSE
	
	switch(recipient.receive_message(message, src))
		if(FALSE)
			computer.visible_message(span_danger("Your message could not be delivered."), null, null, 1)
			computer.visible_message(span_danger("Generic error."), null, null, 1)
		if(TRUE) // success
			computer.visible_message(span_notice("Message sent!"), null, null, 1)
			return TRUE
		if(2)
			computer.visible_message(span_danger("Your message could not be delivered."), null, null, 1)
			computer.visible_message(span_danger("Recipient has you blocked."), null, null, 1)
		if(3)
			computer.visible_message(span_danger("Your message could not be delivered."), null, null, 1)
			computer.visible_message(span_danger("Recipient is no longer accepting messages."), null, null, 1)

	return FALSE

/datum/computer_file/program/pdamessager/proc/receive_message(message, datum/computer_file/program/pdamessager/sender)
	if(blocked_users.Find(sender))
		return 2
	
	if(!receiving)
		return 3

	message_history += list(list(sender.username, message, REF(sender)))
	GLOB.NTPDAMessages += list(list(sender.username, username, message))

	if(!silent && istype(holder, /obj/item/computer_hardware/hard_drive))
		if(HAS_TRAIT(SSstation, STATION_TRAIT_PDA_GLITCHED))
			playsound(holder, pick('sound/machines/twobeep_voice1.ogg', 'sound/machines/twobeep_voice2.ogg'), 6, FALSE)
		else
			playsound(holder, 'sound/machines/twobeep_high.ogg', 6, FALSE)
		
		// FOR SOME REASON [computer] ISN'T SET ON INIT AND IS SET WHEN YOU START IT UP THE FIRST TIME
		if(computer) // I HAVE TO DO THIS OR THEY WON'T RECEIVE MESSAGES UNTIL THEY OPEN THE PDA ONCE (BAD)
			computer.audible_message("[icon2html(computer, hearers(computer))] *[ringtone]*", null, 3)
			computer.visible_message(span_notice("Message from [sender.username], \"[message]\""), null, null, 1)
		else if(istype(holder.loc, /obj/item/modular_computer)) // play it from the (unset) computer
			var/obj/item/modular_computer/tempcomp = holder.loc
			tempcomp.audible_message("[icon2html(tempcomp, hearers(tempcomp))] *[ringtone]*", null, 3)
			tempcomp.visible_message(span_notice("Message from [sender.username], \"[message]\""), null, null, 1)
	
	return TRUE

/datum/computer_file/program/pdamessager/ui_act(action, params)
	if(..())
		return

	computer.play_interact_sound()
	switch(action)
		if("PRG_sendmsg")
			if(next_message > world.time)
				return
			
			var/unsanitized = params["message"]
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

			var/message = reject_bad_text(unsanitized, max_length = 280)
			if(!message)
				computer.visible_message(span_danger("Your message could not be delivered."), null, null, 1)
				computer.visible_message(span_danger("Your message is too long/has bad text!"), null, null, 1)
				return
			
			var/datum/computer_file/program/pdamessager/recipient = locate(params["recipient"]) in GLOB.NTPDAs
			if(!istype(recipient))
				computer.visible_message(span_danger("Your message could not be delivered."), null, null, 1)
				computer.visible_message(span_danger("Recipient does not exist!"), null, null, 1)
				return

			next_message = world.time + 1 SECONDS
			send_message(message, recipient)
			var/mob/living/user = usr
			user.log_talk(message, LOG_CHAT, tag="as [username] to user [recipient.username]")
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
			var/newname = reject_bad_text(params["name"], max_length = 35)
			if(!newname)
				computer.visible_message(span_danger("Your username is too long/has bad text!"), null, null, 1)
				return
			for(var/datum/computer_file/program/pdamessager/P in GLOB.NTPDAs)
				if(newname == P.username)
					computer.visible_message(span_danger("Someone already has the username \"[newname]\"!"), null, null, 1)	
					return

			username = newname
			computer.visible_message(span_notice("Username set to [newname]."), null, null, 1)
			return TRUE

		if("PRG_clearhistory")
			message_history = list()
			computer.visible_message(span_notice("Message history cleared."), null, null, 1)
			return TRUE
		
		if("PRG_ringtone")
			if(computer.SEND_SIGNAL(src, COMSIG_NTOS_CHANGE_RINGTONE, usr, params["name"]) & COMPONENT_STOP_RINGTONE_CHANGE)
				return TRUE
			else
				var/newring = reject_bad_text(params["name"], max_length = 10)
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
	data["message_history"] = message_history
	
	var/list/pdas
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
