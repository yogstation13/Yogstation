//These are all minor mutations that affect your speech somehow.
//Individual ones aren't commented since their functions should be evident at a glance

/datum/mutation/human/regeneration
	name = "Regeneration"
	desc = "Causes the subject to regenerate passively."
	instability = 15
	text_gain_indication = span_notice("You feel better.")

/datum/mutation/human/nervousness/on_life()
	owner.take_overall_damage(-1, -1)
	owner.adjustToxLoss(-0.5)
