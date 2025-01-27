/datum/symptom/disfiguration
	name = "Disfiguration"
	desc = "The virus liquefies facial muscles, disfiguring the host."
	max_count = 1
	badness = EFFECT_DANGER_FLAVOR
	severity = 1
	stage = 2

/datum/symptom/disfiguration/activate(mob/living/carbon/mob)
	ADD_TRAIT(mob, TRAIT_DISFIGURED, type)
	mob.visible_message(span_warning("[mob]'s face appears to cave in!"), span_notice("You feel your face crumple and cave in!"))

/datum/symptom/disfiguration/deactivate(mob/living/carbon/mob)
	REMOVE_TRAIT(mob, TRAIT_DISFIGURED, type)
