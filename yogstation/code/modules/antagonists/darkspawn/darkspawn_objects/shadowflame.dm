//////////////////////////////////////////////////////////////////////////
//--------------------------Cold Fire instead of hot--------------------//
//////////////////////////////////////////////////////////////////////////
/obj/effect/dummy/lighting_obj/moblight/shadowflame
	name = "fire"
	light_power = -1
	light_range = LIGHT_RANGE_FIRE
	light_color = COLOR_VELVET

/datum/status_effect/fire_handler/shadowflame
	id = "shadowflame"
	override_types = list(/datum/status_effect/fire_handler/fire_stacks, /datum/status_effect/fire_handler/wet_stacks)
	stack_modifier = -1
	/// Reference to the mob light emitter itself
	var/obj/effect/dummy/lighting_obj/moblight
	/// Type of mob light emitter we use when on fire
	var/moblight_type = /obj/effect/dummy/lighting_obj/moblight/shadowflame
	//how cold this fire is
	var/temperature = 0

/datum/status_effect/fire_handler/shadowflame/on_apply()
	. = ..()
	owner.add_emitter(/obj/emitter/fire/shadow, "shadowflame")

/datum/status_effect/fire_handler/shadowflame/on_remove()
	owner.remove_emitter("shadowflame")
	return ..()

/datum/status_effect/fire_handler/shadowflame/tick(delta_time, times_fired)
	adjust_stacks(-0.75 * delta_time SECONDS) //change this number to make it last a shorter duration
	if(stacks <= 0)
		qdel(src)
		return

	if(is_team_darkspawn(owner) || !ishuman(owner))
		return

	var/mob/living/carbon/human/victim = owner
	var/thermal_multiplier = 1 - victim.get_cold_protection(temperature)

	var/calculated_cooling = (BODYTEMP_COOLING_MAX - (stacks * 12)) * 0.5 * (delta_time SECONDS) * thermal_multiplier
	victim.adjust_bodytemperature(calculated_cooling, temperature)

	if(HAS_TRAIT(victim, TRAIT_RESISTCOLD) || !calculated_cooling)
		SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "on_fire")
	else
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "on_fire", /datum/mood_event/on_fire)

/// Cold purple turf fire
/obj/effect/temp_visual/darkspawn/shadowflame
	icon = 'icons/effects/turf_fire.dmi'
	icon_state = "white_big"
	layer = GASFIRE_LAYER
	light_system = MOVABLE_LIGHT //we make it a movable light because static lights colour is handled weirdly
	light_power = -1
	light_range = LIGHT_RANGE_FIRE
	light_color = COLOR_VELVET
	color = COLOR_DARKSPAWN_PSI
	mouse_opacity = FALSE
	duration = 10 SECONDS

/obj/effect/temp_visual/darkspawn/shadowflame/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/effect/temp_visual/darkspawn/shadowflame/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/effect/temp_visual/darkspawn/shadowflame/process(delta_time)
	var/turf/placement = get_turf(src)
	for(var/mob/living/target_mob in placement.contents)
		target_mob.set_wet_stacks(20, /datum/status_effect/fire_handler/shadowflame)

/obj/emitter/fire/shadow
	pixel_y = -16 //so it aligns with the floor
	fire_colour = COLOR_VELVET
