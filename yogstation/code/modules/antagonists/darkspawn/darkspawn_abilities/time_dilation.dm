//Greatly speeds up reflexes and recovery, at a massive Psi cost.
/datum/action/cooldown/spell/time_dilation
	name = "Time Dilation"
	desc = "Greatly increases reaction times and action speed, and provides immunity to slowdown. This lasts for 1 minute. Costs 75 Psi."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "time_dilation"
	check_flags = AB_CHECK_CONSCIOUS
	panel = null
	antimagic_flags = NONE
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	sound = 'yogstation/sound/creatures/darkspawn_howl.ogg'
	psi_cost = 75

/datum/action/cooldown/spell/time_dilation/can_cast_spell(feedback)
	if(owner.has_status_effect(STATUS_EFFECT_TIME_DILATION))
		if(feedback)
			to_chat(owner, span_notice("You still have time dilation in effect."))
		return FALSE
	. = ..()

/datum/action/cooldown/spell/time_dilation/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = owner
	L.apply_status_effect(STATUS_EFFECT_TIME_DILATION)
	L.visible_message(span_warning("[L] howls as their body moves at wild speeds!"), span_velvet("<b>ckppw ck bwop</b><br>Your sigils howl out light as your body moves at incredible speed!"))
