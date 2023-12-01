/// Controls the volume at which the user hears radio TTS
/datum/preference/numeric/tts_volume_radio
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_identifier = PREFERENCE_PLAYER
	savefile_key = "tts_volume_radio"

	minimum = 0
	maximum = 100

/datum/preference/numeric/tts_volume_radio/create_default_value()
	return DEFAULT_TTS_VOLUME_RADIO
