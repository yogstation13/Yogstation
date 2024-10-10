/datum/preference/color/mutant_color_secondary
	savefile_key = "feature_mcolor_secondary"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_inherent_trait = TRAIT_MUTANT_COLORS_SECONDARY
	default_null = TRUE
	allows_nulls = TRUE

/datum/preference/color/mutant_color_secondary/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type
	return (TRAIT_MUTANT_COLORS_SECONDARY in species.inherent_traits)

/datum/preference/color/mutant_color_secondary/is_valid(value)
	if (!..(value))
		return FALSE

	if (is_color_dark(value, 15))
		return FALSE

	return TRUE
