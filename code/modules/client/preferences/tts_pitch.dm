/datum/preference/numeric/tts_pitch
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "tts_pitch"

	minimum = 0.8
	maximum = 1.2
	step = 0.05

/datum/preference/numeric/tts_pitch/create_default_value()
	return rand(minimum * 10, maximum * 10) / 10

/datum/preference/numeric/tts_pitch/apply_to_human(mob/living/carbon/human/target, value)
	target.tts_pitch = value
