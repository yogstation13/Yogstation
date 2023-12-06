
/mob/living/carbon/human/restrained(ignore_grab)
	. = ((wear_suit && wear_suit.breakouttime) || ..())


/mob/living/carbon/human/canBeHandcuffed()
	if(get_num_arms(FALSE) >= 2)
		return TRUE
	return FALSE

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(if_no_id = "No id", if_no_job = "No job", hand_first = TRUE)
	var/obj/item/card/id/id = get_idcard(hand_first)
	if(id)
		. = id.assignment
	else
		var/obj/item/pda/pda = wear_id
		if(istype(pda))
			. = pda.ownjob
		else
			return if_no_id
	if(!.)
		return if_no_job

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(if_no_id = "Unknown")
	var/obj/item/card/id/id = get_idcard(FALSE)
	if(id)
		return id.registered_name
	var/obj/item/pda/pda = wear_id
	var/obj/item/modular_computer/tablet/tablet = wear_id
	if(istype(pda))
		return pda.owner
	if(istype(tablet))
		return tablet.name
	return if_no_id

//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a separate proc as it'll be useful elsewhere
/mob/living/carbon/human/get_visible_name()
	var/face_name = get_face_name("")
	var/id_name = get_id_name("")
	if(name_override)
		return name_override
	if(face_name)
		if(id_name && (id_name != face_name))
			return "[face_name] (as [id_name])"
		return face_name
	if(id_name)
		return id_name
	return "Unknown"

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when Fluacided or when updating a human's name variable
/mob/living/carbon/human/proc/get_face_name(if_no_face="Unknown")
	if( wear_mask && (wear_mask.flags_inv&HIDEFACE) )	//Wearing a mask which hides our face, use id-name if possible
		return if_no_face
	if( head && (head.flags_inv&HIDEFACE) )
		return if_no_face		//Likewise for hats
	var/obj/item/bodypart/O = get_bodypart(BODY_ZONE_HEAD)
	if( !O || (HAS_TRAIT(src, TRAIT_DISFIGURED)) || (O.brutestate+O.burnstate)>2 || cloneloss>50 || !real_name )	//disfigured. use id-name if possible
		return if_no_face
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(if_no_id = "Unknown")
	var/obj/item/storage/wallet/wallet = wear_id
	var/obj/item/pda/pda = wear_id
	var/obj/item/card/id/id = wear_id
	var/obj/item/modular_computer/tablet/tablet = wear_id
	if(istype(wallet))
		id = wallet.front_id
	if(istype(id))
		. = id.registered_name
	else if(istype(pda))
		. = pda.owner
	else if(istype(tablet))
		var/obj/item/computer_hardware/card_slot/card_slot = tablet.all_components[MC_CARD]
		if(card_slot?.stored_card)
			. = card_slot.stored_card.registered_name
	if(!.)
		. = if_no_id	//to prevent null-names making the mob unclickable
	return

//Gets ID card from a human. If hand_first is false the one in the id slot is prioritized, otherwise inventory slots go first.
/mob/living/carbon/human/get_idcard(hand_first = TRUE)
	//Check hands
	var/obj/item/card/id/id_card
	var/obj/item/held_item
	held_item = get_active_held_item()
	if(held_item) //Check active hand
		id_card = held_item.GetID()
	if(!id_card) //If there is no id, check the other hand
		held_item = get_inactive_held_item()
		if(held_item)
			id_card = held_item.GetID()

	if(id_card)
		if(hand_first)
			return id_card
		else
			. = id_card

	//Check inventory slots
	if(wear_id)
		id_card = wear_id.GetID()
		if(id_card)
			return id_card
	else if(belt)
		id_card = belt.GetID()
		if(id_card)
			return id_card

/mob/living/carbon/human/get_id_in_hand()
	var/obj/item/held_item = get_active_held_item()
	if(!held_item)
		return
	return held_item.GetID()

/mob/living/carbon/human/IsAdvancedToolUser()
	if(HAS_TRAIT(src, TRAIT_MONKEYLIKE))
		return FALSE
	return TRUE//Humans can use guns and such

