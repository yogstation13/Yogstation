
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

var/global/normal_donor_ooc_colour = "#333333"

/client/proc/donor_ooc_admin(msg as text)
	set name = "Donor OOC"
	set category = "Admin"
	donor_ooc(msg)

/client/proc/donor_ooc(msg as text)
	set name = "Donor OOC"
	set category = "OOC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)	return
	if(IsGuestKey(key))
		to_chat(src, "Guests may not use Donor.")
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)	return

	if(!(prefs.toggles & CHAT_OOC))
		to_chat(src, "<span class='danger'>You have Donor muted.</span>")
		return

	if(!holder)
		if(!GLOB.ooc_allowed)
			to_chat(src, "<span class='danger'>Donor is globally muted.</span>")
			return
		if(!GLOB.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>Donor for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='danger'>You cannot use Donor (muted).</span>")
			return
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in Donor: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in Donor: [msg]")
			return

	log_ooc("\[Donor\] [mob.name]/[key] : [msg]")

	var/keyname = key
	if(prefs.unlock_content && (prefs.toggles & MEMBER_PUBLIC))
		keyname = "<font color='[prefs.ooccolor]'>"
		if(prefs.unlock_content & 1)
			keyname += "<img style='width:9px;height:9px;' class=icon src=\ref['icons/member_content.dmi'] iconstate=blag>"
		if(prefs.unlock_content & 2)
			keyname += "<img style='width:9px;height:9px;' class=icon src=\ref['icons/member_content.dmi'] iconstate=yogdon>"
		keyname += "[key]</font>"

	for(var/client/C in GLOB.clients)
		if((is_admin(C) || is_donator(C)) && C.prefs.toggles & CHAT_OOC)
			if(holder)
				if(!holder.fakekey || C.holder)
					if(check_rights_for(src, R_ADMIN))
						to_chat(C, "<font color='[normal_donor_ooc_colour]'><b><span class='prefix'>\[Admin\] Donor:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></b></font>")
					else
						to_chat(C, "<span class='[normal_donor_ooc_colour]'><span class='prefix'>Donor:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></span>")
				else
					to_chat(C, "<font color='[normal_donor_ooc_colour]'><span class='ooc'><span class='prefix'>Donor:</span> <EM>[holder.fakekey ? holder.fakekey : key]:</EM> <span class='message'>[msg]</span></span></font>")
			else
				to_chat(C, "<font color='[normal_donor_ooc_colour]'><span class='ooc'><span class='prefix'>Donor:</span> <EM>[keyname]:</EM> <span class='message'>[msg]</span></span></font>")
	return

/client/verb/donator_who()
	set name = "Donator Who"
	set category = "OOC"

	var/msg = "<b>Current Donators:</b>\n"
	var/list/Lines = list()
	if(holder)
		if(check_rights(R_ADMIN,0))//If they have +ADMIN, show hidden admins, player IC names and IC status
			for(var/client/C in GLOB.clients)
				if(is_donator(C))
					var/entry = "\t[C.key]"
					if(C.holder && C.holder.fakekey)
						entry += " <i>(as [C.holder.fakekey])</i>"
					entry += " - Playing as [C.mob.real_name]"
					switch(C.mob.stat)
						if(UNCONSCIOUS)
							entry += " - <font color='darkgray'><b>Unconscious</b></font>"
						if(DEAD)
							if(isobserver(C.mob))
								var/mob/dead/observer/O = C.mob
								if(O.started_as_observer)
									entry += " - <font color='gray'>Observing</font>"
								else
									entry += " - <font color='black'><b>DEAD</b></font>"
							else
								entry += " - <font color='black'><b>DEAD</b></font>"
					if(is_special_character(C.mob))
						entry += " - <b><font color='red'>Antagonist</font></b>"
					entry += " (<A HREF='?_src_=holder;adminmoreinfo=\ref[C.mob]'>?</A>)"
					Lines += entry
		else//If they don't have +ADMIN, only show hidden admins
			for(var/client/C in GLOB.clients)
				if(is_donator(C))
					var/entry = "\t[C.key]"
					if(C.holder && C.holder.fakekey)
						entry += " <i>(as [C.holder.fakekey])</i>"
					Lines += entry
	else
		for(var/client/C in GLOB.clients)
			if(is_donator(C))
				if(C.holder && C.holder.fakekey)
					Lines += C.holder.fakekey
				else
					Lines += C.key

	for(var/line in sortList(Lines))
		msg += "[line]\n"

	msg += "<b>Total Players: [length(Lines)]</b>"
	to_chat(src, msg)