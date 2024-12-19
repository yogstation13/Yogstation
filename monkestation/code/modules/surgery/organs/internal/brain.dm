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

	var/list/stored_items = list()

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
	return ..()

/obj/item/organ/internal/brain/slime/examine()
	. = ..()
	if(gps_active)
		. += span_notice("A dim light lowly pulsates from the center of the core, indicating an outgoing signal from a tracking microchip.")
		. += span_red("You could probably snuff that out.")
	. += span_hypnophrase("You remember that pouring plasma on it, if it's non-embodied, would make it regrow one.")

/obj/item/organ/internal/brain/slime/attack_self(mob/living/user) // Allows a player (presumably an antag) to deactivate the GPS signal on a slime core
	if(!(gps_active))
		return
	user.visible_message(span_warning("[user] begins jamming their hand into a slime core! Slime goes everywhere!"),
	span_notice("You jam your hand into the core, feeling for the densest point! Slime covers your arm."),
	span_notice("You hear an obscene squelching sound.")
	)
	playsound(user, 'sound/surgery/organ1.ogg', 80, TRUE)

	if(!do_after(user, 30 SECONDS, src))
		user.visible_message(span_warning("[user]'s hand slips out of the core before they can cause any harm!'"),
		span_warning("Your hand slips out of the goopy core before you can find it's densest point."),
		span_notice("You hear a resounding plop.")
		)
		return

	user.visible_message(span_warning("[user] crunches something deep in the slime core! It gradually stops glowing."),
	span_notice("You find the densest point, crushing it in your palm. The blinking light in the core slowly dissapates and items start to come out."),
	span_notice("You hear a wet crunching sound."))
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

/obj/item/organ/internal/brain/slime/proc/enable_coredeath()
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

	victim.dna.copy_dna(stored_dna)
	core_ejected = TRUE
	victim.visible_message(span_warning("[victim]'s body completely dissolves, collapsing outwards!"), span_notice("Your body completely dissolves, collapsing outwards!"), span_notice("You hear liquid splattering."))
	var/turf/death_turf = get_turf(victim)

	for(var/atom/movable/item as anything in victim.get_equipped_items(include_pockets = TRUE))
		victim.dropItemToGround(item)
		stored_items |= item
		item.forceMove(src)

	if(victim.get_organ_slot(ORGAN_SLOT_BRAIN) == src)
		Remove(victim)
	if(death_turf)
		forceMove(death_turf)
	src.wash(CLEAN_WASH)
	new death_melt_type(death_turf, victim.dir)

	do_steam_effects(death_turf)
	playsound(victim, 'sound/effects/blobattack.ogg', 80, TRUE)

	if(gps_active) // adding the gps signal if they have activated the ability
		AddComponent(/datum/component/gps, "[victim]'s Core")

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

/obj/item/organ/internal/brain/slime/proc/drop_items_to_ground(turf/turf)
	for(var/atom/movable/item as anything in stored_items)
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
		SSquirks.AssignQuirks(new_body, brainmob.client)
	var/obj/item/organ/internal/brain/new_body_brain = new_body.get_organ_slot(ORGAN_SLOT_BRAIN)
	qdel(new_body_brain)
	forceMove(new_body)
	Insert(new_body)
	if(nugget)
		for(var/obj/item/bodypart as anything in new_body.bodyparts)
			if(istype(bodypart, /obj/item/bodypart/chest))
				continue
			qdel(bodypart)
		new_body.visible_message(span_warning("[new_body]'s torso \"forms\" from [new_body.p_their()] core, yet to form the rest."))
		to_chat(owner, span_purple("Your torso fully forms out of your core, yet to form the rest."))
	else
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
	zone = BODY_ZONE_HEAD
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