/mob/living/carbon/human/reagent_check(datum/reagent/R)
	return dna.species.handle_chemicals(R,src)
	// if it returns 0, it will run the usual on_mob_life for that reagent. otherwise, it will stop after running handle_chemicals for the species.


/mob/living/carbon/human/can_track(mob/living/user)
	if(wear_id && istype(wear_id.GetID(), /obj/item/card/id/syndicate))
		return 0
	if(istype(head, /obj/item/clothing/head))
		var/obj/item/clothing/head/hat = head
		if(hat.blockTracking)
			return 0

	return ..()

/mob/living/carbon/human/can_use_guns(obj/item/G)
	. = ..()

	if(G.trigger_guard == TRIGGER_GUARD_NORMAL)
		if(src.dna.check_mutation(HULK))
			to_chat(src, span_warning("Your meaty finger is much too large for the trigger guard!"))
			return FALSE
		if(HAS_TRAIT(src, TRAIT_NOGUNS))
			to_chat(src, span_warning("Your fingers don't fit in the trigger guard!"))
			return FALSE
	if(mind?.martial_art?.no_guns && !(G.type in mind?.martial_art?.gun_exceptions)) //great dishonor to famiry
		to_chat(src, span_warning(mind.martial_art.no_gun_message))
		return FALSE
	return .

/mob/living/carbon/human/proc/get_bank_account()
	RETURN_TYPE(/datum/bank_account)
	var/datum/bank_account/account
	var/obj/item/card/id/I = get_idcard()

	if(I && I.registered_account)
		account = I.registered_account
		return account

	return FALSE

/mob/living/carbon/human/get_policy_keywords()
	. = ..()
	. += "[dna.species.type]"

/mob/living/carbon/human/can_see_reagents()
	. = ..()
	if(.) //No need to run through all of this if it's already true.
		return
	if(isclothing(glasses) && (glasses.clothing_flags & SCAN_REAGENTS))
		return TRUE
	if(isclothing(head) && (head.clothing_flags & SCAN_REAGENTS))
		return TRUE
	if(isclothing(wear_mask) && (wear_mask.clothing_flags & SCAN_REAGENTS))
		return TRUE
	if(HAS_TRAIT(src, TRAIT_SEE_REAGENTS))
		return TRUE

/// When we're joining the game in [/mob/dead/new_player/proc/create_character], we increment our scar slot then store the slot in our mind datum.
/mob/living/carbon/human/proc/increment_scar_slot()
	var/check_ckey = ckey || client?.ckey
	if(!check_ckey || !mind || !client?.prefs.read_preference(/datum/preference/toggle/persistent_scars))
		return

	var/path = "data/player_saves/[check_ckey[1]]/[check_ckey]/scars.sav"
	var/index = mind.current_scar_slot_index
	if(!index)
		if(fexists(path))
			var/savefile/F = new /savefile(path)
			index = F["current_scar_index"] || 1
		else
			index = 1

	mind.current_scar_slot_index = (index % PERSISTENT_SCAR_SLOTS) + 1 || 1

/// For use formatting all of the scars this human has for saving for persistent scarring, returns a string with all current scars/missing limb amputation scars for saving or loading purposes
/mob/living/carbon/human/proc/format_scars()
	var/list/missing_bodyparts = get_missing_limbs()
	if(!all_scars && !length(missing_bodyparts))
		return
	var/scars = ""
	for(var/i in missing_bodyparts)
		var/datum/scar/scaries = new
		scars += "[scaries.format_amputated(i)]"
	for(var/i in all_scars)
		var/datum/scar/iter_scar = i
		if(!iter_scar.fake)
			scars += "[iter_scar.format()];"
	return scars

