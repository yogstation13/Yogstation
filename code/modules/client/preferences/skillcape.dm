/datum/preference/choiced/skillcape
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_identifier = PREFERENCE_PLAYER
	savefile_key = "skillcape_id"
	can_randomize = FALSE

/datum/preference/choiced/skillcape/init_possible_values()
	return GLOB.skillcapes

/datum/preference/choiced/skillcape/compile_constant_data()
	var/list/data = ..()

	var/list/cape_names = list()

	for(var/cape_id in GLOB.skillcapes)
		var/datum/skillcape/cape = GLOB.skillcapes[cape_id]
		cape_names[cape.id] = cape.name
	
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = cape_names

	return data

/datum/preference/choiced/skillcape/create_default_value()
	return "None"

/datum/preference/choiced/skillcape/deserialize(input, datum/preferences/preferences)
	if (!(input in GLOB.skillcapes))
		return "None"

	return ..(input, preferences)
