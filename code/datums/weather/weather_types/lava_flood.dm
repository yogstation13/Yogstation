//Lava often rises from the porous ground in the caverns deep below. It floods the entire level, submerging any space that isn't sealed off.
//Similar to floor is lava except it floods *everywhere* that isn't sealed off from the outside.
/*
/datum/weather/lava_flood
	name = "lava flood"
	desc = "A deluge of lava rises up from the cavern's porous ground, submerging every space that isn't closed off from the outside."

	telegraph_message = span_boldwarning("The ground begins to break and blister. Heat shimmers in the air as it rises from the cracks below. Hurry inside.")
	telegraph_duration = //450 300
	telegraph_overlay = //"light_ash"

	weather_message = span_userdanger("<i>Molten lava surges out from below and floods every inch of the cavern! Stay inside!</i>")
	weather_duration_lower = //300 600
	weather_duration_upper = //600 1200
	weather_overlay = "lava"

	//end_message = span_boldannounce("The shrieking wind whips away the last of the ash and falls to its usual murmur. It should be safe to go outside now.")
	end_message = span_boldannounce("The lava ")
	end_duration = //0 300
	end_overlay = //"light_ash"

	area_type = /area
	protect_indoors = //TRUE
	target_trait = ZTRAIT_LAVAFLOOD

	immunity_type = WEATHER_LAVA

	barometer_predictable = TRUE

	var/datum/looping_sound/active_outside_ashstorm/sound_ao = new(list(), FALSE, TRUE)
	var/datum/looping_sound/active_inside_ashstorm/sound_ai = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_outside_ashstorm/sound_wo = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_inside_ashstorm/sound_wi = new(list(), FALSE, TRUE)

/datum/weather/ash_storm/telegraph()
	. = ..()
	var/list/inside_areas = list()
	var/list/outside_areas = list()
	var/list/eligible_areas = list()
	for (var/z in impacted_z_levels)
		eligible_areas += SSmapping.areas_in_z["[z]"]
	for(var/i in 1 to eligible_areas.len)
		var/area/place = eligible_areas[i]
		if(place.outdoors)
			outside_areas += place
		else
			inside_areas += place
		CHECK_TICK

	sound_ao.output_atoms = outside_areas
	sound_ai.output_atoms = inside_areas
	sound_wo.output_atoms = outside_areas
	sound_wi.output_atoms = inside_areas

	sound_wo.start()
	sound_wi.start()

/datum/weather/ash_storm/start()
	. = ..()
	sound_wo.stop()
	sound_wi.stop()

	sound_ao.start()
	sound_ai.start()

/datum/weather/ash_storm/wind_down()
	. = ..()
	sound_ao.stop()
	sound_ai.stop()

	sound_wo.start()
	sound_wi.start()

/datum/weather/ash_storm/end()
	. = ..()
	sound_wo.stop()
	sound_wi.stop()

/datum/weather/ash_storm/proc/is_ash_immune(atom/L)
	while (L && !isturf(L))
		if(ismecha(L)) //Mechs are immune
			return TRUE
		if(ishuman(L)) //Are you immune?
			var/mob/living/carbon/human/H = L
			var/thermal_protection = H.get_thermal_protection()
			if(thermal_protection >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
				return TRUE
		if(isliving(L))// if we're a non immune mob inside an immune mob we have to reconsider if that mob is immune to protect ourselves
			var/mob/living/the_mob = L
			if((WEATHER_ASH in the_mob.weather_immunities) || (WEATHER_ALL in the_mob.weather_immunities))
				return TRUE
		if(istype(L, /obj/structure/closet))
			var/obj/structure/closet/the_locker = L
			if(the_locker.weather_protection)
				if((WEATHER_ASH in the_locker.weather_protection) || (WEATHER_ALL in the_locker.weather_protection))
					return TRUE
		L = L.loc //Check parent items immunities (recurses up to the turf)
	return FALSE //RIP you

/datum/weather/ash_storm/weather_act(mob/living/L)
	if(is_ash_immune(L))
		return
	L.adjustFireLoss(4)


//Emberfalls are the result of an ash storm passing by close to the playable area of lavaland. They have a 10% chance to trigger in place of an ash storm.
/datum/weather/ash_storm/emberfall
	name = "emberfall"
	desc = "A passing ash storm blankets the area in harmless embers."

	weather_message = span_notice("Gentle embers waft down around you like grotesque snow. The storm seems to have passed you by...")
	weather_overlay = "light_ash"

	end_message = span_notice("The emberfall slows, stops. Another layer of hardened soot to the basalt beneath your feet.")
	end_sound = null

	aesthetic = TRUE

	probability = 10
*/
