/*
	Blueshield's Hellfire is between SC-1 and the Hellfire in terms of Damage and wound output
*/

/// Blueshield's Custom Hellfire
/obj/item/ammo_casing/energy/laser/hellfire/blueshield
	projectile_type = /obj/projectile/beam/laser/hellfire
	e_cost = LASER_SHOTS(13, 1000)
	select_name = "maim"

/obj/item/gun/energy/laser/hellgun/blueshield
	name ="modified hellfire laser gun"
	desc = "A lightly overtuned version of NT's Hellfire Laser rifle, scratches showing its age and the fact it has definitely been owned before. This one is more energy efficient without sacrificing damage."
	icon_state = "hellgun"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hellfire/blueshield)

/obj/item/choice_beacon/blueshield
	name = "gunset beacon"
	desc = "A single use beacon to deliver a gunset of your choice. Please only call this in your office"
	company_source = "Sol Defense Contracting"
	company_message = span_bold("Supply Pod incoming, please stand by.")

/obj/item/choice_beacon/blueshield/generate_display_names()
	var/static/list/selectable_gun_types = list(
		"Takbok Revolver Set" = /obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case/takbok,
		"Custom Hellfire Laser Rifle" = /obj/item/gun/energy/laser/hellgun/blueshield,
		"Bogseo Submachinegun Gunset" = /obj/item/storage/toolbox/guncase/skyrat/xhihao_large_case/bogseo,
		"Tech-9" = /obj/item/storage/toolbox/guncase/skyrat/pistol/tech_9,
	)

	return selectable_gun_types

/obj/item/storage/toolbox/guncase/skyrat/pistol/tech_9
	desc = "A thick yellow gun case with foam inserts laid out to fit a weapon, magazines, and gear securely. The five square grid of Tech-9 is displayed prominently on the top."

	icon = 'monkestation/code/modules/blueshift/icons/obj/gunsets.dmi'
	icon_state = "case_trappiste"

	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/cases_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/cases_righthand.dmi'
	inhand_icon_state = "yellowcase"

	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol/tech_9/no_mag
	extra_to_spawn = /obj/item/ammo_box/magazine/m35/rubber

/obj/item/gun/ballistic/automatic/pistol/tech_9
	name = "\improper Glock-O"
	desc = "The standard issue service pistol of blueshield agents."
	burst_size = 10 //lol
	fire_delay = 1

	icon = 'monkestation/code/modules/blueshield/icons/gun.dmi'
	icon_state = "tech9"

	fire_sound = 'monkestation/code/modules/blueshift/sounds/pistol_light.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/m35

/obj/item/gun/ballistic/automatic/pistol/tech_9/no_mag
	spawnwithmagazine = FALSE
