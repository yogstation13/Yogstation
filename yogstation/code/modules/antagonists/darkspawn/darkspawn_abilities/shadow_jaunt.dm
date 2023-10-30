/datum/action/cooldown/spell/jaunt/ethereal_jaunt/void_jaunt
	name = "Void Jaunt"
	desc = "Move through the void for a time, avoiding mortal eyes and lights."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "jaunt"

	cooldown_time = 60 SECONDS
	antimagic_flags = NONE
	panel = null
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	psi_cost = 30

	exit_jaunt_sound = 'sound/magic/ethereal_exit.ogg'
	/// For how long are we jaunting?
	jaunt_duration = 5 SECONDS
	/// Visual for jaunting
	jaunt_in_type = /obj/effect/temp_visual/wizard
	/// Visual for exiting the jaunt
	jaunt_out_type = /obj/effect/temp_visual/wizard/out

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/void_jaunt/do_steam_effects(turf/loc)
	return FALSE
