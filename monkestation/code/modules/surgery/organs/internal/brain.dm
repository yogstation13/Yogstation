/obj/item/organ/internal/brain/clockwork
	name = "enigmatic gearbox"
	desc ="An engineer would call this inconcievable wonder of gears and metal a 'black box'"
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "brain-clock"
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	var/robust //Set to true if the robustbits causes brain replacement. Because holy fuck is the CLANG CLANG CLANG CLANG annoying

/obj/item/organ/internal/brain/clockwork/emp_act(severity)
		owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 25)

/obj/item/organ/internal/brain/clockwork/on_life()
	. = ..()
	if(prob(5) && !robust)
		SEND_SOUND(owner, sound('sound/ambience/ambiruin3.ogg', volume = 25))

/obj/item/organ/internal/brain/slime
	name = "core"
	desc = "The center core of a slimeperson, technically their 'extract.' Where the cytoplasm, membrane, and organelles come from; perhaps this is also a mitochondria?"
	zone = BODY_ZONE_CHEST
	icon = 'monkestation/code/modules/smithing/icons/oozeling.dmi'
	icon_state = "slime_core"
	resistance_flags = FIRE_PROOF

	var/obj/effect/death_melt_type = /obj/effect/temp_visual/wizard/out
	var/core_color = COLOR_WHITE

	var/core_ejected = FALSE
	var/gps_active = TRUE

	var/datum/dna/stored_dna

///////
/// Core storage
//
	var/list/stored_quirks = list()
	var/list/stored_items = list()
	///Item types that should never be stored in core and will drop on death. Takes priority over allowed lists.
	var/static/list/bannedcore = typecacheof(list(/obj/item/disk/nuclear,))
	//Allowed implants usually given by cases and injectors
	var/static/list/allowed_implants = typecacheof(list(
		//obj/item/implant
	))
	//Extraneous organs not of oozling origin. Usually cyber implants.
	var/static/list/allowed_organ_types = typecacheof(list(
		/obj/item/organ/internal/cyberimp,
		/obj/item/organ/external/wings,
		/obj/item/organ/external/tail,
		/obj/item/organ/external/frills,
		/obj/item/organ/external/horns,
		/obj/item/organ/external/snout,
		/obj/item/organ/external/antennae,
		/obj/item/organ/external/spines,
		/obj/item/organ/internal/eyes/robotic/glow
	))
	//Quirks that roll unique effects or gives items to each new body should be saved between bodies.
	var/static/list/saved_quirks = typecacheof(list(
		/datum/quirk/item_quirk/family_heirloom,
		/datum/quirk/item_quirk/nearsighted,
		/datum/quirk/item_quirk/photographer,
		/datum/quirk/item_quirk/pride_pin,
		/datum/quirk/item_quirk/bald,
		/datum/quirk/item_quirk/clown_enjoyer,
		/datum/quirk/item_quirk/mime_fan,
		/datum/quirk/item_quirk/musician,
		/datum/quirk/item_quirk/poster_boy,
		/datum/quirk/item_quirk/tagger,
		//datum/quirk/item_quirk/signer, // Needs to "add component" on proc add not on_unique
		/datum/quirk/phobia,
		/datum/quirk/indebted,
		/datum/quirk/item_quirk/allergic,
		/datum/quirk/item_quirk/brainproblems,
		/datum/quirk/item_quirk/junkie,
	))

	var/rebuilt = TRUE
	var/coredeath = TRUE

	var/datum/action/cooldown/membrane_murmur/membrane_mur

/obj/item/organ/internal/brain/slime/Initialize(mapload, mob/living/carbon/organ_owner, list/examine_list)
	. = ..()
	membrane_mur = new /datum/action/cooldown/membrane_murmur()
	colorize()
	transform.Scale(2, 2)

/obj/item/organ/internal/brain/slime/Destroy(force)
	QDEL_NULL(membrane_mur)
	QDEL_NULL(stored_dna)
	QDEL_LIST(stored_quirks)

	if(stored_items)
		if(!isnull(src.loc))
			drop_items_to_ground(src.drop_location(), explode = TRUE)
		else
			QDEL_LIST(stored_items)
	return ..()

