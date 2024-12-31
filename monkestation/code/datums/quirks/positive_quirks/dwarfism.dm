/datum/quirk/dwarfism
	name = "Dwarfism"
	desc = "Your cells take up less space than others', giving you a smaller appearance. You also find it easier to climb tables. Rock and Stone!"
	value = 4
	quirk_flags = QUIRK_CHANGES_APPEARANCE
	gain_text = span_danger("You feel really small!")
	lose_text = span_notice("You feel normal sized again.")
	medical_record_text = "Patient has stunted growth, resulting in a small stature."
	mob_trait = TRAIT_DWARF
	icon = FA_ICON_CHEVRON_CIRCLE_DOWN
