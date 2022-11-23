/datum/condition_symptom/tiredness
	name = "Tiredness"
	severity = CONDITION_SYMPTOM_SEVERITY_ANNOYING

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

/datum/condition_symptom/tiredness/orexin
	name = "Orexin-related tiredness"
	var/last_sleep_time = 0

/datum/condition_symptom/tiredness/orexin/process_effects(var/datum/condition/parent, var/mob/living/carbon/human/H)
	. = FALSE
	if (prob(30))
		H.emote("yawn")
		. = TRUE
	if (prob(30))
		to_chat(H, span_notice(pick("You feel tired...", "You could go for a nap.", "You feel fatigued.")))
		M.drowsyness += 1 SECONDS
		. = TRUE
	if (prob(10) && world.time > (last_sleep_time + 30 SECONDS))
		H.Sleeping(3 SECONDS, 0)
		last_sleep_time = world.time
		return TRUE

