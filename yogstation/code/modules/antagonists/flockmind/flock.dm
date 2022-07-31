GLOBAL_VAR(flock)

/datum/team/flock
	name = "flock"
	member_name = "flock member"
	var/stored_resources = 0
	var/mob/camera/flocktrace/flockmind/overmind 
	var/compute = 0

/datum/team/flock/New(starting_members)
	. = ..()
	if(!GLOB.flock)
		GLOB.flock = src
	else
		qdel(src)