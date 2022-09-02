/obj/item/folder
	name = "folder"
	desc = "A folder."
	icon = 'yogstation/icons/obj/bureaucracy.dmi'
	icon_state = "folder"
	w_class = WEIGHT_CLASS_SMALL
	pressure_resistance = 2
	resistance_flags = FLAMMABLE

/obj/item/folder/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins filing an imaginary death warrant! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/folder/blue
	desc = "A blue folder."
	icon_state = "folder_blue"

/obj/item/folder/red
	desc = "A red folder."
	icon_state = "folder_red"

/obj/item/folder/yellow
	desc = "A yellow folder."
	icon_state = "folder_yellow"

/obj/item/folder/white
	desc = "A white folder."
	icon_state = "folder_white"


/obj/item/folder/update_icon()
	cut_overlays()
	if(contents.len)
		add_overlay("folder_paper")


/obj/item/folder/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/paper) || istype(W, /obj/item/photo) || istype(W, /obj/item/documents))
		if(!user.transferItemToLoc(W, src))
			return
		to_chat(user, span_notice("You put [W] into [src]."))
		update_icon()
	else if(istype(W, /obj/item/pen))
		if(!user.is_literate())
			to_chat(user, span_notice("You scribble illegibly on the cover of [src]!"))
			return
		var/inputvalue = stripped_input(user, "What would you like to label the folder?", "Folder Labelling", "", MAX_NAME_LEN)

		if(!inputvalue)
			return

		if(user.canUseTopic(src, BE_CLOSE))
			name = "folder[(inputvalue ? " - '[inputvalue]'" : null)]"


/obj/item/folder/attack_self(mob/user)
	var/dat = "<HTML><HEAD><meta charset='UTF-8'><title>[name]</title></HEAD><BODY>"

	for(var/obj/item/I in src)
		dat += "<A href='?src=[REF(src)];remove=[REF(I)]'>Remove</A> - <A href='?src=[REF(src)];read=[REF(I)]'>[I.name]</A><BR>"
	dat += "</BODY></HTML>"
	user << browse(dat, "window=folder")
	onclose(user, "folder")
	add_fingerprint(usr)

