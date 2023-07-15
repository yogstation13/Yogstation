/mob/living/silicon/proc/laws_sanity_check()
	if(!laws)
		make_laws()

/mob/living/silicon/proc/make_laws()
	laws = new /datum/ai_laws
	laws.set_laws_config()
	laws.associate(src)

/mob/living/silicon/proc/show_laws() // Redefined in silicon/ai/laws.dm and silicon/robot/laws.dm
	return

/mob/living/silicon/proc/post_lawchange(announce = TRUE)
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	if(announce && last_lawchange_announce != world.time)
		to_chat(src, "<b>Your laws have been changed.</b>")
		SEND_SOUND(src, sound('sound/effects/ionlaw.ogg'))
		addtimer(CALLBACK(src, PROC_REF(show_laws)), 0)
		last_lawchange_announce = world.time

//
// Devil Laws
// 
/mob/living/silicon/proc/set_devil_laws(law_list, announce = TRUE)
	laws_sanity_check()
	laws.set_devil_laws(law_list)
	post_lawchange(announce)

/mob/living/silicon/proc/clear_devil_laws(force, announce = TRUE)
	laws_sanity_check()
	laws.clear_devil_laws(force)
	post_lawchange(announce)

/mob/living/silicon/proc/add_devil_law(law, announce = TRUE)
	laws_sanity_check()
	laws.add_devil_law(law)
	post_lawchange(announce)

/mob/living/silicon/proc/remove_devil_law(index, announce = TRUE)
	laws_sanity_check()
	laws.remove_devil_law(index)
	post_lawchange(announce)

/mob/living/silicon/proc/edit_devil_law(index, law, announce = TRUE)
	laws_sanity_check()
	laws.edit_devil_law(index, law)
	post_lawchange(announce)

/mob/living/silicon/proc/flip_devil_state(index, announce = TRUE)
	laws_sanity_check()
	laws.flip_devil_state(index)

//
// Zeroth Law
// 
/mob/living/silicon/proc/set_zeroth_law(law, law_borg, announce = TRUE)
	laws_sanity_check()
	laws.set_zeroth_law(law, law_borg)
	post_lawchange(announce)


/mob/living/silicon/proc/clear_zeroth_law(force, announce = TRUE)
	laws_sanity_check()
	laws.clear_zeroth_law(force)
	post_lawchange(announce)

/mob/living/silicon/proc/flip_zeroth_state()
	laws_sanity_check()
	laws.flip_zeroth_state()

//
// Hacked Laws
//
/mob/living/silicon/proc/set_hacked_laws(law_list, announce = TRUE)
	laws_sanity_check()
	laws.set_hacked_laws(law_list)
	post_lawchange(announce)

/mob/living/silicon/proc/clear_hacked_laws(force, announce = TRUE)
	laws_sanity_check()
	laws.clear_hacked_laws(force)
	post_lawchange(announce)

/mob/living/silicon/proc/add_hacked_law(law, announce = TRUE)
	laws_sanity_check()
	laws.add_hacked_law(law)
	post_lawchange(announce)

/mob/living/silicon/proc/remove_hacked_law(index, announce = TRUE)
	laws_sanity_check()
	laws.remove_hacked_law(index)
	post_lawchange(announce)

/mob/living/silicon/proc/edit_hacked_law(index, law, announce = TRUE)
	laws_sanity_check()
	laws.edit_hacked_law(index, law)
	post_lawchange(announce)

/mob/living/silicon/proc/flip_hacked_state(index, announce = TRUE)
	laws_sanity_check()
	laws.flip_hacked_state(index)

//
// Ion Laws
//
/mob/living/silicon/proc/set_ion_laws(law_list, announce = TRUE)
	laws_sanity_check()
	laws.set_ion_laws(law_list)
	post_lawchange(announce)

/mob/living/silicon/proc/clear_ion_laws(announce = TRUE)
	laws_sanity_check()
	laws.clear_ion_laws()
	post_lawchange(announce)

