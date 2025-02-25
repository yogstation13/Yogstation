/mob/living/carbon/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return

	if(isopenturf(loc))
		var/turf/open/my_our_turf = loc
		if(my_our_turf.pollution)
			my_our_turf.pollution.touch_act(src)
	//monkestation edit start
	if(SSparticle_weather.running_weather || SSparticle_weather.running_eclipse_weather)
		handle_weather(seconds_per_tick)
	//monkestation edit end
	if(damageoverlaytemp)
		damageoverlaytemp = 0
		update_damage_hud()

	if(HAS_TRAIT(src, TRAIT_STASIS))
		. = ..()
		reagents?.handle_stasis_chems(src, seconds_per_tick, times_fired)
	else
		//Reagent processing needs to come before breathing, to prevent edge cases.
		handle_dead_metabolization(seconds_per_tick, times_fired) //Dead metabolization first since it can modify life metabolization.
		handle_organs(seconds_per_tick, times_fired)
		handle_virus_updates(seconds_per_tick, times_fired)

		. = ..()
		if(QDELETED(src))
			return

		if(.) //not dead
			handle_blood(seconds_per_tick, times_fired)

		if(stat != DEAD)
			handle_brain_damage(seconds_per_tick, times_fired)

	if(stat == DEAD)
		stop_sound_channel(CHANNEL_HEARTBEAT)
	else
		var/bprv = handle_bodyparts(seconds_per_tick, times_fired)
		if(bprv & BODYPART_LIFE_UPDATE_HEALTH)
			updatehealth()

	if(. && mind) //. == not dead
		for(var/key in mind.addiction_points)
			var/datum/addiction/addiction = SSaddiction.all_addictions[key]
			addiction.process_addiction(src, seconds_per_tick, times_fired)
	if(stat != DEAD)
		return 1

///////////////
// BREATHING //
///////////////

// Start of a breath chain, calls [carbon/proc/breathe()]
/mob/living/carbon/handle_breathing(seconds_per_tick, times_fired)
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		setOxyLoss(0) //idk how because spec life should cover this
		losebreath = 0
		failed_last_breath = 0
		return

	var/next_breath = 4
	var/obj/item/organ/internal/lungs/lungs = get_organ_slot(ORGAN_SLOT_LUNGS)
	var/obj/item/organ/internal/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
	if(lungs?.damage > lungs?.high_threshold)
		next_breath -= 1
	if(heart?.damage > heart?.high_threshold)
		next_breath -= 1

	if((times_fired % next_breath) == 0 || failed_last_breath)
		// Breathe per 4 ticks if healthy, down to 2 if our lungs or heart are damaged, unless suffocating
		breathe(seconds_per_tick, times_fired, failed_last_breath ? 1 : next_breath)
		if(failed_last_breath)
			add_mood_event("suffocation", /datum/mood_event/suffocation)
		else
			clear_mood_event("suffocation")
	else if(isobj(loc))
		var/obj/location_as_object = loc
		location_as_object.handle_internal_lifeform(src, 0)

/mob/living/carbon/proc/breathe(seconds_per_tick, times_fired, next_breath = 4)
	var/datum/gas_mixture/environment = loc?.return_air()
	var/datum/gas_mixture/breath

	if(!HAS_TRAIT(src, TRAIT_ASSISTED_BREATHING))
		if(stat == HARD_CRIT)
			losebreath = max(losebreath, 1)
		else if(HAS_TRAIT(src, TRAIT_LABOURED_BREATHING))
			losebreath += (1 / next_breath)

	if(losebreath < 1)
		var/pre_sig_return = SEND_SIGNAL(src, COMSIG_CARBON_ATTEMPT_BREATHE, seconds_per_tick, times_fired)
		if(pre_sig_return & BREATHE_BLOCK_BREATH)
			return

		if(pre_sig_return & BREATHE_SKIP_BREATH)
			losebreath = max(losebreath, 1)

	// Suffocate
	var/skip_breath = FALSE
	if(losebreath >= 1)
		losebreath -= 1
		if(prob(10))
			emote("gasp")
		if(isobj(loc))
			var/obj/loc_as_obj = loc
			loc_as_obj.handle_internal_lifeform(src, 0)
		skip_breath = TRUE

	// Breathe from internals or externals (name is misleading)
	else if(internal || external)
		breath = get_breath_from_internal(BREATH_VOLUME)

		if(breath == SKIP_INTERNALS) //in case of 0 pressure internals
			breath = get_breath_from_surroundings(environment, BREATH_VOLUME)

		else if(isobj(loc)) //Breathe from loc as obj again
			var/obj/loc_as_obj = loc
			loc_as_obj.handle_internal_lifeform(src, 0)

	// Breathe from air
	else
		breath = get_breath_from_surroundings(environment, BREATH_VOLUME)

	check_breath(breath, skip_breath)

	if(breath)
		exhale_breath(breath)

