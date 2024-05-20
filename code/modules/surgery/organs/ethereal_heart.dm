#define CRYSTALIZE_COOLDOWN_LENGTH 5 MINUTES
#define CRYSTALIZE_PRE_WAIT_TIME 5 MINUTES
#define CRYSTALIZE_HEAL_TIME 60 SECONDS

/obj/item/organ/heart/ethereal
	name = "crystal core"
	icon_state = "ethereal_heart" //Welp. At least it's more unique in functionaliy.
	visual = TRUE //This is used by the ethereal species for color
	desc = "A crystal-like organ that functions similarly to a heart for Ethereals. It can revive its owner."

	decay_factor = 0 //won't randomly decay and break while reviving the ethereal
	///Cooldown for the next time we can crystalize
	COOLDOWN_DECLARE(crystalize_cooldown)
	///Timer ID for when we will be crystalized, If not preparing this will be null.
	var/crystalize_timer_id
	///The current crystal the ethereal is in, if any
	var/obj/structure/ethereal_crystal/current_crystal
	///The damage that needs to be dealt to the target
	var/brute_damage_to_stop_crystal = 30
	///Damage taken during crystalization, resets after it ends
	var/crystalization_process_damage = 0
	///Color of the heart, is set by the species on gain
	var/ethereal_color = "#9c3030"

/obj/item/organ/heart/ethereal/Initialize(mapload)
	. = ..()
	add_atom_colour(ethereal_color, FIXED_COLOUR_PRIORITY)

/obj/item/organ/heart/ethereal/Insert(mob/living/carbon/heart_owner, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(!isethereal(heart_owner))
		brute_damage_to_stop_crystal = 5
	else
		brute_damage_to_stop_crystal = initial(brute_damage_to_stop_crystal)
	RegisterSignal(heart_owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))
	RegisterSignal(heart_owner, COMSIG_LIVING_POST_FULLY_HEAL, PROC_REF(on_owner_fully_heal))
	RegisterSignal(heart_owner, COMSIG_QDELETING, PROC_REF(owner_deleted))

/obj/item/organ/heart/ethereal/Remove(mob/living/carbon/heart_owner, special = FALSE)
	UnregisterSignal(heart_owner, list(COMSIG_MOB_STATCHANGE, COMSIG_LIVING_POST_FULLY_HEAL, COMSIG_QDELETING))
	REMOVE_TRAIT(heart_owner, TRAIT_CORPSELOCKED, SPECIES_TRAIT)
	stop_crystalization_process(heart_owner)
	QDEL_NULL(current_crystal)
	return ..()

/obj/item/organ/heart/ethereal/update_overlays()
	. = ..()
	var/mutable_appearance/shine = mutable_appearance(icon, icon_state = "[icon_state]_shine")
	shine.appearance_flags = RESET_COLOR //No color on this, just pure white
	. += shine

/obj/item/organ/heart/ethereal/proc/on_owner_fully_heal(mob/living/carbon/healed, heal_flags)
	SIGNAL_HANDLER

	QDEL_NULL(current_crystal) //Kicks out the ethereal

///On stat changes, if the victim is no longer dead but they're crystalizing, cancel it, if they become dead, start the crystalizing process if possible
/obj/item/organ/heart/ethereal/proc/on_stat_change(mob/living/victim, new_stat)
	SIGNAL_HANDLER

	if(new_stat != DEAD)
		if(crystalize_timer_id)
			stop_crystalization_process(victim)
		return


	if(QDELETED(victim) || victim.suiciding)
		return //lol rip

	if(!COOLDOWN_FINISHED(src, crystalize_cooldown))
		return //lol double rip

	to_chat(victim, span_nicegreen("Crystals start forming around your dead body."))
	victim.visible_message(span_notice("Crystals start forming around [victim]."), ignored_mobs = victim)

	crystalize_timer_id = addtimer(CALLBACK(src, PROC_REF(crystalize), victim), CRYSTALIZE_PRE_WAIT_TIME, TIMER_STOPPABLE)

	RegisterSignal(victim, COMSIG_HUMAN_DISARM_HIT, PROC_REF(reset_crystalizing))
	RegisterSignal(victim, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(victim, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_take_damage))

