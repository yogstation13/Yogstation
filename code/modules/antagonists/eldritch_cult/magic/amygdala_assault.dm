/datum/action/cooldown/spell/pointed/projectile/assault
	name = "Amygdala Assault"
	desc = "Blast a single ray of concentrated mental energy at a target, dealing high brute damage if they are caught in it"
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/obj/hand_of_god_structures.dmi'
	button_icon_state = "ward-red"

	sound = 'sound/weapons/resonator_blast.ogg'
	cast_range = 7
	cooldown_time = 25 SECONDS
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	invocation = "D'O'DGE TH'IS!"
	invocation_type = INVOCATION_SHOUT

	projectile_type = /obj/projectile/heretic_assault
