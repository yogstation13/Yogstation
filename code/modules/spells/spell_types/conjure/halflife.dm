/datum/action/cooldown/spell/conjure/xenfloor
	name = "Infest Floor"
	desc = "Plant a fungal node on the floor to infest it."

	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "alien_plant"

	school = SCHOOL_CONJURATION
	cooldown_time = 50 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	summon_radius = 0
	summon_type = list(/obj/structure/alien/weeds/node)
