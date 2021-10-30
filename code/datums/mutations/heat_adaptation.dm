//Heat Resistance gives your entire body a blue halo, and makes you immune to the effects of a plasmafire minus the fire part.
/datum/mutation/human/heat_adaptation
	name = "Heat Adaptation"
	desc = "A strange mutation that renders the host immune to the heat of a plasma fire. Does not grant immunity to fire itself."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = span_notice("Your body feels cold!")
	time_coeff = 5
	instability = 40
	conflicts = list(SPACEMUT)

/datum/mutation/human/heat_adaptation/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "cold", -MUTATIONS_LAYER))

/datum/mutation/human/heat_adaptation/get_visual_indicator()
	return visual_indicators[type][1]

/datum/mutation/human/heat_adaptation/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_RESISTHEAT, "heat_adaptation")
	ADD_TRAIT(owner, TRAIT_RESISTHIGHPRESSURE, "heat_adaptation")
	ADD_TRAIT(owner, TRAIT_NO_PASSIVE_HEATING, "heat_adaptation")

/datum/mutation/human/heat_adaptation/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_RESISTHEAT, "heat_adaptation")
	REMOVE_TRAIT(owner, TRAIT_RESISTHIGHPRESSURE, "heat_adaptation")
	REMOVE_TRAIT(owner, TRAIT_NO_PASSIVE_HEATING, "heat_adaptation")

