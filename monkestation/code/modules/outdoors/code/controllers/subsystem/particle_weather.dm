SUBSYSTEM_DEF(particle_weather)
	name = "Particle Weather"
	flags = SS_BACKGROUND
	wait = 30 SECONDS
	runlevels = RUNLEVEL_GAME
	var/list/eligible_weathers = list()
	var/list/eligible_eclipse_weathers = list()
	var/datum/particle_weather/running_weather
	var/datum/particle_weather/running_eclipse_weather

	var/datum/particle_weather/next_hit
	COOLDOWN_DECLARE(next_weather_start)

	var/datum/particle_weather/next_hit_eclipse
	COOLDOWN_DECLARE(next_weather_start_eclipse)

	var/particles/weather/particle_effect
	var/datum/weather_effect/weather_special_effect
	var/obj/weather_effect/weather_effect

	var/particles/weather/particle_effect_eclipse
	var/datum/weather_effect/weather_special_effect_eclipse
	var/obj/weather_effect/weather_effect_eclipse

	var/enabled = TRUE

//This has been mangled - currently only supports 1 weather effect serverwide so I can finish this
/datum/controller/subsystem/particle_weather/Initialize(start_timeofday)
	if(CONFIG_GET(flag/disable_particle_weather))
		disable()
		return SS_INIT_NO_NEED
	for(var/particle_weather_type in subtypesof(/datum/particle_weather))
		var/datum/particle_weather/particle_weather = new particle_weather_type
		if(particle_weather.target_trait in SSmapping.config.particle_weathers)
			eligible_weathers[particle_weather_type] = particle_weather.probability

		if(particle_weather.eclipse)
			eligible_eclipse_weathers[particle_weather_type] = particle_weather.probability

	return SS_INIT_SUCCESS

/datum/controller/subsystem/particle_weather/Recover()
	running_weather = SSparticle_weather.running_weather
	running_eclipse_weather = SSparticle_weather.running_eclipse_weather

	next_hit = SSparticle_weather.next_hit
	next_weather_start = SSparticle_weather.next_weather_start

	next_hit_eclipse = SSparticle_weather.next_hit_eclipse
	next_weather_start_eclipse = SSparticle_weather.next_weather_start_eclipse

	particle_effect = SSparticle_weather.particle_effect
	weather_special_effect = SSparticle_weather.weather_special_effect
	weather_effect = SSparticle_weather.weather_effect

	particle_effect_eclipse = SSparticle_weather.particle_effect_eclipse
	weather_special_effect_eclipse = SSparticle_weather.weather_special_effect_eclipse
	weather_effect_eclipse = SSparticle_weather.weather_effect_eclipse

/datum/controller/subsystem/particle_weather/stat_entry(msg)
	if(enabled)
		if(running_weather?.running || running_eclipse_weather?.running)
			var/station_msg = "Idle"
			if(running_weather)
				var/time_left = COOLDOWN_TIMELEFT(running_weather, time_left)
				var/weather_name = running_weather.display_name || "[running_weather]"
				station_msg = "[weather_name], [DisplayTimeText(time_left)] left"
			var/eclipse_msg = "Idle"
			if(running_eclipse_weather)
				var/time_left = COOLDOWN_TIMELEFT(running_eclipse_weather, time_left)
				var/weather_name = running_eclipse_weather.display_name || "[running_eclipse_weather]"
				eclipse_msg = "[weather_name], [DisplayTimeText(time_left)] left"
			msg = "Station: [station_msg] | Eclipse: [eclipse_msg]"
		else if(running_weather)
			var/time_left = COOLDOWN_TIMELEFT(src, next_weather_start)
			if(running_weather?.display_name)
				msg = "Next event: [running_weather.display_name] hits in [DisplayTimeText(time_left)]"
			else if(running_weather)
				msg = "Next event of unknown type ([running_weather]) hits in [DisplayTimeText(time_left)]"
		else
			msg = "No event"
	else
		msg = "Disabled"
	return ..()

