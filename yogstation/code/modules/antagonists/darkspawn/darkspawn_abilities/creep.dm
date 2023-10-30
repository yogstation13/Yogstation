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
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	var/datum/antagonist/darkspawn/cost
	var/upkeep_cost = 1 //happens 5 times a second

/datum/action/cooldown/spell/toggle/creep/Grant(mob/grant_to)
	. = ..()
	if(isdarkspawn(owner))
		cost = isdarkspawn(owner)
		
/datum/action/cooldown/spell/toggle/creep/process()
	if(active && cost && (!cost.use_psi(upkeep_cost)))
		Activate(owner)
	. = ..()

/datum/action/cooldown/spell/toggle/creep/Enable()
	owner.visible_message(span_warning("Velvety shadows coalesce around [owner]!"), span_velvet("<b>odeahz</b><br>You begin using Psi to shield yourself from lightburn."))
	playsound(owner, 'yogstation/sound/magic/devour_will_victim.ogg', 50, TRUE)
	ADD_TRAIT(owner, TRAIT_DARKSPAWN_CREEP, type)

/datum/action/cooldown/spell/toggle/creep/Disable()
	to_chat(owner, span_velvet("You release your grip on the shadows."))
	playsound(owner, 'yogstation/sound/magic/devour_will_end.ogg', 50, TRUE)
	REMOVE_TRAIT(owner, TRAIT_DARKSPAWN_CREEP, type)
