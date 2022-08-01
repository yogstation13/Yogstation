/datum/flock_command
	var/mob/camera/flocktrace/daddy 

/datum/flock_command/perform_action(atom/A)
	return FALSE

/datum/flock_command/New(mob/camera/flocktrace/ded)
	. = ..()
	daddy = ded

/datum/flock_command/enemy_of_the_flock

/datum/flock_command/enemy_of_the_flock/perform_action(atom/A)
	if(!isliving(A) || isflockdrone(A) || iscameramob(A))
		return FALSE
	if(HAS_TRAIT(A), TRAIT_ENEMY_OF_THE_FLOCK)
		REMOVE_TRAIT(A, TRAIT_ENEMY_OF_THE_FLOCK, FLOCK_TRAIT)
	else
		ADD_TRAIT(A, TRAIT_ENEMY_OF_THE_FLOCK, FLOCK_TRAIT)