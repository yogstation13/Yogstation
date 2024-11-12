/datum/quirk/voracious
	name = "Voracious"
	// desc = "Nothing gets between you and your food. You eat faster and can binge on junk food! Being fat suits you just fine." monkestation edit original
	desc = "Nothing gets between you and your food. You eat faster and can binge on junk food! Being fat suits you just fine. Also allows you to have an additional food buff."
	icon = FA_ICON_DRUMSTICK_BITE
	value = 6 // Monkestation change 4 -> 6
	mob_trait = TRAIT_VORACIOUS
	gain_text = span_notice("You feel HONGRY.")
	lose_text = span_danger("You no longer feel HONGRY.")
	mail_goodies = list(/obj/effect/spawner/random/food_or_drink/dinner)

// MONKESTATION EDIT START
/datum/quirk/voracious/add()
	var/mob/living/carbon/human/holder = quirk_holder
	holder.max_food_buffs ++

/datum/quirk/voracious/remove()
	var/mob/living/carbon/human/holder = quirk_holder
	holder.max_food_buffs --
// MONKESTATION EDIT END
