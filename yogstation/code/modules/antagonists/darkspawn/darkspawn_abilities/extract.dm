/datum/action/cooldown/spell/pointed/extract
	name = "Extract"
	desc = "Drain a target's life force or bestow it to an ally."
	button_icon_state = "mindread"
	cooldown_time = 5 SECONDS
	panel = null
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	cast_range = 5
	var/mob/living/channeled
	var/datum/beam/visual
	var/datum/antagonist/darkspawn/cost
	var/upkeep_cost = 1 //happens 5 times a second

/datum/action/cooldown/spell/pointed/extract/New()
	..()
	START_PROCESSING(SSfastprocess, src)

/datum/action/cooldown/spell/pointed/extract/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/action/cooldown/spell/pointed/extract/Grant(mob/grant_to)
	. = ..()
	if(isdarkspawn(owner))
		cost = isdarkspawn(owner)

/datum/action/cooldown/spell/pointed/extract/can_cast_spell(feedback)
	if(channeled)
		return FALSE
	. = ..()

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
	if(channeled)
		if(channeled.stat == DEAD)
			channeled = null
			qdel(visual)
			return
		if(get_dist(owner, channeled) > cast_range)
			channeled = null
			qdel(visual)
			return
		if(cost && (!cost.use_psi(upkeep_cost)))
			channeled = null
			qdel(visual)
			return
		if(is_darkspawn_or_veil(channeled))
			channeled.heal_ordered_damage(10, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE))
		else
			channeled.apply_damage(10, BURN)
			if(isliving(owner))
				var/mob/living/healed = owner
				healed.heal_ordered_damage(10, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE))

/datum/action/cooldown/spell/pointed/extract/cast(mob/living/cast_on)
	. = ..()
	visual = owner.Beam(cast_on, "slingbeam", 'yogstation/icons/mob/sling.dmi' , INFINITY, 10)
	channeled = cast_on
