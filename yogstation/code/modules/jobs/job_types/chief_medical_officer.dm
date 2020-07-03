/datum/job/cmo
	exp_requirements = 720

/datum/job/cmo/New()
	access += list(ACCESS_CAPTAIN, ACCESS_PARAMEDIC)
	minimal_access += ACCESS_PARAMEDIC
	return ..()