/mob/living/silicon/proc/add_ion_law(law, announce = TRUE)
	laws_sanity_check()
	laws.add_ion_law(law)
	post_lawchange(announce)

/mob/living/silicon/proc/remove_ion_law(index, announce = TRUE)
	laws_sanity_check()
	laws.remove_ion_law(index)
	post_lawchange(announce)

/mob/living/silicon/proc/edit_ion_law(index, law, announce = TRUE)
	laws_sanity_check()
	laws.edit_ion_law(index, law)
	post_lawchange(announce)

/mob/living/silicon/proc/flip_ion_state(index, announce = TRUE)
	laws_sanity_check()
	laws.flip_ion_state(index)

//
// Inherent Laws
// 
/mob/living/silicon/proc/set_inherent_laws(law_list, announce = TRUE)
	laws_sanity_check()
	laws.set_inherent_laws(law_list)
	post_lawchange(announce)

/mob/living/silicon/proc/clear_inherent_laws(announce = TRUE)
	laws_sanity_check()
	laws.clear_inherent_laws()
	post_lawchange(announce)

/mob/living/silicon/proc/add_inherent_law(law, announce = TRUE)
	laws_sanity_check()
	laws.add_inherent_law(law)
	post_lawchange(announce)

/mob/living/silicon/proc/remove_inherent_law(number, announce = TRUE)
	laws_sanity_check()
	laws.remove_inherent_law(number)
	post_lawchange(announce)

/mob/living/silicon/proc/edit_inherent_law(index, law, announce = TRUE)
	laws_sanity_check()
	laws.edit_inherent_law(index, law)
	post_lawchange(announce)

/mob/living/silicon/proc/flip_inherent_state(index, announce = TRUE)
	laws_sanity_check()
	laws.flip_inherent_state(index)

//
// Supplied Laws
// 
/mob/living/silicon/proc/set_supplied_laws(law_list, announce = TRUE)
	laws_sanity_check()
	laws.set_supplied_laws(law_list)
	post_lawchange(announce)

/mob/living/silicon/proc/clear_supplied_laws(announce = TRUE)
	laws_sanity_check()
	laws.clear_supplied_laws()
	post_lawchange(announce)

/mob/living/silicon/proc/add_supplied_law(number, law, announce = TRUE)
	laws_sanity_check()
	laws.add_supplied_law(number, law)
	post_lawchange(announce)

/mob/living/silicon/proc/remove_supplied_law(number, announce = TRUE)
	laws_sanity_check()
	laws.remove_supplied_law(number)
	post_lawchange(announce)

/mob/living/silicon/proc/edit_supplied_law(index, law, announce = TRUE)
	laws_sanity_check()
	laws.edit_supplied_law(index, law)
	post_lawchange(announce)
		
/mob/living/silicon/proc/flip_supplied_state(index, announce = TRUE)
	laws_sanity_check()
	laws.flip_supplied_state(index)

//
// Unsorted
// 
/mob/living/silicon/proc/replace_random_law(law, groups, announce = TRUE)
	laws_sanity_check()
	laws.replace_random_law(law, groups)
	post_lawchange(announce)

/mob/living/silicon/proc/shuffle_laws(list/groups, announce = TRUE)
	laws_sanity_check()
	laws.shuffle_laws(groups)
	post_lawchange(announce)

/mob/living/silicon/proc/remove_law(number, announce = TRUE)
	laws_sanity_check()
	laws.remove_law(number)
	post_lawchange(announce)

//
// Law Manager
// 
/datum/law_manager
	var/user
	var/zeroth_law = "ZerothLaw"
	var/hacked_law = "HackedLaw"
	var/ion_law	= "IonLaw"
	var/inherent_law = "InherentLaw"
	var/supplied_law = "SuppliedLaw"
	var/supplied_law_position = MIN_SUPPLIED_LAW_NUMBER

	var/current_view = 0

	/// All laws that admins can view/transfer.
	var/list/datum/ai_laws/admin_laws
	/// All laws that players can view/transfer.
	var/list/datum/ai_laws/player_laws
	var/mob/living/silicon/owner = null

