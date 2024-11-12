/obj/item/gas_filter/clown
	name = "'enhanced' gas filter"
	desc = "A piece of filtering cloth to be used with atmospheric gas masks and emergency gas masks. This one uses a highly guarded formula to let small amounts of certain gasses through."
	icon_state = "gas_atmos_filter_clown"

	///List of gases with high filter priority
	high_filtering_gases = list(
		/datum/gas/plasma,
		/datum/gas/carbon_dioxide
		)
	///List of gases with medium filter priority
	mid_filtering_gases = list(
		/datum/gas/nitrium,
		/datum/gas/freon,
		/datum/gas/hypernoblium
		)


/obj/item/gas_filter/clown/reduce_filter_status(datum/gas_mixture/breath)
	breath = ..()
	var/danger_points = 0
	var/const/HIGH_FILTERING_RATIO = 0.001
	if (/datum/gas/nitrous_oxide in breath.gases)
		var/gas_id = /datum/gas/nitrous_oxide
		if(breath.get_breath_partial_pressure(breath.gases[gas_id][MOLES]) >= 1)
			breath.gases[gas_id][MOLES] = max(
				breath.gases[gas_id][MOLES] - filter_strength_high * filter_efficiency * HIGH_FILTERING_RATIO,
				(1 * BREATH_VOLUME) / (R_IDEAL_GAS_EQUATION * breath.temperature)
				)
			danger_points += 0.5
	if (/datum/gas/bz in breath.gases)
		var/gas_id = /datum/gas/bz
		if(breath.get_breath_partial_pressure(breath.gases[gas_id][MOLES]) >= 2)
			breath.gases[gas_id][MOLES] = max(
				breath.gases[gas_id][MOLES] - filter_strength_mid * filter_efficiency * HIGH_FILTERING_RATIO,
				(2 * BREATH_VOLUME) / (R_IDEAL_GAS_EQUATION * breath.temperature)
				)
			danger_points += 0.75

	filter_status = max(filter_status - danger_points, 0)
	return breath
