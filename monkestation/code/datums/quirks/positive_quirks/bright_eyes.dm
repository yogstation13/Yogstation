/datum/quirk/cybernetics_quirk/bright_eyes
	name = "Bright Eyes"
	desc = "You've got bright, cybernetic eyes!"
	icon = FA_ICON_SUN
	value = 3
	quirk_flags = parent_type::quirk_flags | QUIRK_CHANGES_APPEARANCE
	gain_text = span_notice("Your eyes feel extra shiny.")
	lose_text = span_danger("You can't feel your eyes anymore.")
	medical_record_text = "Patient has acquired and been installed with high luminosity eyes."
	cybernetic_type = /obj/item/organ/internal/eyes/robotic/glow

/datum/quirk/cybernetics_quirk/bright_eyes/get_original_type()
	return quirk_holder?.has_dna()?.species?.mutanteyes || /obj/item/organ/internal/eyes
