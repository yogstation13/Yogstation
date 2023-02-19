/// The color of a PDA
/datum/preference/color/pda_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "pda_color"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/color/pda_color/create_default_value()
	return COLOR_OLIVE

/// The visual style of a PDA
/datum/preference/choiced/pda_style
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "pda_style"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/pda_style/init_possible_values()
	return GLOB.pda_styles

/// The visual theme of a PDA
/datum/preference/choiced/pda_theme
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "pda_theme"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/pda_theme/init_possible_values()
	return GLOB.pda_themes

/// Put ID into PDA when spawning
/datum/preference/toggle/id_in_pda
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "id_in_pda"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE
