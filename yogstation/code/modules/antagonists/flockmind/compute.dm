/datum/component/flock_compute
	var/compute_amount = 0
	var/requires_alive = TRUE

/datum/component/flock_compute/Initialize(initial_compute=0, requires_living_if_mob = TRUE)
	var/datum/team/flock/team = get_flock_team()
	team.add_computing_datum(src)
	compute_amount = initial_compute
	requires_alive = requires_living_if_mob

/datum/component/flock_compute/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CHANGE_COMPUTE, .proc/change_compute)

/datum/component/flock_compute/Destroy()
	var/datum/team/flock/team = get_flock_team()
	team.remove_computing_datum(src)
	. = ..()

/datum/component/flock_compute/proc/change_compute(new_amount, deleteself = FALSE)
	if(deleteself)
		qdel(src)
		return
	if(new_amount != compute_amount)
		compute_amount = new_amount
	var/datum/team/flock/team = get_flock_team()
	team.update_flock_status(FALSE)

/datum/component/flock_compute/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_CHANGE_COMPUTE)