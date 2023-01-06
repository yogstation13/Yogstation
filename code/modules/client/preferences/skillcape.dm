/*
// TODO: Implement
/datum/preference/choiced/skillcape
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	can_randomize = FALSE
	savefile_identifier = PREFERENCE_PLAYER
	savefile_key = "skillcape"

/datum/preference/choiced/skillcape/deserialize(input, datum/preferences/preferences)
	if (!(input in GLOB.skillcapes))
		return "None"

	return ..(input, preferences)

/datum/preference/choiced/skillcape/init_possible_values()
	// TODO: I dont know if there is a way to filter it per client
	var/list/selectablecapes = list()
	var/max_eligable = TRUE
	for(var/id in GLOB.skillcapes)
		var/datum/skillcape/A = GLOB.skillcapes[id]
		if(!A.job)
			continue

		var/my_exp = C.calc_exp_type(get_exp_req_type())
		if(user.client.prefs.exp[A.job] >= A.minutes)
			selectablecapes += A
		else
			max_eligable = FALSE

	if(max_eligable)
		selectablecapes += GLOB.skillcapes["max"]

	return selectablecapes

/datum/preference/choiced/skillcape/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/skillcape/create_default_value()
	return "None"
*/
