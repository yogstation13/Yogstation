/client/proc/cmd_admin_drop_everything(mob/M in GLOB.mob_list)
	set category = null
	set name = "Drop Everything"
	if(!check_rights(R_ADMIN))
		return

	var/confirm = tgui_alert(usr, "Make [M] drop everything?", "Message", list("Yes", "No"))
	if(confirm != "Yes")
		return

	for(var/obj/item/W in M)
		if(!M.dropItemToGround(W))
			qdel(W)
			M.regenerate_icons()

	log_admin("[key_name(usr)] made [key_name(M)] drop everything!")
	var/msg = "[key_name(usr)] made [key_name(M)] drop everything!" // yogs - Yog Tickets
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Everything") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_subtle_message(mob/M in GLOB.mob_list)
	set category = "Admin.Player Interaction"
	set name = "Subtle Message"

	if(!ismob(M))
		return
	if(!check_rights(R_ADMIN))
		return

	message_admins("[key_name_admin(src)] has started answering [ADMIN_LOOKUPFLW(M)]'s prayer.")
	var/msg = input("Message:", text("Subtle PM to [M.key]")) as text|null

	if(!msg)
		message_admins("[key_name_admin(src)] decided not to answer [ADMIN_LOOKUPFLW(M)]'s prayer")
		return
	if(usr)
		if (usr.client)
			if(usr.client.holder)
				to_chat(M, span_big("<i>You hear a voice in your head... <b>[msg]</i></b>"))

	log_admin("SubtlePM: [key_name(usr)] -> [key_name(M)] : [msg]")
	msg = "SubtleMessage: [key_name(usr)] -> [key_name(M)] : [msg]" // yogs - Yog Tickets
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Subtle Message") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_headset_message(mob/M in GLOB.mob_list)
	set category = "Admin.Player Interaction"
	set name = "Headset Message"

	admin_headset_message(M)

