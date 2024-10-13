/datum/symptom/gregarious
	name = "Gregarious Impetus"
	desc = "Infests the social structures of the infected's brain, causing them to feel better in crowds of other potential victims, and punishing them for being alone."
	stage = 4
	badness = EFFECT_DANGER_HINDRANCE
	max_chance = 25
	max_multiplier = 4

/datum/symptom/gregarious/activate(mob/living/carbon/mob)
	var/others_count = 0
	for(var/mob/living/carbon/m in oview(5, mob))
		others_count += 1

	if (others_count >= multiplier)
		to_chat(mob, span_notice("A friendly sensation is satisfied with how many are near you - for now."))
		mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -multiplier)
		mob.reagents.add_reagent(/datum/reagent/drug/happiness, multiplier) // ADDICTED TO HAVING FRIENDS
		if (multiplier < max_multiplier)
			multiplier += 0.15 // The virus gets greedier
	else
		to_chat(mob, span_warning("A hostile sensation in your brain stings you... it wants more of the living near you."))
		mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, multiplier / 2)
		mob.AdjustParalyzed(multiplier) // This practically permaparalyzes you at higher multipliers but
		mob.AdjustKnockdown(multiplier) // that's your fucking fault for not being near enough people
		mob.AdjustStun(multiplier)   // You'll have to wait until the multiplier gets low enough
		if (multiplier > 1)
			multiplier -= 0.3 // The virus tempers expectations
