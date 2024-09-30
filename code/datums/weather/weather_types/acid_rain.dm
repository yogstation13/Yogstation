/datum/weather/rain
	name = "rain"
	desc = "There is a possibility of precipitation."

	telegraph_message = span_boldwarning("Thunder rumbles far above. You hear droplets drumming against the canopy. Seek shelter.")
	telegraph_duration = 30 SECONDS //if you change this i will kill you because the sound file lines up with this
	telegraph_sound = 'sound/weather/acidrain/acidrain_telegraph.ogg'

	weather_message = span_boldwarning("Rain pours down around you!")
	weather_overlay = "rain"
	weather_color = "#69b6ff"
	
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

	probability = 40

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
	if(L.mind || L.client) //could be pretty intensive, so only do this to things with players in them
		L.apply_status_effect(/datum/status_effect/raindrops)
		L.adjust_wet_stacks(3*log(2, (50*L.get_permeability(null, TRUE) + 10) / 10))
		L.extinguish_mob() // permeability affects the negative fire stacks but not the extinguishing

		// if preternis, update wetness instantly when applying more water instead of waiting for the next life tick
		if(ispreternis(L) || isjellyperson(L))
			var/mob/living/carbon/human/H = L
			H?.dna?.species?.spec_life(H)

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

	probability = 60

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


/**
 * I am squeezing every last drop of brain power to make this
 */

/**
 * this keeps track of the overlay and all raindrops
 */
/datum/status_effect/raindrops
	id = "raindrops"
	duration = 3 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	/// Fullscreen effect used to provide the visual to that player and only that player
	var/atom/movable/screen/fullscreen/raindrops/holder

/datum/status_effect/raindrops/on_creation(mob/living/new_owner, ...)
	. = ..()
	holder = new_owner.overlay_fullscreen("raindrops", /atom/movable/screen/fullscreen/raindrops)
	
/datum/status_effect/raindrops/tick(delta_time, times_fired) //happening here for now
	. = ..()
	tick_interval = rand(0, 5) //next drop happens in a random amount of time
	for(var/i in rand(1,2))
		droplet()

/datum/status_effect/raindrops/proc/droplet()
	var/obj/effect/temp_visual/raindrops/onedrop = new(owner) //put it inside the mob so it follows the player as they move
	onedrop.pixel_x += rand(-80, 480)
	onedrop.pixel_y += rand(-80, 480) //get put somewhere randomly on the screen
	//because it's a downscaled large image, it starts out in the bottom left corner by default
	holder.vis_contents += onedrop

/datum/status_effect/raindrops/refresh(effect, ...) //also spawn a droplet every time we're refreshed, makes the rain look far more dense if we're standing outside
	for(var/i in rand(1,2))
		droplet()
	return ..()

/datum/status_effect/raindrops/on_remove()
	owner.clear_fullscreen("raindrops")
	if(holder && !QDELETED(holder))
		qdel(holder)
	return ..()
	
/**
 * This provides the images to only the person with it
 */
/atom/movable/screen/fullscreen/raindrops
	icon_state = "raindrops"
	appearance_flags = PIXEL_SCALE | RESET_TRANSFORM
	plane = GRAVITY_PULSE_PLANE 
	
/**
 * this is an individual raindrop, multiple of these are spawned and added to the fullscreen to emulate random raindrops
 */
/obj/effect/temp_visual/raindrops
	plane = GRAVITY_PULSE_PLANE
	icon = 'yogstation/icons/effects/160x160.dmi' //massive picture for smoother edges
	icon_state = "raindrop"
	appearance_flags = PIXEL_SCALE | RESET_TRANSFORM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	duration = (0.8 SECONDS) //fades out over this time, not too long, not too slow

/obj/effect/temp_visual/raindrops/Initialize(mapload)
	. = ..()
	transform = matrix()/5 //we do this so it can larger if needed
	animate(src, alpha = 0, time = duration)
	
