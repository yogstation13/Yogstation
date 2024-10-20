/datum/symptom/damage_converter
	name = "Toxic Compensation"
	desc = "Stimulates cellular growth within the body, causing it to regenerate tissue damage. Repair done by these cells causes toxins to build up in the body."
	badness = EFFECT_DANGER_HELPFUL
	stage = 3
	chance = 10
	max_chance = 50
	multiplier = 5
	max_multiplier = 10

/datum/symptom/damage_converter/activate(mob/living/carbon/mob)
	if(HAS_TRAIT(mob, TRAIT_TOXINLOVER) || HAS_TRAIT(mob, TRAIT_TOXIMMUNE))
		return

	if(mob.getFireLoss() > 0 || mob.getBruteLoss() > 0)
		var/get_damage = rand(1, 3)
		mob.adjustFireLoss(-get_damage)
		mob.adjustBruteLoss(-get_damage)
		mob.adjustToxLoss(max(1,get_damage * multiplier / 5))
