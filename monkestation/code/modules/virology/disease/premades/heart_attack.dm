/datum/disease/acute/premade/heart_failure
	name = "Heart Eating Worms"
	form = "Worms"
	origin = "Heart Worms"
	category = DISEASE_HEART

	symptoms = list(
		new /datum/symptom/heart_failure
	)
	spread_flags = DISEASE_SPREAD_BLOOD
	robustness = 75

	infectionchance = 0
	infectionchance_base = 0
	stage_variance = 0
	severity = DISEASE_SEVERITY_DANGEROUS

/datum/disease/acute/premade/heart_failure/activate(mob/living/mob, starved, seconds_per_tick)
	if(iscarbon(mob))
		var/mob/living/carbon/carbon_mob = mob
		if(!carbon_mob.can_heartattack())
			cure(target = mob)
			return
	return ..()

/datum/disease/acute/premade/heart_failure/cure(add_resistance, mob/living/carbon/target)
	if(iscarbon(target))
		target.set_heartattack(FALSE)
	return ..()
