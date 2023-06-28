/datum/action/cooldown/spell/jaunt/ethereal_jaunt/infernal_jaunt
	name = "Infernal Jaunt"
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"
	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	spell_requirements = NONE

	jaunt_duration = 5 SECONDS
	jaunt_in_time = 0.8 SECONDS
	jaunt_out_time = 0.8 SECONDS
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/devil_jaunt
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/devil_jaunt

/obj/effect/temp_visual/dir_setting/devil_jaunt
	name = "ash_shift"
	icon = 'icons/mob/mob.dmi'
	icon_state = "jaunt"
	duration = 0.8 SECONDS
