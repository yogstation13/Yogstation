/datum/symptom/drunk
	name = "Vermouth Syndrome"
	desc = "Causes the infected to synthesize pure ethanol."
	stage = 2
	badness = EFFECT_DANGER_HARMFUL
	multiplier = 3
	max_multiplier = 7

/datum/symptom/drunk/activate(mob/living/mob)
	if(ismouse(mob))
		return
	to_chat(mob, span_notice("You feel like you had one hell of a party!"))
	if (mob.reagents.get_reagent_amount(/datum/reagent/consumable/ethanol/vermouth) < multiplier*5)
		mob.reagents.add_reagent(/datum/reagent/consumable/ethanol/vermouth, multiplier*5)