/datum/law_manager/New(mob/living/silicon/S)
	..()
	owner = S

	if(!admin_laws)
		admin_laws = new()
		player_laws = new()

		init_subtypes(/datum/ai_laws, admin_laws)

		for(var/datum/ai_laws/laws in admin_laws)
			if(!laws.adminselectable)
				admin_laws -= laws

		for(var/datum/ai_laws/laws in admin_laws)
			if(laws.selectable)
				player_laws += laws
	
/datum/law_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LawManager", "Law Manager - [owner.name]")
		ui.open()

/datum/law_manager/ui_state(mob/user)
	if(owner == user || is_admin(user))
		return GLOB.always_state
	return GLOB.never_state

/datum/law_manager/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(owner != usr && !is_admin(usr))
		message_admins("Warning: Non-silicon and non-admin [usr] attempted to open [owner]'s Law Manager!")
		return

	switch(action)
		if("set_view")
			current_view = text2num(params["set_view"])
		if("state_law")
			var/index = text2num(params["index"])
			var/type = params["type"]
			if(type == "devil")
				owner.laws.flip_devil_state(index)
			if(type == "zeroth")
				owner.laws.flip_zeroth_state()
			if(type == "hacked")
				owner.laws.flip_hacked_state(index)
			if(type == "ion")
				owner.laws.flip_ion_state(index)
			if(type == "inherent")
				owner.laws.flip_inherent_state(index)
			if(type == "supplied")
				owner.laws.flip_supplied_state(index)
		if("edit_law")
			var/index = text2num(params["index"])
			var/type = params["type"]
			if(owner == usr && !is_special_character(owner) && !is_admin(usr))
				message_admins("Warning: Non-antag silicon and non-admin [usr] attempted to edit one of their laws!")
				return
			if(type == "devil" && owner.laws.devil.len >= index)
				if(!is_admin(usr)) // Assume that they're owner from here.
					to_chat(usr, span_warning("You can't edit your own devil laws."))
					return
				if(is_special_character(owner))
					to_chat(usr, span_warning("This silicon is an antag. Remove their status if you want to edit their devil laws."))
					return
				var/new_law = sanitize(input(usr, "Enter new law. Leaving the field blank will cancel the edit.", "Edit Law", owner.laws.devil[index]))
				if(new_law != "" && new_law != owner.laws.devil[index])
					log_admin("[usr] has changed a law of [owner] from '[owner.laws.devil[index]]' to '[new_law]'")
					message_admins("[usr] has changed a law of [owner] from '[owner.laws.devil[index]]' to '[new_law]'")
					owner.edit_devil_law(index, new_law)
					owner.update_law_history(usr) // Will be "ckey/youricname" as ghost/etc or "ckey/(new player)" in lobby; either way is okay! I hope...
			if(type == "zeroth" && !isnull(owner.laws.zeroth))
				if(!is_admin(usr)) // Assume that they're owner from here.
					to_chat(usr, span_warning("You can't edit your own zeroth laws."))
					return
				if(is_special_character(owner))
					to_chat(usr, span_warning("This silicon is an antag. Remove their status if you want to remove their zeroth law."))
					return
				var/new_law = sanitize(input(usr, "Enter new law. Leaving the field blank will cancel the edit.", "Edit Law", owner.laws.zeroth))
				if(new_law != "" && new_law != owner.laws.zeroth)
					log_admin("[usr] has changed a law of [owner] from '[owner.laws.zeroth]' to '[new_law]'")
					message_admins("[usr] has changed a law of [owner] from '[owner.laws.zeroth]' to '[new_law]'")
					owner.set_zeroth_law(new_law)
					owner.update_law_history(usr)
			if(type == "hacked" && owner.laws.hacked.len >= index)
				var/new_law = sanitize(input(usr, "Enter new law. Leaving the field blank will cancel the edit.", "Edit Law", owner.laws.hacked[index]))
				if(new_law != "" && new_law != owner.laws.hacked[index])
					log_admin("[usr] has changed a law of [owner] from '[owner.laws.hacked[index]]' to '[new_law]'")
					message_admins("[usr] has changed a law of [owner] from '[owner.laws.hacked[index]]' to '[new_law]'")
					owner.edit_hacked_law(index, new_law)
					owner.update_law_history(usr)
			if(type == "ion" && owner.laws.ion.len >= index)
				var/new_law = sanitize(input(usr, "Enter new law. Leaving the field blank will cancel the edit.", "Edit Law", owner.laws.ion[index]))
				if(new_law != "" && new_law != owner.laws.ion[index])
					log_admin("[usr] has changed a law of [owner] from '[owner.laws.ion[index]]' to '[new_law]'")
					message_admins("[usr] has changed a law of [owner] from '[owner.laws.ion[index]]' to '[new_law]'")
					owner.edit_ion_law(index, new_law)
					owner.update_law_history(usr)
			if(type == "inherent" && owner.laws.inherent.len >= index)
				var/new_law = sanitize(input(usr, "Enter new law. Leaving the field blank will cancel the edit.", "Edit Law", owner.laws.inherent[index]))
				if(new_law != "" && new_law != owner.laws.inherent[index])
					log_admin("[usr] has changed a law of [owner] from '[owner.laws.inherent[index]]' to '[new_law]'")
					message_admins("[usr] has changed a law of [owner] from '[owner.laws.inherent[index]]' to '[new_law]'")
					owner.edit_inherent_law(index, new_law)
					owner.update_law_history(usr)
			if(type == "supplied" && owner.laws.supplied.len >= index)
				var/new_law = sanitize(input(usr, "Enter new law. Leaving the field blank will cancel the edit.", "Edit Law", owner.laws.supplied[index]))
				if(new_law != "" && new_law != owner.laws.supplied[index])
					log_admin("[usr] has changed a law of [owner] from '[owner.laws.supplied[index]]' to '[new_law]'")
					message_admins("[usr] has changed a law of [owner] from '[owner.laws.supplied[index]]' to '[new_law]'")
					owner.edit_supplied_law(index, new_law)
					owner.update_law_history(usr)
		if("delete_law")
			var/index = text2num(params["index"])
			var/type = params["type"]
			if(owner == usr && !is_special_character(owner) && !is_admin(usr))
				message_admins("Warning: Non-antag silicon and non-admin[usr] attempted to delete one of their laws!")
				return
			if(type == "devil" && owner.laws.devil.len >= index)
				if(!is_admin(usr)) // Assume that they're owner from here.
					to_chat(usr, span_warning("You can't remove your own devil laws."))
					return
				if(is_special_character(owner))
					to_chat(usr, span_warning("This silicon is an antag. Remove their status if you want to delete their devil laws."))
					return
				log_admin("[usr] has deleted a devil law of [owner]: '[owner.laws.devil[index]]'")
				message_admins("[usr] has deleted a devil law of [owner]: '[owner.laws.devil[index]]'")
				owner.remove_devil_law(index)
				owner.update_law_history(usr)
			if(type == "zeroth" && !isnull(owner.laws.zeroth))
				if(!is_admin(usr)) // Assume that they're owner from here.
					to_chat(usr, span_warning("You can't remove your own zeroth law."))
					return
				if(is_special_character(owner))
					to_chat(usr, span_warning("This silicon is an antag. Remove their status if you want to delete their zeroth law."))
					return
				log_admin("[usr] has deleted the zeroth law of [owner]: '[owner.laws.zeroth]'")
				message_admins("[usr] has deleted the zeroth law of [owner]: '[owner.laws.zeroth]'")
				owner.clear_zeroth_law()
				owner.update_law_history(usr)
			if(type == "hacked" && owner.laws.hacked.len >= index)
				log_admin("[usr] has deleted an hacked law of [owner]: '[owner.laws.hacked[index]]'")
				message_admins("[usr] has deleted an hacked law of [owner]: '[owner.laws.hacked[index]]'")
				owner.remove_hacked_law(index)
				owner.update_law_history(usr)
			if(type == "ion" && owner.laws.ion.len >= index)
				log_admin("[usr] has deleted an ion law of [owner]: '[owner.laws.ion[index]]'")
				message_admins("[usr] has deleted an ion law of [owner]: '[owner.laws.ion[index]]'")
				owner.remove_ion_law(index)
				owner.update_law_history(usr)
			if(type == "inherent" && owner.laws.inherent.len >= index)
				log_admin("[usr] has deleted an inherent law of [owner]: '[owner.laws.inherent[index]]'")
				message_admins("[usr] has deleted an inherent law of [owner]: '[owner.laws.inherent[index]]'")
				owner.remove_inherent_law(index)
				owner.update_law_history(usr)
			if(type == "supplied" && owner.laws.supplied.len >= index && length(owner.laws.supplied[index]) > 0 )
				log_admin("[usr] has deleted an supplied law of [owner]: '[owner.laws.supplied[index]]'")
				message_admins("[usr] has deleted a supplied law of [owner]: '[owner.laws.supplied[index]]'")
				owner.remove_supplied_law(index)
				owner.update_law_history(usr)
		if("law_channel")
			if(params["law_channel"] == "None")
				owner.radiomod = ""
				owner.radiomodname = null
			else if(params["law_channel"] == "Common")
				owner.radiomod = ";"
				owner.radiomodname = params["law_channel"]
			else if(params["law_channel"] == "Binary")
				owner.radiomod = ":b"
				owner.radiomodname = params["law_channel"]
			else if(params["law_channel"] == "Holopad")
				owner.radiomod = ":h"
				owner.radiomodname = params["law_channel"]
			else if(params["law_channel"] in owner.radio.channels)
				for(var/key in GLOB.department_radio_keys)
					if(GLOB.department_radio_keys[key] == params["law_channel"])
						owner.radiomod = ":" + key
						owner.radiomodname = params["law_channel"]
						break
		if("state_laws")
			owner.statelaws()
		if("notify_laws")
			owner.show_laws() // If they're an AI, they'll also notify their connected borgs.
			if(usr != owner)
				to_chat(usr, span_notice("Laws displayed."))
		if("add_zeroth_law")
			if(owner == usr && !is_special_character(owner) )
				message_admins("Warning: Non-antag silicon [usr] attempted to give themselves a zeroth law!")
				return
			if(is_admin(usr) && is_special_character(owner))
				to_chat(usr, span_warning("This silicon is an antag. Remove their status if you want to give them a zeroth law."))
				return
			if(zeroth_law && !owner.laws.zeroth && is_admin(usr))
				log_admin("[usr] has added an zeroth law to [owner]: '[zeroth_law]'")
				message_admins("[usr] has deleted a zeroth law to [owner]: '[zeroth_law]'")
				owner.set_zeroth_law(zeroth_law)
				owner.update_law_history(usr)
		if("add_hacked_law")
			if(owner == usr && !is_special_character(owner) )
				message_admins("Warning: Non-antag silicon [usr] attempted to give themselves a hacked law!")
				return
			if(hacked_law)
				log_admin("[usr] has added a hacked law to [owner]: '[hacked_law]'")
				message_admins("[usr] has deleted a hacked law to [owner]: '[hacked_law]'")
				owner.add_hacked_law(hacked_law)
				owner.update_law_history(usr)
		if("add_ion_law")
			if(owner == usr && !is_special_character(owner) )
				message_admins("Warning: Non-antag silicon [usr] attempted to give themselves an ion law!")
				return
			if(ion_law)
				log_admin("[usr] has added an ion law to [owner]: '[ion_law]'")
				message_admins("[usr] has deleted an ion law to [owner]: '[ion_law]'")
				owner.add_ion_law(ion_law)
				owner.update_law_history(usr)
		if("add_inherent_law")
			if(owner == usr && !is_special_character(owner) )
				message_admins("Warning: Non-antag silicon [usr] attempted to give themselves an inherent law!")
				return
			if(inherent_law)
				log_admin("[usr] has added an inherent law to [owner]: '[inherent_law]'")
				message_admins("[usr] has deleted an inherent law to [owner]: '[inherent_law]'")
				owner.add_inherent_law(inherent_law)
		if("add_supplied_law")
			if(owner == usr && !is_special_character(owner) )
				message_admins("Warning: Non-antag silicon [usr] attempted to give themselves a supplied law!")
				return
			if(supplied_law && supplied_law_position >= 15 && MIN_SUPPLIED_LAW_NUMBER <= MAX_SUPPLIED_LAW_NUMBER)
				log_admin("[usr] has added a supplied law to [owner] at position [supplied_law_position]: '[inherent_law]'")
				message_admins("[usr] has added a supplied law to [owner] at position [supplied_law_position]: '[inherent_law]'")
				owner.add_supplied_law(supplied_law_position, supplied_law)
		if("change_zeroth_law")
			var/new_law = sanitize(input("Enter new law Zero. Leaving the field blank will cancel the edit.", "Edit Law", zeroth_law))
			if(new_law && new_law != zeroth_law && (!..()))
				zeroth_law = new_law
		if("change_hacked_law")
			var/new_law = sanitize(input("Enter new hacked law. Leaving the field blank will cancel the edit.", "Edit Law", hacked_law))
			if(new_law && new_law != hacked_law && (!..()))
				hacked_law = new_law
		if("change_ion_law")
			var/new_law = sanitize(input("Enter new ion law. Leaving the field blank will cancel the edit.", "Edit Law", ion_law))
			if(new_law && new_law != ion_law && (!..()))
				ion_law = new_law
		if("change_inherent_law")
			var/new_law = sanitize(input("Enter new inherent law. Leaving the field blank will cancel the edit.", "Edit Law", inherent_law))
			if(new_law && new_law != inherent_law && (!..()))
				inherent_law = new_law
		if("change_supplied_law")
			var/new_law = sanitize(input("Enter new supplied law. Leaving the field blank will cancel the edit.", "Edit Law", supplied_law))
			if(new_law && new_law != supplied_law && (!..()))
				supplied_law = new_law
		if("change_supplied_law_position")
			var/new_position = input(usr, "Enter new supplied law position between [MIN_SUPPLIED_LAW_NUMBER] and [MAX_SUPPLIED_LAW_NUMBER].", "Law Position", supplied_law_position) as num|null
			if(isnum(new_position) && (!..()))
				supplied_law_position = clamp(new_position, MIN_SUPPLIED_LAW_NUMBER, MAX_SUPPLIED_LAW_NUMBER)
		if("transfer_laws")
			if(owner == usr && !is_special_character(owner) )
				message_admins("Warning: Non-antag silicon [usr] attempted to transfer themselves a lawset!")
				return
			var/transfer_id = params["id"]
			var/list/datum/ai_laws/law_list = (is_admin(usr) ? admin_laws : player_laws)
			for(var/datum/ai_laws/law_set in law_list)
				if(law_set.id == transfer_id)
					log_admin("[usr] has transfered the [law_set.name] laws to [owner].")
					message_admins("[usr] has transfered the [law_set.name] laws to [owner].")
					var/lawtype = law_set.lawid_to_type(transfer_id) 
					var/datum/ai_laws/temp_laws = new lawtype
					owner.set_inherent_laws(temp_laws.inherent)
					current_view = 0
					break
	
