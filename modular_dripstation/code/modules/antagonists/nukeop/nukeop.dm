/datum/antagonist/nukeop/on_gain()
	. = ..()
	equip_op()
	give_alias()
	memorize_code()
	if(send_to_spawnpoint)
		move_to_spawnpoint()
		// grant extra TC for the people who start in the nukie base ie. not the lone op
		var/extra_tc = CEILING(GLOB.joined_player_list.len/5, 5)
		var/datum/component/uplink/U = owner.find_syndicate_uplink()
		if (U)
			U.telecrystals += extra_tc

//species toggling
/datum/antagonist/nukeop
	var/whitelist_species = list("human", "felinid")

/datum/antagonist/nukeop/equip_op()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/H = owner.current
	if(isnull(H.client) || !(H.dna.species.id in whitelist_species))
		H.set_species(/datum/species/human) //Plasamen burn up otherwise, and lizards are vulnerable to asimov AIs
		if(H.client.prefs.read_preference(/datum/preference/toggle/purrbation))	//Yeah, above is right, but who cares about felinid players?
			purrbation_toggle_onlyhumans(H)
		var/chosen_name = H.dna.species.random_name(H.gender,0,pick(GLOB.last_names))
		owner.current.real_name = "[chosen_name]"

	H.equipOutfit(nukeop_outfit)
	return TRUE

//naming
/syndicate_name()
	var/name = ""

	// Prefix
	name += pick("Clandestine", "Prima", "Blue", "Zero-G", "Max", "Blasto", "Waffle", "North", "Omni", "Newton", "Cyber", "Bonk", "Gene", "Gib", "Vahlen")

	// Suffix
	if (prob(80))
		name += " "

		// Full
		if (prob(60))
			name += pick("Syndicate", "Consortium", "Collective", "Corporation", "Group", "Holdings", "Biotech", "Industries", "Systems", "Products", "Chemicals", "Pharmaceuticals", "Enterprises", "Creations", "International", "Intergalactic", "Interplanetary", "Foundation", "Positronics", "Hive")
		// Broken
		else
			name += pick("Syndi", "Corp", "Bio", "System", "Prod", "Chem", "Inter", "Hive")
			name += pick("", "-")
			name += pick("Tech", "Sun", "Co", "Tek", "X", "Inc", "Dyne", "Code")
	// Small
	else
		name += pick("-", "")
		name += pick("Tech", "Sun", "Co", "Tek", "X", "Inc", "Gen", "Star", "Dyne", "Code", "Hive", "Group")

	return name


/datum/antagonist/nukeop/give_alias()
	if(nuke_team && nuke_team.syndicate_name)
		var/mob/living/carbon/human/H = owner.current
		var/number = 1
		number = nuke_team.members.Find(owner)
		H.replace_op_id(H,"Operative #[number]", nuke_team.syndicate_name)
	addtimer(CALLBACK(src, PROC_REF(op_rename)), 1)

/datum/antagonist/nukeop/proc/op_rename()
	var/mob/living/op_mob = owner.current
	var/newname = sanitize_name(reject_bad_text(tgui_input_text(op_mob, "You are the [name] of [nuke_team.syndicate_name]. Would you like to change your name to something else?", "Name change", op_mob.real_name, MAX_NAME_LEN)))
	if (!newname)
		return

	op_mob.real_name = "[newname]"



/datum/antagonist/nukeop/leader/give_alias()
	title = pick("Boss", "Commander", "Chief", "Director", "Overlord")
	var/mob/living/carbon/human/H = owner.current
	if(nuke_team && nuke_team.syndicate_name)
		H.replace_op_id(H, title, nuke_team.syndicate_name)
	else
		H.replace_op_id(H,title,"Syndicate")
	addtimer(CALLBACK(src, PROC_REF(op_rename)), 1)
	addtimer(CALLBACK(src, PROC_REF(leader_title_rename)), 1)

/datum/antagonist/nukeop/leader/proc/leader_title_rename()
	switch(tgui_alert(owner.current, "Do you want to change your title?", "Select",list("Manually", "Auto", "No")))
		if("Manually")
			var/newtitle = tgui_input_text(owner.current, "Change your title", "Name change", title, MAX_NAME_LEN)
			title = newtitle
		if("Auto")
			var/newtitle = tgui_alert(owner.current, "Choose your destiny","Choice",list("Boss", "Commander", "Chief", "Director", "Overlord"))
			title = newtitle
		if("No")
			return
	owner.current.replace_op_id(owner.current, title, nuke_team.syndicate_name)

