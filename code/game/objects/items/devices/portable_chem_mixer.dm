/obj/item/storage/portable_chem_mixer
	name = "portable chemical mixer"
	desc = "A portable device that dispenses and mixes chemicals using reagents inside containers. The letters 'S&T' are imprinted on the side."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "portablechemicalmixer_open"
	worn_icon_state = "portable_chem_mixer"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BELT
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'
	custom_price = PAYCHECK_CREW * 10
	custom_premium_price = PAYCHECK_CREW * 14

	var/obj/item/reagent_containers/beaker = null ///Creating an empty slot for a beaker that can be added to dispense into
	var/amount = 30 ///The amount of reagent that is to be dispensed currently

	var/list/dispensable_reagents = list() ///List in which all currently dispensable reagents go

	///If the UI has the pH meter shown
	var/show_ph = TRUE

/obj/item/storage/portable_chem_mixer/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 50
	atom_storage.set_holdable(list(
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/cup/glass/waterbottle,
		/obj/item/reagent_containers/condiment,
	))

	register_context()

/obj/item/storage/portable_chem_mixer/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/item/storage/portable_chem_mixer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "[atom_storage.locked ? "Unl" : "L"]ock storage"
	if(atom_storage.locked && !QDELETED(beaker))
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Eject beaker"

	if(!isnull(held_item))
		if (!atom_storage.locked  || \
			(held_item.item_flags & ABSTRACT) || \
			(held_item.flags_1 & HOLOGRAM_1) || \
			!is_reagent_container(held_item) || \
			!held_item.is_open_container() \
		)
			return CONTEXTUAL_SCREENTIP_SET
		context[SCREENTIP_CONTEXT_LMB] = "Insert beaker"

	return CONTEXTUAL_SCREENTIP_SET

/obj/item/storage/portable_chem_mixer/examine(mob/user)
	. = ..()
	if(!atom_storage.locked)
		. += span_notice("Use [EXAMINE_HINT("Ctrl Click")] to lock in order to use its interface.")
	else
		. += span_notice("Its storage is locked, use [EXAMINE_HINT("Ctrl Click")] to unlock it.")
	if(QDELETED(beaker))
		. += span_notice("A beaker can be inserted to dispense reagents after it is locked.")
	else
		. += span_notice("The stored beaker can be ejected with [EXAMINE_HINT("Alt Click")].")

/obj/item/storage/portable_chem_mixer/ex_act(severity, target)
	if(severity > EXPLODE_LIGHT)
		return ..()

/obj/item/storage/portable_chem_mixer/attackby(obj/item/I, mob/user, params)
	if (is_reagent_container(I) && !(I.item_flags & ABSTRACT) && I.is_open_container() && atom_storage.locked)
		var/obj/item/reagent_containers/B = I
		. = TRUE //no afterattack
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		ui_interact(user)
		return
	return ..()

/**
 * Updates the contents of the portable chemical mixer
 *
 * A list of dispensable reagents is created by iterating through each source beaker in the portable chemical beaker and reading its contents
 */
/obj/item/storage/portable_chem_mixer/proc/update_contents()
	PRIVATE_PROC(TRUE)

	dispensable_reagents.Cut()

	//MONKESTATION EDIT STAT
	for (var/obj/item/reagent_containers/B in contents)
		if(beaker && B == beaker)
			continue
		for(var/datum/reagent/reagent in B.reagents.reagent_list)
			var/key = reagent.type
			if (!(key in dispensable_reagents))
				dispensable_reagents[key] = list()
				dispensable_reagents[key]["reagents"] = list()
			dispensable_reagents[key]["reagents"] += B.reagents
	//MONKESTATION EDIT END
	return

/obj/item/storage/portable_chem_mixer/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == beaker)
		beaker = null

/obj/item/storage/portable_chem_mixer/update_icon_state()
	if(!atom_storage.locked)
		icon_state = "portablechemicalmixer_open"
		return ..()
	if(!QDELETED(beaker))
		icon_state = "portablechemicalmixer_full"
		return ..()
	icon_state = "portablechemicalmixer_empty"
	return ..()


