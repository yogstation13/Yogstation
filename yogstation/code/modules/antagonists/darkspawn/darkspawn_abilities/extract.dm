/datum/action/cooldown/spell/pointed/extract
	name = "Extract"
	desc = "Drain a target's life force."
	button_icon_state = "mindread"
	cooldown_time = 5 SECONDS
	panel = null
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	cast_range = 5
	var/mob/living/target
	var/datum/beam/visual

/datum/action/cooldown/spell/toggle/New()
	..()
	START_PROCESSING(SSfastprocess, src)

/datum/action/cooldown/spell/toggle/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/action/cooldown/spell/pointed/extract/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE
	var/mob/living/living_cast_on = cast_on
	if(living_cast_on.stat == DEAD)
		to_chat(owner, span_warning("[cast_on] is dead!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/extract/process()
	. = ..()
	if(target)
		if(get_dist(owner, target) > cast_range )
			target = null
			qdel(beam)
			return
		if(is_darkspawn_or_veil(target))
			target.heal_ordered_damage(10, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE))
		else
			target.apply_damage(10, BURN)
			owner.heal_ordered_damage(10, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE))
			if(target.stat == DEAD)
				target = null
				qdel(beam)
				return

/datum/action/cooldown/spell/pointed/extract/cast(mob/living/cast_on)
	. = ..()
	visual = owner.beam(cast_on, "slingbeam", 'yogstation/icons/mob/sling.dmi' , INFINITY, 10)
