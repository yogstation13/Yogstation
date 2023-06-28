/datum/action/cooldown/spell/conjure_item/summon_pitchfork
	name = "Summon Pitchfork"
	desc = "A devil's weapon of choice."
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"

	school = SCHOOL_CONJURATION
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	item_type = /obj/item/twohanded/pitchfork/demonic

/datum/action/cooldown/spell/conjure_item/violin
	name = "Summon golden violin"
	desc = "Play some tunes."
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"
	
	invocation = "I aint have this much fun since Georgia."
	invocation_type = INVOCATION_WHISPER
	item_type = /obj/item/instrument/violin/golden
	spell_requirements = NONE
