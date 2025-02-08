#define SSGLOWSHROOMS_RUN_TYPE_SPREAD	1
#define SSGLOWSHROOMS_RUN_TYPE_DECAY	2

SUBSYSTEM_DEF(glowshrooms)
	name = "Glowshroom Processing"
	wait = 1 SECONDS
	priority = FIRE_PRIORITY_GLOWSHROOMS
	flags = SS_BACKGROUND | SS_POST_FIRE_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	var/run_type = SSGLOWSHROOMS_RUN_TYPE_SPREAD
	var/enable_spreading = TRUE
	var/list/obj/structure/glowshroom/glowshrooms = list()
	var/list/obj/structure/glowshroom/currentrun_spread = list()
	var/list/obj/structure/glowshroom/currentrun_decay = list()

/datum/controller/subsystem/glowshrooms/Recover()
	glowshrooms = SSglowshrooms.glowshrooms

/datum/controller/subsystem/glowshrooms/fire(resumed)
	// just... trust me, this makes COMPLETE sense
	if(!length(currentrun_spread) && !length(currentrun_decay))
		list_clear_nulls(glowshrooms)
		if(length(glowshrooms))
			if(enable_spreading)
				currentrun_spread = glowshrooms.Copy()
			currentrun_decay = glowshrooms.Copy()

	var/seconds_per_tick = DELTA_WORLD_TIME(src)
	if(run_type == SSGLOWSHROOMS_RUN_TYPE_SPREAD)
		if(enable_spreading)
			var/list/current_run_spread = currentrun_spread
			while(length(current_run_spread))
				var/obj/structure/glowshroom/glowshroom = current_run_spread[length(current_run_spread)]
				current_run_spread.len--
				if(QDELETED(glowshroom))
					glowshrooms -= glowshroom
				else if(COOLDOWN_FINISHED(glowshroom, spread_cooldown))
					COOLDOWN_START(glowshroom, spread_cooldown, rand(glowshroom.min_delay_spread, glowshroom.max_delay_spread))
					glowshroom.Spread(seconds_per_tick)
				if(MC_TICK_CHECK)
					return
		run_type = SSGLOWSHROOMS_RUN_TYPE_DECAY

	if(run_type == SSGLOWSHROOMS_RUN_TYPE_DECAY)
		var/list/current_run_decay = currentrun_decay
		while(length(current_run_decay))
			var/obj/structure/glowshroom/glowshroom = current_run_decay[length(current_run_decay)]
			current_run_decay.len--
			if(QDELETED(glowshroom))
				glowshrooms -= glowshroom
			else
				glowshroom.Decay(seconds_per_tick)
			if(MC_TICK_CHECK)
				return
		run_type = SSGLOWSHROOMS_RUN_TYPE_SPREAD

/datum/controller/subsystem/glowshrooms/stat_entry(msg)
	msg = "P:[length(glowshrooms)]"
	return ..()

#undef SSGLOWSHROOMS_RUN_TYPE_DECAY
#undef SSGLOWSHROOMS_RUN_TYPE_SPREAD