/obj/item/organ/internal/brain/slime/examine()
	. = ..()
	if(gps_active)
		. += span_notice("A dim light lowly pulsates from the center of the core, indicating an outgoing signal from a tracking microchip.")
		. += span_red("You could probably snuff that out.")
	if((brainmob && (brainmob.client || brainmob.get_ghost())) || decoy_override)
		. += span_hypnophrase("You remember that pouring plasma on it, if it's non-embodied, would make it regrow one.")

/obj/item/organ/internal/brain/slime/attack_self(mob/living/user) // Allows a player (presumably an antag) to deactivate the GPS signal on a slime core
	user.visible_message(
		span_warning("[user] begins jamming their hand into a slime core! Slime goes everywhere!"),
		gps_active ? span_notice("You jam your hand into the core, feeling for the densest point! Slime covers your arm.") : span_notice("You jam your hand into the core, feeling for any dense objects. Slime covers your arm."),
		span_notice("You hear an obscene squelching sound.")
	)
	playsound(user, 'sound/surgery/organ1.ogg', 80, TRUE)

	if(!do_after(user, 30 SECONDS, src))
		user.visible_message(span_warning("[user]'s hand slips out of the core before they can cause any harm!'"),
		gps_active ? span_notice("Your hand slips out of the goopy core before you can find it's densest point.") : span_notice("Your hand slips out of the goopy core before you can find any dense points."),
		span_notice("You hear a resounding plop.")
		)
		return

	if((gps_active))
		user.visible_message(span_warning("[user] crunches something deep in the slime core! It gradually stops glowing."),
		span_notice("You find the densest point, crushing it in your palm. The blinking light in the core slowly dissapates and items start to come out."),
		span_notice("You hear a wet crunching sound."))
		gps_active =  FALSE
		qdel(GetComponent(/datum/component/gps/no_bsa))//Actually remove the gps signal

	else
		user.visible_message(span_warning("[user] crunches something deep in the slime core! It gradually stops glowing."),
		span_notice("You find several dense objects, forcing them out of the core, items start to spill."),
		span_notice("You hear a wet sqlenching sounds."))
	playsound(user, 'sound/effects/wounds/crackandbleed.ogg', 80, TRUE)

	drop_items_to_ground(get_turf(user))

/obj/item/organ/internal/brain/slime/Insert(mob/living/carbon/organ_owner, special = FALSE, drop_if_replaced, no_id_transfer)
	. = ..()
	if(!.)
		return
	colorize()
	core_ejected = FALSE
	RegisterSignal(organ_owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))

/obj/item/organ/internal/brain/slime/proc/colorize()
	if(isoozeling(owner))
		var/datum/color_palette/generic_colors/located = owner.dna.color_palettes[/datum/color_palette/generic_colors]
		core_color = located.return_color(MUTANT_COLOR)
		add_atom_colour(core_color, FIXED_COLOUR_PRIORITY)

/obj/item/organ/internal/brain/slime/proc/on_stat_change(mob/living/victim, new_stat, turf/loc_override)
	SIGNAL_HANDLER

	if(new_stat != DEAD)
		return

	addtimer(CALLBACK(src, PROC_REF(core_ejection), victim), 0) // explode them after the current proc chain ends, to avoid weirdness

/obj/item/organ/internal/brain/slime/proc/enable_coredeath() // No longer used.
	coredeath = TRUE
	if(owner?.stat == DEAD)
		addtimer(CALLBACK(src, PROC_REF(core_ejection), owner), 0)

///////
/// CORE EJECTION PROC
/// Makes it so that when a slime dies, their core ejects and their body is qdel'd.

