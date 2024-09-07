/area
	/// Whether roundstart lockers should be anchored by default in this area, if eligible.
	var/anchor_roundstart_lockers = TRUE


/area/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	if(isliving(arrived))
		var/turf/arrived_turf = get_turf(arrived)
		if(!arrived_turf?.z)
			return
		if(SSparticle_weather.running_eclipse_weather || SSparticle_weather.running_weather)
			if(SSparticle_weather.running_eclipse_weather && SSmapping.level_has_all_traits(arrived_turf.z, list(ZTRAIT_ECLIPSE)))
				SSparticle_weather.running_eclipse_weather.weather_sound_effect(arrived)
			if(SSparticle_weather.running_weather && SSmapping.level_has_all_traits(arrived_turf.z, list(ZTRAIT_STATION)))
				SSparticle_weather.running_weather.weather_sound_effect(arrived)
