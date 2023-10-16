/datum/action/cooldown/spell/pointed/ash_beams
	name = "Nightwatcher's Rite"
	desc = "A powerful spell that releases five streams of eldritch fire towards the target."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "flames"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	invocation = "F'RE"
	invocation_type = INVOCATION_WHISPER
	
	cooldown_time = 30 SECONDS
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	/// The length of the flame line spit out.
	var/flame_line_length = 15

/datum/action/cooldown/spell/pointed/ash_beams/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/pointed/ash_beams/cast(atom/target)
	. = ..()
	var/static/list/offsets = list(-25, -10, 0, 10, 25)
	for(var/offset in offsets)
		INVOKE_ASYNC(src, PROC_REF(fire_line), owner, line_target(offset, flame_line_length, target, owner))

/datum/action/cooldown/spell/pointed/ash_beams/proc/line_target(offset, range, atom/at, atom/user)
	if(!at)
		return
	var/angle = ATAN2(at.x - user.x, at.y - user.y) + offset
	var/turf/T = get_turf(user)
	for(var/i in 1 to range)
		var/turf/check = locate(user.x + cos(angle) * i, user.y + sin(angle) * i, user.z)
		if(!check)
			break
		T = check
	return (getline(user, T) - get_turf(user))

/datum/action/cooldown/spell/pointed/ash_beams/proc/fire_line(atom/source, list/turfs)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			break

		for(var/mob/living/L in T.contents)
			if(L.can_block_magic())
				L.visible_message(span_danger("The fire parts in front of [L]!"),span_danger("As the fire approaches it splits off to avoid contact with you!"))
				continue
			if(L in hit_list || L == source)
				continue
			hit_list += L
			L.adjustFireLoss(20)
			to_chat(L, span_userdanger("You're hit by [source]'s fire blast!"))

		new /obj/effect/hotspot(T)
		T.hotspot_expose(700,50,1)
		// deals damage to mechs
		for(var/obj/mecha/M in T.contents)
			if(M in hit_list)
				continue
			hit_list += M
			M.take_damage(45, BURN, MELEE, 1)
		sleep(0.15 SECONDS)
