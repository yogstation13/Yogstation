/datum/action/cooldown/spell/conjure/summon_mirror
	name = "Summon Mirror"
	desc = "Summon forth a temporary mirror of sin that will allow you and others to change anything they want about themselves."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "magic_mirror"
	background_icon_state = "bg_demon"

	invocation = "Aren't I so amazing?"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cooldown_time = 30 SECONDS
	summon_lifespan = 1 MINUTES
	summon_radius = 0
	summon_type = list(/obj/structure/mirror/magic/lesser)

