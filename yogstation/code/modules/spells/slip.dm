/datum/action/cooldown/spell/aoe/slip
	name = "Slip"
	desc = "Causes the floor within six tiles to become slippery."
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "slip"

	invocation = "OO'BANAN'A!"
	invocation_type = INVOCATION_SHOUT

	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 5 SECONDS
	aoe_radius = 6
	spell_requirements = SPELL_REQUIRES_WIZARD_GARB

/datum/action/cooldown/spell/aoe/slip/cast_on_thing_in_aoe(turf/open/target)
	target.MakeSlippery(TURF_WET_LUBE, 30 SECONDS, 30 SECONDS)

/datum/spellbook_entry/slip
	name = "Slip"
	spell_type = /datum/action/cooldown/spell/aoe/slip
	category = "Defensive"
