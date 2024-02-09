/// A status effect used for adding confusion to a mob.
/datum/status_effect/confusion
	id = "confusion"
	alert_type = null
	remove_on_fullheal = TRUE

/datum/status_effect/confusion/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/confusion/on_apply()
	RegisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(on_move))
	return TRUE

/datum/status_effect/confusion/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE)

/// Signal proc for [COMSIG_MOB_CLIENT_PRE_MOVE]. We have a chance to mix up our movement pre-move with confusion.
/datum/status_effect/confusion/proc/on_move(datum/source, direction)
	SIGNAL_HANDLER

	var/new_dir

	if(prob(50))
		new_dir = angle2dir(dir2angle(direction) + pick(45, -45))

	if(!isnull(new_dir))
		source = get_step(owner, new_dir)
		direction = new_dir