/obj/item/organ/internal/brain/slime/proc/core_ejection(mob/living/carbon/human/victim, new_stat, turf/loc_override)
	if(core_ejected || !coredeath)
		return
	if(QDELETED(stored_dna))
		stored_dna = new

	isnull(victim.dna) ? (stored_dna = null) : victim.dna.copy_dna(stored_dna)

	core_ejected = TRUE
	victim.visible_message(span_warning("[victim]'s body completely dissolves, collapsing outwards!"), span_notice("Your body completely dissolves, collapsing outwards!"), span_notice("You hear liquid splattering."))
	var/turf/death_turf = get_turf(victim)
	var/mob/living/basic/mining/legion/legionbody = victim.loc

	for(var/datum/quirk/quirk in victim.quirks) // Store certain quirks safe to transfer between bodies.
		if(is_type_in_typecache(quirk, saved_quirks))
			quirk.remove_from_current_holder(quirk_transfer = TRUE)
			stored_quirks |= quirk

	process_items(victim) // Start moving items before anything else can touch them.

	if(victim.get_organ_slot(ORGAN_SLOT_BRAIN) == src)
		Remove(victim)
	//Make this check more generalized later. For antags that eat people as they kill. Make sure they drop their
	//contents after death; that is if that is how that item or antag works.
	if(legionbody)
		src.forceMove(legionbody)
	else
		if(death_turf)
			forceMove(death_turf)
	src.wash(CLEAN_WASH)
	new death_melt_type(death_turf, victim.dir)

	do_steam_effects(death_turf)
	playsound(victim, 'sound/effects/blobattack.ogg', 80, TRUE)

	if(gps_active) // adding the gps signal if they have activated the ability
		AddComponent(/datum/component/gps/no_bsa, "[victim]'s Core")

	if(brainmob)
		membrane_mur.Grant(brainmob)
		var/datum/antagonist/changeling/target_ling = brainmob.mind?.has_antag_datum(/datum/antagonist/changeling)

		if(target_ling)
			if(target_ling.oozeling_revives > 0)
				target_ling.oozeling_revives--
				addtimer(CALLBACK(src, PROC_REF(rebuild_body), null, FALSE), 30 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_DELETE_ME)

		if(IS_BLOODSUCKER(brainmob))
			var/datum/antagonist/bloodsucker/target_bloodsucker = brainmob.mind.has_antag_datum(/datum/antagonist/bloodsucker)
			if(target_bloodsucker.bloodsucker_blood_volume >= OOZELING_MIN_REVIVE_BLOOD_THRESHOLD)
				addtimer(CALLBACK(src, PROC_REF(rebuild_body), null, FALSE), 30 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_DELETE_ME)
				target_bloodsucker.bloodsucker_blood_volume -= (OOZELING_MIN_REVIVE_BLOOD_THRESHOLD * 0.5)

	if(stored_dna)
		rebuilt = FALSE
		victim.transfer_observers_to(src)

	Remove(victim)
	qdel(victim)

/obj/item/organ/internal/brain/slime/proc/do_steam_effects(turf/loc)
	var/datum/effect_system/steam_spread/steam = new()
	steam.set_up(10, FALSE, loc)
	steam.start()

///////
/// CHECK FOR REPAIR SECTION
/// Makes it so that when a slime's core has plasma poured on it, it builds a new body and moves the brain into it.

/obj/item/organ/internal/brain/slime/check_for_repair(obj/item/item, mob/user)
	if(damage && item.is_drainable() && item.reagents.has_reagent(/datum/reagent/toxin/plasma)) //attempt to heal the brain
		if (item.reagents.get_reagent_amount(/datum/reagent/toxin/plasma) < 100)
			user.balloon_alert(user, "too little plasma!")
			return FALSE

		user.visible_message(
			span_notice("[user] starts to slowly pour the contents of [item] onto [src]. It seems to bubble and roil, beginning to stretch its cytoskeleton outwards..."),
			span_notice("You start to slowly pour the contents of [item] onto [src]. It seems to bubble and roil, beginning to stretch its membrane outwards..."),
			span_hear("You hear bubbling.")
			)

		if(!do_after(user, 30 SECONDS, src))
			to_chat(user, span_warning("You failed to pour the contents of [item] onto [src]!"))
			return FALSE

		if (item.reagents.get_reagent_amount(/datum/reagent/toxin/plasma) < 100) // minor exploit but might as well patch it
			user.balloon_alert(user, "too little plasma!")
			return FALSE

		user.visible_message(
			span_notice("[user] pours the contents of [item] onto [src], causing it to form a proper cytoplasm and outer membrane."),
			span_notice("You pour the contents of [item] onto [src], causing it to form a proper cytoplasm and outer membrane."),
			span_hear("You hear a splat.")
			)

		item.reagents.remove_reagent(/datum/reagent/toxin/plasma, 100)
		rebuild_body(user)
		return TRUE
	return ..()