/mob/living/carbon/proc/exhale_breath(datum/gas_mixture/breath)
	if(SEND_SIGNAL(src, COMSIG_CARBON_BREATH_EXHALE, breath) & BREATHE_EXHALE_HANDLED)
		return
	loc.assume_air(breath)

/mob/living/carbon/proc/has_smoke_protection()
	return HAS_TRAIT(src, TRAIT_NOBREATH)

/**
 * This proc tests if the lungs can breathe, if the mob can breathe a given gas mixture, and throws/clears gas alerts.
 * If there are moles of gas in the given gas mixture, side-effects may be applied/removed on the mob.
 * This proc expects a lungs organ in order to breathe successfully, but does not defer any work to it.
 *
 * Returns TRUE if the breath was successful, or FALSE if otherwise.
 *
 * Arguments:
 * * breath: A gas mixture to test, or null.
 * * skip_breath: Used to differentiate between a failed breath and a lack of breath.
 * A mob suffocating due to being in a vacuum may be treated differently than a mob suffocating due to lung failure.
 */
/mob/living/carbon/proc/check_breath(datum/gas_mixture/breath, skip_breath = FALSE)
	return

/// Applies suffocation side-effects to a given Human, scaling based on ratio of required pressure VS "true" pressure.
/// If pressure is greater than 0, the return value will represent the amount of gas successfully breathed.
/mob/living/carbon/proc/handle_suffocation(breath_pp = 0, safe_breath_min = 0, true_pp = 0)
	. = 0
	// Can't suffocate without minimum breath pressure.
	if(!safe_breath_min)
		return
	// Mob is suffocating.
	failed_last_breath = TRUE
	// Give them a chance to notice something is wrong.
	if(prob(20))
		emote("gasp")
	// Mob is at critical health, check if they can be damaged further.
	if(health < crit_threshold)
		// Mob is immune to damage at critical health.
		if(HAS_TRAIT(src, TRAIT_NOCRITDAMAGE))
			return
		// Reagents like Epinephrine stop suffocation at critical health.
		if(reagents.has_reagent(/datum/reagent/medicine/epinephrine, needs_metabolizing = TRUE))
			return
	// Low pressure.
	if(breath_pp)
		var/ratio = safe_breath_min / breath_pp
		adjustOxyLoss(min(5 * ratio, 3))
		return true_pp * ratio / 6
	// Zero pressure.
	if(health >= crit_threshold)
		adjustOxyLoss(3)
	else
		adjustOxyLoss(1)

/// Fourth and final link in a breath chain
/mob/living/carbon/proc/handle_breath_temperature(datum/gas_mixture/breath)
	// The air you breathe out should match your body temperature
	breath.temperature = bodytemperature

/**
 * Attempts to take a breath from the external or internal air tank.
 *
 * Return a gas mixture datum if a breath was taken
 * Return null if there was no gas inside the tank or no gas was distributed
 * Return SKIP_INTERNALS to skip using internals entirely and get a normal breath
 */
