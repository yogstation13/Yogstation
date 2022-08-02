/obj/structure/destructible/flock
	name = "BIG CHUNGUS BIG CHUNGUS BIG CHUNGUS BIG CHUNGUS BIG CHUNGUS BIG CHUNGUS BIG CHUNGUS "
	desc = "You shouldn't see this."
	var/flock_desc = "You STILL shouldn't see this"
	var/flock_id = "ERROR"
	var/compute_provided = 0

/obj/structure/destructible/flock/Initialize()
	. = ..()
	AddComponent(/datum/component/flock_compute, compute_provided)

/obj/structure/destructible/flock/proc/change_compute_amount(new_amount)
	compute_provided = new_amount
	SEND_SIGNAL(src, COMSIG_CHANGE_COMPUTE, compute_provided, FALSE)

/obj/structure/destructible/flock/Cross(atom/movable/mover)
	return isflockdrone(mover)

/obj/structure/destructible/flock/CanAllowThrough(atom/movable/O)
	. = ..()
	if(isflockdrone(O))
		return TRUE

/obj/structure/destructible/flock/examine(mob/user)
	. = ..()
	if(isflockdrone(user) || isflocktrace(user))
		. = span_swarmer("<span class='bold'>###=-</span> Ident confirmed, data packet received.")
		. += span_swarmer("<span class='bold'>ID:</span> [icon2html(src, user)] [name ? name : "none"]")
		. += span_swarmer("<span class='bold'>Information:</span> [flock_desc]%")
		. += span_swarmer("<span class='bold'>System Integrity:</span> [round((obj_integrity/max_integrity)*100)]%")
		. += span_swarmer("<span class='bold'>###=-</span>")