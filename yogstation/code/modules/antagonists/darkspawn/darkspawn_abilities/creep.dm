//Allows you to move through light unimpeded while active. Drains 5 Psi per second.
/datum/action/cooldown/spell/toggle/creep
	name = "Creep"
	desc = "Grants immunity to lightburn while active. Can be toggled on and off. Drains 5 Psi per second."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "creep"
	panel = null
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	psi_cost = 5

/datum/action/innate/darkspawn/toggle/creep/process()
	var/mob/living/L = owner
	active = L.has_status_effect(STATUS_EFFECT_CREEP)
	. = ..()

/datum/action/innate/darkspawn/toggle/creep/Enable()
	if(!isdarkspawn(owner))
		return
	var/mob/living/L = owner
	owner.visible_message(span_warning("Velvety shadows coalesce around [owner]!"), span_velvet("<b>odeahz</b><br>You begin using Psi to shield yourself from lightburn."))
	playsound(owner, 'yogstation/sound/magic/devour_will_victim.ogg', 50, TRUE)
	L.apply_status_effect(STATUS_EFFECT_CREEP, isdarkspawn(owner))

/datum/action/innate/darkspawn/toggle/creep/Disable()
	if(!isdarkspawn(owner))
		return
	var/mob/living/L = owner
	to_chat(owner, span_velvet("You release your grip on the shadows."))
	playsound(owner, 'yogstation/sound/magic/devour_will_end.ogg', 50, TRUE)
	L.remove_status_effect(STATUS_EFFECT_CREEP)
