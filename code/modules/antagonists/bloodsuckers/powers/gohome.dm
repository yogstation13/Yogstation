#define GOHOME_START 0
#define GOHOME_FLICKER_ONE 2
#define GOHOME_FLICKER_TWO 4
#define GOHOME_TELEPORT 6

/datum/action/bloodsucker/gohome
	name = "Vanishing Act"
	desc = "As dawn aproaches, disperse into mist and return directly to your Lair.<br><b>WARNING:</b> You will drop <b>ALL</b> of your possessions if observed by mortals."
	button_icon_state = "power_gohome"
	background_icon_state_on = "vamp_power_off_oneshot"
	background_icon_state_off = "vamp_power_off_oneshot"
	power_explanation = "<b>Vanishing Act</b>: \n\
		Activating Vanishing Act will, after a short delay, teleport the user to their <b>Claimed Coffin</b>. \n\
		The power will cancel out if the <b>Claimed Coffin</b> is somehow destroyed. \n\
		Immediately after activating, lights around the user will begin to flicker. \n\
		Once the user teleports to their coffin, in their place will be a Rat or Bat."
	power_flags = BP_AM_TOGGLE|BP_AM_SINGLEUSE|BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_STAKED|BP_CANT_USE_WHILE_INCAPACITATED
	// You only get this once you've claimed a lair and Sol is near.
	purchase_flags = NONE
	constant_bloodcost = 2
	bloodcost = 100
	cooldown = 100 SECONDS
	///What stage of the teleportation are we in
	var/teleporting_stage = GOHOME_START
	var/list/spawning_mobs = list(
		/mob/living/simple_animal/mouse = 3,
		/mob/living/simple_animal/hostile/retaliate/bat = 1,
	)

/datum/action/bloodsucker/gohome/CheckCanUse(mob/living/carbon/user)
	. = ..()
	if(!.)
		return FALSE
	/// Have No Lair (NOTE: You only got this power if you had a lair, so this means it's destroyed)
	if(!istype(bloodsuckerdatum_power) || !bloodsuckerdatum_power.coffin)
		to_chat(owner, span_warning("Your coffin has been destroyed!"))
		return FALSE
	return TRUE

/datum/action/bloodsucker/gohome/ActivatePower()
	. = ..()
	to_chat(owner, span_notice("You focus on separating your consciousness from your physical form..."))

/datum/action/bloodsucker/gohome/UsePower(mob/living/user)
	. = ..()
	if(!.)
		return FALSE
	if(!bloodsuckerdatum_power.coffin)
		to_chat(owner, span_warning("Your coffin has been destroyed! You no longer have a destination."))
		return FALSE
	switch(teleporting_stage)
		if(GOHOME_START)
			INVOKE_ASYNC(src, .proc/flicker_lights, 3, 20)
		if(GOHOME_FLICKER_ONE)
			INVOKE_ASYNC(src, .proc/flicker_lights, 4, 40)
		if(GOHOME_FLICKER_TWO)
			INVOKE_ASYNC(src, .proc/flicker_lights, 4, 60)
		if(GOHOME_TELEPORT)
			do_mob(user, user, 1 SECONDS, TRUE)
			INVOKE_ASYNC(src, .proc/teleport_to_coffin, user)
	teleporting_stage++

/datum/action/bloodsucker/gohome/ContinueActive(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!isturf(user.loc))
		return FALSE
	if(!bloodsuckerdatum_power.coffin)
		to_chat(user, span_warning("Your coffin has been destroyed! You no longer have a destination."))
		return FALSE
	return TRUE

/datum/action/bloodsucker/gohome/proc/flicker_lights(flicker_range, beat_volume)
	for(var/obj/machinery/light/nearby_lights in view(flicker_range, get_turf(owner)))
		nearby_lights.flicker(5)
	playsound(get_turf(owner), 'sound/effects/singlebeat.ogg', beat_volume, TRUE)

/datum/action/bloodsucker/gohome/proc/teleport_to_coffin(mob/living/carbon/user)
	var/drop_item = FALSE
	var/turf/current_turf = get_turf(user)
	// If we aren't in the dark, anyone watching us will cause us to drop out stuff
	if(current_turf && current_turf.lighting_object && current_turf.get_lumcount() >= 0.2)
		for(var/mob/living/watchers in viewers(world.view, get_turf(user)) - user)
			if(!watchers.client)
				continue
			if(watchers.has_unlimited_silicon_privilege)
				continue
			if(watchers.eye_blind)
				continue
			if(!IS_BLOODSUCKER(watchers) && !IS_VASSAL(watchers))
				drop_item = TRUE
				break
	// Drop all necessary items (handcuffs, legcuffs, items if seen)
	if(user.handcuffed)
		var/obj/item/handcuffs = user.handcuffed
		user.dropItemToGround(handcuffs)
	if(user.legcuffed)
		var/obj/item/legcuffs = user.legcuffed
		user.dropItemToGround(legcuffs)
	if(drop_item)
		for(var/obj/item/literally_everything in user)
			user.dropItemToGround(literally_everything, TRUE)

	playsound(current_turf, 'sound/magic/summon_karp.ogg', 60, TRUE)
	var/datum/effect_system/steam_spread/bloodsucker/puff = new /datum/effect_system/steam_spread/bloodsucker()
	puff.set_up(3, 0, current_turf)
	puff.start()

	/// STEP FIVE: Create animal at prev location
	var/mob/living/simple_animal/new_mob = pick(spawning_mobs)
	new new_mob(current_turf)
	/// TELEPORT: Move to Coffin & Close it!
	user.set_resting(TRUE, TRUE, FALSE)
	do_teleport(user, bloodsuckerdatum_power.coffin, no_effects = TRUE, forced = TRUE, channel = TELEPORT_CHANNEL_QUANTUM)
	user.Stun(3 SECONDS, TRUE)
	// Puts me inside.
	if(!bloodsuckerdatum_power.coffin.close(user))
		// CLOSE LID: If fail, force me in.
		bloodsuckerdatum_power.coffin.insert(user)
		playsound(bloodsuckerdatum_power.coffin.loc, bloodsuckerdatum_power.coffin.close_sound, 15, TRUE, -3)

	DeactivatePower()

/datum/effect_system/steam_spread/bloodsucker
	effect_type = /obj/effect/particle_effect/smoke/vampsmoke

#undef GOHOME_START
#undef GOHOME_FLICKER_ONE
#undef GOHOME_FLICKER_TWO
#undef GOHOME_TELEPORT