/// Takes a single scar from the persistent scar loader and recreates it from the saved data
/mob/living/carbon/human/proc/load_scar(scar_line, specified_char_index)
	var/list/scar_data = splittext(scar_line, "|")
	if(LAZYLEN(scar_data) != SCAR_SAVE_LENGTH)
		return // invalid, should delete
	var/version = text2num(scar_data[SCAR_SAVE_VERS])
	if(!version || version < SCAR_CURRENT_VERSION) // get rid of old scars
		return
	if(specified_char_index && (mind?.original_character_slot_index != specified_char_index))
		return
	var/obj/item/bodypart/the_part = get_bodypart("[scar_data[SCAR_SAVE_ZONE]]")
	var/datum/scar/scaries = new
	return scaries.load(the_part, scar_data[SCAR_SAVE_VERS], scar_data[SCAR_SAVE_DESC], scar_data[SCAR_SAVE_PRECISE_LOCATION], text2num(scar_data[SCAR_SAVE_SEVERITY]), text2num(scar_data[SCAR_SAVE_BIOLOGY]), text2num(scar_data[SCAR_SAVE_CHAR_SLOT]))

/// Read all the scars we have for the designated character/scar slots, verify they're good/dump them if they're old/wrong format, create them on the user, and write the scars that passed muster back to the file
/mob/living/carbon/human/proc/load_persistent_scars()
	if(!ckey || !mind?.original_character_slot_index || !client?.prefs.read_preference(/datum/preference/toggle/persistent_scars))
		return

	var/path = "data/player_saves/[ckey[1]]/[ckey]/scars.sav"
	var/loaded_char_slot = client.prefs.default_slot

	if(!loaded_char_slot || !fexists(path))
		return FALSE
	var/savefile/F = new /savefile(path)
	if(!F)
		return

	var/char_index = mind.original_character_slot_index
	var/scar_index = mind.current_scar_slot_index || F["current_scar_index"] || 1

	var/scar_string = F["scar[char_index]-[scar_index]"]
	var/valid_scars = ""

	for(var/scar_line in splittext(sanitize_text(scar_string), ";"))
		if(load_scar(scar_line, char_index))
			valid_scars += "[scar_line];"

	WRITE_FILE(F["scar[char_index]-[scar_index]"], sanitize_text(valid_scars))

/// Save any scars we have to our designated slot, then write our current slot so that the next time we call [/mob/living/carbon/human/proc/increment_scar_slot] (the next round we join), we'll be there
/mob/living/carbon/human/proc/save_persistent_scars(nuke=FALSE)
	if(!ckey || !mind?.original_character_slot_index || !client?.prefs.read_preference(/datum/preference/toggle/persistent_scars))
		return

	var/path = "data/player_saves/[ckey[1]]/[ckey]/scars.sav"
	var/savefile/F = new /savefile(path)
	var/char_index = mind.original_character_slot_index
	var/scar_index = mind.current_scar_slot_index || F["current_scar_index"] || 1

	if(nuke)
		WRITE_FILE(F["scar[char_index]-[scar_index]"], "")
		return

	for(var/k in all_wounds)
		var/datum/wound/iter_wound = k
		iter_wound.remove_wound() // so we can get the scars for open wounds

	var/valid_scars = format_scars()
	WRITE_FILE(F["scar[char_index]-[scar_index]"], sanitize_text(valid_scars))
	WRITE_FILE(F["current_scar_index"], sanitize_integer(scar_index))

/mob/living/carbon/human/get_biological_state()
	return dna.species.get_biological_state()

/mob/living/carbon/human/proc/get_punchdamagehigh()	//Gets the total maximum punch damage
	return dna.species.punchdamagehigh + physiology.punchdamagehigh_bonus

/mob/living/carbon/human/proc/get_punchdamagelow()	//Gets the total minimum punch damage
	return dna.species.punchdamagelow + physiology.punchdamagelow_bonus

/mob/living/carbon/human/proc/get_punchstunthreshold()	//Gets the total punch damage needed to knock down someone
	return dna.species.punchstunthreshold + physiology.punchstunthreshold_bonus

/// Fully randomizes everything according to the given flags.
/mob/living/carbon/human/proc/randomize_human_appearance(randomize_flags = ALL)
	var/datum/preferences/preferences = new

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (!preference.included_in_randomization_flags(randomize_flags))
			continue

		if (preference.is_randomizable())
			preferences.write_preference(preference, preference.create_random_value(preferences))

