//Acid rain is part of the natural weather cycle in the humid forests of Planetstation, and cause acid damage to anyone unprotected.
/datum/weather/acid_rain
	name = "acid rain"
	desc = "The planet's thunderstorms are by nature acidic, and will incinerate anyone standing beneath them without protection."

	telegraph_duration = 400
	telegraph_message = span_boldwarning("Thunder rumbles far above. You hear droplets drumming against the canopy. Seek shelter.")
	telegraph_sound = 'sound/ambience/acidrain_start.ogg'

	weather_message = span_userdanger("<i>Acidic rain pours down around you! Get inside!</i>")
	weather_overlay = "acid_rain"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_sound = 'sound/ambience/acidrain_mid.ogg'

	end_duration = 100
	end_message = span_boldannounce("The downpour gradually slows to a light shower. It should be safe outside now.")
	end_sound = 'sound/ambience/acidrain_end.ogg'

	area_type = /area
	protect_indoors = TRUE
	target_trait = ZTRAIT_ACIDRAIN

	immunity_type = WEATHER_ACID // temp

	probability = 90

	barometer_predictable = TRUE


/datum/weather/acid_rain/proc/is_acid_immune(atom/L)
	while (L && !isturf(L))
		if(ismecha(L)) //Mechs are immune
			return TRUE
		if(isliving(L))// if we're a non immune mob inside an immune mob we have to reconsider if that mob is immune to protect ourselves
			var/mob/living/the_mob = L
			var/resist = L.getarmor(null, ACID)
			if(resist >= 100)
				return TRUE
			if((immunity_type in the_mob.weather_immunities) || (WEATHER_ALL in the_mob.weather_immunities))
				return TRUE
		if(istype(L, /obj/structure/closet))
			var/obj/structure/closet/the_locker = L
			if(the_locker.weather_protection)
				if((immunity_type in the_locker.weather_protection) || (WEATHER_ALL in the_locker.weather_protection))
					return TRUE
		L = L.loc //Check parent items immunities (recurses up to the turf)
	return FALSE //RIP you

/datum/weather/acid_rain/weather_act(mob/living/L)
	if(is_acid_immune(L))
		return
	//rather than applying acid which would break the server, just apply a mix of burn and tox
	L.apply_damage_type(2, BURN)
	L.apply_damage_type(2, TOX)
