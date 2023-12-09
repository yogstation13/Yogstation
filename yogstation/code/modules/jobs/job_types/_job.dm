/datum/job/proc/give_donor_stuff(mob/living/H, mob/M)
	var/client/C = M.client
	if(!C)
		C = H.client
		if(!C)
			return // nice

	if(!is_donator(C))
		return

	if(C.prefs.read_preference(/datum/preference/toggle/purrbation))
		purrbation_toggle_onlyhumans(H)

	var/datum/donator_gear/donor_hat_datum = GLOB.donator_gear.item_names[C.prefs.read_preference(/datum/preference/choiced/donor_hat)]
	if(donor_hat_datum)
		var/donor_hat_type = donor_hat_datum.unlock_path
		if (!!donor_hat_datum.ckey && (lowertext(C.ckey) != lowertext(donor_hat_datum.ckey)))
			to_chat(C, span_warning("Your selected donor hat is restricted to [donor_hat_datum.ckey]."))
		else if (donor_hat_type)
			var/obj/hat = new donor_hat_type()
			if(!H.equip_to_appropriate_slot(hat))
				var/obj/item/storage/backpack/BP = locate(/obj/item/storage/backpack) in H.get_all_contents()
				if(BP)
					hat.forceMove(BP)

	var/obj/item/storage/backpack/BP = locate(/obj/item/storage/backpack) in H.get_all_contents()
	if(BP)
		var/datum/donator_gear/donor_item_datum = GLOB.donator_gear.item_names[C.prefs.read_preference(/datum/preference/choiced/donor_item)]
		if (donor_item_datum)
			var/donor_item_type = donor_item_datum.unlock_path
			if (!!donor_item_datum.ckey && (lowertext(C.ckey) != lowertext(donor_item_datum.ckey)))
				to_chat(C, span_warning("Your selected donor item is restricted to [donor_item_datum.ckey]."))
			else if (donor_item_type)
				var/obj/item = new donor_item_type()
				if(!H.put_in_hands(item))
					item.forceMove(BP)
		var/datum/donator_gear/donor_plush_datum = GLOB.donator_gear.item_names[C.prefs.read_preference(/datum/preference/choiced/donor_plush)]
		if (donor_plush_datum)
			var/donor_plush_type = donor_plush_datum.unlock_path
			if (!!donor_plush_datum.ckey && (lowertext(C.ckey) != lowertext(donor_plush_datum.ckey)))
				to_chat(C, span_warning("Your selected donor item is restricted to [donor_plush_datum.ckey]."))
			else if (donor_plush_type)
				var/obj/item = new donor_plush_type()
				if(!H.put_in_hands(item))
					item.forceMove(BP)

	switch(C.prefs.read_preference(/datum/preference/choiced/donor_pda))
		if(PDA_COLOR_TRANSPARENT)
			var/obj/item/modular_computer/tablet/pda/PDA = locate(/obj/item/modular_computer/tablet/pda) in H.get_all_contents()
			if(PDA)
				PDA.finish_color = "glass"
				PDA.update_appearance(UPDATE_ICON)
		if(PDA_COLOR_PIPBOY)
			var/obj/item/modular_computer/tablet/pda/PDA = locate(/obj/item/modular_computer/tablet/pda) in H.get_all_contents()
			if(PDA)
				PDA.finish_color = "pipboy"
				PDA.slot_flags |= ITEM_SLOT_GLOVES
				PDA.update_appearance(UPDATE_ICON)
		if(PDA_COLOR_RAINBOW)
			var/obj/item/modular_computer/tablet/pda/PDA = locate(/obj/item/modular_computer/tablet/pda) in H.get_all_contents()
			if(PDA)
				PDA.finish_color = "rainbow"
				PDA.update_appearance(UPDATE_ICON)

/datum/job/proc/give_cape(mob/living/H, mob/M)
	var/client/C = M.client
	if(!C)
		C = H.client
		if(!C)
			return

	if(issilicon(H) || issilicon(M))
		return

	var/cape_id = C.prefs.read_preference(/datum/preference/choiced/skillcape)
	if(cape_id == "None")
		return

	var/datum/skillcape/cape_datum = GLOB.skillcapes[cape_id]
	if (cape_id == "max")
		for(var/id in GLOB.skillcapes)
			var/datum/skillcape/cape_check = GLOB.skillcapes[id]
			if(!cape_check.job)
				continue

			if(C.prefs.exp[cape_check.job] < cape_check.minutes)
				to_chat(M, span_warning("You do not meet the requirement for your selected skillcape"))
				return

	else
		if(cape_datum.job && C.prefs.exp[cape_datum.job] < cape_datum.minutes)
			to_chat(M, span_warning("You do not meet the requirement for your selected skillcape"))
			return

	var/type = cape_datum.path
	var/obj/item/clothing/neck/skillcape/cape = new type(get_turf(H))
	if(!H.equip_to_appropriate_slot(cape))
		H.put_in_hands(cape)