///////
/// PROCESS ITEMS FOR CORE EJECTION
/// Processes different types of items and prepares them to be stored when the core is ejected.

/obj/item/organ/internal/brain/slime/proc/process_items(mob/living/carbon/human/victim) // Handle all items to be stored into core.
	var/list/focus_slots = list(
		ITEM_SLOT_SUITSTORE,
		ITEM_SLOT_BELT,
		ITEM_SLOT_ID,
		ITEM_SLOT_LPOCKET,
		ITEM_SLOT_RPOCKET
	)
	for(var/islot in focus_slots) // Focus on storage items and any others that drop when uniform is unequiped
		var/obj/item/item = victim.get_item_by_slot(islot)
		if(QDELETED(item))
			continue
		victim.temporarilyRemoveItemFromInventory(item, force = TRUE, idrop = FALSE)
		process_and_store_item(item, victim)

	var/obj/item/back_item = victim.back
	if(!QDELETED(back_item))
		victim.temporarilyRemoveItemFromInventory(back_item, force = TRUE, idrop = FALSE)
		process_and_store_item(back_item, victim) // Jank to handle modsuit covering items, so it's removed first. Fix this.

	var/obj/item/bodypart/chest/target_chest = victim.get_bodypart(BODY_ZONE_CHEST) // Store chest cavity item
	if(istype(target_chest))
		process_and_store_item(target_chest.cavity_item, victim)

	for(var/obj/item/item as anything in victim.get_equipped_items(include_pockets = TRUE)) // Store rest of equipment
		if(QDELETED(item))
			continue
		victim.temporarilyRemoveItemFromInventory(item, force = TRUE, idrop = FALSE)
		process_and_store_item(item, victim)

	for(var/obj/item/implant/curimplant in victim.implants) // Process and store implants
		if(!is_type_in_typecache(curimplant, allowed_implants))
			continue
		if(curimplant.removed(victim))
			var/obj/item/implantcase/case =  new /obj/item/implantcase
			case.imp = curimplant
			curimplant.forceMove(case) //Recase implant it doesn't like to be moved without it.
			case.update_appearance()
			process_and_store_item(case, victim)

	for(var/obj/item/organ/organ in victim.organs) // Process and store organ implants and related organs
		if(is_type_in_typecache(organ, allowed_organ_types))
			organ.Remove(victim)
			process_and_store_item(organ, victim)

/obj/item/organ/internal/brain/slime/proc/process_and_store_item(atom/movable/item, mob/living/carbon/human/victim) // Helper proc to finally move items
	if(QDELETED(item))
		return
	if(!isnull(item.contents))
		for(var/atom/movable/content_item in item.get_all_contents())
			if(is_type_in_typecache(content_item, bannedcore))
				content_item.forceMove(victim.drop_location()) // Move item from container to victims turf if banned
	if(is_type_in_typecache(item, bannedcore))
		item.forceMove(victim.drop_location()) // Move banned item from victim to the victim's turf if banned.
	else
		item.forceMove(src)
		stored_items |= item

/obj/item/organ/internal/brain/slime/proc/drop_items_to_ground(turf/turf, explode = FALSE)
	for(var/atom/movable/item as anything in stored_items)
		if(explode)
			var/mob/living/explodedcore = src.brainmob
			explodedcore.dropItemToGround(item, violent = TRUE)
		else
			item.forceMove(turf)
	stored_items.Cut()

