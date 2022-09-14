/*********************Hivelord stabilizer****************/
/obj/item/hivelordstabilizer
	name = "stabilizing serum"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	desc = "Inject certain types of monster organs with this stabilizer to preserve their healing powers indefinitely."
	w_class = WEIGHT_CLASS_TINY

/obj/item/hivelordstabilizer/afterattack(obj/item/organ/M, mob/user)
	. = ..()
	var/obj/item/organ/regenerative_core/C = M
	if(!istype(C, /obj/item/organ/regenerative_core))
		to_chat(user, span_warning("The stabilizer only works on certain types of monster organs, generally regenerative in nature."))
		return ..()

	C.preserved()
	to_chat(user, span_notice("You inject the [M] with the stabilizer. It will no longer go inert."))
	qdel(src)

// Hivelord super-stabilizer

/obj/item/hivelordstabilizer_super
	name = "super-stabilizing serum"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle21"
	desc = "Inject certain types of monster organs with this stabilizer to preserve their healing powers indefinitely. \
			This stabilizer will also ensure that they retain more effectiveness away from their world of origin."
	w_class = WEIGHT_CLASS_TINY

/obj/item/hivelordstabilizer_super/afterattack(obj/item/organ/M, mob/user)
	. = ..()
	var/obj/item/organ/regenerative_core/C = M
	if(!istype(C, /obj/item/organ/regenerative_core))
		to_chat(user, span_warning("The super-stabilizer only works on certain types of monster organs, generally regenerative in nature."))
		return ..()

	C.superpreserved()
	to_chat(user, span_notice("You inject the [M] with the super-stabilizer. It will no longer go inert and it will work better away from its world of origin."))
	qdel(src)

/************************Hivelord core*******************/
/obj/item/organ/regenerative_core
	name = "regenerative core"
	desc = "All that remains of a hivelord. It can be used to heal completely, but it will rapidly decay into uselessness."
	icon_state = "roro core 2"
	item_flags = NOBLUDGEON
	slot = "hivecore"
	force = 0
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/inert = 0
	var/preserved = 0
	var/superpreserved = 0

/obj/item/organ/regenerative_core/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/inert_check), 2400)

/obj/item/organ/regenerative_core/proc/inert_check()
	if(!preserved)
		go_inert()

/obj/item/organ/regenerative_core/proc/preserved(implanted = 0)
	inert = FALSE
	preserved = TRUE
	update_icon()
	desc = "All that remains of a hivelord. It is preserved, meaning its regenerative properties will never decay."
	if(implanted)
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "implanted"))
	else
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "stabilizer"))

/obj/item/organ/regenerative_core/proc/superpreserved()
	inert = FALSE
	preserved = TRUE
	superpreserved = TRUE
	update_icon()
	desc = "All that remains of a hivelord. It is superpreserved, allowing you to use it to heal completely, even away from its world of origin."
	SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "superstabilizer"))

/obj/item/organ/regenerative_core/proc/go_inert()
	inert = TRUE
	name = "decayed regenerative core"
	desc = "All that remains of a hivelord. It has decayed, and is completely useless."
	SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "inert"))
	update_icon()

/obj/item/organ/regenerative_core/ui_action_click()
	if(inert)
		to_chat(owner, span_notice("[src] breaks down as it tries to activate."))
	else
		owner.revive(full_heal = 1)
	qdel(src)

/obj/item/organ/regenerative_core/on_life()
	..()
	if(owner.health <= owner.crit_threshold)
		ui_action_click()

/obj/item/organ/regenerative_core/proc/weak_heal(mob/living/carbon/human/target) //Off lavaland
	target.adjustBruteLoss(-15)
	target.adjustFireLoss(-15)

/obj/item/organ/regenerative_core/proc/moderate_heal(mob/living/carbon/human/target) //Off lavaland but superstabilized
	target.adjustBruteLoss(-20)
	target.adjustFireLoss(-20)
	target.remove_CC()
	target.bodytemperature = BODYTEMP_NORMAL