/client/proc/admin_headset_message(mob/M in GLOB.mob_list, sender = null)
	var/mob/living/carbon/human/H = M

	if(!check_rights(R_ADMIN))
		return

	if(!istype(H))
		to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human", confidential=TRUE)
		return
	if(!istype(H.ears, /obj/item/radio/headset))
		to_chat(usr, "The person you are trying to contact is not wearing a headset.", confidential=TRUE)
		return

	if (!sender)
		sender = input("Who is the message from?", "Sender") as null|anything in list(RADIO_CHANNEL_CENTCOM,RADIO_CHANNEL_SYNDICATE)
		if(!sender)
			return

	message_admins("[key_name_admin(src)] has started answering [key_name_admin(H)]'s [sender] request.")
	var/input = input("Please enter a message to reply to [key_name(H)] via their headset.","Outgoing message from [sender]", "") as text|null
	if(!input)
		message_admins("[key_name_admin(src)] decided not to answer [key_name_admin(H)]'s [sender] request.")
		return

	log_directed_talk(mob, H, input, LOG_ADMIN, "reply")
	message_admins("[key_name_admin(src)] replied to [key_name_admin(H)]'s [sender] message with: \"[input]\"")
	to_chat(H, "You hear something crackle in your ears for a moment before a voice speaks.  \"Please stand by for a message from [sender == "Syndicate" ? "your benefactor" : "Central Command"].  Message as follows[sender == "Syndicate" ? ", agent." : ":"] [span_bold("[input].")] Message ends.\"")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Headset Message") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_mod_antag_rep(client/C in GLOB.clients, operation)
	set category = "Misc.Unused"
	set name = "Modify Antagonist Reputation"

	if(!check_rights(R_ADMIN))
		return

	var/msg = ""
	var/log_text = ""

	if(operation == "zero")
		log_text = "Set to 0"
		SSpersistence.antag_rep -= C.ckey
	else
		var/prompt = "Please enter the amount of reputation to [operation]:"

		if(operation == "set")
			prompt = "Please enter the new reputation value:"

		msg = input("Message:", prompt) as num|null

		if (!msg)
			return

		var/ANTAG_REP_MAXIMUM = CONFIG_GET(number/antag_rep_maximum)

		if(operation == "set")
			log_text = "Set to [num2text(msg)]"
			SSpersistence.antag_rep[C.ckey] = max(0, min(msg, ANTAG_REP_MAXIMUM))
		else if(operation == "add")
			log_text = "Added [num2text(msg)]"
			SSpersistence.antag_rep[C.ckey] = min(SSpersistence.antag_rep[C.ckey]+msg, ANTAG_REP_MAXIMUM)
		else if(operation == "subtract")
			log_text = "Subtracted [num2text(msg)]"
			SSpersistence.antag_rep[C.ckey] = max(SSpersistence.antag_rep[C.ckey]-msg, 0)
		else
			to_chat(src, "Invalid operation for antag rep modification: [operation] by user [key_name(usr)]", confidential=TRUE)
			return

		if(SSpersistence.antag_rep[C.ckey] <= 0)
			SSpersistence.antag_rep -= C.ckey

	log_admin("[key_name(usr)]: Modified [key_name(C)]'s antagonist reputation [log_text]")
	message_admins(span_adminnotice("[key_name_admin(usr)]: Modified [key_name(C)]'s antagonist reputation ([log_text])"))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Modify Antagonist Reputation") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_world_narrate()
	set category = "Admin.Round Interaction"
	set name = "Global Narrate"

	if(!check_rights(R_ADMIN))
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to everyone:")) as text|null

	if (!msg)
		return
	to_chat(world, "[msg]")
	log_admin("GlobalNarrate: [key_name(usr)] : [msg]")
	message_admins(span_adminnotice("[key_name_admin(usr)] Sent a global narrate"))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Global Narrate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_direct_narrate(mob/M)
	set category = "Admin.Player Interaction"
	set name = "Direct Narrate"

	if(!check_rights(R_ADMIN))
		return

	if(!M)
		M = input("Direct narrate to whom?", "Active Players") as null|anything in GLOB.player_list

	if(!M)
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to your target:")) as text|null

	if( !msg )
		return

	to_chat(M, msg)
	log_admin("DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]")
	msg = "DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]" // yogs - Yog Tickets
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Direct Narrate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_local_narrate(atom/A)
	set category = "Admin.Player Interaction"
	set name = "Local Narrate"

	if(!check_rights(R_ADMIN))
		return
	if(!A)
		return
	var/range = input("Range:", "Narrate to mobs within how many tiles:", 7) as num|null
	if(!range)
		return
	var/msg = input("Message:", text("Enter the text you wish to appear to everyone within view:")) as text|null
	if (!msg)
		return
	for(var/mob/M in view(range,A))
		to_chat(M, msg)

	log_admin("LocalNarrate: [key_name(usr)] at [AREACOORD(A)]: [msg]")
	message_admins(span_adminnotice("<b> LocalNarrate: [key_name_admin(usr)] at [ADMIN_VERBOSEJMP(A)]:</b> [msg]<BR>"))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Local Narrate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_godmode(mob/M in GLOB.mob_list)
	set category = "Admin.Player Interaction"
	set name = "Godmode"
	if(!check_rights(R_ADMIN))
		return

	M.status_flags ^= GODMODE
	to_chat(usr, span_adminnotice("Toggled [(M.status_flags & GODMODE) ? "ON" : "OFF"]"), confidential=TRUE)

	log_admin("[key_name(usr)] has toggled [key_name(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]")
	var/msg = "[key_name(usr)] has toggled [key_name(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]" // yogs - Yog Tickets
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Godmode", "[M.status_flags & GODMODE ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/proc/cmd_admin_mute(whom, mute_type, automute = 0)
	if(!whom)
		return

	var/muteunmute
	var/mute_string
	var/feedback_string
	switch(mute_type)
		if(MUTE_IC)
			mute_string = "IC (say and emote)"
			feedback_string = "IC"
		if(MUTE_OOC)
			mute_string = "OOC"
			feedback_string = "OOC"
		if(MUTE_PRAY)
			mute_string = "pray"
			feedback_string = "Pray"
		if(MUTE_ADMINHELP)
			mute_string = "adminhelp, admin PM and ASAY"
			feedback_string = "Adminhelp"
		if(MUTE_MENTORHELP)
			mute_string = "mentorhelp, mentor PM and MSAY"
			feedback_string = "mentorhelp"
		if(MUTE_DEADCHAT)
			mute_string = "deadchat and DSAY"
			feedback_string = "Deadchat"
		if(MUTE_ALL)
			mute_string = "everything"
			feedback_string = "Everything"
		else
			return

	var/client/C
	if(istype(whom, /client))
		C = whom
	else if(istext(whom))
		C = GLOB.directory[whom]
	else
		return

	var/datum/preferences/P
	if(C)
		P = C.prefs
	else
		P = GLOB.preferences_datums[whom]
	if(!P)
		return

	if(automute)
		if(!CONFIG_GET(flag/automute_on))
			return
	else
		if(!check_rights())
			return

	if(automute)
		muteunmute = "auto-muted"
		P.muted |= mute_type
		log_admin("SPAM AUTOMUTE: [muteunmute] [key_name(whom)] from [mute_string]")
		message_admins("SPAM AUTOMUTE: [muteunmute] [key_name_admin(whom)] from [mute_string].")
		if(C)
			to_chat(C, "You have been [muteunmute] from [mute_string] by the SPAM AUTOMUTE system. Contact an admin.", confidential=TRUE)
		SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Auto Mute [feedback_string]", "1")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return

	if(P.muted & mute_type)
		muteunmute = "unmuted"
		P.muted &= ~mute_type
	else
		muteunmute = "muted"
		P.muted |= mute_type

	log_admin("[key_name(usr)] has [muteunmute] [key_name(whom)] from [mute_string]")
	message_admins("[key_name_admin(usr)] has [muteunmute] [key_name_admin(whom)] from [mute_string].")
	if(C)
		to_chat(C, "You have been [muteunmute] from [mute_string] by [key_name(usr, include_name = FALSE)].", confidential=TRUE)
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Mute [feedback_string]", "[P.muted & mute_type]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


//I use this proc for respawn character too. /N
/proc/create_xeno(ckey)
	if(!ckey)
		var/list/candidates = list()
		for(var/mob/M in GLOB.player_list)
			if(M.stat != DEAD)
				continue	//we are not dead!
			if(!(ROLE_ALIEN in M.client.prefs.be_special))
				continue	//we don't want to be an alium
			if(M.client.is_afk())
				continue	//we are afk
			if(M?.mind?.current?.stat != DEAD)
				continue	//we have a live body we are tied to
			candidates += M.ckey
		if(candidates.len)
			ckey = input("Pick the player you want to respawn as a xeno.", "Suitable Candidates") as null|anything in candidates
		else
			to_chat(usr, span_danger("Error: create_xeno(): no suitable candidates."), confidential=TRUE)
	if(!istext(ckey))
		return 0

	var/alien_caste = input(usr, "Please choose which caste to spawn.","Pick a caste",null) as null|anything in list("Queen","Praetorian","Hunter","Sentinel","Drone","Larva")
	var/obj/effect/landmark/spawn_here = GLOB.xeno_spawn.len ? pick(GLOB.xeno_spawn) : null
	var/mob/living/carbon/alien/new_xeno
	switch(alien_caste)
		if("Queen")
			new_xeno = new /mob/living/carbon/alien/humanoid/royal/queen(spawn_here)
		if("Praetorian")
			new_xeno = new /mob/living/carbon/alien/humanoid/royal/praetorian(spawn_here)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(spawn_here)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(spawn_here)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(spawn_here)
		if("Larva")
			new_xeno = new /mob/living/carbon/alien/larva(spawn_here)
		else
			return 0
	if(!spawn_here)
		SSjob.SendToLateJoin(new_xeno, FALSE)

	new_xeno.ckey = ckey
	var/msg = "[key_name(usr)] has spawned [ckey] as a filthy xeno [alien_caste]." // yogs - Yog Tickets
	message_admins(msg)
	admin_ticket_log(new_xeno, msg)
	return 1

/*
If a guy was gibbed and you want to revive him, this is a good way to do so.
Works kind of like entering the game with a new character. Character receives a new mind if they didn't have one.
Traitors and the like can also be revived with the previous role mostly intact.
/N */
/client/proc/respawn_character()
	set category = "Admin.Player Interaction"
	set name = "Respawn Character"
	set desc = "Respawn a person that has been gibbed/dusted/killed. They must be a ghost for this to work and preferably should not have a body to go back into."
	if(!check_rights(R_ADMIN))
		return

	var/input = ckey(input(src, "Please specify which key will be respawned.", "Key", ""))
	if(!input)
		return

	var/mob/dead/observer/G_found
	for(var/mob/dead/observer/G in GLOB.player_list)
		if(G.ckey == input)
			G_found = G
			break

	if(!G_found)//If a ghost was not found.
		to_chat(usr, "<font color='red'>There is no active key like that in the game or the person is not currently a ghost.</font>", confidential=TRUE)
		return

	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		//Check if they were an alien
		if(G_found.mind.assigned_role == ROLE_ALIEN)
			if(tgui_alert(usr,"This character appears to have been an alien. Would you like to respawn them as such?",,list("Yes","No"))=="Yes")
				var/turf/T
				if(GLOB.xeno_spawn.len)
					T = pick(GLOB.xeno_spawn)

				var/mob/living/carbon/alien/new_xeno
				switch(G_found.mind.special_role)//If they have a mind, we can determine which caste they were.
					if("Hunter")
						new_xeno = new /mob/living/carbon/alien/humanoid/hunter(T)
					if("Sentinel")
						new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(T)
					if("Drone")
						new_xeno = new /mob/living/carbon/alien/humanoid/drone(T)
					if("Praetorian")
						new_xeno = new /mob/living/carbon/alien/humanoid/royal/praetorian(T)
					if("Queen")
						new_xeno = new /mob/living/carbon/alien/humanoid/royal/queen(T)
					else//If we don't know what special role they have, for whatever reason, or they're a larva.
						create_xeno(G_found.ckey)
						return

				if(!T)
					SSjob.SendToLateJoin(new_xeno, FALSE)

				//Now to give them their mind back.
				G_found.mind.transfer_to(new_xeno)	//be careful when doing stuff like this! I've already checked the mind isn't in use
				new_xeno.key = G_found.key
				to_chat(new_xeno, "You have been fully respawned. Enjoy the game.")
				var/msg = "[key_name(usr)] has respawned [new_xeno.key] as a filthy xeno." // yogs - Yog Tickets
				message_admins(msg)
				admin_ticket_log(new_xeno, msg)
				return	//all done. The ghost is auto-deleted

		//check if they were a monkey
		else if(findtext(G_found.real_name,"monkey"))
			if(tgui_alert(usr, "This character appears to have been a monkey. Would you like to respawn them as such?",,list("Yes","No"))=="Yes")
				var/mob/living/carbon/monkey/new_monkey = new
				SSjob.SendToLateJoin(new_monkey)
				G_found.mind.transfer_to(new_monkey)	//be careful when doing stuff like this! I've already checked the mind isn't in use
				new_monkey.key = G_found.key
				to_chat(new_monkey, "You have been fully respawned. Enjoy the game.")
				var/msg = "[key_name(usr)] has respawned [new_monkey.key] as a filthy xeno." // yogs - Yog Tickets
				message_admins(msg)
				admin_ticket_log(new_monkey, msg)
				return	//all done. The ghost is auto-deleted


	//Ok, it's not a xeno or a monkey. So, spawn a human.
	var/mob/living/carbon/human/new_character = new//The mob being spawned.
	SSjob.SendToLateJoin(new_character)

	var/datum/data/record/record_found			//Referenced to later to either randomize or not randomize the character.
	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		/*Try and locate a record for the person being respawned through GLOB.data_core.
		This isn't an exact science but it does the trick more often than not.*/
		var/id = md5("[G_found.real_name][G_found.mind.assigned_role]")

		record_found = find_record("id", id, GLOB.data_core.locked)

	if(record_found)//If they have a record we can determine a few things.
		new_character.real_name = record_found.fields["name"]
		new_character.gender = record_found.fields["gender"]
		new_character.age = record_found.fields["age"]
		new_character.hardset_dna(record_found.fields["identity"], record_found.fields["enzymes"], null, record_found.fields["name"], record_found.fields["blood_type"], new record_found.fields["species"], record_found.fields["features"])
	else
		new_character.randomize_human_appearance(~(RANDOMIZE_NAME|RANDOMIZE_SPECIES))
		new_character.name = G_found.real_name
		new_character.real_name = G_found.real_name
		new_character.dna.update_dna_identity()

	new_character.name = new_character.real_name

	if(G_found.mind && !G_found.mind.active)
		G_found.mind.transfer_to(new_character)	//be careful when doing stuff like this! I've already checked the mind isn't in use
	else
		new_character.mind_initialize()
	if(!new_character.mind.assigned_role)
		new_character.mind.assigned_role = "Assistant"//If they somehow got a null assigned role.

	new_character.key = G_found.key

	/*
	The code below functions with the assumption that the mob is already a traitor if they have a special role.
	So all it does is re-equip the mob with powers and/or items. Or not, if they have no special role.
	If they don't have a mind, they obviously don't have a special role.
	*/

	//Two variables to properly announce later on.
	var/admin = key_name_admin(src)
	var/player_key = G_found.key

	//Now for special roles and equipment.
	var/datum/antagonist/traitor/traitordatum = new_character.mind.has_antag_datum(/datum/antagonist/traitor)
	if(traitordatum)
		SSjob.EquipRank(new_character, new_character.mind.assigned_role, 1)
		traitordatum.equip()


	switch(new_character.mind.special_role)
		if(ROLE_WIZARD)
			new_character.forceMove(pick(GLOB.wizardstart))
			var/datum/antagonist/wizard/A = new_character.mind.has_antag_datum(/datum/antagonist/wizard,TRUE)
			A.equip_wizard()
		if(ROLE_OPERATIVE)
			new_character.forceMove(pick(GLOB.nukeop_start))
			var/datum/antagonist/nukeop/N = new_character.mind.has_antag_datum(/datum/antagonist/nukeop,TRUE)
			N.equip_op()
		if(ROLE_NINJA)
			var/list/ninja_spawn = list()
			for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
				ninja_spawn += L
			var/datum/antagonist/ninja/ninjadatum = new_character.mind.has_antag_datum(/datum/antagonist/ninja)
			ninjadatum.equip_space_ninja()
			if(ninja_spawn.len)
				new_character.forceMove(pick(ninja_spawn))

		else//They may also be a cyborg or AI.
			switch(new_character.mind.assigned_role)
				if("Cyborg")//More rigging to make em' work and check if they're traitor.
					new_character = new_character.Robotize(TRUE)
				if("AI")
					new_character = new_character.AIize()
				else
					SSjob.EquipRank(new_character, new_character.mind.assigned_role, 1)//Or we simply equip them.

	//Announces the character on all the systems, based on the record.
	if(!issilicon(new_character))//If they are not a cyborg/AI.
		if(!record_found&&new_character.mind.assigned_role!=new_character.mind.special_role)//If there are no records for them. If they have a record, this info is already in there. MODE people are not announced anyway.
			//Power to the user!
			if(tgui_alert(new_character,"Warning: No data core entry detected. Would you like to announce the arrival of this character by adding them to various databases, such as medical records?",,list("No","Yes"))=="Yes")
				GLOB.data_core.manifest_inject(new_character)

			if(tgui_alert(new_character,"Would you like an active AI to announce this character?",,list("No","Yes"))=="Yes")
				AnnounceArrival(new_character, new_character.mind.assigned_role)

	var/msg = "[admin] has respawned [player_key] as [new_character.real_name]." // yogs - Yog Tickets
	message_admins(msg)
	admin_ticket_log(new_character, msg)

	to_chat(new_character, "You have been fully respawned. Enjoy the game.")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Respawn Character") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return new_character

/client/proc/cmd_admin_add_freeform_ai_law()
	set category = "Admin.Round Interaction"
	set name = "Add Custom AI law"

	if(!check_rights(R_ADMIN))
		return

	var/input = input(usr, "Please enter anything you want the AI to do. Anything. Serious.", "What?", "") as text|null
	if(!input)
		return

	log_admin("Admin [key_name(usr)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(usr)] has added a new AI law - [input]")

	var/show_log = tgui_alert(usr, "Show ion message?", "Message", list("Yes", "No"))
	var/announce_ion_laws = (show_log == "Yes" ? 100 : 0)

	var/datum/round_event/ion_storm/add_law_only/ion = new()
	ion.announceEvent = announce_ion_laws
	ion.ionMessage = input

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Add Custom AI Law") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_rejuvenate(mob/living/M in GLOB.mob_list)
	set category = "Admin.Player Interaction"
	set name = "Rejuvenate"

	if(!check_rights(R_ADMIN))
		return

	if(!mob)
		return
	if(!istype(M))
		tgui_alert(usr,"Cannot revive a ghost")
		return
	M.revive(full_heal = 1, admin_revive = 1)

	log_admin("[key_name(usr)] healed / revived [key_name(M)]")
	var/msg = "Admin [key_name(usr)] healed / revived [key_name(M)]!" // yogs - Yog Tickets
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Rejuvinate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_offer_rename(mob/living/L in GLOB.player_list)
	set category = "Admin.Player Interaction"
	set name = "Offer Rename"
	var/newname
	var/forced_answer = " "
	var/unforced_answer = " "

	if(!check_rights(R_ADMIN))
		return

	var/forced_rename = alert("Would you like the targeted mob to be allowed to decline?", "Allow decline?", "Yes", "No", "Cancel")
	if(forced_rename == "Cancel")
		message_admins(span_boldnotice("[usr] has decided not to offer ([L.ckey])[L] a rename."))
		log_game("[usr] has decided not to offer ([L.ckey])[L] a rename.")
		return
	if(forced_rename == "Yes")
		if(!L.ckey)
			message_admins(span_boldnotice("[usr] attempted to offer a rename to a mob with no player!"))
			log_game("[usr] attempted to offer a rename to a mob with no player.")
			return
		else
			unforced_answer = alert(L, "An admin is offering you a chance to rename yourself", "Admin rename?", "Accept", "Decline", "Random Name")
			log_game("[usr] forced a rename on [L.ckey].")
	else
		if(!L.ckey)
			message_admins(span_boldnotice("[usr] attempted to offer a rename to a mob with no player!"))
			log_game("[usr] attempted to offer a rename to a mob with no player.")
			return
		else
			forced_answer = alert(L, "An admin is \"offering\" you a chance to rename yourself", "Admin rename?", "Accept", "Random Name")
			log_game("[usr] chose to offer an optional rename to [L.ckey].")

	if(QDELETED(L))
		message_admins(span_boldnotice("([L.ckey])[L] has been deleted before they could rename themselves!"))
		log_game("([L.ckey])[L] was Qdeleted before they could complete a rename.")
		return
	if(unforced_answer == "Decline")
		message_admins(span_boldnotice("([L.ckey])[L] has declined the rename."))
		log_game("([L.ckey])[L] chose to decline an offered rename.")
		return
	if(forced_answer == "Random Name" || unforced_answer == "Random Name")
		newname = random_unique_name(L.gender)
		log_game("([L.ckey])[L] chose to use a random name when offered a rename.")
	if(forced_answer == "Accept" || unforced_answer == "Accept")
		newname = sanitize_name(reject_bad_text(stripped_input(L, "Who are we again?", "Name change", L.real_name, MAX_NAME_LEN)))
		log_game("([L.ckey])[L] accepted an offered name change.")
	if(isnotpretty(newname))
		to_chat(L, span_warning("your chosen name was not accepted! Please ahelp if you would like a second chance."))
		message_admins(span_notice("([L.ckey])[L]'s new name [newname] was filtered, and was rejected!"))
		log_game("([L.ckey])[L]'s new name [newname] was filtered, and was rejected.")
		if(forced_rename == "No")
			return
		else
			newname = random_unique_name(L.gender)
	if(!newname || newname == "" || newname == L.real_name)
		message_admins(span_boldnotice("[L.ckey]'s new name was blank or unchanged! Defaulting to random!"))
		log_game("([L.ckey])[L]'s entered an identical, blank, or null new name, and was defaulted to random.")
		newname = random_unique_name(L.gender)
	message_admins(span_boldnotice("([L.ckey])[L.real_name] has been admin renamed to [newname]."))
	log_game("([L.ckey])[L.real_name] has been renamed to [newname].")
	L.fully_replace_character_name(L.real_name, newname)
	if(iscarbon(L)) //doing these two JUST to be sure you dont have edge cases of your DNA and mind not matching your new name, somehow
		var/mob/living/carbon/C = L
		if(C?.dna)
			C?.dna?.real_name = newname
	if(L?.mind)
		L?.mind?.name = newname
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Offer Mob Rename") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc

/client/proc/cmd_admin_delete(atom/A as obj|mob|turf in world)
	set category = "Misc.Unused"
	set name = "Delete"

	if(!check_rights(R_ADMIN)) //yogs - makes this +admin instead of +spawn/+debug
		return

	admin_delete(A)

/client/proc/admin_delete(datum/D)
	var/atom/A = D
	var/coords = ""
	var/jmp_coords = ""
	if(istype(A))
		var/turf/T = get_turf(A)
		if(T)
			coords = "at [COORD(T)]"
			jmp_coords = "at [ADMIN_COORDJMP(T)]"
		else
			jmp_coords = coords = "in nullspace"

	if (alert(src, "Are you sure you want to delete:\n[D]\n[coords]?", "Confirmation", "Yes", "No") == "Yes")
		log_admin("[key_name(usr)] deleted [D] [coords]")
		message_admins("[key_name_admin(usr)] deleted [D] [jmp_coords]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Delete") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		if(isturf(D))
			var/turf/T = D
			T.ScrapeAway()
		else
			vv_update_display(D, "deleted", VV_MSG_DELETED)
			qdel(D)
			if(!QDELETED(D))
				vv_update_display(D, "deleted", "")

/client/proc/cmd_admin_list_open_jobs()
	set category = "Admin.Round Interaction"
	set name = "Manage Job Slots"

	if(!check_rights(R_ADMIN))
		return
	holder.manage_free_slots()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Manage Job Slots") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_explosion(atom/O as obj|mob|turf in world)
	set category = "Admin.Round Interaction"
	set name = "Explosion"

	if(!check_rights(R_ADMIN))
		return

	var/devastation = input("Range of total devastation. -1 to none", text("Input"))  as num|null
	if(devastation == null)
		return
	var/heavy = input("Range of heavy impact. -1 to none", text("Input"))  as num|null
	if(heavy == null)
		return
	var/light = input("Range of light impact. -1 to none", text("Input"))  as num|null
	if(light == null)
		return
	var/flash = input("Range of flash. -1 to none", text("Input"))  as num|null
	if(flash == null)
		return
	var/flames = input("Range of flames. -1 to none", text("Input"))  as num|null
	if(flames == null)
		return

	if ((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1) || (flames != -1))
		if ((devastation > 20) || (heavy > 20) || (light > 20) || (flames > 20))
			if (tgui_alert(usr, "Are you sure you want to do this? It will laaag.", "Confirmation", list("Yes", "No")) == "No")
				return

		explosion(O, devastation, heavy, light, flash, null, null,flames)
		log_admin("[key_name(usr)] created an explosion ([devastation],[heavy],[light],[flames]) at [AREACOORD(O)]")
		message_admins("[key_name_admin(usr)] created an explosion ([devastation],[heavy],[light],[flames]) at [AREACOORD(O)]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Explosion") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return
	else
		return

/client/proc/cmd_admin_emp(atom/O as obj|mob|turf in world)
	set category = "Admin.Round Interaction"
	set name = "EM Pulse"

	if(!check_rights(R_ADMIN))
		return

	var/severity = input("Severity of pulse.", text("Input"))  as num|null
	if(!isnum(severity))
		return
	var/range = input("Range of pulse.", text("Input"))  as num|null
	if(!isnum(range))
		range = severity

	if (severity)
		empulse(O, severity, range)
		log_admin("[key_name(usr)] created an EM Pulse ([range] range, [severity] severity) at [AREACOORD(O)]")
		message_admins("[key_name_admin(usr)] created an EM Pulse ([range] range, [severity] severity) at [AREACOORD(O)]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "EM Pulse") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		return
	else
		return

/client/proc/cmd_admin_gib(mob/living/M in GLOB.mob_list)
	set category = "Admin.Player Interaction"
	set name = "Gib"

	if(!check_rights(R_ADMIN))
		return

	var/confirm = tgui_alert(usr, "Drop a brain?", "Confirm", list("Yes", "No","Cancel"))
	if(confirm == "Cancel")
		return
	//Due to the delay here its easy for something to have happened to the mob
	if(!M)
		return

	log_admin("[key_name(usr)] has gibbed [key_name(M)]")
	message_admins("[key_name_admin(usr)] has gibbed [key_name_admin(M)]")

	if(isobserver(M))
		new /obj/effect/gibspawner/generic(get_turf(M))
		return
	if(confirm == "Yes")
		M.gib()
	else
		M.gib(1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Gib") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_gib_self()
	set name = "Gibself"
	set category = "Admin.Player Interaction"

	var/confirm = tgui_alert(usr, "You sure?", "Confirm", list("Yes", "No"))
	if(confirm == "Yes")
		log_admin("[key_name(usr)] used gibself.")
		message_admins(span_adminnotice("[key_name_admin(usr)] used gibself."))
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Gib Self") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		var/mob/living/user_mob = mob
		user_mob.gib(1, 1, 1)

/client/proc/cmd_admin_check_contents(mob/living/M in GLOB.mob_list)
	set category = "Misc.Unused"
	set name = "Check Contents"

	var/list/L = M.get_contents()
	for(var/t in L)
		to_chat(usr, "[t]", confidential=TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Contents") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_view_range()
	set category = "Misc.Unused"
	set name = "Change View Range"
	set desc = "switches between 1x and custom views"

	if(view_size.getView() == view_size.default)
		//yogs start -- Adds customization and warnings
		var/newview = input("Select view range:", "FUCK YE", 7) in list(7,10,12,14,32,64,128,"Custom...")
		if(newview == "Custom...")
			newview = input("Enter custom view range:","FUCK YEEEEE") as num
			if(!newview)
				return
		if(newview >= 64)
			if(alert("Warning: Setting your view range to that large size may cause horrendous lag, visual bugs, and/or game crashes. Are you sure?",,"Yes","No") != "Yes")
				return
		view_size.setTo(newview)
		//yogs end
	else
		view_size.resetToDefault(getScreenSize(prefs.read_preference(/datum/preference/toggle/widescreen)))

	log_admin("[key_name(usr)] changed their view range to [view].")
	//message_admins("\blue [key_name_admin(usr)] changed their view range to [view].")	//why? removed by order of XSI

	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Change View Range", "[view]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/admin_call_shuttle()
	set category = "Admin.Round Interaction"
	set name = "Call Shuttle"

	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	if(!check_rights(R_ADMIN))
		return

	var/confirm = tgui_alert(src, "You sure?", "Confirm", list("Yes", "No"))
	if(confirm != "Yes")
		return

	SSshuttle.emergency.request()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Call Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-called the emergency shuttle.")
	message_admins(span_adminnotice("[key_name_admin(usr)] admin-called the emergency shuttle."))
	return

/client/proc/admin_cancel_shuttle()
	set category = "Admin.Round Interaction"
	set name = "Cancel Shuttle"
	if(!check_rights(0))
		return
	if(tgui_alert(usr, "You sure?", "Confirm", list("Yes", "No")) != "Yes")
		return

	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	SSshuttle.emergency.cancel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Cancel Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-recalled the emergency shuttle.")
	message_admins(span_adminnotice("[key_name_admin(usr)] admin-recalled the emergency shuttle."))

	return

/client/proc/everyone_random()
	set category = "Admin.Round Interaction"
	set name = "Make Everyone Random"
	set desc = "Make everyone have a random appearance. You can only use this before rounds!"

	if(SSticker.HasRoundStarted())
		to_chat(usr, "Nope you can't do this, the game's already started. This only works before rounds!", confidential=TRUE)
		return

	var/frn = CONFIG_GET(flag/force_random_names)
	if(frn)
		CONFIG_SET(flag/force_random_names, FALSE)
		message_admins("Admin [key_name_admin(usr)] has disabled \"Everyone is Special\" mode.")
		to_chat(usr, "Disabled.", confidential=TRUE)
		return


	var/notifyplayers = tgui_alert(usr, "Do you want to notify the players?", "Options", list("Yes", "No", "Cancel"))
	if(notifyplayers == "Cancel")
		return

	log_admin("Admin [key_name(src)] has forced the players to have random appearances.")
	message_admins("Admin [key_name_admin(usr)] has forced the players to have random appearances.")

	if(notifyplayers == "Yes")
		to_chat(world, span_adminnotice("Admin [usr.key] has forced the players to have completely random identities!"))

	to_chat(usr, "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>.", confidential=TRUE)

	CONFIG_SET(flag/force_random_names, TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Everyone Random") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/admin_change_sec_level()
	set category = "Admin.Round Interaction"
	set name = "Set Security Level"
	set desc = "Changes the security level. Announcement only, i.e. setting to Delta won't activate nuke"

	if(!check_rights(R_ADMIN))
		return

	var/level = input("Select security level to change to","Set Security Level") as null|anything in list("green","blue","red","gamma","epsilon","delta")
	if(level)
		SSsecurity_level.set_level(level)

		log_admin("[key_name(usr)] changed the security level to [level]")
		message_admins("[key_name_admin(usr)] changed the security level to [level]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Set Security Level [capitalize(level)]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_nuke(obj/machinery/nuclearbomb/N in GLOB.nuke_list)
	set name = "Toggle Nuke"
	set category = "Admin.Round End"
	set popup_menu = FALSE
	if(!check_rights(R_DEBUG))
		return

	var/areyousure = alert(src, "Are you sure you want to trigger a nuke?", "Options", "Yes", "No", "Cancel")
	if(areyousure == "Cancel" || areyousure == "No")
		return

	if(N.type != /obj/machinery/nuclearbomb/beer)
		var/areyousure2 = alert(src, "THIS WILL BLOW UP THE STATION?", "Options", "Yes", "No", "Cancel")
		if(areyousure2 == "Cancel" || areyousure2 == "No")
			return

	if(!N.timing)
		var/newtime = input(usr, "Set activation timer.", "Activate Nuke", "[N.timer_set]") as num|null
		if(!newtime)
			return
		N.timer_set = newtime
	N.set_safety()
	N.set_active()

	log_admin("[key_name(usr)] [N.timing ? "activated" : "deactivated"] a nuke at [AREACOORD(N)].")
	message_admins("[ADMIN_LOOKUPFLW(usr)] [N.timing ? "activated" : "deactivated"] a nuke at [ADMIN_VERBOSEJMP(N)].")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Nuke", "[N.timing]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_combo_hud()
	set category = "Admin"
	set name = "Toggle Combo HUD"
	set desc = "Toggles the Admin Combo HUD (antag, sci, med, eng)"

	if(!check_rights(R_ADMIN))
		return

	if (combo_hud_enabled)
		disable_combo_hud()
	else
		enable_combo_hud()

	to_chat(usr, "You toggled your admin combo HUD [combo_hud_enabled ? "ON" : "OFF"].", confidential = TRUE)
	message_admins("[key_name_admin(usr)] toggled their admin combo HUD [combo_hud_enabled ? "ON" : "OFF"].")
	log_admin("[key_name(usr)] toggled their admin combo HUD [combo_hud_enabled ? "ON" : "OFF"].")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Combo HUD", "[combo_hud_enabled ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/enable_combo_hud()
	if (combo_hud_enabled)
		return

	combo_hud_enabled = TRUE

	for (var/hudtype in list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC_ADVANCED))
		var/datum/atom_hud/atom_hud = GLOB.huds[hudtype]
		atom_hud.show_to(mob)

	for (var/datum/atom_hud/alternate_appearance/basic/antagonist_hud/antag_hud in GLOB.active_alternate_appearances)
		antag_hud.show_to(mob)

	mob.update_sight()

/client/proc/disable_combo_hud()
	if (!combo_hud_enabled)
		return

	combo_hud_enabled = FALSE

	for (var/hudtype in list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC_ADVANCED))
		var/datum/atom_hud/atom_hud = GLOB.huds[hudtype]
		atom_hud.hide_from(mob)

	for (var/datum/atom_hud/alternate_appearance/basic/antagonist_hud/antag_hud in GLOB.active_alternate_appearances)
		antag_hud.hide_from(mob)

	mob.update_sight()

/client/proc/run_weather()
	set category = "Admin.Round Interaction"
	set name = "Run Weather"
	set desc = "Triggers a weather on the z-level you choose."

	if(!holder)
		return

	var/weather_type = input("Choose a weather", "Weather")  as null|anything in subtypesof(/datum/weather)
	if(!weather_type)
		return

	var/turf/T = get_turf(mob)
	var/z_level = input("Z-Level to target?", "Z-Level", T?.z) as num|null
	if(!isnum(z_level))
		return

	SSweather.run_weather(weather_type, z_level)

	message_admins("[key_name_admin(usr)] started weather of type [weather_type] on the z-level [z_level].")
	log_admin("[key_name(usr)] started weather of type [weather_type] on the z-level [z_level].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Run Weather")

/client/proc/mass_zombie_infection()
	set category = "Admin.Round Interaction"
	set name = "Mass Zombie Infection"
	set desc = "Infects all humans with a latent organ that will zombify \
		them on death."

	if(!check_rights(R_ADMIN))
		return

	var/confirm = tgui_alert(usr, "Please confirm you want to add latent zombie organs in all humans?", "Confirm Zombies", list("Yes", "No"))
	if(confirm != "Yes")
		return

	for(var/mob/living/carbon/human/H in GLOB.carbon_list)
		new /obj/item/organ/zombie_infection/nodamage(H)

	message_admins("[key_name_admin(usr)] added a latent zombie infection to all humans.")
	log_admin("[key_name(usr)] added a latent zombie infection to all humans.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Mass Zombie Infection")

/client/proc/mass_zombie_cure()
	set category = "Admin.Round Interaction"
	set name = "Mass Zombie Cure"
	set desc = "Removes the zombie infection from all humans, returning them to normal."
	if(!check_rights(R_ADMIN))
		return

	var/confirm = tgui_alert(usr, "Please confirm you want to cure all zombies?", "Confirm Zombie Cure", list("Yes", "No"))
	if(confirm != "Yes")
		return

	for(var/obj/item/organ/zombie_infection/nodamage/I in GLOB.zombie_infection_list)
		qdel(I)

	message_admins("[key_name_admin(usr)] cured all zombies.")
	log_admin("[key_name(usr)] cured all zombies.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Mass Zombie Cure")

/client/proc/polymorph_all()
	set category = "Admin.Round End"
	set name = "Polymorph All"
	set desc = "Applies the effects of the bolt of change to every single mob."

	if(!check_rights(R_ADMIN))
		return

	var/confirm = tgui_alert(usr, "Please confirm you want polymorph all mobs?", "Confirm Polymorph", list("Yes", "No"))
	if(confirm != "Yes")
		return

	var/list/mobs = shuffle(GLOB.alive_mob_list.Copy()) // might change while iterating
	var/who_did_it = key_name_admin(usr)

	message_admins("[key_name_admin(usr)] started polymorphed all living mobs.")
	log_admin("[key_name(usr)] polymorphed all living mobs.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Polymorph All")

	for(var/mob/living/M in mobs)
		CHECK_TICK

		if(!M)
			continue

		M.audible_message(span_italics("...wabbajack...wabbajack..."))
		playsound(M.loc, 'sound/magic/staff_change.ogg', 50, 1, -1)

		wabbajack(M)

	message_admins("Mass polymorph started by [who_did_it] is complete.")


/client/proc/show_tip()
	set category = "Admin"
	set name = "Show Tip"
	set desc = "Sends a tip (that you specify) to all players. After all \
		you're the experienced player here."

	if(!check_rights(R_ADMIN))
		return

	var/input = input(usr, "Please specify your tip that you want to send to the players.", "Tip", "") as message|null
	if(!input)
		return

	if(!SSticker)
		return

	SSticker.selected_tip = input

	// If we've already tipped, then send it straight away.
	if(SSticker.tipped)
		SSticker.send_tip_of_the_round()


	message_admins("[key_name_admin(usr)] sent a tip of the round.")
	log_admin("[key_name(usr)] sent \"[input]\" as the Tip of the Round.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Tip")

/client/proc/modify_goals()
	set category = "Misc.Server Debug"
	set name = "Modify goals"

	if(!check_rights(R_ADMIN))
		return

	holder.modify_goals()

/datum/admins/proc/modify_goals()
	var/dat = "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY>"
	for(var/datum/station_goal/S in SSgamemode.station_goals)
		dat += "[S.name] - <a href='byond://?src=[REF(S)];[HrefToken()];announce=1'>Announce</a> | <a href='byond://?src=[REF(S)];[HrefToken()];remove=1'>Remove</a><br>"
	dat += "<br><a href='byond://?src=[REF(src)];[HrefToken()];add_station_goal=1'>Add New Goal</a>"
	dat += "</BODY></HTML>"
	var/datum/browser/browser = new(usr, "goals", "Modify Goals", 400, 400)
	browser.set_content(dat)
	browser.open()

/client/proc/toggle_hub()
	set category = "Server"
	set name = "Toggle Hub"

	world.update_hub_visibility(!GLOB.hub_visibility)

	log_admin("[key_name(usr)] has toggled the server's hub status for the round, it is now [(GLOB.hub_visibility?"on":"off")] the hub.")
	message_admins("[key_name_admin(usr)] has toggled the server's hub status for the round, it is now [(GLOB.hub_visibility?"on":"off")] the hub.")
	if (GLOB.hub_visibility && !world.reachable)
		message_admins("WARNING: The server will not show up on the hub because byond is detecting that a filewall is blocking incoming connections.")

	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggled Hub Visibility", "[GLOB.hub_visibility ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/smite(mob/living/target as mob)
	set name = "Smite"
	set category = "Admin.Player Interaction"
	if(!check_rights(R_ADMIN) || !check_rights(R_FUN))
		return

	var/list/punishment_list = list(ADMIN_PUNISHMENT_LIGHTNING,
									ADMIN_PUNISHMENT_BRAINDAMAGE,
									ADMIN_PUNISHMENT_GIB,
									ADMIN_PUNISHMENT_BSA,
									ADMIN_PUNISHMENT_FIREBALL,
									ADMIN_PUNISHMENT_ROD,
									ADMIN_PUNISHMENT_SUPPLYPOD_QUICK,
									ADMIN_PUNISHMENT_SUPPLYPOD,
									ADMIN_PUNISHMENT_MAZING,
									ADMIN_PUNISHMENT_PIE,
									ADMIN_PUNISHMENT_WHISTLE,
									ADMIN_PUNISHMENT_CLUWNE,
									ADMIN_PUNISHMENT_MCNUGGET,
									ADMIN_PUNISHMENT_CRACK,
									ADMIN_PUNISHMENT_BLEED,
									ADMIN_PUNISHMENT_PERFORATE,
									ADMIN_PUNISHMENT_SCARIFY,
									ADMIN_PUNISHMENT_SMSPIDER,
									ADMIN_PUNISHMENT_FLASHBANG,
									ADMIN_PUNISHMENT_WIBBLY,
									ADMIN_PUNISHMENT_WIBBLY_VIRUS,
									ADMIN_PUNISHMENT_BACKROOMS)

	var/punishment = input("Choose a punishment", "DIVINE SMITING") as null|anything in punishment_list

	if(QDELETED(target) || !punishment)
		return

	switch(punishment)
		if(ADMIN_PUNISHMENT_LIGHTNING)
			var/turf/T = get_step(get_step(target, NORTH), NORTH)
			T.Beam(target, icon_state="lightning[rand(1,12)]", time = 5)
			target.adjustFireLoss(75)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				H.electrocution_animation(40)
			to_chat(target, span_userdanger("The gods have punished you for your sins!"))
		if(ADMIN_PUNISHMENT_BRAINDAMAGE)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 199, 199)
		if(ADMIN_PUNISHMENT_MCNUGGET)
			if(iscarbon(target))
				var/mob/living/carbon/CM = target
				for(var/obj/item/bodypart/bodypart in CM.bodyparts)
					if(!(bodypart.body_part & (HEAD|CHEST)))
						if(bodypart.dismemberable)
							bodypart.dismember()
		if(ADMIN_PUNISHMENT_GIB)
			target.gib(FALSE)
		if(ADMIN_PUNISHMENT_BSA)
			bluespace_artillery(target)
		if(ADMIN_PUNISHMENT_FIREBALL)
			new /obj/effect/temp_visual/target(get_turf(target))
		if(ADMIN_PUNISHMENT_ROD)
			var/turf/T = get_turf(target)
			var/startside = pick(GLOB.cardinals)
			var/turf/startT = spaceDebrisStartLoc(startside, T.z)
			var/turf/endT = spaceDebrisFinishLoc(startside, T.z)
			new /obj/effect/immovablerod(startT, endT,target)
		if(ADMIN_PUNISHMENT_SUPPLYPOD_QUICK)
			var/target_path = input(usr,"Enter typepath of an atom you'd like to send with the pod (type \"empty\" to send an empty pod):" ,"Typepath","/obj/item/reagent_containers/food/snacks/grown/harebell") as null|text
			var/obj/structure/closet/supplypod/centcompod/pod = new()
			pod.damage = 40
			pod.explosionSize = list(0,0,0,2)
			pod.effectStun = TRUE
			if (isnull(target_path)) //The user pressed "Cancel"
				return
			if (target_path != "empty")//if you didn't type empty, we want to load the pod with a delivery
				var/delivery = text2path(target_path)
				if(!ispath(delivery))
					delivery = pick_closest_path(target_path)
					if(!delivery)
						alert("ERROR: Incorrect / improper path given.")
						return
				new delivery(pod)
			new /obj/effect/DPtarget(get_turf(target), pod)
		if(ADMIN_PUNISHMENT_SUPPLYPOD)
			var/datum/centcom_podlauncher/plaunch  = new(usr)
			if(!holder)
				return
			plaunch.specificTarget = target
			plaunch.launchChoice = 0
			plaunch.damageChoice = 1
			plaunch.explosionChoice = 1
			plaunch.temp_pod.damage = 40//bring the mother fuckin ruckus
			plaunch.temp_pod.explosionSize = list(0,0,0,2)
			plaunch.temp_pod.effectStun = TRUE
			plaunch.ui_interact(usr)
			return //We return here because punish_log() is handled by the centcom_podlauncher datum

		if(ADMIN_PUNISHMENT_MAZING)
			var/confirm = alert(usr, "Puzzle them?", "Puzzle", "Yes", "No")
			if(confirm == "Yes")
				if(!puzzle_imprison(target))
					to_chat(usr,span_warning("Imprisonment failed!"), confidential=TRUE)
					return
		if(ADMIN_PUNISHMENT_PIE)
			var/confirm = alert(usr, "Send honk message?", "Honk Message", "Yes", "No")
			if(confirm == "Yes")
				to_chat(target, span_clown("Honk! You probably did something stupid.."))
			var/mob/living/carbon/C = target
			C.adminpie(target)
		if(ADMIN_PUNISHMENT_WHISTLE)
			var/confirm = alert(usr, "Sure you want to Warp Whistle them?", "Whistle Message", "Yes", "No")
			if(confirm == "Yes")
				var/mob/living/M = target
				M.whistle()
		if(ADMIN_PUNISHMENT_CLUWNE)
			var/confirm = alert(usr, "Send Cluwne Message?", "Cluwne Message", "Yes", "No")
			if(confirm == "Yes")
				to_chat(target, span_reallybigphobia("HENK!! HENK!! HENK!! YOU DID SOMETHING EXTREMELY DUMB, AND MADE GOD MAD. CRY ABOUT IT."))
			var/mob/living/carbon/human/H = target
			H?.cluwneify()
		if(ADMIN_PUNISHMENT_SMSPIDER)
			var/confirm = alert(usr, "Dust target with a spider? There is no chance of revival!", "Supermatter Spider", "Yes", "No")
			if(confirm == "No")
				return
			//What's an open turf within the target's sight? Lets make a list of them.
			var/FOVlist = circleviewturfs(target,5)
			//Okay, now we spawn a spider on the turf...
			var/mob/living/simple_animal/hostile/smspider/spider = new /mob/living/simple_animal/hostile/smspider(pick(FOVlist))
			//And have it target the victim.
			spider.GiveTarget(target)
			to_chat(usr, span_alert("Dusting target with a spider..."))
		if(ADMIN_PUNISHMENT_CRACK)
			if(!iscarbon(target))
				to_chat(usr,span_warning("This must be used on a carbon mob."), confidential = TRUE)
				return
			var/mob/living/carbon/C = target
			for(var/i in C.bodyparts)
				var/obj/item/bodypart/squish_part = i
				var/type_wound = pick(list(/datum/wound/blunt/critical, /datum/wound/blunt/severe, /datum/wound/blunt/critical, /datum/wound/blunt/severe, /datum/wound/blunt/moderate))
				squish_part.force_wound_upwards(type_wound, smited=TRUE)
		if(ADMIN_PUNISHMENT_BLEED)
			if(!iscarbon(target))
				to_chat(usr,span_warning("This must be used on a carbon mob."), confidential = TRUE)
				return
			var/mob/living/carbon/C = target
			for(var/obj/item/bodypart/slice_part in C.bodyparts)
				var/type_wound = pick(list(/datum/wound/slash/severe, /datum/wound/slash/moderate))
				slice_part.force_wound_upwards(type_wound, smited=TRUE)
				type_wound = pick(list(/datum/wound/slash/critical, /datum/wound/slash/severe, /datum/wound/slash/moderate))
				slice_part.force_wound_upwards(type_wound, smited=TRUE)
				type_wound = pick(list(/datum/wound/slash/critical, /datum/wound/slash/severe))
				slice_part.force_wound_upwards(type_wound, smited=TRUE)
		if(ADMIN_PUNISHMENT_PERFORATE)
			if(!iscarbon(target))
				to_chat(usr,span_warning("This must be used on a carbon mob."), confidential = TRUE)
				return

			var/list/how_fucked_is_this_dude = list("A little", "A lot", "So fucking much", "FUCK THIS DUDE")
			var/hatred = input("How much do you hate this guy?") in how_fucked_is_this_dude
			var/repetitions
			var/shots_per_limb_per_rep = 2
			var/damage
			switch(hatred)
				if("A little")
					repetitions = 1
					damage = 5
				if("A lot")
					repetitions = 2
					damage = 8
				if("So fucking much")
					repetitions = 3
					damage = 10
				if("FUCK THIS DUDE")
					repetitions = 4
					damage = 10

			var/mob/living/carbon/dude = target
			var/list/open_adj_turfs = get_adjacent_open_turfs(dude)
			var/list/wound_bonuses = list(15, 70, 110, 250)

			var/delay_per_shot = 1
			var/delay_counter = 1

			dude.Immobilize(5 SECONDS)
			for(var/wound_bonus_rep in 1 to repetitions)
				for(var/i in dude.bodyparts)
					var/obj/item/bodypart/slice_part = i
					var/shots_this_limb = 0
					for(var/t in shuffle(open_adj_turfs))
						var/turf/iter_turf = t
						addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(firing_squad), dude, iter_turf, slice_part.body_zone, wound_bonuses[wound_bonus_rep], damage), delay_counter)
						delay_counter += delay_per_shot
						shots_this_limb++
						if(shots_this_limb > shots_per_limb_per_rep)
							break

		if(ADMIN_PUNISHMENT_SCARIFY)
			if(!iscarbon(target))
				to_chat(usr,span_warning("This must be used on a carbon mob."), confidential = TRUE)
				return
			var/mob/living/carbon/C = target
			C.generate_fake_scars(rand(1, 4))
			to_chat(C, span_warning("You feel your body grow jaded and torn..."))

		if(ADMIN_PUNISHMENT_FLASHBANG)
			var/mob/living/carbon/chucklenuts = target
			playsound(chucklenuts,'sound/misc/thinkfast.ogg',300 , FALSE)
			to_chat(chucklenuts, span_warning("Think Fast!"))
			sleep(1.5 SECONDS)
			var/obj/item/grenade/flashbang/CB = new/obj/item/grenade/flashbang(target.loc)
			CB.prime()
			chucklenuts.flash_act()

		if(ADMIN_PUNISHMENT_WIBBLY)
			apply_wibbly_filters(target)
			to_chat(target, span_warning("Something feels very... wibbly!"))

		if(ADMIN_PUNISHMENT_WIBBLY_VIRUS)
			var/datum/disease/D = new /datum/disease/wibblification()
			target.ForceContractDisease(D, FALSE, TRUE)
			
		if(ADMIN_PUNISHMENT_BACKROOMS)
			INVOKE_ASYNC(target, TYPE_PROC_REF(/mob/living, clip_into_backrooms))

	punish_log(target, punishment)

/**
  * firing_squad is a proc for the :B:erforate smite to shoot each individual bullet at them, so that we can add actual delays without sleep() nonsense
  *
  * Hilariously, if you drag someone away mid smite, the bullets will still chase after them from the original spot, possibly hitting other people. Too funny to fix imo
  *
  * Arguments:
  * * target- guy we're shooting obviously
  * * source_turf- where the bullet begins, preferably on a turf next to the target
  * * body_zone- which bodypart we're aiming for, if there is one there
  * * wound_bonus- the wounding power we're assigning to the bullet, since we don't care about the base one
  * * damage- the damage we're assigning to the bullet, since we don't care about the base one
  */

/proc/firing_squad(mob/living/carbon/target, turf/source_turf, body_zone, wound_bonus, damage)
	if(!target.get_bodypart(body_zone))
		return
	playsound(target, 'sound/weapons/revolver357shot.ogg', 100)
	var/obj/projectile/bullet/smite/divine_wrath = new(source_turf)
	divine_wrath.damage = damage
	divine_wrath.wound_bonus = wound_bonus
	divine_wrath.original = target
	divine_wrath.def_zone = body_zone
	divine_wrath.spread = 0
	divine_wrath.preparePixelProjectile(target, source_turf)
	divine_wrath.fire()

/client/proc/punish_log(whom, punishment)
	var/msg = "[key_name(usr)] punished [key_name_admin(whom)] with [punishment]." //yogs - Yog tickets
	message_admins(msg)
	admin_ticket_log(whom, msg)
	log_admin("[key_name(usr)] punished [key_name(whom)] with [punishment].")

/client/proc/trigger_centcom_recall()
	if(!check_rights(R_ADMIN))
		return
	var/message = pick(GLOB.admiral_messages)
	message = input("Enter message from the on-call admiral to be put in the recall report.", "Admiral Message", message) as text|null

	if(!message)
		return

	message_admins("[key_name_admin(usr)] triggered a CentCom recall, with the admiral message of: [message]")
	log_game("[key_name(usr)] triggered a CentCom recall, with the message of: [message]")
	SSshuttle.centcom_recall(SSshuttle.emergency.timer, message)

/client/proc/cmd_admin_check_player_exp()	//Allows admins to determine who the newer players are.
	set category = "Admin"
	set name = "Player Playtime"
	if(!check_rights(R_ADMIN))
		return

	if(!CONFIG_GET(flag/use_exp_tracking))
		to_chat(usr, span_warning("Tracking is disabled in the server configuration file."), confidential=TRUE)
		return

	var/list/msg = list()
	msg += "<html><head><meta charset='UTF-8'><title>Playtime Report</title></head><body>Playtime:<BR><UL>"
	for(var/client/C in GLOB.clients)
		msg += "<LI> - [key_name_admin(C)]: <A href='byond://?_src_=holder;[HrefToken()];getplaytimewindow=[REF(C.mob)]'>" + C.get_exp_living() + "</a></LI>"
	msg += "</UL></BODY></HTML>"
	src << browse(msg.Join(), "window=Player_playtime_check")

/datum/admins/proc/cmd_show_exp_panel(client/client_to_check)
	if(!check_rights(R_ADMIN))
		return
	if(!client_to_check)
		to_chat(usr, span_danger("ERROR: Client not found."), confidential = TRUE)
		return
	if(!CONFIG_GET(flag/use_exp_tracking))
		to_chat(usr, span_warning("Tracking is disabled in the server configuration file."), confidential=TRUE)
		return

	new /datum/job_report_menu(client_to_check, usr)


/datum/admins/proc/toggle_exempt_status(client/C)
	if(!check_rights(R_ADMIN))
		return
	if(!C)
		to_chat(usr, span_danger("ERROR: Client not found."), confidential=TRUE)
		return

	if(!C.set_db_player_flags())
		to_chat(usr, span_danger("ERROR: Unable read player flags from database. Please check logs."), confidential=TRUE)
	var/dbflags = C.prefs.db_flags
	var/newstate = FALSE
	if(dbflags & DB_FLAG_EXEMPT)
		newstate = FALSE
	else
		newstate = TRUE

	if(C.update_flag_db(DB_FLAG_EXEMPT, newstate))
		to_chat(usr, span_danger("ERROR: Unable to update player flags. Please check logs."), confidential=TRUE)
	else
		message_admins("[key_name_admin(usr)] has [newstate ? "activated" : "deactivated"] job exp exempt status on [key_name_admin(C)]")
		log_admin("[key_name(usr)] has [newstate ? "activated" : "deactivated"] job exp exempt status on [key_name(C)]")

/// Allow admin to add or remove traits of datum
/datum/admins/proc/modify_traits(datum/D)
	if(!D)
		return

	var/add_or_remove = input("Remove/Add?", "Trait Remove/Add") as null|anything in list("Add","Remove")
	if(!add_or_remove)
		return
	var/list/available_traits = list()

	switch(add_or_remove)
		if("Add")
			for(var/key in GLOB.admin_visible_traits)
				if(istype(D,key))
					available_traits += GLOB.admin_visible_traits[key]
		if("Remove")
			if(!GLOB.admin_trait_name_map)
				GLOB.admin_trait_name_map = generate_admin_trait_name_map()
			for(var/trait in D._status_traits)
				var/name = GLOB.admin_trait_name_map[trait] || trait
				available_traits[name] = trait

	var/chosen_trait = input("Select trait to modify", "Trait") as null|anything in sort_list(available_traits)
	if(!chosen_trait)
		return
	chosen_trait = available_traits[chosen_trait]

	var/source = "adminabuse"
	switch(add_or_remove)
		if("Add") //Not doing source choosing here intentionally to make this bit faster to use, you can always vv it.
			if(GLOB.movement_type_trait_to_flag[chosen_trait]) //include the required element.
				D.AddElement(/datum/element/movetype_handler)
			ADD_TRAIT(D,chosen_trait,source)
		if("Remove")
			var/specific = input("All or specific source ?", "Trait Remove/Add") as null|anything in list("All","Specific")
			if(!specific)
				return
			switch(specific)
				if("All")
					source = null
				if("Specific")
					source = input("Source to be removed","Trait Remove/Add") as null|anything in sort_list(GET_TRAIT_SOURCES(D, chosen_trait))
					if(!source)
						return
			REMOVE_TRAIT(D,chosen_trait,source)

/mob/living/carbon/proc/adminpie(mob/user)
	var/obj/item/reagent_containers/food/snacks/pie/cream/admin/p = new (get_turf(pick(oview(3,user))))
	p.item_flags = UNCATCHABLE
	p.throw_at(user, 10, 0.5, usr)
	sleep(0.5 SECONDS)
	var/mob/living/carbon/human/T = user
	if(!T.IsParalyzed())
		var/obj/item/reagent_containers/food/snacks/pie/cream/admin/pie = new (get_turf(pick(oview(1,user))))
		pie.item_flags = UNCATCHABLE
		pie.throw_at(user, 10, 0.5, usr)

/client/proc/admincryo(mob/living/carbon/human/target as mob)
	set category = "Misc.Unused"
	set name = "Admin Cryo"
	if(!check_rights(R_ADMIN))
		return
	var/confirm = alert(usr, "Are you sure you want to cryo them?", "Admin Cryo", "Yes", "No")
	if(confirm == "No")
		return
	var/offer = alert(usr, "Do you want to offer control of their mob to ghosts?", "Offer Control", "Yes", "No")
	for(var/obj/machinery/cryopod/cryopod in GLOB.cryopods)
		if(cryopod.occupant)
			continue
		if(!istype(get_area(cryopod), /area/crew_quarters))
			continue
		new /obj/effect/particle_effect/sparks/quantum(get_turf(target))
		target.forceMove(cryopod.loc)
		var/msg = "[key_name_admin(usr)] has put [target.real_name]/[key_name(target)] into cryostorage at [ADMIN_VERBOSEJMP(target)]."
		message_admins(msg)
		log_admin(msg)
		new /obj/effect/particle_effect/sparks/quantum(get_turf(target))
		if(offer == "Yes")
			cryopod.close_machine(target, admin_forced = TRUE)
			offer_control(target)
		else
			cryopod.close_machine(target)
		return

/datum/admins/proc/cmd_create_centcom()
	set category = "Admin.Round Interaction"
	set name = "Spawn on Centcom"
	if(!check_rights(R_ADMIN))
		return
	var/turf/T
	for(var/obj/effect/landmark/centcom/centcomturf in GLOB.landmarks_list)
		T = centcomturf.loc
	if(ismob(usr))
		var/mob/M = usr
		if(isobserver(M))
			var/mob/living/carbon/human/H = new(T)
			H.randomize_human_appearance(~(RANDOMIZE_SPECIES))
			H.dna.update_dna_identity()
			H.equipOutfit(/datum/outfit/centcom/official/nopda)

			var/datum/mind/Mind = new /datum/mind(M.key) // Reusing the mob's original mind actually breaks objectives for any antag who had this person as their target.
			// For that reason, we're making a new one. This mimics the behavior of, say, lone operatives, and I believe other ghostroles.
			Mind.active = 1
			Mind.transfer_to(H)

			var/msg = "[key_name_admin(H)] has spawned in at centcom [ADMIN_VERBOSEJMP(H)]."
			message_admins(msg)
			log_admin(msg)
			return
	to_chat(usr,span_warning("Only observers can use this command!"))

/datum/admins/proc/cmd_admin_fuckrads()
	set category = "Admin.Round Interaction"
	set name = "Delete All Rads"
	if(!check_rights(R_ADMIN))
		return
	for(var/datum/a in SSradiation.processing)
		qdel(a)
	message_admins("[key_name_admin(usr)] has cleared all radiation.")
	log_admin("[key_name_admin(usr)] has cleared all radiation.")


/mob/living/proc/whistle()
	INVOKE_ASYNC(src, PROC_REF(whistletrigger), "whistle")

/mob/living/proc/whistletrigger()
	var/turf/T = get_turf(src)
	var/mob/living/user = src
	playsound(T,'sound/magic/warpwhistle.ogg', 200, 1)
	user.mobility_flags &= ~MOBILITY_MOVE
	new /obj/effect/temp_visual/tornado(T)
	sleep(2 SECONDS)
	user.invisibility = INVISIBILITY_MAXIMUM
	user.status_flags |= GODMODE
	sleep(2 SECONDS)
	var/breakout = 0
	while(breakout < 50)
		var/turf/potential_T = find_safe_turf()
		if(T.z != potential_T.z || abs(get_dist_euclidian(potential_T,T)) > 50 - breakout)
			do_teleport(user, potential_T, channel = TELEPORT_CHANNEL_MAGIC)
			user.mobility_flags &= ~MOBILITY_MOVE
			T = potential_T
			break
		breakout += 1
	new /obj/effect/temp_visual/tornado(T)
	sleep(2 SECONDS)
	user.invisibility = initial(user.invisibility)
	user.status_flags &= ~GODMODE
	user.update_mobility()
	sleep(4 SECONDS)

/datum/admins/proc/cmd_create_wiki()
	set category = "OOC"
	set name = "Go to Wiki Room"
	if(!check_rights(R_ADMIN))
		return
	var/turf/T
	for(var/obj/effect/landmark/wiki/wikiturf in GLOB.landmarks_list)
		T = wikiturf.loc
	if(ismob(usr))
		var/mob/M = usr
		if(isobserver(M))
			var/mob/living/carbon/human/H = new(T)
			H.randomize_human_appearance(~(RANDOMIZE_SPECIES))
			H.dna.update_dna_identity()

			var/datum/mind/Mind = new /datum/mind(M.key) // Reusing the mob's original mind actually breaks objectives for any antag who had this person as their target.
			// For that reason, we're making a new one. This mimics the behavior of, say, lone operatives, and I believe other ghostroles.
			Mind.active = 1
			Mind.transfer_to(H)

			var/msg = "[key_name_admin(H)] has spawned in the wiki room [ADMIN_VERBOSEJMP(H)]."
			message_admins(msg)
			log_admin(msg)
			return
		else
			usr.forceMove(T)