/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(invalid_internals())
		// Unexpectely lost breathing apparatus and ability to breathe from the internal air tank.
		cutoff_internals()
		return SKIP_INTERNALS

	if (external)
		. = external.remove_air_volume(volume_needed)
	else if (internal)
		. = internal.remove_air_volume(volume_needed)
	else
		// Return without taking a breath if there is no air tank.
		stack_trace("get_breath_from_internal called on a mob without internals or externals")
		return SKIP_INTERNALS

	return .

/**
 * Attempts to take a breath from the surroundings.
 *
 * Returns a gas mixture datum if a breath was taken.
 * Returns null if there was no gas in the surroundings or no gas was distributed.
 */
/mob/living/carbon/proc/get_breath_from_surroundings(datum/gas_mixture/environment, volume_needed)
	if(isobj(loc)) //Breathe from loc as object
		var/obj/loc_as_obj = loc
		. = loc_as_obj.handle_internal_lifeform(src, volume_needed)

	else if(isturf(loc)) //Breathe from loc as turf
		. = loc.remove_air((environment?.total_moles() * BREATH_PERCENTAGE) || 0)

	return .

/mob/living/carbon/proc/handle_blood(seconds_per_tick, times_fired)
	return

/mob/living/carbon/proc/handle_bodyparts(seconds_per_tick, times_fired)
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		. |= limb.on_life(seconds_per_tick, times_fired)

/mob/living/carbon/proc/handle_organs(seconds_per_tick, times_fired)
	if(stat == DEAD)
		if(reagents && (reagents.has_reagent(/datum/reagent/toxin/formaldehyde, 1) || reagents.has_reagent(/datum/reagent/cryostylane))) // No organ decay if the body contains formaldehyde.
			return
		for(var/obj/item/organ/internal/organ in organs)
			// On-death is where organ decay is handled
			organ?.on_death(seconds_per_tick, times_fired) // organ can be null due to reagent metabolization causing organ shuffling
			// We need to re-check the stat every organ, as one of our others may have revived us
			if(stat != DEAD)
				break
		return

	// NOTE: organs_slot is sorted by GLOB.organ_process_order on insertion
	for(var/slot in organs_slot)
		// We don't use get_organ_slot here because we know we have the organ we want, since we're iterating the list containing em already
		// This code is hot enough that it's just not worth the time
		var/obj/item/organ/internal/organ = organs_slot[slot]
		if(organ?.owner) // This exist mostly because reagent metabolization can cause organ reshuffling
			organ.on_life(seconds_per_tick, times_fired)


/mob/living/carbon/handle_diseases(seconds_per_tick, times_fired)
	for(var/thing in diseases)
		var/datum/disease/D = thing
		if(SPT_PROB(D.infectivity, seconds_per_tick))
			D.spread()

/mob/living/carbon/handle_wounds(seconds_per_tick, times_fired)
	for(var/thing in all_wounds)
		var/datum/wound/W = thing
		if(W.processes) // meh
			W.handle_process(seconds_per_tick, times_fired)

/mob/living/carbon/handle_mutations(time_since_irradiated, seconds_per_tick, times_fired)
	if(!dna?.temporary_mutations.len)
		return

	for(var/mut in dna.temporary_mutations)
		if(dna.temporary_mutations[mut] < world.time)
			if(mut == UI_CHANGED)
				if(dna.previous["UI"])
					dna.unique_identity = merge_text(dna.unique_identity,dna.previous["UI"])
					updateappearance(mutations_overlay_update=1)
					dna.previous.Remove("UI")
				dna.temporary_mutations.Remove(mut)
				continue
			if(mut == UF_CHANGED)
				if(dna.previous["UF"])
					dna.unique_features = merge_text(dna.unique_features,dna.previous["UF"])
					updateappearance(mutcolor_update=1, mutations_overlay_update=1)
					dna.previous.Remove("UF")
				dna.temporary_mutations.Remove(mut)
				continue
			if(mut == UE_CHANGED)
				if(dna.previous["name"])
					real_name = dna.previous["name"]
					name = real_name
					update_name_tag() // monkestation edit: name tags
					dna.previous.Remove("name")
				if(dna.previous["UE"])
					dna.unique_enzymes = dna.previous["UE"]
					dna.previous.Remove("UE")
				if(dna.previous["blood_type"])
					dna.human_blood_type = blood_name_to_blood_type(dna.previous["blood_type"])
					dna.previous.Remove("blood_type")
				dna.temporary_mutations.Remove(mut)
				continue
	for(var/datum/mutation/human/HM in dna.mutations)
		if(HM?.timeout)
			dna.remove_mutation(HM.type)