/obj/item/organ/regenerative_core/proc/strong_heal(mob/living/carbon/human/target) //On lavaland
	target.apply_status_effect(STATUS_EFFECT_REGENERATIVE_CORE)
		
/obj/item/organ/regenerative_core/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/turf/planet = get_turf(user) //Needs this to actually recognize where the item is annoyingly
	var/final_message
	if(inert)
		to_chat(user, span_notice("[src] has decayed and can no longer be used to heal."))
		return
	final_message += "[user] crushes [src] in [H.p_their()] hand... "
	SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "self"))
	if(!is_mining_level(planet.z))
		if(!superpreserved)
			weak_heal(H)
			final_message += "black tendrils lick across [H.p_them()] before falling to the ground and disintegrating!"
		else
			moderate_heal(H)
			final_message += "black tendrils wrap around [H.p_them()] and fade into [H.p_their()] form!"
	else
		strong_heal(H)
		final_message += "black tendrils entangle and reinforce [H.p_them()]!"
	H.visible_message(span_warning("[final_message]"))
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "core", /datum/mood_event/healsbadman)
	qdel(src)
	
/obj/item/organ/regenerative_core/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag && ishuman(target))
		var/mob/living/carbon/human/H = target
		var/turf/planet = get_turf(user) //See above
		var/final_message
		if(inert)
			to_chat(user, span_notice("[src] has decayed and can no longer be used to heal."))
			return
		else
			if(H.stat == DEAD)
				to_chat(user, span_notice("[src] are useless on the dead."))
				return
			if(H != user)
				final_message += "[user] forces [H] to apply [src]... "
				SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "other"))
			else
				final_message += "[user] smears [src] on [H.p_their()] own body... "
				SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "self"))
			if(!is_mining_level(planet.z))
				if(!superpreserved)
					weak_heal(H)
					final_message += "black tendrils lick across [H.p_them()] before falling to the ground and disintegrating!"
				else
					moderate_heal(H)
					final_message += "black tendrils wrap around [H.p_them()] and fade into [H.p_their()] form!"
			else
				strong_heal(H)
				final_message += "black tendrils entangle and reinforce [H.p_them()]!"
			H.visible_message(span_warning("[final_message]"))
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "core", /datum/mood_event/healsbadman) //Now THIS is a miner buff (fixed - nerf)
			qdel(src)

/obj/item/organ/regenerative_core/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(!preserved && !inert)
		preserved(TRUE)
		owner.visible_message(span_notice("[src] stabilizes as it's inserted."))

/obj/item/organ/regenerative_core/Remove(mob/living/carbon/M, special = 0)
	if(!inert && !special)
		owner.visible_message(span_notice("[src] rapidly decays as it's removed."))
		go_inert()
	return ..()

/obj/item/organ/regenerative_core/prepare_eat()
	return null

/*************************Legion core********************/
/obj/item/organ/regenerative_core/legion
	desc = "A strange rock that crackles with power. It can be used to heal completely, but it will rapidly decay into uselessness. Its power wanes off Lavaland, away from the tendril's influence."
	icon_state = "legion_soul"

/obj/item/organ/regenerative_core/legion/Initialize()
	. = ..()
	update_icon()

/obj/item/organ/regenerative_core/update_icon()
	icon_state = inert ? "legion_soul_inert" : "legion_soul"
	cut_overlays()
	if(!inert && !preserved)
		add_overlay("legion_soul_crackle")
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/organ/regenerative_core/legion/go_inert()
	..()
	desc = "[src] has become inert. It has decayed, and is completely useless."

/obj/item/organ/regenerative_core/legion/preserved(implanted = 0)
	..()
	desc = "[src] has been stabilized. It is preserved, meaning it will never decay and lose its properties."

/obj/item/organ/regenerative_core/legion/superpreserved()
	..()
	desc = "[src] has been superstabilized. Not only is it preserved, but it will function more effectively off Lavaland."
