/datum/job/cyborg
	title = "Cyborg"
	flag = CYBORG
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 2
	supervisors = "your laws and the AI"	//Nodrak
	selection_color = "#ddffdd"
	minimal_player_age = 21
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW
	alt_titles = list("Droid", "Robot", "Automaton")

	display_order = JOB_DISPLAY_ORDER_CYBORG

	changed_maps = list("EclipseStation", "OmegaStation")

/datum/job/cyborg/proc/EclipseStationChanges()
	spawn_positions = 3

/datum/job/cyborg/proc/OmegaStationChanges()
	spawn_positions = 1

/datum/job/cyborg/equip(mob/living/carbon/human/H, visualsOnly = FALSE, announce = TRUE, latejoin = FALSE, datum/outfit/outfit_override = null, client/preference_source = null)
	if(visualsOnly)
		CRASH("dynamic preview is unsupported")
	return H.Robotize(FALSE, latejoin)

/datum/job/cyborg/after_spawn(mob/living/silicon/robot/R, mob/M)
	R.updatename(M.client)
	R.gender = NEUTER

/datum/job/cyborg/radio_help_message(mob/M)
	to_chat(M, "<b>Prefix your message with :b to speak with other cyborgs and AI.</b>")

/datum/job/cyborg/give_donor_stuff(mob/living/silicon/robot/H, mob/M)
	if(!istype(H))
		return

	var/client/C = M.client
	if(!C)
		C = H.client
		if(!C)
			return // nice

	if(!is_donator(C))
		return

	if(C.prefs.donor_hat && C.prefs.borg_hat)
		var/type = C.prefs.donor_hat
		if(type)
			var/obj/item/hat = new type()
			if(istype(hat) && hat.slot_flags & ITEM_SLOT_HEAD && H.hat_offset != INFINITY && !is_type_in_typecache(hat, H.blacklisted_hats))
				H.place_on_head(hat)