/**
 * Handles calling metabolization for dead people.
 * Due to how reagent metabolization code works this couldn't be done anywhere else.
 *
 * Arguments:
 * - seconds_per_tick: The amount of time that has elapsed since the last tick.
 * - times_fired: The number of times SSmobs has ticked.
 */
/mob/living/carbon/proc/handle_dead_metabolization(seconds_per_tick, times_fired)
	if(stat != DEAD)
		return
	reagents?.metabolize(src, seconds_per_tick, times_fired, can_overdose = TRUE, liverless = TRUE, dead = TRUE) // Your liver doesn't work while you're dead.

/// Base carbon environment handler, adds natural stabilization
/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	. = ..()
	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure)

	// Set alerts and apply damage based on the amount of pressure
	switch(adjusted_pressure)
		// Very high pressure, show an alert and take damage
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			if(HAS_TRAIT(src, TRAIT_RESISTHIGHPRESSURE))
				clear_alert(ALERT_PRESSURE)
			else
				var/pressure_damage = min(((adjusted_pressure / HAZARD_HIGH_PRESSURE) - 1) * PRESSURE_DAMAGE_COEFFICIENT, MAX_HIGH_PRESSURE_DAMAGE) * physiology.pressure_mod * physiology.brute_mod * seconds_per_tick
				adjustBruteLoss(pressure_damage, required_bodytype = BODYTYPE_ORGANIC)
				throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/highpressure, 2)

		// High pressure, show an alert
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/highpressure, 1)

		// No pressure issues here clear pressure alerts
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			clear_alert(ALERT_PRESSURE)

		// Low pressure here, show an alert
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			// We have low pressure resit trait, clear alerts
			if(HAS_TRAIT(src, TRAIT_RESISTLOWPRESSURE))
				clear_alert(ALERT_PRESSURE)
			else
				throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/lowpressure, 1)

		// Very low pressure, show an alert and take damage
		else
			// We have low pressure resit trait, clear alerts
			if(HAS_TRAIT(src, TRAIT_RESISTLOWPRESSURE))
				clear_alert(ALERT_PRESSURE)
			else
				var/pressure_damage = LOW_PRESSURE_DAMAGE * physiology.pressure_mod * physiology.brute_mod * seconds_per_tick
				adjustBruteLoss(pressure_damage, required_bodytype = BODYTYPE_ORGANIC)
				throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/lowpressure, 2)
/**
 * Have two mobs share body heat between each other.
 * Account for the insulation and max temperature change range for the mob
 *
 * vars:
 * * M The mob/living/carbon that is sharing body heat
 */
/mob/living/carbon/proc/share_bodytemperature(mob/living/carbon/M)
	var/temp_diff = bodytemperature - M.bodytemperature
	if(temp_diff > 0) // you are warm share the heat of life
		M.adjust_bodytemperature((temp_diff * 0.5) * 0.075 KELVIN, use_insulation = TRUE) // warm up the giver
		adjust_bodytemperature((temp_diff * -0.5) * 0.075 KELVIN, use_insulation = TRUE) // cool down the reciver

	else // they are warmer leech from them
		adjust_bodytemperature((temp_diff * -0.5) * 0.075 KELVIN, use_insulation = TRUE) // warm up the reciver
		M.adjust_bodytemperature((temp_diff * 0.5) * 0.075 KELVIN, use_insulation = TRUE) // cool down the giver


