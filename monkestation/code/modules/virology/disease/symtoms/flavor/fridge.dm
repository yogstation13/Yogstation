/datum/symptom/fridge
	name = "Refridgerator Syndrome"
	desc = "Causes the infected to shiver at random."
	encyclopedia = "No matter whether the room is cold or hot. This has no effect on their body temperature."
	stage = 2
	max_multiplier = 4
	multiplier = 1
	badness = EFFECT_DANGER_FLAVOR
	severity = 1

/datum/symptom/fridge/activate(mob/living/mob)
	to_chat(mob, span_warning("[pick("You feel cold.", "You shiver.")]"))
	mob.emote("shiver")
	set_body_temp(mob)

/datum/symptom/fridge/proc/set_body_temp(mob/living/mob)
	if(multiplier >= 3) // when unsafe the shivers can cause cold damage
		mob.add_homeostasis_level(type, -6, 0.25 KELVIN * power)
	else
		mob.add_homeostasis_level(type, -6 * power, 0.25 KELVIN * power)

/datum/symptom/fridge/deactivate(mob/living/carbon/mob)
	if(mob)
		mob.remove_homeostasis_level(type)
