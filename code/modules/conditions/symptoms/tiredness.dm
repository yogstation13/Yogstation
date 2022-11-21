/datum/condition_symptom/tiredness
	name = "Tiredness"

/datum/condition_symptom/tiredness/process_effects(var/datum/condition/parent, var/mob/living/carbon/human/H)
	if (prob(10))
		H.emote("yawn")
		return TRUE
	if (prob(10))
		to_chat(H, span_notice(pick("You feel tired...", "You could go for a nap.", "You feel fatigued.")))
		M.drowsyness += 1 SECONDS
		return TRUE
	if (prob(1))
		H.Sleeping(3 SECONDS, 0)
		return TRUE
	return FALSE