///////////
//Stomach//
///////////

/mob/living/carbon/get_fullness()
	var/fullness = nutrition

	var/obj/item/organ/internal/stomach/belly = get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!belly) //nothing to see here if we do not have a stomach
		return fullness

	for(var/bile in belly.reagents.reagent_list)
		var/datum/reagent/bits = bile
		if(istype(bits, /datum/reagent/consumable))
			var/datum/reagent/consumable/goodbit = bile
			fullness += goodbit.nutriment_factor * goodbit.volume / goodbit.metabolization_rate
			continue
		fullness += 0.6 * bits.volume / bits.metabolization_rate //not food takes up space

	return fullness

/mob/living/carbon/has_reagent(reagent, amount = -1, needs_metabolizing = FALSE)
	. = ..()
	if(.)
		return
	var/obj/item/organ/internal/stomach/belly = get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!belly)
		return FALSE
	return belly.reagents.has_reagent(reagent, amount, needs_metabolizing)

/////////
//LIVER//
/////////

///Check to see if we have the liver, if not automatically gives you last-stage effects of lacking a liver.

/mob/living/carbon/proc/handle_liver(seconds_per_tick, times_fired)
	if(isnull(has_dna()))
		return

	var/obj/item/organ/internal/liver/liver = get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver)
		return

	reagents.end_metabolization(src, keep_liverless = TRUE) //Stops trait-based effects on reagents, to prevent permanent buffs
	reagents.metabolize(src, seconds_per_tick, times_fired, can_overdose=TRUE, liverless = TRUE)

	if(HAS_TRAIT(src, TRAIT_STABLELIVER) || HAS_TRAIT(src, TRAIT_LIVERLESS_METABOLISM))
		return

	adjustToxLoss(0.6 * seconds_per_tick, TRUE,  TRUE)
	adjustOrganLoss(pick(ORGAN_SLOT_HEART, ORGAN_SLOT_LUNGS, ORGAN_SLOT_STOMACH, ORGAN_SLOT_EYES, ORGAN_SLOT_EARS), 0.5* seconds_per_tick)

/mob/living/carbon/proc/undergoing_liver_failure()
	var/obj/item/organ/internal/liver/liver = get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver?.organ_flags & ORGAN_FAILING)
		return TRUE

////////////////
//BRAIN DAMAGE//
////////////////

/mob/living/carbon/proc/handle_brain_damage(seconds_per_tick, times_fired)
	for(var/T in get_traumas())
		var/datum/brain_trauma/BT = T
		BT.on_life(seconds_per_tick, times_fired)

/////////////////////////////////////
//MONKEYS WITH TOO MUCH CHOLOESTROL//
/////////////////////////////////////

/mob/living/carbon/proc/can_heartattack()
	if(!needs_heart())
		return FALSE
	var/obj/item/organ/internal/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart || (heart.organ_flags & ORGAN_SYNTHETIC))
		return FALSE
	return TRUE

/mob/living/carbon/proc/needs_heart()
	if(HAS_TRAIT(src, TRAIT_STABLEHEART))
		return FALSE
	if(dna && dna.species && (HAS_TRAIT(src, TRAIT_NOBLOOD) || isnull(dna.species.mutantheart))) //not all carbons have species!
		return FALSE
	return TRUE

/*
 * The mob is having a heart attack
 *
 * NOTE: this is true if the mob has no heart and needs one, which can be suprising,
 * you are meant to use it in combination with can_heartattack for heart attack
 * related situations (i.e not just cardiac arrest)
 */
/mob/living/carbon/proc/undergoing_cardiac_arrest()
	var/obj/item/organ/internal/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
	if(istype(heart) && heart.beating)
		return FALSE
	else if(!needs_heart())
		return FALSE
	return TRUE

/mob/living/carbon/proc/set_heartattack(status)
	if(status && !can_heartattack())
		return FALSE

	var/obj/item/organ/internal/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
	if(!istype(heart))
		return

	heart.beating = !status
