// Nospoilcomp much to this, this is the opposite pair to the spoiling component
/datum/component/refrigerating

/datum/component/refrigerating/Initialize(...)
	. = ..()
	RegisterSignal(parent, COMSIG_STORAGE_OPEN, .proc/open)
	RegisterSignal(parent, COMSIG_STORAGE_CLOSE, .proc/close)
	for(var/atom/objects in parent)
		var/datum/component/spoiling/spoilcomp = objects.GetComponent(/datum/component/spoiling)
		if(spoilcomp)
			spoilcomp.cold = TRUE

/datum/component/refrigerating/Destroy(force, silent)
	. = ..()
	UnregisterSignal(parent, COMSIG_STORAGE_OPEN, .proc/open)
	UnregisterSignal(parent, COMSIG_STORAGE_CLOSE, .proc/close)	

/datum/component/refrigerating/proc/open(datum/source, atom/movable/AM)
	var/datum/component/spoiling/spoilcomp = AM.GetComponent(/datum/component/spoiling)
	if(spoilcomp)
		spoilcomp.cold = FALSE

/datum/component/refrigerating/proc/close(datum/source, atom/movable/AM)
	var/datum/component/spoiling/spoilcomp = AM.GetComponent(/datum/component/spoiling)
	if(spoilcomp)
		spoilcomp.cold = TRUE
