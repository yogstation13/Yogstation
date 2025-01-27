/datum/symptom/sweat
	name = "Hyper-perspiration Effect"
	desc = "Causes the infected's sweat glands to go into overdrive."
	stage = 3
	badness = EFFECT_DANGER_HINDRANCE
	severity = 2

/datum/symptom/sweat/activate(mob/living/carbon/mob)
	if(prob(30))
		mob.emote("me",1,"is sweating profusely!")

		if(istype(mob.loc,/turf/open))
			var/turf/open/turf = mob.loc
			turf.add_liquid_list(list(/datum/reagent/water = 20), TRUE)
