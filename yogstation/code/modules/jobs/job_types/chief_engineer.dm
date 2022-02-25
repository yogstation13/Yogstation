/datum/job/chief_engineer
	exp_requirements = 720
	minimal_character_age = 25 // Geordi LaForge became CE of the Entreprise when he was 30, for comparison.

/datum/job/chief_engineer/New()
	access += list(ACCESS_CAPTAIN,ACCESS_TCOM_ADMIN)
	minimal_access += ACCESS_TCOM_ADMIN
	return ..()
