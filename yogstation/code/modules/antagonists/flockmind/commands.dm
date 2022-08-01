/datum/flock_command
	var/mob/camera/flocktrace/daddy
	var/atom/dude

/datum/flock_command/perform_action(atom/A)
	return FALSE

/datum/flock_command/New(mob/camera/flocktrace/ded, atom/A)
	. = ..()
	daddy = ded
	if(A)
		dude = A

/datum/flock_command/enemy_of_the_flock

/datum/flock_command/enemy_of_the_flock/perform_action(atom/A)
	if(!isliving(A) || isflockdrone(A) || iscameramob(A))
		return FALSE
	if(HAS_TRAIT(A, TRAIT_ENEMY_OF_THE_FLOCK))
		to_chat(daddy , "You order your allies to treat [A] as a normal being.")
		REMOVE_TRAIT(A, TRAIT_ENEMY_OF_THE_FLOCK, FLOCK_TRAIT)
		ping_flock("[A] is no longer The Enemy Of The Flock!",daddy)
	else
		ADD_TRAIT(A, TRAIT_ENEMY_OF_THE_FLOCK, FLOCK_TRAIT)
		to_chat(daddy , "You designate [A] as The Enemy Of The Flock.")
		ping_flock("[daddy] has designated [A] as The Enemy Of The Flock!",daddy)
	return TRUE