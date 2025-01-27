/datum/symptom/minttoxin
	name = "Creosote Syndrome"
	desc = "Causes the infected to synthesize a wafer thin mint."
	stage = 4
	badness = EFFECT_DANGER_HARMFUL
	severity = 2

/datum/symptom/minttoxin/activate(mob/living/carbon/mob)
	if(istype(mob) && mob.reagents?.get_reagent_amount(/datum/reagent/consumable/mintextract) < 5)
		to_chat(mob, span_notice("You feel a minty freshness"))
		mob.reagents.add_reagent(/datum/reagent/consumable/mintextract, 5)
