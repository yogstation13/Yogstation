/datum/action/cooldown/spell/aoe/slip/void
	name = "Diamond Dust"
	desc = "Causes the floor within 2 tiles to become frozen."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/humble/actions_humble.dmi'
	button_icon_state = "blind"

	invocation = "OBL'VION!"
	invocation_type = INVOCATION_SHOUT

	cooldown_time = 50 SECONDS
	aoe_radius = 2
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

/datum/action/cooldown/spell/aoe/slip/void/cast_on_thing_in_aoe(turf/open/target)
	target.MakeSlippery(TURF_WET_PERMAFROST, 15 SECONDS, 15 SECONDS)
