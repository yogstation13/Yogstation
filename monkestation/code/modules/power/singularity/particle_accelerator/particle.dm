/obj/effect/accelerated_particle
	name = "Accelerated Particles"
	desc = "Small things moving very fast."
	icon = 'monkestation/icons/obj/machines/particle_accelerator.dmi'
	icon_state = "particle"
	anchored = TRUE
	density = FALSE
	var/movement_range = 10
	var/energy = 10
	var/speed = 1
	COOLDOWN_DECLARE(next_move)

/obj/effect/accelerated_particle/weak
	movement_range = 8
	energy = 5

/obj/effect/accelerated_particle/strong
	movement_range = 15
	energy = 15

/obj/effect/accelerated_particle/powerful
	movement_range = 20
	energy = 50

/obj/effect/accelerated_particle/Initialize(mapload)
	. = ..()
	if(QDELETED(loc))
		return INITIALIZE_HINT_QDEL
	START_PROCESSING(SSactualfastprocess, src)

/obj/effect/accelerated_particle/Destroy(force)
	STOP_PROCESSING(SSactualfastprocess, src)
	return ..()

/obj/effect/accelerated_particle/Bump(atom/bumped_atom)
	if(QDELETED(bumped_atom))
		return
	if(isliving(bumped_atom))
		toxmob(bumped_atom)
	else if(istype(bumped_atom, /obj/machinery/the_singularitygen))
		var/obj/machinery/the_singularitygen/generator = bumped_atom
		generator.energy += energy
	else if(istype(bumped_atom, /obj/singularity))
		var/obj/singularity/singuloth = bumped_atom
		singuloth.energy += energy
	else if(istype(bumped_atom, /obj/energy_ball))
		var/obj/energy_ball/tesloose = bumped_atom
		tesloose.energy += energy
	else if(istype(bumped_atom, /obj/structure/blob))
		var/obj/structure/blob/blob = bumped_atom
		blob.take_damage(energy * 0.6)
		movement_range = 0

/obj/effect/accelerated_particle/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived))
		toxmob(arrived)

/obj/effect/accelerated_particle/process()
	if(QDELETED(loc) || movement_range <= 0)
		qdel(src)
		return PROCESS_KILL
	if(!COOLDOWN_FINISHED(src, next_move))
		return
	if(!step(src, dir))
		var/turf/next_step = get_step(src, dir) // this doesn't make sense but it was in the original code so I'm keeping it (with an actual qdeleted check) ~Lucy
		if(QDELETED(next_step))
			qdel(src)
			return PROCESS_KILL
		forceMove(next_step)
	movement_range--
	COOLDOWN_START(src, next_move, speed)

/obj/effect/accelerated_particle/ex_act(severity, target)
	qdel(src)

/obj/effect/accelerated_particle/singularity_pull()
	return

/obj/effect/accelerated_particle/proc/toxmob(mob/living/victim)
	radiation_pulse(victim, 1, 3, 0.5)
