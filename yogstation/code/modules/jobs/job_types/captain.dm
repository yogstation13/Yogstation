/datum/job/captain
	exp_requirements = 300
	exp_type_department = EXP_TYPE_COMMAND
	minimal_character_age = 28 // Jean-Luc Picard became Captain of the Stargazer when he was 28, for comparison.

/datum/job/hop/New()
	access += ACCESS_CAPTAIN
	return ..()
