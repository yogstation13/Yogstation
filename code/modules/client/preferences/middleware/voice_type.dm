/// Middleware for voice types

/// Generate list of valid voice_types for the species
/datum/preference_middleware/voice_type/get_ui_data()
	. = list()
	.["available_voices"] = list()

	var/datum/species/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/species_id = initial(species_type.id)

	for(var/i in GLOB.voice_types)
		var/datum/voice/test = GLOB.voice_types[i]
		if(test.can_use(species_id))
			.["available_voices"] += test.name
