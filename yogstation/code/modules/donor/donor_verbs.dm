
var/list/donor_verbs_list = list(
	/client/proc/donor_ooc
	)

/client/proc/add_donor_verbs()
	if(is_donator(src))
		verbs += donor_verbs_list

/client/proc/remove_donor_verbs()
	if(is_donator(src))
		verbs.Remove(
			donor_verbs_list,
			)

/client/proc/donor_ooc(msg as text)
	set name = "Donor OOC"
	set category = "OOC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)	
		return
		
	if(IsGuestKey(key))
		to_chat(src, "Guests may not use Donor.")
		return

	if(!holder)
		if(!GLOB.ooc_allowed)
			to_chat(src, "<span class='danger'>OOC is globally muted.</span>")
			return
		if(!GLOB.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>OOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='danger'>You cannot use OOC (muted).</span>")
			return
	if(jobban_isbanned(src.mob, "OOC"))
		to_chat(src, "<span class='danger'>You have been banned from OOC.</span>")
		return
	if(QDELETED(src))
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	var/raw_msg = msg
	
	if(!msg)
		return
		
	msg = pretty_filter(msg)
	msg = emoji_parse(msg)

	if((copytext(msg, 1, 2) in list(".",";",":","#")) || (findtext(lowertext(copytext(msg, 1, 5)), "say")))
		if(alert("Your message \"[raw_msg]\" looks like it was meant for in game communication, say it in OOC?", "Meant for OOC?", "No", "Yes") != "Yes")
			return

	if(!holder)
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	if(!(prefs.toggles & CHAT_OOC))
		to_chat(src, "<span class='danger'>You have OOC muted.</span>")
		return

	mob.log_talk(raw_msg, LOG_OOC)
	if(holder && holder.fakekey)
		webhook_send_ooc(holder.fakekey, msg)
	else
		webhook_send_ooc(key, msg)


	var/keyname = key
	if(prefs.unlock_content)
		if(prefs.toggles & MEMBER_PUBLIC)
			keyname = "<font color='[prefs.ooccolor ? prefs.ooccolor : GLOB.normal_ooc_colour]'>[icon2html('icons/member_content.dmi', world, "blag")][keyname]</font>"
	for(var/client/C in GLOB.clients)
		if((is_admin(C) || is_donator(C)) && C.prefs.toggles & CHAT_OOC)
			if(holder)
				if(!holder.fakekey || C.holder)
					if(check_rights_for(src, R_ADMIN))
						to_chat(C, "<span class='adminooc'>[CONFIG_GET(flag/allow_admin_ooccolor) && prefs.ooccolor ? "<font color=[prefs.ooccolor]>" :"" ]<span class='prefix'>[find_admin_rank(src)] Donor:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message linkify'>[msg]</span></span></font>")
					else
						to_chat(C, "<span class='adminobserverooc'><span class='prefix'>Donor:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message linkify'>[msg]</span></span>")
				else
					to_chat(C, "<font color='donorooc'><span class='ooc'><span class='prefix'>\[Donator\] Donor:</span> <EM>[holder.fakekey ? holder.fakekey : key]:</EM> <span class='message linkify'>[msg]</span></span></font>")
			else
				to_chat(C, "<font color='donorooc'><span class='ooc'><span class='prefix'>\[Donator\] Donor:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></span></font>")
	return

/client/verb/donator_who()
	set name = "Donator Who"
	set category = "OOC"

	var/msg = "<b>Current Donators:</b>\n"
	var/list/Lines = list()
	if(holder)
		for(var/client/C in GLOB.clients)
			if(is_donator(C))
				msg += "\t[C] is a [C.holder.rank]"

			if(C.holder.fakekey)
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
		for(var/client/C in GLOB.clients)
			if(is_donator(C))
				if(C.holder && C.holder.fakekey)
					Lines += "[C.holder.fakekey])"
				else
					Lines += "[C.key])"

	to_chat(src, msg)