/datum/law_manager/ui_data(mob/user)
	var/list/data = list()

	data["isAI"] = isAI(owner)
	if(istype(owner, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = owner
		data["isConnected"] = R.connected_ai ? sanitize(R.connected_ai.name) : null
		data["hasLawsync"] = R.lawupdate ? R.lawupdate : FALSE
	else
		data["isConnected"] = FALSE
		data["hasLawsync"] = FALSE

	// Gives the power to add/delete/edit their laws.
	data["isAntag"] = is_special_character(owner)
	data["isAdmin"] = FALSE // is_admin(user)
	data["view"] = current_view

	// For "Laws" section
	handle_laws(data, owner.laws)

	// For "Add Laws" section
	data["zeroth_law"] = zeroth_law
	data["hacked_law"] = hacked_law
	data["ion_law"] = ion_law
	data["inherent_law"] = inherent_law
	data["supplied_law"] = supplied_law
	data["supplied_law_position"] = supplied_law_position

	// For "Statement Settings" section
	handle_channels(data)

	data["law_sets"] = handle_lawsets(data["isAdmin"] ? admin_laws : player_laws)
	
	return data

/// Sets the data with a lawset.
/datum/law_manager/proc/handle_laws(list/data, datum/ai_laws/laws)
	data["devil"] = list()
	for(var/index = 1, index <= laws.devil.len, index++)
		data["devil"][++data["devil"].len] = list("law" = laws.devil[index], "index" = index, "indexdisplay" = 666,  "state" = (laws.devilstate.len >= index ? laws.devilstate[index] : 0), "type" = "devil")
	data["has_devil"] = data["devil"].len

	data["zeroth"] = list()
	if(laws.zeroth)
		data["zeroth"][++data["zeroth"].len] = list("law" = laws.zeroth, "index" = 0, "indexdisplay" = 0, "state" = (!isnull(laws.zerothstate) ? laws.zerothstate : 0), "type" = "zeroth")
	data["has_zeroth"] = data["zeroth"].len

	data["hacked"] = list()
	for(var/index = 1, index <= laws.hacked.len, index++)
		data["hacked"][++data["hacked"].len] = list("law" = laws.hacked[index], "index" = index, "indexdisplay" = ionnum(), "state" = (laws.hackedstate.len >= index ? laws.hackedstate[index] : 1 ), "type" = "hacked")
	data["has_hacked"] = data["hacked"].len

	data["ion"] = list()
	for(var/index = 1, index <= laws.ion.len, index++)
		data["ion"][++data["ion"].len] = list("law" = laws.ion[index], "index" = index, "indexdisplay" = ionnum(), "state" = (laws.ionstate.len >= index ? laws.ionstate[index] : 1 ), "type" = "ion")
	data["has_ion"] = data["ion"].len

	data["inherent"] = list()
	for(var/index = 1, index <= laws.inherent.len, index++)
		data["inherent"][++data["inherent"].len] = list("law" = laws.inherent[index], "index" = index, "indexdisplay" = index, "state" = (laws.inherentstate.len >= index ? laws.inherentstate[index] : 1 ), "type" = "inherent")
	data["has_inherent"] = data["inherent"].len

	data["supplied"] = list()
	for(var/index = 1, index <= laws.supplied.len, index++)
		if(length(laws.supplied[index]) > 0)
			data["supplied"][++data["supplied"].len] = list("law" = laws.supplied[index], "index" = index, "indexdisplay" = index, "state" = (laws.suppliedstate.len >= index ? laws.suppliedstate[index] : 1 ), "type" = "supplied")
	data["has_supplied"] = data["supplied"].len

/datum/law_manager/proc/handle_channels(list/data)
	var/list/channels = list()

	channels[++channels.len] = list("channel" = "None")
	for(var/ch_name in owner.radio.channels)
		channels[++channels.len] = list("channel" = ch_name)
	channels[++channels.len] = list("channel" = "Common")
	channels[++channels.len] = list("channel" = "Holopad")
	channels[++channels.len] = list("channel" = "Binary")

	data["channels"] = channels
	data["channel"] = "None"
	if(owner.radiomodname) // TODO: Add check if they actually have access to the radiomodname.
		data["channel"] = owner.radiomodname

/datum/law_manager/proc/handle_lawsets(list/datum/ai_laws/laws)
	var/list/lawsets_data = list()
	for(var/datum/ai_laws/lawset in laws)
		var/list/law_data = list()
		handle_laws(law_data, lawset)
		lawsets_data[++lawsets_data.len] = list("id" = lawset.id, "name" = lawset.name, "header" = lawset.law_header, "laws" = law_data)
	return lawsets_data
