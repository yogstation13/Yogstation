
// NOTE: Breathing happens once per FOUR TICKS, unless the last breath fails.
// In which case it happens once per ONE TICK!
// So oxyloss healing is done once per 4 ticks while oxyloss damage is applied once per tick!

/mob/living/carbon/human/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return

	. = ..()
	if(QDELETED(src))
		return FALSE

	if(!HAS_TRAIT(src, TRAIT_STASIS))
		if(.) //not dead

			for(var/datum/mutation/human/HM in dna.mutations) // Handle active genes
				HM.on_life(seconds_per_tick, times_fired)

		if(stat != DEAD)
			//heart attack stuff
			handle_heart(seconds_per_tick, times_fired)
			handle_liver(seconds_per_tick, times_fired)

		dna.species.spec_life(src, seconds_per_tick, times_fired) // for mutantraces
	else
		for(var/i in all_wounds)
			var/datum/wound/iter_wound = i
			iter_wound.on_stasis(seconds_per_tick, times_fired)

	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()
	update_name_tag(name) // monkestation edit: name tags

	if(stat != DEAD)
		return TRUE


/mob/living/carbon/human/calculate_affecting_pressure(pressure)
	var/chest_covered = FALSE
	var/head_covered = FALSE
	for(var/obj/item/clothing/equipped in get_equipped_items())
		if((equipped.body_parts_covered & CHEST) && (equipped.clothing_flags & STOPSPRESSUREDAMAGE))
			chest_covered = TRUE
		if((equipped.body_parts_covered & HEAD) && (equipped.clothing_flags & STOPSPRESSUREDAMAGE))
			head_covered = TRUE

	if(chest_covered && head_covered)
		return ONE_ATMOSPHERE
	if(ismovable(loc))
		/// If we're in a space with 0.5 content pressure protection, it averages the values, for example.
		var/atom/movable/occupied_space = loc
		return (occupied_space.contents_pressure_protection * ONE_ATMOSPHERE + (1 - occupied_space.contents_pressure_protection) * pressure)
	return pressure

/mob/living/carbon/human/check_breath(datum/gas_mixture/breath, skip_breath = FALSE)
	var/obj/item/organ/internal/lungs/human_lungs = get_organ_slot(ORGAN_SLOT_LUNGS)
	if(human_lungs)
		return human_lungs.check_breath(breath, src, skip_breath)

	failed_last_breath = TRUE

	var/datum/species/human_species = dna.species

	switch(human_species.breathid)
		if("o2")
			throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)
		if("plas")
			throw_alert(ALERT_NOT_ENOUGH_PLASMA, /atom/movable/screen/alert/not_enough_plas)
		if("co2")
			throw_alert(ALERT_NOT_ENOUGH_CO2, /atom/movable/screen/alert/not_enough_co2)
		if("n2")
			throw_alert(ALERT_NOT_ENOUGH_NITRO, /atom/movable/screen/alert/not_enough_nitro)
	return FALSE

/mob/living/carbon/human/handle_random_events(seconds_per_tick, times_fired)
	//Puke if toxloss is too high
	if(stat)
		return
	if(getToxLoss() < 45 || nutrition <= 20)
		return

	lastpuke += SPT_PROB(30, seconds_per_tick)
	if(lastpuke >= 50) // about 25 second delay I guess // This is actually closer to 150 seconds
		vomit(20)
		lastpuke = 0


/mob/living/carbon/human/has_smoke_protection()
	if(isclothing(wear_mask))
		if(wear_mask.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
			return TRUE
	if(isclothing(glasses))
		if(glasses.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
			return TRUE
	if(isclothing(head))
		var/obj/item/clothing/CH = head
		if(CH.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
			return TRUE
	return ..()

/mob/living/carbon/human/proc/handle_heart(seconds_per_tick, times_fired)
	var/we_breath = !HAS_TRAIT_FROM(src, TRAIT_NOBREATH, SPECIES_TRAIT)

	if(!undergoing_cardiac_arrest())
		return

	if(we_breath)
		adjustOxyLoss(4 * seconds_per_tick)
		Unconscious(80)
	// Tissues die without blood circulation
	adjustBruteLoss(1 * seconds_per_tick)

/mob/living/carbon/human/proc/get_thermal_protection()
	var/thermal_protection = 0 //Simple check to estimate how protected we are against multiple temperatures
	if(wear_suit)
		if(wear_suit.max_heat_protection_temperature >= FIRE_SUIT_MAX_TEMP_PROTECT)
			thermal_protection += wear_suit.max_heat_protection_temperature
	if(head)
		if((head.max_heat_protection_temperature >= FIRE_HELM_MAX_TEMP_PROTECT))
			thermal_protection += head.max_heat_protection_temperature
	thermal_protection = thermal_protection * 0.5
	return thermal_protection
