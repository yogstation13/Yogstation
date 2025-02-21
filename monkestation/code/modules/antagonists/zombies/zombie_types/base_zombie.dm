#define FLESH_REQUIRED_TO_EVOLVE 200

// I would like to convert these to their own datum type but I have like 2 hours so this is what we are getting.
/datum/species/zombie/infectious
	/// The path of mutant hands to give this zombie.
	var/obj/item/mutant_hand/zombie/hand_path = /obj/item/mutant_hand/zombie

	/// The list of action types to give on gain.
	var/list/granted_action_types = list(
		/datum/action/cooldown/zombie/feast,
		/datum/action/cooldown/zombie/evolve,
	)

	/// The list of action instances we have actually granted.
	var/list/granted_actions = list()

	/// File that bodypart_overlay_icon_states pulls from.
	var/list/bodypart_overlay_icon = 'monkestation/icons/mob/species/zombie/special_zombie_overlays.dmi'

	/// Associative list of bodypart overlays by body zone.
	var/list/bodypart_overlay_icon_states = list()

	/// How much flesh we've consumed. Used for evolving.
	var/consumed_flesh = 0

/datum/species/zombie/infectious/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	for(var/zone as anything in bodypart_overlay_icon_states)
		var/obj/item/bodypart/bodypart = C.get_bodypart(zone)
		if(!bodypart)
			continue

		var/overlay_state = bodypart_overlay_icon_states[zone]
		var/datum/bodypart_overlay/simple/overlay = new
		overlay.icon = bodypart_overlay_icon
		overlay.icon_state = overlay_state
		overlay.layers = EXTERNAL_ADJACENT | EXTERNAL_FRONT

		bodypart.add_bodypart_overlay(overlay)

/datum/species/zombie/infectious/proc/set_consumed_flesh(mob/living/carbon/user, amount)
	var/old_amount = consumed_flesh
	consumed_flesh = max(0, amount)

	if(old_amount == consumed_flesh)
		return

	SEND_SIGNAL(user, COMSIG_ZOMBIE_FLESH_ADJUSTED, consumed_flesh, old_amount)

/datum/species/zombie/infectious/proc/adjust_consumed_flesh(mob/living/carbon/user, amount)
	set_consumed_flesh(consumed_flesh + amount)

/datum/action/cooldown/zombie
	name = "Zombie Action"
	desc = "You should not be seeing this."
	background_icon = 'monkestation/icons/mob/actions/actions_zombie.dmi'
	button_icon = 'monkestation/icons/mob/actions/actions_zombie.dmi'
	background_icon_state = "bg_zombie"
	check_flags = AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS

/datum/action/cooldown/zombie/IsAvailable(feedback)
	if(!iszombie(owner))
		return FALSE
	return ..()

/datum/action/cooldown/zombie/PreActivate(atom/target)
	if(!iszombie(owner))
		CRASH("A non-zombie([owner]) tried to use a zombie action, it seems the game has taken too much LSD today. (report this shit)")
	// Parent calls Activate(), so if parent returns TRUE, it means the activation happened successfuly by this point
	. = ..()
	if(!.)
		return FALSE
	// Xeno actions like "evolve" may result in our action (or our alien) being deleted
	// In that case, we can just exit now as a "success"
	if(QDELETED(src) || QDELETED(owner))
		return TRUE


/datum/action/cooldown/zombie/proc/update_button()
	SIGNAL_HANDLER
	build_all_button_icons(UPDATE_BUTTON_STATUS)

/datum/action/cooldown/zombie/feast
	name = "Feast"
	desc = "Consume the flesh of the fallen ones."
	button_icon_state = "feast"
	ranged_mousepointer = 'monkestation/icons/effects/mouse_pointers/feast.dmi'
	click_to_activate = TRUE
	cooldown_time = 5 SECONDS

