/datum/weather/snow_storm
	name = "snow storm"
	desc = "Harsh snowstorms roam the topside of this arctic planet, burying any area unfortunate enough to be in its path."
	probability = 90

	telegraph_message = span_warning("Drifting particles of snow begin to dust the surrounding area..")
	telegraph_duration = 300
	telegraph_overlay = "light_snow"

	weather_message = span_userdanger("<i>Harsh winds pick up as dense snow begins to fall from the sky! Seek shelter!</i>")
	weather_overlay = "snow_storm"
	weather_duration_lower = 600
	weather_duration_upper = 1500

	end_duration = 100
	end_message = span_boldannounce("The snowfall dies down, it should be safe to go outside again.")

	area_type = /area
	protect_indoors = TRUE
	target_trait = ZTRAIT_SNOWSTORM

	immunity_type = WEATHER_SNOW

	barometer_predictable = TRUE


/datum/weather/snow_storm/weather_act(mob/living/L)
	var/weather_strength = -rand(5, 15)
	var/datum/gas_mixture/environment = L.loc?.return_air()
	if(!environment) // no air == no snow
		return
	if(ismovable(L.loc))
		var/atom/movable/occupied_space = L.loc
		weather_strength *= (1 - occupied_space.contents_thermal_insulation)
	if(ishuman(L))
		var/mob/living/carbon/human/human_mob = L
		weather_strength *= (1 - human_mob.get_cold_protection(environment.return_temperature()))
	L.adjust_bodytemperature(weather_strength)
