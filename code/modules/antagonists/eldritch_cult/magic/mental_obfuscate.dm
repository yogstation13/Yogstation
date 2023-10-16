/datum/action/cooldown/spell/pointed/phase_jump/obfuscation
	name = "Mental Obfuscation"
	desc = "A short range targeted teleport."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mansus_link"
	ranged_mousepointer = 'icons/effects/mouse_pointers/phase_jump.dmi'

	school = SCHOOL_FORBIDDEN

	cooldown_time = 25 SECONDS
	cast_range = 7
	invocation = "PH'ASE"
	invocation_type = INVOCATION_WHISPER
	active_msg = span_notice("You prepare to warp everyone's vision.")
	deactive_msg = span_notice("You relax your mind.")
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION
