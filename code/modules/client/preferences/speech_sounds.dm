/datum/preference/toggle/speech_hear
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "speech_hear"
	savefile_identifier = PREFERENCE_PLAYER

/// Controls the volume at which the user hears in-person Speech sounds
/datum/preference/numeric/speech_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "speech_volume"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 100

/datum/preference/numeric/speech_volume/create_default_value()
	return DEFAULT_SPEECH_VOLUME




/datum/preference/choiced/voice_type
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "voice_type"

/datum/preference/choiced/voice_type/init_possible_values()
	return GLOB.voice_types

/datum/preference/choiced/voice_type/compile_constant_data()
	var/list/data = ..()

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = GLOB.voice_types

	return data

//this doesn't yet prevent people from taking invalid voices, but it'll stop you from having one to start
/datum/preference/choiced/voice_type/create_informed_default_value(datum/preferences/preferences)
	var/datum/species/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/species_id = initial(species_type.id)

	var/list/valid = list()
	for(var/i in GLOB.voice_types)
		var/datum/voice/test = GLOB.voice_types[i]
		if(test.can_use(species_id))
			valid |= i
			
	if(length(valid))
		return pick(valid)
	return pick(GLOB.voice_types)

/datum/preference/choiced/voice_type/apply_to_human(mob/living/carbon/human/target, value)
	target.voice_type = GLOB.voice_types[value]


/datum/preference/choiced/voice_type/deserialize(input, datum/preferences/preferences)
	var/datum/species/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/species_id = initial(species_type.id)

	var/datum/voice/test = GLOB.voice_types[input]

	if (!test || !test.can_use(species_id))
		return create_informed_default_value(preferences)

	return ..(input, preferences)
