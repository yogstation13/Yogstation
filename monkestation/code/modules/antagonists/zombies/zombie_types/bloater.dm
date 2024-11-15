//UNIMPLEMENTED
//explodes on death, blinding(and damaging?) nearby non zombies
/datum/species/zombie/infectious/bloater
	name = "Bloater Zombie"
	id = SPECIES_ZOMBIE_INFECTIOUS_BLOATER
	bodypart_overlay_icon_states = list(BODY_ZONE_CHEST = "bloater-chest", BODY_ZONE_R_ARM = "generic-right-hand", BODY_ZONE_L_ARM = "generic-left-hand")
	granted_action_types = list(
		/datum/action/cooldown/zombie/melt_wall,
		/datum/action/cooldown/zombie/explode,
	)

/datum/species/zombie/infectious/bloater/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	RegisterSignal(C, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/species/zombie/infectious/bloater/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(C, COMSIG_LIVING_DEATH)

/datum/species/zombie/infectious/bloater/proc/on_death(mob/living/carbon/user, gibbed)
	SIGNAL_HANDLER

	if(gibbed || QDELETED(user)) // Congratulations, you've defused the bomb.
		return

	user.visible_message(
		message = span_danger("[user] bursts apart into a violent shower of infectious gibs!"),
		self_message = span_userdanger("You burst apart!"),
		blind_message = span_hear("You hear squelching and tearing as your eardrums are assaulted by noise!"),
	)

	var/infects = 0

	for(var/mob/living/target in oview(4, user)) //need to make this not go through glass
		to_chat(target, span_userdanger("Some of the gibs flew onto you!"))

		var/datum/client_colour/colour = target.add_client_colour(/datum/client_colour/bloodlust)
		QDEL_IN(colour, 1.1 SECONDS)

		var/dist = max(1, get_dist(user, target))

		target.adjustBruteLoss(50 / dist)
		target.adjustFireLoss(50 / dist)

		target.throw_at(get_edge_target_turf(user, get_dir(user, target)), range = 4 / dist, speed = 2, spin = FALSE)

		if(!iscarbon(target) || !prob(80 / max(1, dist))) // A minimum of a 20% chance to infect.
			continue

		var/mob/living/carbon/infectee = target
		var/obj/item/organ/internal/zombie_infection/infection
		infection = infectee.get_organ_slot(ORGAN_SLOT_ZOMBIE)
		if(!infection)
			infection = new()
			infection.Insert(infectee)

		infects++

	if(infects > 0)
		to_chat(user, span_alien("In your final moments, you managed to infect [infects] [infects == 1 ? "person" : "people"]."))

	user.gib(no_brain = TRUE, no_organs = TRUE, no_bodyparts = TRUE, safe_gib = FALSE)

/datum/action/cooldown/zombie/melt_wall
	name = "Stomach Acid"
	desc = "Drench an object in stomach acid, destroying it over time."
	button_icon_state = "zombie_vomit"
	background_icon_state = "bg_zombie"
	cooldown_time = 30 SECONDS
	click_to_activate = TRUE

/datum/action/cooldown/zombie/melt_wall/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return

	to_chat(on_who, span_notice("You prepare to vomit. <b>Click a target to puke on it!</b>"))
	on_who.update_icons()

/datum/action/cooldown/zombie/melt_wall/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return

	if(refund_cooldown)
		to_chat(on_who, span_notice("You empty your mouth."))
	on_who.update_icons()

/datum/action/cooldown/zombie/melt_wall/PreActivate(atom/target)
	if(get_dist(owner, target) > 1)
		return FALSE
	if(ismob(target)) //If it could corrode mobs, it would one-shot them.
		owner.balloon_alert(owner, "doesn't work on mobs!")
		return FALSE
	if(isfloorturf(target)) // Turns floors into landmines which do the same as above
		owner.balloon_alert(owner, "doesn't work on floors!")
		return FALSE

	return ..()

/datum/action/cooldown/zombie/melt_wall/Activate(atom/target)
	if(!target.acid_act(200, 1000))
		to_chat(owner, span_notice("You cannot dissolve this object."))
		return FALSE

	owner.visible_message(
		span_alert("[owner] vomits globs of vile stuff all over [target]. It begins to sizzle and melt under the bubbling mess of acid!"),
		span_notice("You vomit globs of acid over [target]. It begins to sizzle and melt."),
	)
	StartCooldown()
	return TRUE

/datum/action/cooldown/zombie/explode
	name = "Explode"
	button_icon_state = "explode"
	desc = "Trigger the explosive cocktail residing in your body, causing a devastating explosion that infects nearby targets. Triggers automatically on death."
	check_flags = NONE

/datum/action/cooldown/zombie/explode/Activate(atom/target)
	. = ..()
	var/mob/living/user = owner
	user.death() // lol