/obj/item/organ/internal/brain/slime/proc/rebuild_body(mob/user, nugget = TRUE) as /mob/living/carbon/human
	RETURN_TYPE(/mob/living/carbon/human)
	if(rebuilt)
		return owner
	set_organ_damage(-maxHealth) // heals the brain fully

	if(gps_active) // making sure the gps signal is removed if it's active on revival
		gps_active = FALSE
		qdel(GetComponent(/datum/component/gps))

	//we have the plasma. we can rebuild them.
	brainmob?.mind?.grab_ghost()
	if(isnull(brainmob))
		user?.balloon_alert(user, "This brain is not a viable candidate for repair!")
		return null
	if(isnull(brainmob.stored_dna))
		user?.balloon_alert(user, "This brain does not contain any dna!")
		return null
	if(isnull(brainmob.client))
		user?.balloon_alert(user, "This brain does not contain a mind!")
		return null
	var/mob/living/carbon/human/new_body = new /mob/living/carbon/human(drop_location())

	rebuilt = TRUE
	brainmob.client?.prefs?.safe_transfer_prefs_to(new_body)
	new_body.underwear = "Nude"
	new_body.undershirt = "Nude"
	new_body.socks = "Nude"
	stored_dna.transfer_identity(new_body, transfer_SE = TRUE)
	new_body.real_name = new_body.dna.real_name
	new_body.name = new_body.dna.real_name
	new_body.updateappearance(mutcolor_update = TRUE)
	new_body.domutcheck()
	new_body.forceMove(drop_location())
	if(!nugget)
		new_body.set_nutrition(NUTRITION_LEVEL_FED)
	new_body.blood_volume = nugget ? (BLOOD_VOLUME_SAFE + 60) : BLOOD_VOLUME_NORMAL
	REMOVE_TRAIT(new_body, TRAIT_NO_TRANSFORM, REF(src))
	if(!QDELETED(brainmob))
		if(!isnull(stored_quirks))
			for(var/datum/quirk/quirk in stored_quirks)
				quirk.add_to_holder(new_body, quirk_transfer = TRUE) // Return their old quirk to them.
			stored_quirks.Cut()
		SSquirks.AssignQuirks(new_body, brainmob.client) // Still need to copy over the rest of their quirks.
	var/obj/item/organ/internal/brain/new_body_brain = new_body.get_organ_slot(ORGAN_SLOT_BRAIN)
	qdel(new_body_brain)
	forceMove(new_body)
	Insert(new_body)
	if(nugget)
		for(var/obj/item/bodypart/bodypart as anything in new_body.bodyparts)
			if(istype(bodypart, /obj/item/bodypart/chest))
				continue
			if(istype(bodypart, /obj/item/bodypart/head))
				// Living mobs eyes are stored in the body so remove the organs properly for their effect to work.
				if(new_body.has_quirk(/datum/quirk/cybernetics_quirk/bright_eyes)) // Either they have their eyes in their core or they are destroyed dont spawn another.
					var/obj/item/organ/internal/eyes/eyes = new_body.get_organ_slot(ORGAN_SLOT_EYES)
					eyes.Remove(new_body)
					qdel(eyes)
			bodypart.drop_limb() // Drop limb should delete the limb for oozlings unless someone changes it.
		new_body.visible_message(span_warning("[new_body]'s torso \"forms\" from [new_body.p_their()] core, yet to form the rest."))
		to_chat(owner, span_purple("Your torso fully forms out of your core, yet to form the rest."))
		//Make oozlings revive similar to other species.
		new_body.set_jitter_if_lower(200 SECONDS)
		new_body.emote("scream")
	else
		if(new_body.has_quirk(/datum/quirk/cybernetics_quirk/bright_eyes)) // Either they have their eyes in core or they are destroyed don't spawn another.
			var/obj/item/organ/new_organ = new_body.dna.species.get_mutant_organ_type_for_slot(ORGAN_SLOT_EYES)
			new_organ = SSwardrobe.provide_type(new_organ)
			new_organ.Insert(new_body, special = TRUE, drop_if_replaced = FALSE)
		new_body.visible_message(span_warning("[new_body]'s body fully forms from [new_body.p_their()] core!"))
		to_chat(owner, span_purple("Your body fully forms from your core!"))

	membrane_mur.Remove(brainmob)
	brainmob?.mind?.transfer_to(new_body)
	new_body.grab_ghost()
	transfer_observers_to(new_body)

	drop_items_to_ground(new_body.drop_location())
	return new_body

