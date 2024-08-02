/datum/weather/rain
	name = "rain"
	desc = "There is a possibility of precipitation."

	telegraph_message = span_boldwarning("Thunder rumbles far above. You hear droplets drumming against the canopy. Seek shelter.")
	telegraph_duration = 30 SECONDS //if you change this i will kill you because the sound file lines up with this
	telegraph_sound = 'sound/weather/acidrain/acidrain_telegraph.ogg'

	weather_message = span_warning("<i>Rain pours down around you!</i>")
	weather_overlay = "rain"
	weather_color = "#609bdf" //same colour as water (minus the alpha because the sprite itself has reduced alpha)
	overlay_plane = HIGHEST_EVER_PLANE + 1 //why does this work, it shouldn't work, this is stupid and i hate it, why is this the ONLY thing that works, why won't it just show up normally, it shows up normally on lavaland, but not on jungleland, i don't understand it doesn't make any sense, this is all wrong
	
	//lasts shorter
	weather_duration_lower = 30 SECONDS
	weather_duration_upper = 180 SECONDS //inconsistent tropical storms

	//happens slightly more often
	cooldown_lower = 3 MINUTES
	cooldown_higher = 5 MINUTES

	end_duration = 20 SECONDS
	end_message = span_boldannounce("The downpour gradually slows to a light shower.")

	area_type = /area
	protect_indoors = TRUE
	target_trait = ZTRAIT_ACIDRAIN

	immunity_type = WEATHER_RAIN

	probability = 10

	barometer_predictable = TRUE

	var/datum/looping_sound/outside_acid_rain/sound_outside = new(list(), FALSE, TRUE)
	var/datum/looping_sound/inside_acid_rain/sound_inside = new(list(), FALSE, TRUE)

/datum/weather/rain/telegraph()
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

	sound_outside.output_atoms = outside_areas
	sound_inside.output_atoms = inside_areas

/datum/weather/rain/start()
	. = ..()
	sound_outside.start()
	sound_inside.start()

/datum/weather/rain/wind_down()
	. = ..()
	sound_outside.stop()
	sound_inside.stop()

/datum/weather/rain/weather_act(mob/living/L)
	if(prob(L.get_permeability(null, TRUE) * 100)) //partial permability reduces the chance to get wet
		L.adjust_wet_stacks(2) //just makes you wet

/**
 * Acid rain also injects toxic metabolites to mobs that can have reagents
 * otherwise just does a bit of burn and tox
 */
/datum/weather/rain/acid
	name = "acid rain"
	desc = "The planet's thunderstorms are by nature acidic, and will incinerate anyone standing beneath them without protection."

	weather_message = span_userdanger("<i>Acidic rain pours down around you! Get inside!</i>")
	weather_color = "#00FF32"

	end_message = span_boldannounce("The downpour gradually slows to a light shower. It should be safe outside now.")

	/**
	 * We don't actually use weather_acid for immunity_type we check acid immunity using is_acid_immune
	 * This allows rain immunity to protect from wetness
	 * and acid immunity to protect from acid
	 * So people can be immune to acid but not wet or immune to wet but not acid
	 */

	probability = 90

	barometer_predictable = TRUE

/datum/weather/rain/acid/weather_act(mob/living/L)
	. = ..()
	if(is_acid_immune(L)) //immunity to the acid doesn't mean immunity to the wet
		return
	if(ishuman(L)) //inject metabolites
		var/mob/living/carbon/human/humie = L
		if(humie.reagents.get_reagent_amount(/datum/reagent/toxic_metabolites) <= 25) //don't let them get up to the absolute highest metabolites tier, but they should still need to be worried
			humie.reagents.add_reagent(/datum/reagent/toxic_metabolites, 2)
	else
		L.apply_damage_type(0.5, BURN)
		L.apply_damage_type(0.5, TOX)

/datum/weather/rain/acid/proc/is_acid_immune(atom/L)
	while (L && !isturf(L))
		if(HAS_TRAIT(L, TRAIT_SULPH_PIT_IMMUNE))
			return TRUE
		if(ismecha(L)) //Mechs are immune
			return TRUE
		if(isliving(L))// if we're a non immune mob inside an immune mob we have to reconsider if that mob is immune to protect ourselves
			var/mob/living/the_mob = L
			var/acid_armour = the_mob.getarmor(null, ACID)
			if(acid_armour >= 65) //give a bit of wiggle room, this isn't supposed to be that dangerous for someone that's prepared
				return TRUE

			if(the_mob.weather_immunities & WEATHER_ACID)
				return TRUE
		if(istype(L, /obj/structure/closet))
			var/obj/structure/closet/the_locker = L
			if(the_locker.weather_protection & WEATHER_ACID)
				return TRUE
		L = L.loc //Check parent items immunities (recurses up to the turf)
	return FALSE //RIP you
