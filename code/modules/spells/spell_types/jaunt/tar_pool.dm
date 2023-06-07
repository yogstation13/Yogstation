/datum/action/cooldown/spell/jaunt/ethereal_jaunt/tar_pool
	name = "Return to tar"
	desc = "Temporarily dissolve into a pool of tar, in this form you are involnurable to damage."
	button_icon = 'yogstation/icons/mob/actions/actions.dmi'
	button_icon_state = "tar_shift"

	jaunt_type = /obj/effect/dummy/phased_mob/tar_pool
	spell_requirements = NONE
	cooldown_time = 25 SECONDS

	jaunt_duration = 10 SECONDS
	jaunt_in_time = 1 SECONDS
	jaunt_out_time = 1 SECONDS
	jaunt_in_type = /obj/effect/better_animated_temp_visual/skin_twister_in
	jaunt_out_type = /obj/effect/better_animated_temp_visual/skin_twister_out



