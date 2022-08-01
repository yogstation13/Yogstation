/datum/flock_command
	var/mob/camera/flocktrace/daddy
	var/atom/dude
	var/messg = "Uhh you will do nothing cry about it"

/datum/flock_command/proc/perform_action(atom/A)
	return FALSE //return TRUE if we want the order to be qdeleted, FALSE if we do an normal action but keep the order

/datum/flock_command/New(mob/camera/flocktrace/ded, atom/A)
	. = ..()
	daddy = ded
	if(daddy.stored_action && daddy.stored_action != src)
		qdel(daddy.stored_action)
		daddy.stored_action = src
	if(A)
		dude = A
	if(messg)
		to_chat(daddy, span_boldnotice(messg))

/datum/flock_command/enemy_of_the_flock
	messg = "Next living being you will click will be designated as The Enemy Of The Flock"

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

/datum/flock_command/move
	messg = "Your next click on an object will order the flockrone to move to it(if it is a valid location)."

/datum/flock_command/move/perform_action(atom/A)
	if(!dude || QDELETED(dude) || !isliving(dude))
		return TRUE 
	var/turf/T = isturf(A) ? A : get_turf(A)
	if(!is_station_level(T.z))
		to_chat(owner, span_warning("You can't do this if not on the station Z-level!"))
		return TRUE
	var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
	if(!surrounding_turfs.len)
		return FALSE
	var/mob/living/simple_animal/hostile/H = A
	if(isturf(H.loc) && get_dist(H, T) <= 35 && !H.key)
		H.LoseTarget()
		H.Goto(pick(surrounding_turfs), H.move_to_delay)
		return TRUE
	return FALSE
	