/datum/job/proc/give_map_flare(mob/living/H, mob/M)
	var/client/C = M.client
	if(!C)
		C = H.client
		if(!C)
			return
	
	var/spawn_map = C.prefs.read_preference(/datum/preference/toggle/spawn_map)
	var/spawn_flare = C.prefs.read_preference(/datum/preference/toggle/spawn_flare)

	var/obj/item/storage/backpack/BP = locate(/obj/item/storage/backpack) in H.get_all_contents()
	if(BP)
		var/obj/item/storage/box/box = locate(/obj/item/storage/box) in BP
		if(spawn_map)
			var/obj/item/map/station/map = new get_turf(H)
			if(box)
				map.forceMove(box)
			else
				map.forceMove(BP)
		if(spawn_flare)
			var/obj/item/flashlight/flare/emergency/flare = new get_turf(H)
			if(box)
				flare.forceMove(box)
			else
				flare.forceMove(BP)

/datum/job/proc/give_clerk_choice(mob/living/H, mob/M)
	try
		var/choice

		var/client/C = M.client
		if(!C)
			C = H.client
			if(!C)
				choice = "Random"

		if(C)
			choice = C.prefs.read_preference(/datum/preference/choiced/clerk_choice)

		if(choice != "Random")
			var/clerk_sanitize = FALSE
			for(var/A in GLOB.potential_box_clerk)
				if(choice == A)
					clerk_sanitize = TRUE
					break

			if(!clerk_sanitize)
				choice = "Random"
		
		if(choice == "Random")
			choice = pick(GLOB.potential_box_clerk)
		
		var/datum/map_template/template = SSmapping.station_room_templates[choice]

		if(!template)
			log_game("clerk FAILED TO LOAD!!! [C.ckey]/([M.name]) attempted to load [choice]. Loading Clerk Box as backup.")
			message_admins("clerk FAILED TO LOAD!!! [C.ckey]/([M.name]) attempted to load [choice]. Loading Clerk Box as backup.")
			template = SSmapping.station_room_templates["Clerk Box"]

		for(var/obj/effect/landmark/stationroom/box/clerk/B in GLOB.landmarks_list)
			template.load(B.loc, centered = FALSE)
			qdel(B)
	catch(var/exception/e)
		message_admins("RUNTIME IN GIVE_CLERK_CHOICE")
		spawn_clerk()
		throw e



/datum/job/proc/give_chapel_choice(mob/living/H, mob/M)
	try
		var/choice

		var/client/C = M.client
		if(!C)
			C = H.client
			if(!C)
				choice = "Random"

		if(C)
			choice = C.prefs.read_preference(/datum/preference/choiced/chapel_choice)

		if(choice != "Random")
			var/chapel_sanitize = FALSE
			for(var/A in GLOB.potential_box_chapels)
				if(choice == A)
					chapel_sanitize = TRUE
					break

			if(!chapel_sanitize)
				choice = "Random"

		if(choice == "Random")
			choice = pick(GLOB.potential_box_chapels)

		var/datum/map_template/template = SSmapping.station_room_templates[choice]

		if(!template)
			log_game("chapel FAILED TO LOAD!!! [C.ckey]/([M.name]) attempted to load [choice]. Loading chapel 1 as backup.")
			message_admins("chapel FAILED TO LOAD!!! [C.ckey]/([M.name]) attempted to load [choice]. Loading chapel 1 as backup.")
			template = SSmapping.station_room_templates["Chapel 1"]

		for(var/obj/effect/landmark/stationroom/box/chapel/B in GLOB.landmarks_list)
			template.load(B.loc, centered = FALSE)
			qdel(B)
	catch(var/exception/e)
		message_admins("RUNTIME IN GIVE_CHAPEL_CHOICE")
		spawn_chapel()
		throw e
