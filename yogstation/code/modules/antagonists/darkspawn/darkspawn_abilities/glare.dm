/datum/action/cooldown/spell/pointed/glare //Stuns and mutes a human target for 10 seconds
	name = "Glare"
	desc = "Disrupts the target's motor and speech abilities. Much more effective within two meters."
	panel = "Shadowling Abilities"
	button_icon_state = "glare"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	panel = null
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	cooldown_time = 30 SECONDS
	ranged_mousepointer = 'icons/effects/mouse_pointers/daze_target.dmi'
	var/strong = TRUE

/datum/action/cooldown/spell/pointed/glare/before_cast(atom/cast_on)
	. = ..()
	if(!cast_on || !isliving(cast_on))
		return . | SPELL_CANCEL_CAST
	if(!owner.getorganslot(ORGAN_SLOT_EYES))
		to_chat(owner, span_warning("You need eyes to glare!"))
		return . | SPELL_CANCEL_CAST
	var/mob/living/carbon/target = cast_on
	if(istype(target) && target.stat)
		to_chat(owner, span_warning("[target] must be conscious!"))
		return . | SPELL_CANCEL_CAST
	if(is_darkspawn_or_veil(target))
		to_chat(owner, span_warning("You cannot glare at allies!"))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/glare/cast(atom/cast_on)
	. = ..()
	if(!isliving(cast_on))
		return
	var/mob/living/target = cast_on
	owner.visible_message(span_warning("<b>[owner]'s eyes flash a purpleish-red!</b>"))
	var/distance = get_dist(target, owner)
	if (distance <= 2 && strong)
		target.visible_message(span_danger("[target] suddenly collapses..."))
		to_chat(target, span_userdanger("A purple light flashes across your vision, and you lose control of your movements!"))
		target.Paralyze(10 SECONDS)
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			M.silent += 10
	else //Distant glare
		var/loss = 100 - (distance * 10)
		target.adjustStaminaLoss(loss)
		target.adjust_stutter(loss)
		to_chat(target, span_userdanger("A purple light flashes across your vision, and exhaustion floods your body..."))
		target.visible_message(span_danger("[target] looks very tired..."))
