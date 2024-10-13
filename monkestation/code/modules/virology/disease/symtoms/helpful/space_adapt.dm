/datum/symptom/spaceadapt
	name = "Space Adaptation Effect"
	desc = "Causes the infected to secrete a thin thermally insulating and spaceproof barrier from their skin."
	stage = 4
	max_count = 1
	badness = EFFECT_DANGER_HELPFUL
	chance = 10
	max_chance = 25

/datum/symptom/spaceadapt/activate(mob/living/mob)
	mob.add_traits(list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE), type)

/datum/symptom/spaceadapt/deactivate(mob/living/carbon/mob)
	mob.remove_traits(list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE), type)
