/datum/quirk/gigantism
	name = "Gigantism"
	desc = "Your cells take up more space than others', giving you a larger appearance. You find it difficult to avoid looking down on others. Literally."
	quirk_flags = QUIRK_CHANGES_APPEARANCE
	value = 0
	gain_text = span_danger("You feel really tall!")
	lose_text = span_notice("You feel normal sized again.")
	medical_record_text = "Patient's growth is far above average, giving them a very large stature."
	mob_trait = TRAIT_GIANT
	icon = FA_ICON_CHEVRON_CIRCLE_UP
