/datum/symptom/asphyxiation
	name = "Acute respiratory distress syndrome"
	desc = "The virus causes shrinking of the host's lungs, causing severe asphyxiation. May also lead to brain damage in critical patients."
	badness = EFFECT_DANGER_DEADLY
	max_chance = 5
	max_multiplier = 5
	stage = 3

/datum/symptom/asphyxiation/activate(mob/living/carbon/mob)
	if(HAS_TRAIT(mob, TRAIT_NOBREATH))
		return
	mob.emote("gasp")
	if(prob(20) && multiplier >= 4 && iscarbon(mob))
		mob.reagents.add_reagent_list(list(/datum/reagent/toxin/pancuronium = 3, /datum/reagent/toxin/sodium_thiopental = 3))
	mob.adjustOxyLoss(rand(5,15) * multiplier)
	if(mob.getOxyLoss() >= 120 && multiplier == 5)
		mob.adjustOxyLoss(rand(5,7) * multiplier)
		mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, multiplier)
