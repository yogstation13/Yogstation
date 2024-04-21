/datum/preference/color/mutant_color
	blacklisted_species = list(/datum/species/vox)

/datum/preference/color/mutant_color_secondary
	savefile_key = "feature_mcolor_secondary"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_species_trait = MUTCOLORS_SECONDARY
	blacklisted_species = list(/datum/species/vox)

/datum/preference/color/mutant_color_secondary/create_default_value()
	return sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]")

/datum/preference/color/mutant_color_secondary/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["mcolor_secondary"] = value
