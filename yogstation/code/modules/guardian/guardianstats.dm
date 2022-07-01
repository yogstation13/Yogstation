/datum/guardian_stats
	var/damage = 1
	var/defense = 1
	var/speed = 1
	var/potential = 1
	var/range = 1
	var/ranged = FALSE
	var/datum/guardian_ability/major/ability
	var/list/datum/guardian_ability/minor/minor_abilities = list()

/datum/guardian_stats/proc/Apply(mob/living/simple_animal/hostile/guardian/guardian)
	guardian.range = range * 2
	if (ranged)
		guardian.ranged = TRUE
		guardian.ranged_cooldown_time = 20 / speed
	else
		guardian.melee_damage_lower = damage * 5
		guardian.melee_damage_upper = damage * 5
		guardian.obj_damage = damage * 16
	var/armor = clamp((max(6 - defense, 1)/2.5)/2, 0.25, 1)
	guardian.damage_coeff = list(BRUTE = armor, BURN = armor, TOX = armor, CLONE = armor, STAMINA = 0, OXY = armor)
	if (damage == 5)
		guardian.environment_smash = ENVIRONMENT_SMASH_WALLS
	guardian.atk_cooldown = (15 / speed) * 1.5
	if (ability)
		ability.guardian = guardian
		ability.Apply()
	for (var/datum/guardian_ability/minor/minor in minor_abilities)
		minor.guardian = guardian
		minor.Apply()

/datum/guardian_stats/proc/Unapply(mob/living/simple_animal/hostile/guardian/guardian)
	guardian.range = initial(guardian.range)
	guardian.ranged = FALSE
	guardian.ranged_cooldown_time = initial(guardian.ranged_cooldown_time)
	guardian.melee_damage_lower = initial(guardian.melee_damage_lower)
	guardian.melee_damage_upper = initial(guardian.melee_damage_upper)
	guardian.obj_damage = initial(guardian.obj_damage)
	guardian.damage_coeff = initial(guardian.damage_coeff)
	guardian.environment_smash = initial(guardian.environment_smash)
	guardian.atk_cooldown = initial(guardian.atk_cooldown)
	if (ability)
		ability.Remove()
	for (var/datum/guardian_ability/minor/minor in minor_abilities)
		minor.Remove()

/datum/guardian_stats/proc/HasMinorAbility(typepath)
	for (var/datum/guardian_ability/minor/minor in minor_abilities)
		if (istype(minor, typepath))
			return TRUE
	return FALSE

/datum/guardian_stats/proc/AddMinorAbility(typepath)
	var/datum/guardian_ability/minor/minor_ability = new typepath
	minor_ability.master_stats = src
	minor_abilities += minor_ability

/datum/guardian_stats/proc/TakeMinorAbility(typepath)
	for (var/datum/guardian_ability/minor/minor in minor_abilities)
		if (istype(minor, typepath))
			minor_abilities -= minor
			qdel(minor)

/datum/guardian_stats/proc/short_info()
	var/list/stats_info = list()
	stats_info += "Damage [level_to_grade(damage)]"
	stats_info += "Defense [level_to_grade(defense)]"
	stats_info += "Speed [level_to_grade(speed)]"
	stats_info += "Potential [level_to_grade(potential)]"
	stats_info += "Range [level_to_grade(range)]"
	if (ability)
		stats_info += ability.name
	for (var/A in minor_abilities)
		var/datum/guardian_ability/minor/minor_ability = A
		stats_info += minor_ability.name
	return stats_info.Join(", ")
