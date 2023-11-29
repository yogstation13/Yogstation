
//Here are the procs used to modify status effects of a mob.
//The effects include: stun, knockdown, unconscious, sleeping, resting, jitteriness, dizziness, ear damage,
// eye damage, eye_blind, eye_blurry, druggy, TRAIT_BLIND trait, and TRAIT_NEARSIGHT trait.

///Blind a mobs eyes by amount
/mob/proc/blind_eyes(amount)
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind = max(eye_blind, amount)
		if(!old_eye_blind)
			if(stat == CONSCIOUS || stat == SOFT_CRIT)
				throw_alert("blind", /atom/movable/screen/alert/blind)
			if(stat != CONSCIOUS && HAS_TRAIT(src, TRAIT_HEAVY_SLEEPER))
				overlay_fullscreen("blind", /atom/movable/screen/fullscreen/black)
			else
				overlay_fullscreen("blind", /atom/movable/screen/fullscreen/blind)

/**
  * Adjust a mobs blindness by an amount
  *
  * Will apply the blind alerts if needed
  */
/mob/proc/adjust_blindness(amount)
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind += amount
		if(!old_eye_blind)
			if(stat == CONSCIOUS || stat == SOFT_CRIT)
				throw_alert("blind", /atom/movable/screen/alert/blind)
			if(stat != CONSCIOUS && HAS_TRAIT(src, TRAIT_HEAVY_SLEEPER))
				overlay_fullscreen("blind", /atom/movable/screen/fullscreen/black)
			else
				overlay_fullscreen("blind", /atom/movable/screen/fullscreen/blind)
	else if(eye_blind)
		var/blind_minimum = 0
		if((stat != CONSCIOUS && stat != SOFT_CRIT))
			blind_minimum = 1
		if(isliving(src))
			var/mob/living/L = src
			if(HAS_TRAIT(L, TRAIT_BLIND))
				blind_minimum = 1
		eye_blind = max(eye_blind+amount, blind_minimum)
		if(!eye_blind)
			clear_alert("blind")
			clear_fullscreen("blind")
/**
  * Force set the blindness of a mob to some level
  */
/mob/proc/set_blindness(amount)
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind = amount
		if(client && !old_eye_blind)
			if(stat == CONSCIOUS || stat == SOFT_CRIT)
				throw_alert("blind", /atom/movable/screen/alert/blind)
			if(stat != CONSCIOUS && HAS_TRAIT(src, TRAIT_HEAVY_SLEEPER))
				overlay_fullscreen("blind", /atom/movable/screen/fullscreen/black)
			else
				overlay_fullscreen("blind", /atom/movable/screen/fullscreen/blind)
	else if(eye_blind)
		var/blind_minimum = 0
		if(stat != CONSCIOUS && stat != SOFT_CRIT)
			blind_minimum = 1
		if(isliving(src))
			var/mob/living/L = src
			if(HAS_TRAIT(L, TRAIT_BLIND))
				blind_minimum = 1
		eye_blind = blind_minimum
		if(!eye_blind)
			clear_alert("blind")
			clear_fullscreen("blind")

///Adjust the disgust level of a mob
/mob/proc/adjust_disgust(amount)
	return

///Set the disgust level of a mob
/mob/proc/set_disgust(amount)
	return

///Adjust the body temperature of a mob, with min/max settings
/mob/proc/adjust_bodytemperature(amount,min_temp=0,max_temp=INFINITY)
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		amount *= H.dna.species.tempmod
		amount *= H.physiology.temp_mod
	if(bodytemperature >= min_temp && bodytemperature <= max_temp)
		bodytemperature = clamp(bodytemperature + amount,min_temp,max_temp)
	// Infrared luminosity, how far away can you pick up someone's heat with infrared (NOT THERMAL) vision
	// 37C has 12 range (11 tiles)
	// 20C has 7 range (6 tiles)
	// 10C has 3 range (2 tiles)
	// 0C has 0 range (0 tiles)
	infra_luminosity = round(max((bodytemperature - T0C)/3, 0))

/// Sight here is the mob.sight var, which tells byond what to actually show to our client
/// See [code\__DEFINES\sight.dm] for more details
/mob/proc/set_sight(new_value)
	SHOULD_CALL_PARENT(TRUE)
	if(sight == new_value)
		return
	var/old_sight = sight
	sight = new_value

	SEND_SIGNAL(src, COMSIG_MOB_SIGHT_CHANGE, new_value, old_sight)

/mob/proc/add_sight(new_value)
	set_sight(sight | new_value)

/mob/proc/clear_sight(new_value)
	set_sight(sight & ~new_value)

/// see invisibility is the mob's capability to see things that ought to be hidden from it
/// Can think of it as a primitive version of changing the alpha of planes
/// We mostly use it to hide ghosts, no real reason why
/mob/proc/set_invis_see(new_sight)
	SHOULD_CALL_PARENT(TRUE)
	if(new_sight == see_invisible)
		return
	var/old_invis = see_invisible
	see_invisible = new_sight
	SEND_SIGNAL(src, COMSIG_MOB_SEE_INVIS_CHANGE, see_invisible, old_invis)
