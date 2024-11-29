/obj/effect/accelerated_particle
	name = "Accelerated Particles"
	desc = "Small things moving very fast."
	icon = 'monkestation/icons/obj/machines/particle_accelerator.dmi'
	icon_state = "particle"
	anchored = TRUE
	density = FALSE
	/// How many tiles remaining the particle will move.
	/// The particle will delete itself if this reaches 0.
	var/movement_range = 10
	/// How much energy this particle has.
	var/energy = 10
	/// The cooldown for this particle's movement. Higher = slower.
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
	if(!isturf(loc))
		return INITIALIZE_HINT_QDEL
	START_PROCESSING(SSactualfastprocess, src)

/obj/effect/accelerated_particle/Destroy(force)
	STOP_PROCESSING(SSactualfastprocess, src)
	return ..()

/obj/effect/accelerated_particle/Bump(atom/movable/bumped_atom)
	if(QDELETED(src) || !ismovable(bumped_atom) || QDELING(bumped_atom))
		return
	bumped_atom.accelerated_particle_act(src)

/obj/effect/accelerated_particle/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!QDELETED(src) && !QDELETED(arrived))
		arrived.accelerated_particle_act(src)

/obj/effect/accelerated_particle/process()
	if(!isturf(loc) || movement_range <= 0)
		qdel(src)
		return PROCESS_KILL
	if(!COOLDOWN_FINISHED(src, next_move))
		return
	if(!step(src, dir))
		var/turf/next_step = get_step(src, dir) // this doesn't make sense but it was in the original code so I'm keeping it (with an actual qdeleted check) ~Lucy
		if(!next_step)
			qdel(src)
			return PROCESS_KILL
		forceMove(next_step)
	movement_range--
	COOLDOWN_START(src, next_move, speed)

/obj/effect/accelerated_particle/ex_act(severity, target)
	qdel(src)

/obj/effect/accelerated_particle/singularity_pull()
	return

/obj/effect/accelerated_particle/newtonian_move(direction, instant, start_delay)
	return TRUE

/atom/movable/proc/accelerated_particle_act(obj/effect/accelerated_particle/particle)
	return

/obj/machinery/the_singularitygen/accelerated_particle_act(obj/effect/accelerated_particle/particle)
	energy += particle.energy

/obj/singularity/accelerated_particle_act(obj/effect/accelerated_particle/particle)
	energy += particle.energy

/obj/energy_ball/accelerated_particle_act(obj/effect/accelerated_particle/particle)
	energy += particle.energy

/obj/structure/blob/accelerated_particle_act(obj/effect/accelerated_particle/particle)
	take_damage(particle.energy * 0.6)
	particle.movement_range = 0

/mob/living/accelerated_particle_act(obj/effect/accelerated_particle/particle)
	radiation_pulse(src, 1, 3, 0.5)