/datum/action/cooldown/zombie/feast/Activate(mob/living/target)
	if(target == owner) // Don't eat yourself, dumbass.
		return TRUE

	if(!istype(target))
		return TRUE

	if(!owner.Adjacent(target))
		owner.balloon_alert(owner, "get closer!")
		return TRUE

	if(target.stat != DEAD)
		owner.balloon_alert(owner, "[target.p_they()] [target.p_are()] alive!")
		return TRUE

	if(HAS_TRAIT(target, TRAIT_ZOMBIE_CONSUMED))
		owner.balloon_alert(owner, "already consumed!")
		return TRUE

	for(var/i in 1 to 4)
		if(!do_after(owner, 0.5 SECONDS, target, timed_action_flags = IGNORE_HELD_ITEM | IGNORE_SLOWDOWNS))
			owner.balloon_alert(owner, "interrupted!")
			return TRUE
		playsound(owner, 'sound/items/eatfood.ogg', vol = 80, vary = TRUE) // Om nom nom, good flesh.

		if(iscarbon(target))
			var/mob/living/carbon/carbon_target = target
			carbon_target.apply_damage(25, BRUTE, pick(carbon_target.bodyparts), forced = TRUE, wound_bonus = 10, sharpness = SHARP_EDGED, attack_direction = get_dir(owner, target))
		else
			playsound(target, 'sound/effects/wounds/blood2.ogg', vol = 50, vary = TRUE)
			target.adjustBruteLoss(25)

	ADD_TRAIT(target, TRAIT_ZOMBIE_CONSUMED, ZOMBIE_TRAIT)

	var/mob/living/carbon/user = owner

	var/healing = target.maxHealth // Bigger kills give more health, most simple mobs will be worth far less than a carbon.
	var/needs_update = FALSE // Optimization, if nothing changes then don't update our owner's health.
	needs_update += user.adjustBruteLoss(-healing, updating_health = FALSE)
	needs_update += user.adjustFireLoss(-healing, updating_health = FALSE)
	needs_update += user.adjustToxLoss(-healing, updating_health = FALSE)
	needs_update += user.adjustOxyLoss(-healing, updating_health = FALSE)

	if(needs_update)
		user.updatehealth()

	user.adjustOrganLoss(ORGAN_SLOT_BRAIN, -healing)
	user.set_nutrition(min(user.nutrition + healing, NUTRITION_LEVEL_FULL)) // Doesn't use adjust_nutrition since that would make the zombies fat.

	var/datum/species/zombie/infectious/zombie_datum = user.dna.species
	zombie_datum.consumed_flesh += healing

	..()

	return TRUE

/// Evolve into a special zombie, needs at least FLESH_REQUIRED_TO_EVOLVE consumed flesh.
/datum/action/cooldown/zombie/evolve
	name = "Evolve"
	desc = "Mutate into something even more grotesque and powerful. You must consume the flesh of the dead beforehand."
	button_icon_state = "evolve"

/datum/action/cooldown/zombie/evolve/Grant(mob/granted_to)
	. = ..()
	RegisterSignal(granted_to, COMSIG_ZOMBIE_FLESH_ADJUSTED, PROC_REF(update_button))

/datum/action/cooldown/zombie/evolve/Remove(mob/removed_from)
	. = ..()
	UnregisterSignal(removed_from, COMSIG_ZOMBIE_FLESH_ADJUSTED)

/datum/action/cooldown/zombie/evolve/IsAvailable(feedback)
	if(!..())
		return FALSE

	var/mob/living/carbon/user = owner
	var/datum/species/zombie/infectious/zombie_datum = user.dna.species

	if(zombie_datum.consumed_flesh < FLESH_REQUIRED_TO_EVOLVE)
		if(feedback)
			user.balloon_alert(user, "needs [ceil(FLESH_REQUIRED_TO_EVOLVE - zombie_datum.consumed_flesh)] more flesh!")
		return FALSE

	return TRUE

/datum/action/cooldown/zombie/evolve/Activate(atom/target)
	. = ..()

	var/mob/living/carbon/user = owner

	var/datum/species/picked = show_radial_menu(user, user, subtypesof(/datum/species/zombie/infectious))

	if(!picked)
		return

	user.set_species(picked)

	user.visible_message(
		message = span_danger("[user]'s flesh shifts, tears and changes, giving way to something even more dangerous!"),
		self_message = span_alien("Your flesh shifts, tears and changes as you transform into a [lowertext(initial(picked.name))]!"),
		blind_message = span_hear("You hear a grotesque cacophony of flesh shifting and tearing!"),
	)

	playsound(user, 'sound/effects/blobattack.ogg', vol = 80, vary = TRUE)

#undef FLESH_REQUIRED_TO_EVOLVE
