/obj/effect/particle_effect/fluid/smoke
	/// ID of the fallback timer, used to ensure that the smoke does not far outlive its intended lifetime, in case of subsystem delay or whatnot.
	var/fallback_timer

/obj/effect/particle_effect/fluid/smoke/Initialize(mapload, datum/fluid_group/group, ...)
	. = ..()
	// Ensure that smoke does not live for much longer than 1.5x the length of its lifetime (rounded up to the nearest 2 seconds)
	var/fallback_time = CEILING(initial(lifetime) * 1.5, 2 SECONDS)
	fallback_timer = addtimer(CALLBACK(src, PROC_REF(anti_fog_measures)), fallback_time, TIMER_UNIQUE | TIMER_STOPPABLE)

/obj/effect/particle_effect/fluid/smoke/Destroy()
	if(fallback_timer)
		deltimer(fallback_timer)
		fallback_timer = null
	return ..()

/obj/effect/particle_effect/fluid/smoke/proc/anti_fog_measures()
	fallback_timer = null
	if(!QDELETED(src))
		kill_smoke()
