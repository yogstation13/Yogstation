/datum/job/cyborg
	title = "Cyborg"
	description = "Assist the crew, follow your laws, obey your AI."
	flag = CYBORG
	orbit_icon = "robot"
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

	departments_list = list(
		/datum/job_department/silicon,
	)

	smells_like = "inorganic indifference"

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

	if(C.prefs.read_preference(/datum/preference/toggle/borg_hat))
		var/datum/donator_gear/donor_hat_datum = GLOB.donator_gear.item_names[C.prefs.read_preference(/datum/preference/choiced/donor_hat)]
		if(donor_hat_datum)
			var/donor_hat_type = donor_hat_datum.unlock_path
			if (!!donor_hat_datum.ckey && (lowertext(C.ckey) != lowertext(donor_hat_datum.ckey)))
				to_chat(C, span_warning("Your selected donor hat is restricted to [donor_hat_datum.ckey]."))
			else if (donor_hat_type)
				var/obj/item/hat = new donor_hat_type()
				if(istype(hat) && hat.slot_flags & ITEM_SLOT_HEAD && H.hat_offset != INFINITY && !is_type_in_typecache(hat, H.blacklisted_hats))
					H.place_on_head(hat)
