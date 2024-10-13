/datum/symptom/delightful
	name = "Delightful Effect"
	desc = "A more powerful version of Full Glass. Makes the infected feel delightful."
	stage = 4
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/delightful/activate(mob/living/carbon/mob)
	to_chat(mob, "<span class = 'notice'>You feel delightful!</span>")
	if (mob.reagents?.get_reagent_amount(/datum/reagent/drug/happiness) < 5)
		mob.reagents.add_reagent(/datum/reagent/drug/happiness, 10)
