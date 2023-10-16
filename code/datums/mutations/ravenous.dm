/datum/mutation/human/ravenous
	name = "Ravenous"
	desc = "An inconvenient mutation that greatly increases the host's metabolism to the point of constant hunger."
	quality = MINOR_NEGATIVE
	difficulty = 16 //should be annoying to get because of how silly it can be
	locked = TRUE
	text_gain_indication = span_notice("You need more and more and MORE!")
	text_lose_indication = span_notice("That should be enough for now.")
	instability = 10 //could be an upside maybe, or could force it on some poor sap while stabilized

/datum/mutation/human/ravenous/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_EAT_MORE, "ravenous")
	ADD_TRAIT(owner, TRAIT_BOTTOMLESS_STOMACH, "ravenous")
	ADD_TRAIT(owner, TRAIT_VORACIOUS, "ravenous")

/datum/mutation/human/ravenous/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_EAT_MORE, "ravenous")
	REMOVE_TRAIT(owner, TRAIT_BOTTOMLESS_STOMACH, "ravenous")
	REMOVE_TRAIT(owner, TRAIT_VORACIOUS, "ravenous")