/proc/visually_duplicate_human(mob/living/carbon/human/copied_human_mob, dropdel = FALSE)
	if(!istype(copied_human_mob))
		return FALSE

	var/mob/living/carbon/human/new_human_mob = new copied_human_mob.type // in case it's a special type with special inits

	if(copied_human_mob.dna?.species)
		INVOKE_ASYNC(new_human_mob, TYPE_PROC_REF(/mob,set_species), new copied_human_mob.dna.species.type)
		new_human_mob.dna.features = LAZYCOPY(copied_human_mob.dna.features)

	new_human_mob.real_name = copied_human_mob.name
	new_human_mob.name = copied_human_mob.name
	new_human_mob.gender = copied_human_mob.gender
	new_human_mob.eye_color = copied_human_mob.eye_color
	var/obj/item/organ/eyes/organ_eyes = new_human_mob.getorgan(/obj/item/organ/eyes)
	if(organ_eyes)
		organ_eyes.eye_color = copied_human_mob.eye_color
		organ_eyes.old_eye_color = copied_human_mob.eye_color
	new_human_mob.hair_color = copied_human_mob.hair_color
	new_human_mob.facial_hair_color = copied_human_mob.facial_hair_color
	new_human_mob.skin_tone = copied_human_mob.skin_tone
	new_human_mob.hair_style = copied_human_mob.hair_style
	new_human_mob.facial_hair_style = copied_human_mob.facial_hair_style
	new_human_mob.underwear = copied_human_mob.underwear
	new_human_mob.undershirt = copied_human_mob.undershirt
	new_human_mob.socks = copied_human_mob.socks
	new_human_mob.update_body()
	new_human_mob.update_hair()
	new_human_mob.update_body_parts()

	// Clothes for humans
	if(copied_human_mob.w_uniform)
		visually_duplicate_and_equip_item(copied_human_mob.w_uniform, ITEM_SLOT_ICLOTHING, new_human_mob, dropdel)
	if(copied_human_mob.wear_suit)
		visually_duplicate_and_equip_item(copied_human_mob.wear_suit, ITEM_SLOT_OCLOTHING, new_human_mob, dropdel)
	if(copied_human_mob.s_store)
		visually_duplicate_and_equip_item(copied_human_mob.s_store, ITEM_SLOT_SUITSTORE, new_human_mob, dropdel)
	if(copied_human_mob.back)
		visually_duplicate_and_equip_item(copied_human_mob.back, ITEM_SLOT_BACK, new_human_mob, dropdel)
	if(copied_human_mob.belt)
		visually_duplicate_and_equip_item(copied_human_mob.belt, ITEM_SLOT_BELT, new_human_mob, dropdel)
	if(copied_human_mob.wear_mask)
		visually_duplicate_and_equip_item(copied_human_mob.wear_mask, ITEM_SLOT_MASK, new_human_mob, dropdel)
	if(copied_human_mob.wear_neck)
		visually_duplicate_and_equip_item(copied_human_mob.wear_neck, ITEM_SLOT_NECK, new_human_mob, dropdel)
	if(copied_human_mob.ears)
		visually_duplicate_and_equip_item(copied_human_mob.ears, ITEM_SLOT_EARS, new_human_mob, dropdel)
	if(copied_human_mob.glasses)
		visually_duplicate_and_equip_item(copied_human_mob.glasses, ITEM_SLOT_EYES, new_human_mob, dropdel)
	if(copied_human_mob.gloves)
		visually_duplicate_and_equip_item(copied_human_mob.gloves, ITEM_SLOT_GLOVES, new_human_mob, dropdel)
	if(copied_human_mob.shoes)
		visually_duplicate_and_equip_item(copied_human_mob.shoes, ITEM_SLOT_FEET, new_human_mob, dropdel)
	if(copied_human_mob.head)
		visually_duplicate_and_equip_item(copied_human_mob.head, ITEM_SLOT_HEAD, new_human_mob, dropdel)
	if(copied_human_mob.wear_id)
		visually_duplicate_and_equip_item(copied_human_mob.wear_id, ITEM_SLOT_ID, new_human_mob, dropdel)
		new_human_mob.sec_hud_set_ID()

	for(var/obj/item/implant/implant_instance in copied_human_mob.implants)
		var/obj/item/implant/implant_copy
		if(istype(implant_instance, /obj/item/implant/dusting/iaa))
			implant_copy = new /obj/item/implant/dusting/iaa/fake ()
		else 
			implant_copy = new implant_instance.type
		if(!implant_copy)
			continue //if somehow it doesn't create a copy, don't runtime
		implant_copy.implant(new_human_mob, null, TRUE)
		if(dropdel)
			QDEL_IN(implant_copy, 7 SECONDS)

	if(dropdel)
		for(var/organ in new_human_mob.internal_organs)
			QDEL_IN(organ, 7 SECONDS)

	copied_human_mob.sec_hud_set_implants()

	return new_human_mob

