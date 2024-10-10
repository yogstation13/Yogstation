/mob/living/proc/body_temperature_damage(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	if(bodytemperature > bodytemp_heat_damage_limit && !HAS_TRAIT(src, TRAIT_RESISTHEAT))
		var/heat_diff = bodytemp_heat_damage_limit - standard_body_temperature
		var/heat_threshold_low = bodytemp_heat_damage_limit + heat_diff * 1.25
		var/heat_threshold_medium = bodytemp_heat_damage_limit + heat_diff * 2
		var/heat_threshold_high = bodytemp_heat_damage_limit + heat_diff * 4

		var/firemodifier = round(fire_stacks, 1) * 0.01
		if (!on_fire) // We are not on fire, reduce the modifier
			firemodifier = min(firemodifier, 0) // Note that wetstacks make us take less burn damage

		// convering back and forth so we can apply a multiplier from firestacks without sending temp to the moon
		var/effective_temp = CELCIUS_TO_KELVIN(KELVIN_TO_CELCIUS(bodytemperature) * (1 + firemodifier))
		var/burn_damage = HEAT_DAMAGE
		if(effective_temp > heat_threshold_high)
			burn_damage *= 5
		else if(effective_temp > heat_threshold_medium)
			burn_damage *= 3
		else if(effective_temp > heat_threshold_low)
			burn_damage *= 1

		temperature_burns(burn_damage * seconds_per_tick)
		if(effective_temp > heat_threshold_medium)
			apply_status_effect(/datum/status_effect/stacking/heat_exposure, 1, heat_threshold_medium)


	// For cold damage, we cap at the threshold if you're dead
	if(bodytemperature < bodytemp_cold_damage_limit && !HAS_TRAIT(src, TRAIT_RESISTCOLD) && (getFireLoss() < maxHealth || stat != DEAD))
		var/cold_diff = bodytemp_cold_damage_limit - standard_body_temperature
		var/cold_threshold_low = bodytemp_cold_damage_limit + cold_diff * 1.2
		var/cold_threshold_medium = bodytemp_cold_damage_limit + cold_diff * 1.75
		// For cold damage, we cap at the threshold if you're dead
		var/cold_threshold_high = bodytemp_cold_damage_limit + cold_diff * 2

		var/cold_damage = COLD_DAMAGE
		if(bodytemperature < cold_threshold_high)
			cold_damage *= 8
		else if(bodytemperature < cold_threshold_medium)
			cold_damage *= 4
		else if(bodytemperature < cold_threshold_low)
			cold_damage *= 2

		temperature_cold_damage(cold_damage * seconds_per_tick)

/// Applies damage to the mob due to being too cold
/mob/living/proc/temperature_cold_damage(damage)
	return apply_damage(damage, HAS_TRAIT(src, TRAIT_HULK) ? BRUTE : BURN, spread_damage = TRUE, wound_bonus = CANT_WOUND)

/mob/living/carbon/human/temperature_cold_damage(damage)
	damage *= physiology.cold_mod
	return ..()

/// Applies damage to the mob due to being too hot
/mob/living/proc/temperature_burns(damage)
	return apply_damage(damage, BURN, spread_damage = TRUE, wound_bonus = CANT_WOUND)

/mob/living/carbon/human/temperature_burns(damage)
	damage *= physiology.heat_mod
	return ..()

/mob/living/proc/body_temperature_alerts()
	// give out alerts based on how the skin feels, not how the body is
	// this gives us an early warning system - since we tend to trend up/down to skin temperature -
	// how we're going to be feeling soon if we don't change our environment
	var/feels_like = get_skin_temperature()

	var/hot_diff = bodytemp_heat_damage_limit - standard_body_temperature
	var/hot_threshold_low = bodytemp_heat_damage_limit - hot_diff * 0.5
	var/hot_threshold_medium = bodytemp_heat_damage_limit
	var/hot_threshold_high = bodytemp_heat_damage_limit + hot_diff
	// Body temperature is too hot, and we do not have resist traits
	if(feels_like > hot_threshold_low && !HAS_TRAIT(src, TRAIT_RESISTHEAT))
		clear_mood_event("cold")
		// Clear cold once we return to warm
		remove_movespeed_modifier(/datum/movespeed_modifier/cold)
		if(feels_like > hot_threshold_high)
			throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 3)
			add_mood_event("hot", /datum/mood_event/overhot)
		else if(feels_like > hot_threshold_medium)
			throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 2)
			add_mood_event("hot", /datum/mood_event/hot)
		else
			throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 1)
			add_mood_event("hot", /datum/mood_event/warm)
		temp_alerts = TRUE

	var/cold_diff = bodytemp_cold_damage_limit - standard_body_temperature
	var/cold_threshold_low = bodytemp_cold_damage_limit - cold_diff * 0.5
	var/cold_threshold_medium = bodytemp_cold_damage_limit
	var/cold_threshold_high = bodytemp_cold_damage_limit + cold_diff
	// Body temperature is too cold, and we do not have resist traits
	if(feels_like < cold_threshold_low && !HAS_TRAIT(src, TRAIT_RESISTCOLD))
		clear_mood_event("hot")
		if(feels_like < cold_threshold_high)
			throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 3)
			add_mood_event("cold", /datum/mood_event/freezing)
		else if(feels_like < cold_threshold_medium)
			throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 2)
			add_mood_event("cold", /datum/mood_event/cold)
		else
			throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 1)
			add_mood_event("cold", /datum/mood_event/chilly)
		temp_alerts = TRUE
	// Only apply slowdown if the body is cold rather than the skin
	if(bodytemperature < cold_threshold_medium && !HAS_TRAIT(src, TRAIT_RESISTCOLD))
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/cold, multiplicative_slowdown = ((cold_threshold_medium - bodytemperature) / COLD_SLOWDOWN_FACTOR))
	else if(has_movespeed_modifier(/datum/movespeed_modifier/cold))
		remove_movespeed_modifier(/datum/movespeed_modifier/cold)

	// We are not to hot or cold, remove status and moods
	if(temp_alerts && (feels_like < hot_threshold_low || HAS_TRAIT(src, TRAIT_RESISTHEAT)) && (feels_like > cold_threshold_low || HAS_TRAIT(src, TRAIT_RESISTCOLD)))
		clear_alert(ALERT_TEMPERATURE)
		clear_mood_event("cold")
		clear_mood_event("hot")
		temp_alerts = FALSE