/datum/antagonist/nukeop/leader/nuketeam_name_assign()
	if(!nuke_team)
		return
	switch(tgui_alert(owner.current, "Please select how you want to rename your team.", "Select",list("Manually", "Automatic", "Cancel")))
		if("Manually")
			nuke_team.rename_team(title,ask_name())
		if("Automatic")
			nuke_team.rename_team(title,automatic_select())
		if("Cancel")
			return

/datum/antagonist/nukeop/leader/proc/automatic_select()
	var/name = ""
	var/list/prefix = list("Clandestine", "Prima", "Blue", "Zero-G", "Max", "Blasto", "Waffle", "Donk", "North", "Omni", "Newton", "Cyber", "Bonk", "Gene", "Gib", "Vahlen")
	var/list/fullsuffix = list("Syndicate", "Consortium", "Collective", "Corporation", "Group", "Holdings", "Biotech", "Industries", "Systems", "Products", "Chemicals", "Pharmaceuticals", "Enterprises", "Creations", "International", "Intergalactic", "Interplanetary", "Foundation", "Positronics", "Hive")
	var/list/customfirstsuffix = list("Syndi", "Corp", "Bio", "System", "Prod", "Chem", "Inter", "Hive")
	var/list/customsecondsuffix = list("Tech", "Sun", "Co", "Tek", "X", "Inc", "Dyne", "Code")
	var/list/shortsuffix = list("Tech", "Sun", "Co", "Tek", "X", "Inc", "Gen", "Star", "Dyne", "Code", "Hive", "Group")

	var/name_prefix = tgui_alert(owner.current, "Please select prefix", "Select", prefix)
	name += name_prefix

	// Suffix
	switch(tgui_alert(owner.current, "Please select suffix", "Select",list("Full", "Custom", "Small")))
		if("Full")
			name += " "
			var/name_suffix = tgui_alert(owner.current, "Please select suffix", "Select", fullsuffix)
			name += name_suffix
		if ("Custom")
			name += " "
			var/name_firstsuffix = tgui_alert(owner.current, "Please select first suffix", "Select", customfirstsuffix)
			name += name_firstsuffix
			switch(tgui_alert(owner.current, "Please select second suffix", "Select", list("None", "-")))
				if("None")
					name += ""
				if("-")
					name += "-"
			var/name_secondsuffix = tgui_alert(owner.current, "Please select second suffix", "Select", customsecondsuffix)
			name += name_secondsuffix
		if("Small")
			switch(tgui_alert(owner.current, "Please select second suffix", "Select", list("None", "-")))
				if("None")
					name += ""
				if("-")
					name += "-"
			var/name_shortsuffix  = tgui_alert(owner.current, "Please select short suffix", "Select", shortsuffix)
			name += name_shortsuffix

	return name

/datum/antagonist/nukeop/leader/ask_name()
	var/oldname = "Syndicate"
	if(nuke_team.syndicate_name)
		oldname = nuke_team.syndicate_name
	var/newname = tgui_input_text(owner.current,"You are the nuke operative [title]. Please choose a last name of your Dream Team.", "Name change",oldname)
	if (!newname)
		newname = oldname
	else
		newname = reject_bad_name(newname)
		if(!newname)
			newname = oldname

	return capitalize(newname)

/datum/team/nuclear/rename_team(title,new_name)
	syndicate_name = new_name
	name = "[syndicate_name] Team"
	for(var/I in members)
		var/datum/mind/synd_mind = I
		var/mob/living/carbon/human/H = synd_mind.current
		if(!istype(H))
			continue
		if(synd_mind.has_antag_datum(/datum/antagonist/nukeop/leader))
			H.replace_op_id(H,title, syndicate_name)
		else
			var/number = 1
			number = members.Find(synd_mind)
			H.replace_op_id(H,"Operative #[number]", syndicate_name)

/atom/proc/replace_op_id(op,newname,squad_name)
	var/mob/living/carbon/oper = op
	var/list/searching = oper.get_all_gear()
	var/search_id = 1

	for(var/A in searching)
		if( search_id && istype(A, /obj/item/card/id) )
			var/obj/item/card/id/ID = A
			ID.registered_name = "[squad_name] [newname]"
			ID.assignment = squad_name
			ID.originalassignment = squad_name
			ID.registered_age = null
			if(istype(ID, /obj/item/card/id/syndicate))
				var/obj/item/card/id/syndicate/SID = ID
				SID.forged = TRUE
				SID.anyone = TRUE
			ID.update_label()
			if(istype(ID.loc, /obj/item/computer_hardware/card_slot))
				var/obj/item/computer_hardware/card_slot/CS = ID.loc
				CS.holder?.update_label()
			balloon_alert(op, "name replaced")
			search_id = 0