/proc/visually_duplicate_and_equip_item(obj/item/item_instance, slot, mob/living/carbon/human/new_human_mob, dropdel = FALSE)
	var/obj/item/item_copy = new item_instance.type

	// Update ID + HUD
	if(istype(item_instance, /obj/item/card/id))
		var/obj/item/card/id/id_copy = item_copy
		var/obj/item/card/id/id_instance = item_instance
		id_copy.registered_name = id_instance.registered_name
		id_copy.assignment = id_instance.assignment
		id_copy.originalassignment = id_instance.originalassignment

	// Update ID + HUD but if it's in a PDA
	if(istype(item_instance, /obj/item/modular_computer/tablet))
		var/obj/item/modular_computer/tablet/tablet_copy = item_copy
		var/obj/item/modular_computer/tablet/tablet_instance = item_instance
		tablet_copy.finish_color = tablet_instance.finish_color
		var/obj/item/computer_hardware/card_slot/card_slot = tablet_instance.all_components[MC_CARD]
		if(card_slot?.stored_card)
			var/obj/item/card/id/id_copy = new card_slot.stored_card.type
			var/obj/item/card/id/id_instance = card_slot.stored_card
			id_copy.registered_name = id_instance.registered_name
			id_copy.assignment = id_instance.assignment
			id_copy.originalassignment = id_instance.originalassignment
			var/obj/item/computer_hardware/card_slot/card_slot_copy = tablet_copy.all_components[MC_CARD]
			if(!card_slot_copy)
				card_slot_copy = new
				tablet_copy.install_component(card_slot_copy)
			id_copy.forceMove(card_slot_copy)
			card_slot_copy.stored_card = id_copy

			tablet_copy.update_label()


	// Update damaged clothing
	if(isclothing(item_instance))
		var/obj/item/clothing/cloth_copy = item_copy
		var/obj/item/clothing/cloth_instance = item_instance
		cloth_copy.damaged_clothes = cloth_instance.damaged_clothes

	// Swap the lights, don't want the seccies following our trail of light!
	if(dropdel && item_instance.light_on)
		item_instance.set_light_on(FALSE)
		item_copy.set_light_on(TRUE)

	// In case of chameleon clothes or otherwise
	item_copy.name = item_instance.name
	item_copy.icon = item_instance.icon
	item_copy.icon_state = item_instance.icon_state
	item_copy.item_state = item_instance.item_state

	if(HAS_BLOOD_DNA(item_instance))
		var/datum/component/forensics/detective_work = item_instance.GetComponent(/datum/component/forensics)
		item_copy.add_blood_DNA(detective_work.blood_DNA) // authentic lol

	item_copy.update_icon(UPDATE_OVERLAYS)

	// So you can attempt to take off the clothes to prevent meta, but they will be deleted anyways
	if(dropdel)
		item_copy.item_flags |= DROPDEL

	new_human_mob.equip_to_slot_if_possible(item_copy, slot, TRUE, TRUE, TRUE, TRUE, TRUE) // he's TRUE you know
