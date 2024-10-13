/datum/symptom/stimulant
	name = "Adrenaline Extra"
	desc = "Causes the infected to synthesize artificial adrenaline."
	stage = 2
	badness = EFFECT_DANGER_HELPFUL
	max_multiplier = 20

/datum/symptom/stimulant/activate(mob/living/mob)
	to_chat(mob, span_notice("You feel a rush of energy inside you!"))
	if(ismouse(mob))
		mob.Shake(3,3, 10 SECONDS)
		return
	if (mob.reagents.get_reagent_amount(/datum/reagent/adrenaline) < 10)
		if(prob(5 * multiplier) && multiplier >= 8)
			mob.reagents.add_reagent(/datum/reagent/adrenaline, 11) //you are gonna probably die
		else
			mob.reagents.add_reagent(/datum/reagent/adrenaline, 4)
	if (prob(30))
		mob.adjust_jitter_up_to(1 SECONDS, 30 SECONDS)