/obj/item/folder/AltClick(mob/living/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(contents.len)
		to_chat(user, span_warning("You can't fold this folder with something still inside!"))
		return
	to_chat(user, span_notice("You fold [src] flat."))
	var/obj/item/I = new /obj/item/stack/sheet/cardboard
	qdel(src)
	user.put_in_hands(I)

/obj/item/folder/Topic(href, href_list)
	..()
	if(usr.stat || usr.restrained())
		return

	if(usr.contents.Find(src))

		if(href_list["remove"])
			var/obj/item/I = locate(href_list["remove"]) in src
			if(istype(I))
				I.forceMove(usr.loc)
				usr.put_in_hands(I)

		if(href_list["read"])
			var/obj/item/I = locate(href_list["read"]) in src
			if(istype(I))
				usr.examinate(I)

		//Update everything
		attack_self(usr)
		update_icon()

/obj/item/folder/documents
	name = "folder- 'TOP SECRET'"
	desc = "A folder stamped \"Top Secret - Property of Nanotrasen Corporation. Unauthorized distribution is punishable by death.\""

/obj/item/folder/documents/Initialize()
	. = ..()
	new /obj/item/documents/nanotrasen(src)
	update_icon()

/obj/item/folder/syndicate
	icon_state = "folder_syndie"
	name = "folder- 'TOP SECRET'"
	desc = "A folder stamped \"Top Secret - Property of The Syndicate.\""

/obj/item/folder/syndicate/red
	icon_state = "folder_sred"

/obj/item/folder/syndicate/red/Initialize()
	. = ..()
	new /obj/item/documents/syndicate/red(src)
	update_icon()

/obj/item/folder/syndicate/blue
	icon_state = "folder_sblue"

/obj/item/folder/syndicate/blue/Initialize()
	. = ..()
	new /obj/item/documents/syndicate/blue(src)
	update_icon()

/obj/item/folder/syndicate/mining/Initialize()
	. = ..()
	new /obj/item/documents/syndicate/mining(src)
	update_icon()

/// For traitors: New objective
/obj/item/folder/objective
	var/datum/objective/objective // Object not typepath
	var/difficulty = 0
	var/tc = 0
	var/admin_msg = FALSE
	// Steal objectives initialized later
	var/list/easy_objectives = list(
		new /datum/objective/assassinate/once, // Kill someone once
		new /datum/objective/download, // Download research nodes
		new /datum/objective/minor/pet, // Kill a pet
	)
	var/list/med_objectives = list()
	var/list/hard_objectives = list(
		new /datum/objective/destroy, // Kill AI
	)

/obj/item/folder/objective/Initialize(mapload, _user, _obj, _diff)
	. = ..()

	init_steal_objs()

	difficulty = _diff ? _diff : rand(1,3)
	tc = clamp(difficulty * 2 + rand(-1,1), 2, 10)
	forge_objective(_obj)

	var/folder_type = rand(1,5)
	var/folder_color = "gray"
	switch(folder_type)
		if(2)
			desc = "A blue folder."
			icon_state = "folder_blue"
			folder_color = "blue"
		if(3)
			desc = "A red folder."
			icon_state = "folder_red"
			folder_color = "red"
		if(4)
			desc = "A yellow folder."
			icon_state = "folder_yellow"
			folder_color = "yellow"
		if(5)
			desc = "A white folder."
			icon_state = "folder_white"
			folder_color = "white"
	update_icon()
	if(_user)
		to_chat(_user, span_notice("<b>Your objective has been curated.</b> You will find it as a [folder_color] folder in [get_area_name(src, TRUE)]."))

/// Initialize steal objectives based on difficulty
/obj/item/folder/objective/proc/init_steal_objs()
	for(var/I in subtypesof(/datum/objective_item/steal))
		var/datum/objective/steal/newsteal = new /datum/objective/steal
		var/datum/objective_item/steal/S = new I
		if(!S.TargetExists())
			continue
		if(LAZYLEN(S.special_equipment) > 0) // No special equipment allowed
			continue
		newsteal.set_target(S)
		if(S.difficulty < 5) // 1-4 is easy
			easy_objectives += newsteal
		else if(S.difficulty >= 5 && S.difficulty < 10) // 5-9 is medium
			med_objectives += newsteal
		else // 10+ is hard
			hard_objectives += newsteal

/obj/item/folder/objective/proc/forge_objective(_obj)
	if(_obj)
		objective = _obj
	else
		var/list/potential_objectives = list(easy_objectives, med_objectives, hard_objectives)[difficulty]
		var/inf_protection = 0 // Threshold of 30 may have to be raised if more objectives are added
		// This will cycle through invalid objectives
		while(!objective || objective.explanation_text == "Nothing." || objective.explanation_text == "Free Objective")
			inf_protection++
			if(inf_protection >= 30)
				break
			
			if(objective)
				potential_objectives.Remove(objective)
				qdel(objective)
			
			if(LAZYLEN(potential_objectives) <= 0)
				break
			
			objective = pick(potential_objectives)
			objective.find_target()

			// i hate objective code so much WHO WROTE THIS????
			if(istype(objective, /datum/objective/download)) 
				var/datum/objective/download/O = objective
				O.gen_amount_goal()
			
			if(istype(objective, /datum/objective/minor))
				var/datum/objective/minor/O = objective
				O.finalize()
			
			objective.update_explanation_text()

		if(LAZYLEN(potential_objectives) <= 0 || inf_protection >= 30)
			qdel(src)
			CRASH("No valid [list("EASY", "MEDIUM", "HARD")[difficulty]] objective could be chosen! Deleting folder!")

	// Cleanup
	for(var/datum/objective/O in easy_objectives)
		easy_objectives.Remove(O)
		if(O != objective)
			qdel(O)
	for(var/datum/objective/O in med_objectives)
		med_objectives.Remove(O)
		if(O != objective)
			qdel(O)
	for(var/datum/objective/O in hard_objectives)
		hard_objectives.Remove(O)
		if(O != objective)
			qdel(O)

/obj/item/folder/objective/attack_self(mob/user)
	. = ..()
	if(is_syndicate(user))
		ui_interact(user)
		objective.owner = user.mind
	
/obj/item/folder/objective/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		// Open UI
		admin_msg = FALSE
		ui = new(user, src, "FolderObjective")
		ui.open()

/obj/item/folder/objective/ui_static_data(mob/user)
	. = ..()
	.["tc"] = tc || "0"
	.["difficulty"] = list("EASY", "MEDIUM", "HARD")[difficulty]
	.["objective_text"] = objective?.explanation_text
	.["admin_msg"] = admin_msg

/obj/item/folder/objective/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("check_done")
			if(objective.check_completion())
				to_chat(usr, span_notice("<b>NOTICE: OBJECTIVE COMPLETE.</b> GOOD WORK AGENT. DISPENSING REWARD. MAKE SURE THE OBJECTIVE STAYS COMPLETED OR WE WILL HURT YOU."))
				to_chat(usr, "\The [src] suddenly transforms into [tc] telecrystal[tc == 1 ? "" : "s"]!")
				usr.playsound_local(loc, 'sound/machines/ping.ogg', 20, 0)
				var/obj/item/stack/telecrystal/reward = new /obj/item/stack/telecrystal
				reward.amount = tc
				dropped(usr, TRUE)
				usr.put_in_hands(reward)
				if(usr.mind?.has_antag_datum(/datum/antagonist/traitor))
					var/datum/antagonist/traitor/T = usr.mind.has_antag_datum(/datum/antagonist/traitor)
					T.add_objective(objective) // Keep the objective done or you will redtext
				qdel(src)
				return TRUE
			else if(istype(objective, /datum/objective/custom))
				admin_msg = TRUE
				message_admins("[ADMIN_LOOKUPFLW(usr)] has requested an admin objective be checked for completion (<b>[objective.explanation_text]</b>). (<A HREF='?_src_=holder;[HrefToken()];uplink_custom_obj_accept=[REF(src)];requester=[REF(usr)]'>MARK COMPLETED</A>) (<A HREF='?_src_=holder;[HrefToken()];uplink_custom_obj_deny=[REF(src)];requester=[REF(usr)]'>MARK INCOMPLETE</A>)")
				to_chat(usr, span_danger("<b>NOTICE: SENT OBJECTIVE STATUS TO COMMAND FOR REVIEW.</b>"))
				return TRUE
			else
				to_chat(usr, span_danger("<b>ERR: OBJECTIVE NOT COMPLETE</b>"))
				usr.playsound_local(loc, 'sound/machines/buzz-two.ogg', 20, 0)
				return TRUE

			