/**
 * Handles this mob internally managing its body temperature (sweating or generating heat)
 *
 * Arguments:
 * * seconds_per_tick: The amount of time that has elapsed since this last fired.
 * * times_fired: The number of times SSmobs has fired
 */
/mob/living/proc/temperature_homeostasis(seconds_per_tick, times_fired)
	if(HAS_TRAIT(src, TRAIT_COLD_BLOODED))
		return
	if(!HAS_TRAIT(src, TRAIT_NOHUNGER) && nutrition < (NUTRITION_LEVEL_STARVING / 3))
		return

	// find exactly what temperature we're aiming for
	var/homeostasis_target = standard_body_temperature
	if(LAZYLEN(homeostasis_targets))
		homeostasis_target = 0
		for(var/source in homeostasis_targets)
			homeostasis_target += homeostasis_targets[source]
		homeostasis_target /= LAZYLEN(homeostasis_targets)

	// temperature delta is capped, so you can't attempt to homeostaize from vacuum to standard temp in a second
	var/temp_delta = (homeostasis_target - bodytemperature)
	temp_delta = temp_delta < 0 ? max(temp_delta, BODYTEMP_HOMEOSTASIS_COOLING_MAX) : min(temp_delta, BODYTEMP_HOMEOSTASIS_HEATING_MAX)
	// note: Because this scales by metabolism efficiency, being well fed boosts your homeostasis, and being poorly fed reduces it
	var/natural_change = temp_delta * metabolism_efficiency * temperature_homeostasis_speed
	if(natural_change == 0)
		return

	var/sigreturn = SEND_SIGNAL(src, COMSIG_LIVING_HOMEOSTASIS, natural_change, seconds_per_tick)
	if(sigreturn & HOMEOSTASIS_HANDLED)
		return

	var/min = natural_change < 0 ? homeostasis_target : 0
	var/max = natural_change > 0 ? homeostasis_target : INFINITY
	// calculates how much nutrition decay per kelvin of temperature change
	// while having this scale may be confusing, it's to make sure that stepping into an extremely cold environment (space)
	// doesn't immediately drain nutrition to zero in under a minute
	// at 0.25 kelvin, nutrition_per_kelvin is 2.5. at 1, it's ~1.5, and at 4, it's 1.
	var/nutrition_per_kelvin = round(2.5 / ((abs(natural_change) / 0.25) ** 0.33), 0.01)

	adjust_bodytemperature(natural_change * seconds_per_tick, min_temp = min, max_temp = max) // no use_insulation beacuse this is internal
	if(!(sigreturn & HOMEOSTASIS_NO_HUNGER))
		adjust_nutrition(-0.1 * HOMEOSTASIS_HUNGER_MULTIPLIER * HUNGER_FACTOR * nutrition_per_kelvin * abs(natural_change) * seconds_per_tick)

/mob/living/silicon/temperature_homeostasis(seconds_per_tick, times_fired)
	return // Not yet

/mob/proc/adjust_satiety(change)
	satiety = clamp(satiety + change, -MAX_SATIETY, MAX_SATIETY)
