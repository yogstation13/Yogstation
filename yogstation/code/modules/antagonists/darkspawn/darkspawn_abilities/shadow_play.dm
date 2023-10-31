/datum/action/cooldown/spell/erase_time/darkspawn
	name = "shadow play"
	desc = "Erase the very concept of time for a short period of time."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "time_dilation"
	panel = null
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	psi_cost = 100 //lol
	cooldown_time = 60 SECONDS
	length = 5 SECONDS
	guardian_lock = FALSE
