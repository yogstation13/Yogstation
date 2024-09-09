/mob/dead/new_player
	/// What is our temp assignment, used for round start antag calculation
	var/datum/job/temp_assignment

/mob/dead/new_player/Destroy()
	. = ..()
	if(temp_assignment)
		temp_assignment = null