/obj/item/storage/portable_chem_mixer/AltClick(mob/living/user)
	if(!atom_storage.locked)
		balloon_alert(user, "lock first to use alt eject!")
		return ..()
	if(!can_interact(user) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	replace_beaker(user)

/obj/item/storage/portable_chem_mixer/CtrlClick(mob/living/user)
	if(atom_storage.locked == STORAGE_FULLY_LOCKED)
		atom_storage.locked = STORAGE_NOT_LOCKED
	else
		atom_storage.locked = STORAGE_FULLY_LOCKED
		atom_storage.hide_contents(user)
		update_contents()

	to_chat(user, span_notice("You [atom_storage.locked ? "close" : "open"] the chemical storage of \the [src]."))
	update_appearance()
	playsound(src, 'sound/items/screwdriver2.ogg', 50)
	return

/**
 * Replaces the beaker of the portable chemical mixer with another beaker, or simply adds the new beaker if none is in currently
 *
 * Checks if a valid user and a valid new beaker exist and attempts to replace the current beaker in the portable chemical mixer with the one in hand. Simply places the new beaker in if no beaker is currently loaded
 * Arguments:
 * * mob/living/user - The user who is trying to exchange beakers
 * * obj/item/reagent_containers/new_beaker - The new beaker that the user wants to put into the device
 */
/obj/item/storage/portable_chem_mixer/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	PRIVATE_PROC(TRUE)

	if(!user)
		return

	if(!QDELETED(beaker))
		user.put_in_hands(beaker)
	if(!QDELETED(new_beaker))
		if(user.transferItemToLoc(new_beaker, src))
			beaker = new_beaker
			to_chat(user, span_notice("You add \the [new_beaker] to \the [src]."))
	update_appearance()

/obj/item/storage/portable_chem_mixer/attack_hand(mob/user, list/modifiers)
	if (loc != user)
		return ..()
	else
		if (!atom_storage.locked)
			return ..()
	if(atom_storage?.locked)
		ui_interact(user)
		return

/obj/item/storage/portable_chem_mixer/attack_self(mob/user)
	if(loc == user)
		if (atom_storage.locked)
			ui_interact(user)
/*MONKESTATION REMOVAL START
			return
		else
			to_chat(user, span_notice("It looks like this device can be worn as a belt for increased accessibility. A label indicates that the 'CTRL'-button on the device may be used to close it after it has been filled with bottles and beakers of chemicals."))
			return
	return
MONKESTATION REMOVAL END */

/obj/item/storage/portable_chem_mixer/MouseDrop(obj/over_object)
	. = ..()
	if(ismob(loc))
		var/mob/M = loc
		if(!M.incapacitated() && istype(over_object, /atom/movable/screen/inventory/hand))
			var/atom/movable/screen/inventory/hand/H = over_object
			M.putItemFromInventoryInHandIfPossible(src, H.held_index)

/obj/item/storage/portable_chem_mixer/ui_status(mob/user, datum/ui_state/state)
	if(loc != user)
		return UI_CLOSE
	if(!atom_storage.locked) //MONKESTATION ADDITION
		return UI_DISABLED
	return ..()

/obj/item/storage/portable_chem_mixer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortableChemMixer", name)
		ui.open()

		var/is_hallucinating = FALSE
		if(isliving(user))
			var/mob/living/living_user = user
			is_hallucinating = !!living_user.has_status_effect(/datum/status_effect/hallucination)
		ui.set_autoupdate(!is_hallucinating) // to not ruin the immersion by constantly changing the fake chemicals

/obj/item/storage/portable_chem_mixer/ui_data(mob/user)
	var/list/data = list()
	data["amount"] = amount
	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null
	data["beakerTransferAmounts"] = beaker ? list(1,5,10,30,50,100) : null
	data["showpH"] = show_ph
	var/chemicals[0]
	var/is_hallucinating = FALSE
	if(isliving(user))
		var/mob/living/living_user = user
		is_hallucinating = !!living_user.has_status_effect(/datum/status_effect/hallucination)

	for(var/datum/reagent/reagent_type as anything in dispensable_reagents)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[reagent_type]
		if(temp)
			var/chemname = temp.name
			var/total_volume = 0
			//MONKESTATION EDIT START
			for (var/datum/reagents/rs in dispensable_reagents[reagent_type]["reagents"])
				var/datum/reagent/RG = rs.has_reagent(reagent_type)
				if(RG)
					total_volume += RG.volume
			if(is_hallucinating && prob(5))
				chemname = "[pick_list_replacements("hallucination.json", "chemicals")]"
			chemicals.Add(list(list("title" = chemname, "id" = ckey(temp.name), "volume" = total_volume, "pH" = reagent_type.ph)))
			//MONKESTATION EDIT END
	data["chemicals"] = chemicals
	var/beakerContents[0]
	if(!QDELETED(beaker))
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			var/chem_name = R.name
			if(istype(R, /datum/reagent/ammonia/urine) && user.client?.prefs.read_preference(/datum/preference/toggle/prude_mode))
				chem_name = "Ammonia?"
			beakerContents.Add(list(list("name" = chem_name, "id" = ckey(R.name), "volume" = R.volume, "pH" = R.ph))) // list in a list because Byond merges the first list...
		data["beakerCurrentpH"] = round(beaker.reagents.ph, 0.01)
	data["beakerContents"] = beakerContents

	return data

/obj/item/storage/portable_chem_mixer/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("amount")
			var/target = text2num(params["target"])
			amount = target
			. = TRUE
		if("dispense")
			var/datum/reagent/reagent = GLOB.name2reagent[params["reagent"]]
			if(isnull(reagent))
				return

			if(!QDELETED(beaker))
				var/datum/reagents/R = beaker.reagents
				var/actual = min(amount, 1000, R.maximum_volume - R.total_volume)
				for (var/datum/reagents/source in dispensable_reagents[reagent]["reagents"])
					actual -= source.trans_id_to(beaker, reagent, min(source.total_volume, actual)) //MONKESTATION EDIT
					if(actual <= 0)
						break
			. = TRUE
		if("remove")
			var/amount = text2num(params["amount"])
			beaker.reagents.remove_all(amount)
			. = TRUE
		if("eject")
			replace_beaker(usr)
			. = TRUE
