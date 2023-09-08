/datum/action/cooldown/spell/summon_dancefloor
	name = "Summon Dancefloor"
	desc = "When what a Devil really needs is funk."
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"

	spell_requirements = NONE
	school = SCHOOL_EVOCATION
	cooldown_time = 5 SECONDS //5 seconds, so the smoke can't be spammed

	button_icon = 'icons/mob/actions/actions_devil.dmi'
	button_icon_state = "disco"

	var/dancefloor_exists = FALSE
	var/list/dancefloor_turfs
	var/list/dancefloor_turfs_types
	var/datum/effect_system/fluid_spread/smoke/transparent/dancefloor_devil/smoke

/datum/action/cooldown/spell/summon_dancefloor/cast(atom/target)
	. = ..()
	LAZYINITLIST(dancefloor_turfs)
	LAZYINITLIST(dancefloor_turfs_types)

	if(!smoke)
		smoke = new()
	smoke.set_up(0, get_turf(owner))
	smoke.start()

	if(dancefloor_exists)
		dancefloor_exists = FALSE
		for(var/i in 1 to dancefloor_turfs.len)
			var/turf/T = dancefloor_turfs[i]
			T.ChangeTurf(dancefloor_turfs_types[i], flags = CHANGETURF_INHERIT_AIR)
	else
		var/list/funky_turfs = RANGE_TURFS(1, owner)
		for(var/turf/closed/solid in funky_turfs)
			to_chat(owner, "<span class='warning'>You're too close to a wall.</span>")
			return
		dancefloor_exists = TRUE
		var/i = 1
		dancefloor_turfs.len = funky_turfs.len
		dancefloor_turfs_types.len = funky_turfs.len
		for(var/turf/T as anything in funky_turfs)
			dancefloor_turfs[i] = T
			dancefloor_turfs_types[i] = T.type
			T.ChangeTurf((i % 2 == 0) ? /turf/open/floor/light/colour_cycle/dancefloor_a : /turf/open/floor/light/colour_cycle/dancefloor_b, flags = CHANGETURF_INHERIT_AIR)
			i++

/datum/effect_system/fluid_spread/smoke/transparent/dancefloor_devil
	effect_type = /obj/effect/particle_effect/fluid/smoke/transparent/dancefloor_devil

/obj/effect/particle_effect/fluid/smoke/transparent/dancefloor_devil
	lifetime = 2
