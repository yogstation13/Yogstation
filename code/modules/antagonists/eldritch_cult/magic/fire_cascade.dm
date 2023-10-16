/// Creates one, large, expanding ring of fire around the caster, which does not follow them.
/datum/action/cooldown/spell/fire_cascade
	name = "Lesser Fire Cascade"
	desc = "Heats the air around you."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "fire_ring"
	sound = 'sound/items/welder.ogg'

	school = SCHOOL_FORBIDDEN
	invocation = "C'SC'DE"
	invocation_type = INVOCATION_WHISPER

	cooldown_time = 30 SECONDS
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	/// The radius the flames will go around the caster.
	var/flame_radius = 4

/datum/action/cooldown/spell/fire_cascade/cast(atom/cast_on)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(fire_cascade), get_turf(cast_on), flame_radius)

/// Spreads a huge wave of fire in a radius around us, staggered between levels
/datum/action/cooldown/spell/fire_cascade/proc/fire_cascade(atom/centre, flame_radius = 1)
	for(var/i in 0 to flame_radius)
		for(var/turf/nearby_turf as anything in spiral_range_turfs(i + 1, centre))
			new /obj/effect/hotspot(nearby_turf)
			nearby_turf.hotspot_expose(750, 50, 1)
			for(var/mob/living/fried_living in nearby_turf.contents - centre)
				fried_living.apply_damage(5, BURN)
		stoplag(0.3 SECONDS)

/datum/action/cooldown/spell/fire_cascade/big
	name = "Greater Fire Cascade"
	flame_radius = 6
