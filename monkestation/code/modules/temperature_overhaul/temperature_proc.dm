#define THERMAL_PROTECTION_HEAD 0.3
#define THERMAL_PROTECTION_CHEST 0.2
#define THERMAL_PROTECTION_GROIN 0.10
#define THERMAL_PROTECTION_LEG (0.075 * 2)
#define THERMAL_PROTECTION_FOOT (0.025 * 2)
#define THERMAL_PROTECTION_ARM (0.075 * 2)
#define THERMAL_PROTECTION_HAND (0.025 * 2)

/**
 * Get the insulation that is appropriate to the temperature you're being exposed to.
 * All clothing, natural insulation, and traits are combined returning a single value.
 *
 * Args
 * * temperature - what temperature is being exposed to this mob?
 * some articles of clothing are only effective within a certain temperature range
 *
 * returns the percentage of protection as a value from 0 - 1
**/
/mob/living/proc/get_insulation(temperature = T20C)
	// There is an occasional bug where the temperature is miscalculated in areas with small amounts of gas.
	// This is necessary to ensure that does not affect this calculation.
	// Space's temperature is 2.7K and most suits that are intended to protect against any cold, protect down to 2.0K.
	temperature = max(temperature, TCMB)

	var/thermal_protection_flags = NONE
	for(var/obj/item/worn in get_equipped_items())
		var/valid = FALSE
		if(isnum(worn.max_heat_protection_temperature) && isnum(worn.min_cold_protection_temperature))
			valid = worn.max_heat_protection_temperature >= temperature && worn.min_cold_protection_temperature <= temperature

		else if (isnum(worn.max_heat_protection_temperature))
			valid = worn.max_heat_protection_temperature >= temperature

		else if (isnum(worn.min_cold_protection_temperature))
			valid = worn.min_cold_protection_temperature <= temperature

		if(valid)
			thermal_protection_flags |= worn.body_parts_covered

	var/thermal_protection = temperature_insulation
	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection += THERMAL_PROTECTION_HEAD
		if(thermal_protection_flags & CHEST)
			thermal_protection += THERMAL_PROTECTION_CHEST
		if(thermal_protection_flags & GROIN)
			thermal_protection += THERMAL_PROTECTION_GROIN
		if(thermal_protection_flags & LEGS)
			thermal_protection += THERMAL_PROTECTION_LEG
		if(thermal_protection_flags & FEET)
			thermal_protection += THERMAL_PROTECTION_FOOT
		if(thermal_protection_flags & ARMS)
			thermal_protection += THERMAL_PROTECTION_ARM
		if(thermal_protection_flags & HANDS)
			thermal_protection += THERMAL_PROTECTION_HAND

	return min(1, thermal_protection)

#undef THERMAL_PROTECTION_HEAD
#undef THERMAL_PROTECTION_CHEST
#undef THERMAL_PROTECTION_GROIN
#undef THERMAL_PROTECTION_LEG
#undef THERMAL_PROTECTION_FOOT
#undef THERMAL_PROTECTION_ARM
#undef THERMAL_PROTECTION_HAND

/**
 * Returns a multiplier to apply to temperature-based damage given to a mob, based on the exposed temperature.
 *
 * Args
 * * temperature - what temperature is being exposed to this mob?
 *
 * Returns a multiplier as a value from 0 - 1.
 */
/mob/living/proc/get_insulation_damage_multiplier(temperature = T20C)
	return (1 - get_insulation(temperature))

/mob/living/carbon/human/get_insulation_damage_multiplier(temperature = T20C)
	. = ..()
	if(physiology)
		if(temperature < bodytemp_cold_damage_limit)
			. *= physiology.cold_mod
		else if(temperature > bodytemp_heat_damage_limit)
			. *= physiology.heat_mod

/mob/living/proc/adjust_bodytemperature(amount = 0, min_temp = 0, max_temp = INFINITY, use_insulation = FALSE)
	// apply insulation to the amount of change
	if(use_insulation)
		amount *= (1 - get_insulation(bodytemperature + amount))
	if(amount == 0)
		return FALSE
	if(amount == 0)
		return 0
	amount = round(amount, 0.01)

	if(bodytemperature >= min_temp && bodytemperature <= max_temp)
		var/old_temp = bodytemperature
		bodytemperature = clamp(bodytemperature + amount, min_temp, max_temp)
		SEND_SIGNAL(src, COMSIG_LIVING_BODY_TEMPERATURE_CHANGE, old_temp, bodytemperature)
		// body_temperature_alerts()
		return bodytemperature - old_temp
	return 0

// Robot bodytemp unimplemented for now. Add overheating later >:3
/mob/living/silicon/adjust_bodytemperature(amount, min_temp, max_temp, use_insulation)
	return

/**
 * Get the temperature of the skin of the mob
 *
 * This is a weighted average of the body temperature and the temperature of the air around the mob,
 * plus some other modifiers
 */
/mob/living/proc/get_skin_temperature()
	var/area_temperature = get_temperature(loc?.return_air())
	if(!(mob_biotypes & MOB_ORGANIC) && !isipc(src))
		// non-organic mobs likely don't feel or regulate temperature
		// so we can just report the area temp... probably
		// there's an argument to be made for putting the cold blooded check here
		return round(area_temperature, 0.01)

	// calculate skin temp based on a weight average between body temp and area temp plus a multiplier
	// this weighting gives us about 34.4c for a 37c body temp in a 20c room which is about average
	var/insulation = get_insulation(area_temperature)
	// converting to celcius as it's easier to work with / multiply on
	var/skin_temp = 1.1 * ((KELVIN_TO_CELCIUS(bodytemperature) * 2 + KELVIN_TO_CELCIUS(area_temperature) * (1 - insulation)) / (3 - insulation))

	if(temperature_homeostasis_speed != 0) // not cold blooded
		if(bodytemperature >= standard_body_temperature + 2 CELCIUS)
			skin_temp *= 1.1 // vasodilation / sweating
		if(bodytemperature <= standard_body_temperature + ((bodytemp_cold_damage_limit - standard_body_temperature) * 0.5))
			skin_temp *= 0.9 // vasoconstriction

	// back to kelvin
	. = CELCIUS_TO_KELVIN(skin_temp)
	// and if we're on fire just add a flat amount of heat
	if(on_fire)
		. += fire_stacks ** 2 KELVIN

	return .