/datum/controller/subsystem/particle_weather/fire()
	// process active weather
	if(QDELETED(running_weather))
		if(next_hit && COOLDOWN_FINISHED(src, next_weather_start))
			run_weather(next_hit)
		else if(!next_hit && length(eligible_weathers))
			for(var/our_event in eligible_weathers)
				if(!our_event)
					continue
				if(!prob(eligible_weathers[our_event]))
					continue
				next_hit = new our_event()
				COOLDOWN_START(src, next_weather_start, rand(-3000, 3000) + initial(next_hit.weather_duration_upper) / 5)
				break

	if(QDELETED(running_eclipse_weather))
		if(next_hit_eclipse && COOLDOWN_FINISHED(src, next_weather_start_eclipse))
			run_weather(next_hit_eclipse, eclipse = TRUE)
		else if(!next_hit_eclipse && length(eligible_eclipse_weathers))
			for(var/our_event in eligible_eclipse_weathers)
				if(!our_event)
					continue
				if(!prob(eligible_eclipse_weathers[our_event]))
					continue
				next_hit_eclipse = new our_event("Eclipse")
				COOLDOWN_START(src, next_weather_start_eclipse, rand(-3000, 3000) + initial(next_hit_eclipse.weather_duration_upper) / 5)
				break

	if(!QDELETED(running_weather))
		running_weather.tick()

		if(weather_special_effect)
			SEND_GLOBAL_SIGNAL(COMSIG_GLOB_WEATHER_EFFECT, weather_special_effect)

	if(!QDELETED(running_eclipse_weather))
		running_eclipse_weather.tick()

		if(weather_special_effect_eclipse)
			SEND_GLOBAL_SIGNAL(COMSIG_GLOB_WEATHER_EFFECT, weather_special_effect_eclipse)

/datum/controller/subsystem/particle_weather/proc/disable()
	flags |= SS_NO_FIRE
	enabled = FALSE
	stop_weather()

/datum/controller/subsystem/particle_weather/proc/run_weather(datum/particle_weather/weather_datum_type, force = FALSE, eclipse = FALSE)
	if(!enabled)
		return
	if(eclipse)
		if(!QDELETED(running_eclipse_weather))
			if(!force)
				return
			running_eclipse_weather.end()

		if(!istype(weather_datum_type, /datum/particle_weather))
			CRASH("run_weather called with invalid weather_datum_type: [weather_datum_type || "null"]")
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_WEATHER_CHANGE)
		running_eclipse_weather = weather_datum_type
		running_eclipse_weather.start()
		weather_datum_type = null
	else
		if(!QDELETED(running_weather))
			if(!force)
				return
			running_weather.end()

		if(!istype(weather_datum_type, /datum/particle_weather))
			CRASH("run_weather called with invalid weather_datum_type: [weather_datum_type || "null"]")
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_WEATHER_CHANGE)
		running_weather = weather_datum_type
		running_weather.start()
		weather_datum_type = null

/datum/controller/subsystem/particle_weather/proc/make_eligible(datum/particle_weather/possible_weather, probability = 10)
	eligible_weathers[possible_weather] = probability

/datum/controller/subsystem/particle_weather/proc/get_weather_effect(atom/movable/screen/plane_master/weather_effect/weather_plane_master)
	switch(weather_plane_master.z_type)
		if("Default")
			if(QDELETED(weather_effect))
				weather_effect = new /obj()
				weather_effect.particles = particle_effect
				weather_effect.filters += filter(type="alpha", render_source="[WEATHER_RENDER_TARGET] #[weather_plane_master.offset]")
				weather_effect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
			return weather_effect
		if("Eclipse")
			if(QDELETED(weather_effect_eclipse))
				weather_effect_eclipse = new /obj()
				weather_effect_eclipse.filters += filter(type="alpha", render_source="[WEATHER_ECLIPSE_RENDER_TARGET] #[weather_plane_master.offset]")
				weather_effect_eclipse.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
			return weather_effect_eclipse

/datum/controller/subsystem/particle_weather/proc/set_particle_effect(particles/particle, z_type)
	if(!particle)
		return
	switch(z_type)
		if("Default")
			if(QDELETED(weather_effect))
				return
			particle_effect = particle
			weather_effect.particles = particle_effect
		if("Eclipse")
			if(QDELETED(weather_effect_eclipse))
				return
			particle_effect_eclipse = particle
			weather_effect_eclipse.particles = particle_effect_eclipse

/datum/controller/subsystem/particle_weather/proc/stop_weather(z_type)
	switch(z_type)
		if("Default")
			QDEL_NULL(running_weather)
			QDEL_NULL(particle_effect)
			//QDEL_NULL(weather_effect)
			QDEL_NULL(weather_special_effect)
		if("Eclipse")
			QDEL_NULL(running_eclipse_weather)
			QDEL_NULL(particle_effect_eclipse)
			//QDEL_NULL(weather_effect_eclipse)
			QDEL_NULL(weather_special_effect_eclipse)

/obj/weather_effect
	plane = LIGHTING_PLANE
