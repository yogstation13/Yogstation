/datum/action/cooldown/spell/conjure/summon_greedslots
	name = "Summon Slotmachine"
	desc = "Summon forth a temporary slot machine of greed, allowing you to offer patrons a deadly game where the price is their life (and some money if you'd like) and the possible prize is a one use die of fate."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "slots"
	background_icon_state = "bg_demon"

	invocation = "Just one game?"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cooldown_time = 30 SECONDS
	summon_lifespan = 1 MINUTES
	summon_radius = 0 //spawns on top of us
	summon_type = list(/obj/structure/cursed_slot_machine/betterchance)
