///Forced directional movement, but with a twist
///Let's block pressure and client movements while doing it so we can't be interrupted
///Supports spinning on each move, for lube related reasons
/datum/component/force_move

/datum/component/force_move/Initialize(atom/target, spin)
	if(!target || !ismob(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/mob_parent = parent
	var/dist = get_dist(mob_parent, target)
	var/datum/move_loop/loop = SSmove_manager.move_towards(mob_parent, target, delay = 1, timeout = dist)
	RegisterSignal(mob_parent, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(stop_move))
	RegisterSignal(mob_parent, COMSIG_ATOM_PRE_PRESSURE_PUSH, PROC_REF(stop_pressure))
	RegisterSignal(mob_parent, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(slip_crash))
	if(spin)
		RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(slip_spin))
	RegisterSignal(loop, COMSIG_QDELETING, PROC_REF(loop_ended))

/datum/component/force_move/proc/stop_move(datum/source)
	SIGNAL_HANDLER
	return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE

/datum/component/force_move/proc/stop_pressure(datum/source)
	SIGNAL_HANDLER
	return COMSIG_ATOM_BLOCKS_PRESSURE

/datum/component/force_move/proc/slip_spin(datum/source)
	SIGNAL_HANDLER
	var/mob/mob_parent = parent
	mob_parent.spin(1, 1)

/datum/component/force_move/proc/slip_crash(datum/source, result, delay, turf/target_turf, datum/blocked)
	SIGNAL_HANDLER
	if(!result && ishuman(parent) && istype(blocked, /datum/move_loop/has_target/move_towards)) // Something prevented us from moving into the space.
		var/obj/machinery/heavy_weight = (locate(/obj/machinery/vending) in target_turf)
		var/datum/move_loop/has_target/move_towards/blocked_move = blocked
		if(istype(heavy_weight, /obj/machinery/vending)) // When a stoppable force hits immovable capitalism.
			blocked_move.lifetime = -1
			INVOKE_ASYNC(heavy_weight, /obj/machinery/vending/proc/tilt, parent) // We hit the machine so let them hit back.

		else
			// We hit a structure and we need to keep going.
			var/mob/living/mob_parent = parent
			mob_parent.Immobilize(0.8 SECONDS) // Prevent them from throw bending around objects.
			// We don't exactly know what stopped us. So throw us at the turf and let physics handle it.
			blocked_move.lifetime = -1
			INVOKE_ASYNC(mob_parent, /atom/movable/proc/throw_at, target_turf, 1, 1)

/datum/component/force_move/proc/loop_ended(datum/source)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	qdel(src)


