GLOBAL_LIST_EMPTY_TYPED(bluespace_varient_list, /datum/symptom_varient/bluespace)

/datum/symptom_varient/bluespace
	name = "Quantumly Entangled"
	desc = "The cloning process seems to have caused genes to communicate through hosts."
	cooldown_time = 30 SECONDS

	weight = 2

	var/bluespace_id = 0
	var/static/last_bluespace_id = 0

/datum/symptom_varient/bluespace/New(datum/symptom/host, bluespace_id)
	. = ..()
	GLOB.bluespace_varient_list += src
	if(isnull(bluespace_id))
		bluespace_id = last_bluespace_id++
	src.bluespace_id = bluespace_id

/datum/symptom_varient/bluespace/Destroy(force)
	GLOB.bluespace_varient_list -= src
	return ..()

/datum/symptom_varient/bluespace/setup_varient()
	. = ..()
	RegisterSignal(host_symptom, COMSIG_SYMPTOM_TRIGGER, PROC_REF(propagate))

/datum/symptom_varient/bluespace/Copy(datum/symptom/new_symp)
	return new /datum/symptom_varient/bluespace(new_symp, bluespace_id)

/datum/symptom_varient/bluespace/proc/propagate()
	for(var/datum/symptom_varient/bluespace/bluespace as anything in GLOB.bluespace_varient_list)
		if(QDELETED(bluespace) || bluespace_id != bluespace.bluespace_id)
			continue
		bluespace.trigger_symptom()
