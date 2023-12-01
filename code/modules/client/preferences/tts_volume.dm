/// Controls the volume at which the user hears in-person TTS
/datum/preference/numeric/tts_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_identifier = PREFERENCE_PLAYER
	savefile_key = "tts_volume"

	minimum = 0
	maximum = 100

/datum/preference/numeric/tts_volume/create_default_value()
	return DEFAULT_TTS_VOLUME
