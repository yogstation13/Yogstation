#define JOB_MODIFICATION_MAP_NAME "Clown Station"

//Removed jobs
MAP_REMOVE_JOB(hos)
MAP_REMOVE_JOB(captain)
MAP_REMOVE_JOB(qm)
MAP_REMOVE_JOB(cargo_tech)
MAP_REMOVE_JOB(mining)
MAP_REMOVE_JOB(bartender)
MAP_REMOVE_JOB(cook)
MAP_REMOVE_JOB(hydro)
MAP_REMOVE_JOB(janitor)
MAP_REMOVE_JOB(curator)
MAP_REMOVE_JOB(lawyer)
MAP_REMOVE_JOB(tourist)
MAP_REMOVE_JOB(clerk)
MAP_REMOVE_JOB(chaplain)
MAP_REMOVE_JOB(chief_engineer)
MAP_REMOVE_JOB(engineer)
MAP_REMOVE_JOB(atmos)
MAP_REMOVE_JOB(signal_tech)
MAP_REMOVE_JOB(cmo)
MAP_REMOVE_JOB(doctor)
MAP_REMOVE_JOB(chemist)
MAP_REMOVE_JOB(geneticist)
MAP_REMOVE_JOB(virologist)
MAP_REMOVE_JOB(miningmedic)
MAP_REMOVE_JOB(paramedic)
MAP_REMOVE_JOB(psych)
MAP_REMOVE_JOB(rd)
MAP_REMOVE_JOB(scientist)
MAP_REMOVE_JOB(roboticist)
MAP_REMOVE_JOB(warden)
MAP_REMOVE_JOB(detective)
MAP_REMOVE_JOB(officer)
MAP_REMOVE_JOB(hop)


//Job changes
/datum/job/clown/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2^10*32
	spawn_positions = 2^10*32

/datum/job/clown/get_access()
	. = ..()
	MAP_JOB_CHECK
	return get_all_accesses()

/datum/job/assistant/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 0
    spawn_positions = 0