///Ran when examined while crystalizing, gives info about the amount of time left
/obj/item/organ/heart/ethereal/proc/on_examine(atom/A, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!crystalize_timer_id)
		return
	
	var/remaining = timeleft(crystalize_timer_id)

	switch(remaining)
		if(0 to (CRYSTALIZE_PRE_WAIT_TIME/3))
			examine_list += span_warning("Crystals are almost engulfing [owner]! ")
		if((CRYSTALIZE_PRE_WAIT_TIME/3) to (2*(CRYSTALIZE_PRE_WAIT_TIME/3)))
			examine_list += span_notice("Crystals are starting to cover [owner]. ")
		if((2*(CRYSTALIZE_PRE_WAIT_TIME/3)) to INFINITY)
			examine_list += span_notice("Some crystals are coming out of [owner]. ")

///Ran when disarmed, prevents the ethereal from reviving
/obj/item/organ/heart/ethereal/proc/reset_crystalizing(mob/living/defender, mob/living/attacker, zone)
	SIGNAL_HANDLER
	defender.visible_message(
		span_notice("The crystals on [defender] are gently broken off."),
		span_notice("The crystals on your corpse are gently broken off, and will need some time to recover."),
	)
	deltimer(crystalize_timer_id)
	crystalize_timer_id = addtimer(CALLBACK(src, PROC_REF(crystalize), defender), CRYSTALIZE_PRE_WAIT_TIME, TIMER_STOPPABLE) //Lets us restart the timer on disarm

///Lets you stop the process with enough brute damage
/obj/item/organ/heart/ethereal/proc/on_take_damage(datum/source, damage, damagetype, def_zone)
	SIGNAL_HANDLER
	if(damagetype != BRUTE)
		return

	crystalization_process_damage += damage

	if(crystalization_process_damage < brute_damage_to_stop_crystal)
		return

	var/mob/living/carbon/human/ethereal = source

	ethereal.visible_message(
		span_notice("The crystals on [ethereal] are completely shattered and stopped growing."),
		span_warning("The crystals on your body have completely broken."),
	)

	stop_crystalization_process(ethereal)

