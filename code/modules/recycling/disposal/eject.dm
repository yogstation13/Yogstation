// called when movable is expelled from a disposal pipe or outlet
// by default does nothing, override for special behaviour
///atom/movable/proc/pipe_eject(direction)
/obj/proc/pipe_eject(obj/holder, direction, throw_em = TRUE, turf/target, throw_range = 5, throw_speed = 1)
	var/turf/src_T = get_turf(src)
	for(var/A in holder)
		var/atom/movable/AM = A
		AM.forceMove(src_T)
		SEND_SIGNAL(AM, COMSIG_MOVABLE_PIPE_EJECTING, direction)
		if(throw_em && !QDELETED(AM))
			var/turf/T = target || get_offset_target_turf(loc, rand(5)-rand(5), rand(5)-rand(5))
			AM.throw_at(T, throw_range, throw_speed)


/obj/effect/decal/cleanable/blood/gibs/pipe_eject(direction)
	var/list/dirs
	if(direction)
		dirs = list(direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = GLOB.alldirs.Copy()

	streak(dirs)

/obj/effect/decal/cleanable/robot_debris/gib/pipe_eject(direction)
	var/list/dirs
	if(direction)
		dirs = list(direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = GLOB.alldirs.Copy()

	streak(dirs)
