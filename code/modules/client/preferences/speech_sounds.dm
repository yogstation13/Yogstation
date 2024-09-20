/datum/preference/toggle/speech_hear
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "speech_hear"
	savefile_identifier = PREFERENCE_PLAYER

/// Controls the volume at which the user hears in-person TTS
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

/datum/preference/choiced/voice_type/apply_to_human(mob/living/carbon/human/target, value)
	target.voice_type = GLOB.voice_types[value]




//ty ynot
// /datum/preference/toggle/tts_hear_radio
// 	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
// 	savefile_key = "tts_hear_radio"
// 	savefile_identifier = PREFERENCE_PLAYER

// /// Controls the volume at which the user hears radio TTS
// /datum/preference/numeric/tts_volume_radio
// 	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
// 	savefile_identifier = PREFERENCE_PLAYER
// 	savefile_key = "tts_volume_radio"

// 	minimum = 0
// 	maximum = 100

// /datum/preference/numeric/tts_volume_radio/create_default_value()
// 	return DEFAULT_TTS_VOLUME_RADIO

