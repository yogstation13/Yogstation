/datum/mutation/human/regeneration
	name = "Regeneration"
	desc = "Causes the subject to regenerate passively."
	instability = 15
	text_gain_indication = span_notice("You feel better.")

/datum/mutation/human/regeneration/on_life()
	owner.take_overall_damage(-1, -1)
	owner.adjustToxLoss(-0.5)