///Stop the crystalization process, unregistering any signals and resetting any variables.
/obj/item/organ/heart/ethereal/proc/stop_crystalization_process(mob/living/ethereal, succesful = FALSE)
	UnregisterSignal(ethereal, COMSIG_HUMAN_DISARM_HIT)
	UnregisterSignal(ethereal, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(ethereal, COMSIG_MOB_APPLY_DAMAGE)

	crystalization_process_damage = 0 //Reset damage taken during crystalization

	if(!succesful)
		REMOVE_TRAIT(ethereal, TRAIT_CORPSELOCKED, SPECIES_TRAIT)
		QDEL_NULL(current_crystal)

	if(crystalize_timer_id)
		deltimer(crystalize_timer_id)
		crystalize_timer_id = null

/obj/item/organ/heart/ethereal/proc/owner_deleted(datum/source)
	SIGNAL_HANDLER

	stop_crystalization_process(owner)
	return

///Actually spawns the crystal which puts the ethereal in it.
/obj/item/organ/heart/ethereal/proc/crystalize(mob/living/ethereal)

	var/location = ethereal.loc

	if(!COOLDOWN_FINISHED(src, crystalize_cooldown) || ethereal.stat != DEAD)
		return //Should probably not happen, but lets be safe.

	ethereal.grab_ghost()//pull them in and LOCK THEM
	ADD_TRAIT(ethereal, TRAIT_CORPSELOCKED, SPECIES_TRAIT)

	if(ismob(location) || isitem(location) || iseffect(location) || HAS_TRAIT_FROM(src, TRAIT_HUSK, CHANGELING_DRAIN)) //Stops crystallization if they are eaten by a dragon, turned into a legion, consumed by his grace, etc.
		to_chat(ethereal, span_warning("You were unable to finish your crystallization, for obvious reasons."))
		stop_crystalization_process(ethereal, FALSE)
		return
	COOLDOWN_START(src, crystalize_cooldown, INFINITY) //Prevent cheeky double-healing until we get out, this is against stupid admemery
	current_crystal = new(get_turf(ethereal), src)
	stop_crystalization_process(ethereal, TRUE)

/obj/structure/ethereal_crystal
	name = "ethereal resurrection crystal"
	desc = "It seems to contain the corpse of an ethereal mending its wounds."
	icon = 'icons/mob/ethereal_crystal.dmi'
	icon_state = "ethereal_crystal"
	damage_deflection = 0
	max_integrity = 100
	resistance_flags = FIRE_PROOF
	density = TRUE
	anchored = TRUE
	///The organ this crystal belongs to
	var/obj/item/organ/heart/ethereal/ethereal_heart
	///Timer for the healing process. Stops if destroyed.
	var/crystal_heal_timer
	///Is the crystal still being built? True by default, gets changed after a timer.
	var/being_built = TRUE

/obj/structure/ethereal_crystal/relaymove()
	return

/obj/structure/ethereal_crystal/Initialize(mapload, obj/item/organ/heart/ethereal/ethereal_heart)
	. = ..()
	if(!ethereal_heart)
		stack_trace("Our crystal has no related heart")
		return INITIALIZE_HINT_QDEL
	src.ethereal_heart = ethereal_heart
	ethereal_heart.owner.visible_message(span_notice("The crystals fully encase [ethereal_heart.owner]!"))
	to_chat(ethereal_heart.owner, span_notice("You are encased in a huge crystal!"))
	playsound(get_turf(src), 'sound/effects/ethereal_crystalization.ogg', 50)
	var/atom/movable/possible_chair = ethereal_heart.owner.buckled
	possible_chair?.unbuckle_mob(ethereal_heart.owner, force = TRUE)
	ethereal_heart.owner.forceMove(src) //put that ethereal in
	add_atom_colour(ethereal_heart.ethereal_color, FIXED_COLOUR_PRIORITY)
	crystal_heal_timer = addtimer(CALLBACK(src, PROC_REF(heal_ethereal)), CRYSTALIZE_HEAL_TIME, TIMER_STOPPABLE)
	set_light(4, 10, ethereal_heart.ethereal_color)
	update_icon()
	flick("ethereal_crystal_forming", src)
	addtimer(CALLBACK(src, PROC_REF(start_crystalization)), 1 SECONDS)

/obj/structure/ethereal_crystal/proc/start_crystalization()
	being_built = FALSE
	update_icon()

/obj/structure/ethereal_crystal/atom_destruction(damage_flag)
	playsound(get_turf(ethereal_heart.owner), 'sound/effects/ethereal_revive_fail.ogg', 100)
	return ..()

/obj/structure/ethereal_crystal/Destroy()
	set_light(0)
	if(!ethereal_heart)
		return ..()

	ethereal_heart.current_crystal = null
	COOLDOWN_START(ethereal_heart, crystalize_cooldown, CRYSTALIZE_COOLDOWN_LENGTH)
	ethereal_heart.owner.forceMove(get_turf(src))
	REMOVE_TRAIT(ethereal_heart.owner, TRAIT_CORPSELOCKED, SPECIES_TRAIT)
	deltimer(crystal_heal_timer)
	visible_message(span_notice("The crystals shatters, causing [ethereal_heart.owner] to fall out."))
	return ..()

/obj/structure/ethereal_crystal/update_overlays()
	. = ..()
	if(!being_built)
		var/mutable_appearance/shine = mutable_appearance(icon, icon_state = "[icon_state]_shine")
		shine.appearance_flags = RESET_COLOR //No color on this, just pure white
		. += shine

/obj/structure/ethereal_crystal/proc/heal_ethereal()
	var/datum/brain_trauma/trauma_type = BRAIN_TRAUMA_MILD
	if(prob(1))
		trauma_type = BRAIN_TRAUMA_SPECIAL
	else if(prob(10))
		trauma_type = BRAIN_TRAUMA_SEVERE
		
	// revive will regenerate organs, so our heart refence is going to be null'd. Unreliable
	var/mob/living/carbon/regenerating = ethereal_heart.owner

	playsound(get_turf(regenerating), 'sound/effects/ethereal_revive.ogg', 100)
	to_chat(regenerating, span_notice("You burst out of the crystal with vigour... </span><span class='userdanger'>But at a cost."))
	regenerating.revive(TRUE)
	regenerating.gain_trauma_type(trauma_type, TRAUMA_RESILIENCE_ABSOLUTE)
	// revive calls fully heal -> deletes the crystal.
	// this qdeleted check is just for sanity.
	if(!QDELETED(src))
		qdel(src)
