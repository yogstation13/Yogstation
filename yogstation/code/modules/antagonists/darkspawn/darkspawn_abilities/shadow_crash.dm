/datum/action/cooldown/spell/pointed/shadow_crash
	name = "Shadow crash"
	desc = "Charge in a direction."
	panel = "Shadowling Abilities"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "glare"
	panel = null
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	cooldown_time = 15 SECONDS
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	psi_cost = 20
	var/charging = FALSE

/datum/action/cooldown/spell/pointed/shadow_crash/Grant(mob/grant_to)
	. = ..()
	ADD_TRAIT(owner, TRAIT_IMPACTIMMUNE, type)
	RegisterSignal(owner, COMSIG_MOVABLE_IMPACT, PROC_REF(impact))
	
/datum/action/cooldown/spell/pointed/shadow_crash/Remove(mob/living/remove_from)
	UnregisterSignal(owner, COMSIG_MOVABLE_IMPACT)
	REMOVE_TRAIT(owner, TRAIT_IMPACTIMMUNE, type)
	. = ..()
	
/datum/action/cooldown/spell/pointed/shadow_crash/cast(atom/cast_on)
	. = ..()
	owner.throw_at(cast_on, 5, 1, owner, FALSE)
	owner.SetImmobilized(0.3 SECONDS)
	charging = TRUE
	addtimer(VARSET_CALLBACK(src, charging, FALSE), 1 SECONDS, TIMER_UNIQUE)
	
/datum/action/cooldown/spell/pointed/shadow_crash/proc/impact(atom/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!charging)
		return
	
	if(isturf(hit_atom))
		return

	if(isobj(hit_atom))
		var/obj/thing = hit_atom
		thing.take_damage(29)
		thing.take_damage(29)

	if(!isliving(hit_atom))
		return

	var/mob/living/target = hit_atom
	var/blocked = FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.check_shields(src, 0, "[source]", attack_type = LEAP_ATTACK))
			blocked = TRUE
	
	var/destination = get_ranged_target_turf(get_turf(target), throwingdatum.init_dir, 5)
	if(blocked)
		target.throw_at(destination, 5, 2)
	else
		target.throw_at(destination, 5, 2, callback = CALLBACK(target, TYPE_PROC_REF(/mob/living, Knockdown), 2 SECONDS))
