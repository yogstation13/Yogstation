/**
 * Handles the biological and general over-time processes of the mob.
 *
 *
 * Arguments:
 * - seconds_per_tick: The amount of time that has elapsed since this last fired.
 * - times_fired: The number of times SSmobs has fired
 */
/mob/living/proc/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	set waitfor = FALSE

	var/signal_result = SEND_SIGNAL(src, COMSIG_LIVING_LIFE, seconds_per_tick, times_fired)

	if(signal_result & COMPONENT_LIVING_CANCEL_LIFE_PROCESSING) // mmm less work
		return

	if (client)
		var/turf/T = get_turf(src)
		if(!T)
			move_to_error_room()
			var/msg = "[ADMIN_LOOKUPFLW(src)] was found to have no .loc with an attached client, if the cause is unknown it would be wise to ask how this was accomplished."
			message_admins(msg)
			send2tgs_adminless_only("Mob", msg, R_ADMIN)
			src.log_message("was found to have no .loc with an attached client.", LOG_GAME)

		// This is a temporary error tracker to make sure we've caught everything
		else if (registered_z != T.z)
#ifdef TESTING
			message_admins("[ADMIN_LOOKUPFLW(src)] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z]. If you could ask them how that happened and notify coderbus, it would be appreciated.")
#endif
			log_game("Z-TRACKING: [src] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z].")
			update_z(T.z)
	else if (registered_z)
		log_game("Z-TRACKING: [src] of type [src.type] has a Z-registration despite not having a client.")
		update_z(null)

	if(isnull(loc) || HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return

	if(!HAS_TRAIT(src, TRAIT_STASIS))

		if(stat != DEAD)
			//Mutations and radiation
			handle_mutations(seconds_per_tick, times_fired)

		if(stat != DEAD)
			//Breathing, if applicable
			handle_breathing(seconds_per_tick, times_fired)

		handle_diseases(seconds_per_tick, times_fired)// DEAD check is in the proc itself; we want it to spread even if the mob is dead, but to handle its disease-y properties only if you're not.

		if (QDELETED(src)) // diseases can qdel the mob via transformations
			return

		if(stat != DEAD)
			//Random events (vomiting etc)
			handle_random_events(seconds_per_tick, times_fired)

		//Handle temperature/pressure differences between body and environment
		var/datum/gas_mixture/environment = loc.return_air()
		if(environment)
			handle_environment(environment, seconds_per_tick, times_fired)
			body_temperature_damage(environment, seconds_per_tick, times_fired)
		if(stat <= SOFT_CRIT && !on_fire)
			if(!ishuman(src))
				return
			temperature_homeostasis(seconds_per_tick, times_fired)

		handle_gravity(seconds_per_tick, times_fired)

	if(stat != DEAD)
		body_temperature_alerts()

	handle_wounds(seconds_per_tick, times_fired)

	if(machine)
		machine.check_eye(src)

	if(stat != DEAD)
		return 1

/mob/living/proc/handle_breathing(seconds_per_tick, times_fired)
	SEND_SIGNAL(src, COMSIG_LIVING_HANDLE_BREATHING, seconds_per_tick, times_fired)
	return

/mob/living/proc/handle_mutations(seconds_per_tick, times_fired)
	return

/mob/living/proc/handle_diseases(seconds_per_tick, times_fired)
	return

/mob/living/proc/handle_wounds(seconds_per_tick, times_fired)
	return

/mob/living/proc/handle_random_events(seconds_per_tick, times_fired)
	return

/**
 * Handle this mob's interactions with the environment
 *
 * By default handles body temperature normalization to the area's temperature,
 * but also handles pressure for many mobs
 *
 * Arguments:
 * * environment: The gas mixture of the area the mob is in, will never be null
 * * seconds_per_tick: The amount of time that has elapsed since this last fired.
 * * times_fired: The number of times SSmobs has fired
 */
/mob/living/proc/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	var/loc_temp = get_temperature(environment)
	var/temp_delta = loc_temp - bodytemperature
	if(temp_delta == 0)
		return
	if(temp_delta < 0 && on_fire)
		return

	var/thermal_protection = get_insulation(loc_temp)
	var/protection_modifier = 1
	if(bodytemperature > standard_body_temperature + 2 KELVIN)
		protection_modifier = 0.7

	// Calculate the equilibrium temperature considering insulation
	var/equilibrium_temp = get_insulated_equilibrium_temperature(loc_temp, thermal_protection * protection_modifier)

	var/temp_change = (equilibrium_temp - bodytemperature) * temperature_normalization_speed * seconds_per_tick

	// Cap increase and decrease
	temp_change = temp_change < 0 ? max(temp_change, BODYTEMP_HOMEOSTASIS_COOLING_MAX) : min(temp_change, BODYTEMP_HOMEOSTASIS_HEATING_MAX)

	adjust_bodytemperature(temp_change * seconds_per_tick) // No use_insulation because we manually account for it

/mob/living/proc/get_insulated_equilibrium_temperature(environment_temp, insulation)
	return environment_temp + (standard_body_temperature - environment_temp) * insulation

/mob/living/silicon/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	return // Not yet

/**
 * Get the fullness of the mob
 *
 * This returns a value form 0 upwards to represent how full the mob is.
 * The value is a total amount of consumable reagents in the body combined
 * with the total amount of nutrition they have.
 * This does not have an upper limit.
 */
/mob/living/proc/get_fullness()
	var/fullness = nutrition
	// we add the nutrition value of what we're currently digesting
	for(var/datum/reagent/consumable/bits in reagents.reagent_list)
		fullness += bits.nutriment_factor  * bits.volume / bits.metabolization_rate
	return fullness

/**
 * Check if the mob contains this reagent.
 *
 * This will validate the the reagent holder for the mob and any sub holders contain the requested reagent.
 * Vars:
 * * reagent (typepath) takes a PATH to a reagent.
 * * amount (int) checks for having a specific amount of that chemical.
 * * needs_metabolizing (bool) takes into consideration if the chemical is matabolizing when it's checked.
 */
/mob/living/proc/has_reagent(reagent, amount = -1, needs_metabolizing = FALSE)
	return reagents.has_reagent(reagent, amount, needs_metabolizing)

/mob/living/proc/update_damage_hud()
	return

/mob/living/proc/handle_gravity(seconds_per_tick, times_fired)
	if(gravity_state > STANDARD_GRAVITY)
		handle_high_gravity(gravity_state, seconds_per_tick, times_fired)

/mob/living/proc/gravity_animate()
	if(!get_filter("gravity"))
		add_filter("gravity",1,list("type"="motion_blur", "x"=0, "y"=0))
	animate(get_filter("gravity"), y = 1, time = 10, loop = -1)
	animate(y = 0, time = 10)

/mob/living/proc/handle_high_gravity(gravity, seconds_per_tick, times_fired)
	if(gravity < GRAVITY_DAMAGE_THRESHOLD) //Aka gravity values of 3 or more
		return

	var/grav_strength = gravity - GRAVITY_DAMAGE_THRESHOLD
	adjustBruteLoss(min(GRAVITY_DAMAGE_SCALING * grav_strength, GRAVITY_DAMAGE_MAXIMUM) * seconds_per_tick)