/obj/item/organ/internal/brain/synth
	name = "compact positronic brain"
	slot = ORGAN_SLOT_BRAIN
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves. It has an IPC serial number engraved on the top. It is usually slotted into the chest of synthetic crewmembers."
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "posibrain-ipc"
	/// The last time (in ticks) a message about brain damage was sent. Don't touch.
	var/last_message_time = 0

/obj/item/organ/internal/brain/synth/on_insert(mob/living/carbon/brain_owner)
	. = ..()

	if(brain_owner.stat != DEAD || !ishuman(brain_owner))
		return

	var/mob/living/carbon/human/user_human = brain_owner
	if(HAS_TRAIT(user_human, TRAIT_REVIVES_BY_HEALING) && user_human.health > SYNTH_BRAIN_WAKE_THRESHOLD)
		if(!HAS_TRAIT(user_human, TRAIT_DEFIB_BLACKLISTED))
			user_human.revive(FALSE)

/obj/item/organ/internal/brain/synth/emp_act(severity) // EMP act against the posi, keep the cap far below the organ health
	. = ..()

	if(!owner || . & EMP_PROTECT_SELF)
		return

	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)

	switch(severity)
		if(EMP_HEAVY)
			to_chat(owner, span_warning("01001001 00100111 01101101 00100000 01100110 01110101 01100011 01101011 01100101 01100100 00101110"))
			apply_organ_damage(SYNTH_ORGAN_HEAVY_EMP_DAMAGE, SYNTH_EMP_BRAIN_DAMAGE_MAXIMUM, required_organtype = ORGAN_ROBOTIC)
		if(EMP_LIGHT)
			to_chat(owner, span_warning("Alert: Electromagnetic damage taken in central processing unit. Error Code: 401-YT"))
			apply_organ_damage(SYNTH_ORGAN_LIGHT_EMP_DAMAGE, SYNTH_EMP_BRAIN_DAMAGE_MAXIMUM, required_organtype = ORGAN_ROBOTIC)

/obj/item/organ/internal/brain/synth/apply_organ_damage(damage_amount, maximumm, required_organtype)
	. = ..()

	if(owner && damage > 0 && (world.time - last_message_time) > SYNTH_BRAIN_DAMAGE_MESSAGE_INTERVAL)
		last_message_time = world.time

		if(damage > BRAIN_DAMAGE_SEVERE)
			to_chat(owner, span_warning("Alre: re oumtnin ilir tocorr:pa ni ne:cnrrpiioruloomatt cessingode: P1_1-H"))
			return

		if(damage > BRAIN_DAMAGE_MILD)
			to_chat(owner, span_warning("Alert: Minor corruption in central processing unit. Error Code: 001-HP"))

/*
/obj/item/organ/internal/brain/synth/circuit
	name = "compact AI circuit"
	desc = "A compact and extremely complex circuit, perfectly dimensioned to fit in the same slot as a synthetic-compatible positronic brain. It is usually slotted into the chest of synthetic crewmembers."
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "circuit-occupied"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
*/

/obj/item/organ/internal/brain/synth/mmi
	name = "compact man-machine interface"
	desc = "A compact man-machine interface, perfectly dimensioned to fit in the same slot as a synthetic-compatible positronic brain. Unfortunately, the brain seems to be permanently attached to the circuitry, and it seems relatively sensitive to it's environment. It is usually slotted into the chest of synthetic crewmembers."
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "mmi-ipc"

