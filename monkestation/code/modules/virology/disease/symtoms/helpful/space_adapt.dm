/datum/symptom/spaceadapt
	name = "Space Adaptation Effect"
	desc = "Causes the infected to secrete a thin thermally insulating and spaceproof barrier from their skin."
	stage = 4
	max_count = 1
	badness = EFFECT_DANGER_HELPFUL
	severity = 0

	chance = 12
	max_chance = 25
	var/spaceproof = FALSE
/datum/symptom/spaceadapt/activate(mob/living/mob)
	mob.add_traits(list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE), type)
	if(!spaceproof)
		spaceproof = TRUE
		to_chat(mob, span_notice("You feel a warm glow along the length of your entire body"))

/datum/symptom/spaceadapt/deactivate(mob/living/carbon/mob)
	mob.remove_traits(list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE), type)
	if(spaceproof)
		spaceproof = FALSE
		to_chat(mob, span_notice("You feel the chill of the air once more."))
		mob.emote("shiver")
