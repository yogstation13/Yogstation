/datum/symptom/wendigo_warning
	name = "Fullness Syndrome"
	desc = "An unsual symptom that causes the infected to feel hungry, even after eating."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	severity = 3
	var/list/host_messages = list(
		"Your stomach grumbles.",
		"You feel peckish.",
		"So hungry...",
		"Your stomach feels empty.",
		"Hunger...",
		"Who are we...?",
		"Our mind hurts...",
		"You feel... different...",
		"There's something wrong."
	)

/datum/symptom/wendigo_warning/activate(mob/living/mob)
	to_chat(mob, span_warning("[pick(host_messages)]"))
	mob.adjust_nutrition(-10)
