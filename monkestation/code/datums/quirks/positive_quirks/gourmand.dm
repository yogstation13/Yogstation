/datum/quirk/gourmand
	name = "Gourmand"
	desc = "You enjoy the finer things in life. You are able to have one more food buff applied at once."
	value = 2
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_HIDE_FROM_SCAN
	gain_text = span_notice("You start to enjoy fine cuisine.</span>")
	lose_text = span_warning("Those Space Twinkies are starting to look mighty fine.")
	mob_trait = TRAIT_GOURMAND
	icon = FA_ICON_COOKIE_BITE

/datum/quirk/gourmand/add()
	var/mob/living/carbon/human/holder = quirk_holder
	holder.max_food_buffs++

/datum/quirk/gourmand/remove()
	var/mob/living/carbon/human/holder = quirk_holder
	holder.max_food_buffs--
