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

// Blueshields custom takbok revolver.
/obj/item/gun/ballistic/revolver/takbok/blueshield
	name = "unmarked takbok revolver" //Give it a unique prefix compared hellfire's 'modified' to stand out
	desc = "A modified revolver resembling that of Trappiste's signature Takbok, notabley lacking any of the company's orginal markings or tracablable identifaction. The custom modifactions allows it to shoot the five .585 Trappiste rounds in its cylinder quicker and with more consistancy."

	//In comparasion to the orginal's fire_delay = 1 second, recoil = 3, and wield_recoil =1.
	fire_delay = 0.8 SECONDS
	recoil = 1.6
	wield_recoil = 0.8

/obj/item/gun/ballistic/revolver/takbok/blueshield/give_manufacturer_examine()
	RemoveElement(/datum/element/manufacturer_examine, COMPANY_TRAPPISTE)
	AddElement(/datum/element/manufacturer_examine, COMPANY_REMOVED)

/obj/item/gun/ballistic/revolver/takbok/blueshield/examine_more(mob/user)
	. = ..()
    //Basically, it is a short continuation story of the original takbok about fans continuing their passion for an idea or project. Still, the original company stopped them despite the innovations they brought. And the ‘C’ is a callback to their inspirational figure ‘Cawgo’
	. += ""
	. += "After the production run of the original Takbok \
		ended in 2523 alongside its popularity, enthusiasts of the sidearm continued\
		to tinker with the make of the weapon to keep it with modern standards for \
		firearms, despite Trappiste's license on the design. This unusual passion \
		for the weapon led to variations with few to no identifying marks besides \
		the occasional 'C' carved into the hilt of the gun. As a consequence of its \
		production methods, it is unable to be distributed through conventional means \
		despite the typical assessment of most being an improved model."
	return .

// Gunset for the custom Takbok Revolver

/obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case/takbok/blueshield
	name = "Unmarked 'Takbok' gunset"

	weapon_to_spawn = /obj/item/gun/ballistic/revolver/takbok/blueshield

/obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case/takbok/blueshield/PopulateContents()
	new weapon_to_spawn (src)

	generate_items_inside(list(
		/obj/item/ammo_box/c585trappiste/incapacitator = 1,
		/obj/item/ammo_box/c585trappiste = 1,
	), src)

//Weapon beacon
/obj/item/choice_beacon/blueshield
	name = "armament beacon"
	desc = "A single use beacon to deliver a gunset of your choice. Please only call this in your office"
	company_source = "Sol Defense Contracting"
	company_message = span_bold("Supply Pod incoming, please stand by.")

/obj/item/choice_beacon/blueshield/generate_display_names()
	var/static/list/selectable_gun_types = list(
		"Unmarked Takbok Revolver Gunset" = /obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case/takbok/blueshield,
		"Custom Hellfire Laser Rifle" = /obj/item/gun/energy/laser/hellgun/blueshield,
		"Bogseo Submachinegun Gunset" = /obj/item/storage/toolbox/guncase/skyrat/xhihao_large_case/bogseo,
		"Tech-9" = /obj/item/storage/toolbox/guncase/skyrat/pistol/tech_9,
		"S.A.Y.A. Arm Defense System Cyberset" = /obj/item/storage/box/shield_blades,
	)

	return selectable_gun_types

/obj/item/storage/toolbox/guncase/skyrat/pistol/tech_9
	name = "Tech-9 Gunset"
	desc = "A thick yellow gun case with foam inserts laid out to fit a weapon, magazines, and gear securely. The five square grid of Tech-9 is displayed prominently on the top."

	icon = 'monkestation/code/modules/blueshift/icons/obj/gunsets.dmi'
	icon_state = "case_trappiste"

	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/cases_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/cases_righthand.dmi'
	inhand_icon_state = "yellowcase"

	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol/tech_9/no_mag
	extra_to_spawn = /obj/item/ammo_box/magazine/m35/rubber

/obj/item/storage/toolbox/guncase/skyrat/pistol/tech_9/PopulateContents()
	new weapon_to_spawn (src)

	generate_items_inside(list(
		/obj/item/ammo_box/magazine/m35/rubber = 2,
		/obj/item/ammo_box/magazine/m35 = 1,
	), src)


/obj/item/gun/ballistic/automatic/pistol/tech_9
	name = "\improper Glock-O"
	desc = "The standard issue service pistol of blueshield agents."
	burst_size = 4
	fire_delay = 1

	icon = 'monkestation/icons/obj/weapons/guns/tech9.dmi'
	icon_state = "tech9"

	fire_sound = 'monkestation/code/modules/blueshift/sounds/pistol_light.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/m35

/obj/item/gun/ballistic/automatic/pistol/tech_9/no_mag
	spawnwithmagazine = FALSE

/obj/item/storage/box/shield_blades
	name = "S.A.Y.A. Arm Defense System Cyberset"
	desc = "A box with essentials for S.A.Y.A. Arm Defense System. Blades that serve protection purposes, while being harder to swing and dealing less wounds to the target."
	icon_state = "cyber_implants"

/obj/item/storage/box/shield_blades/PopulateContents()
	new /obj/item/autosurgeon/organ/cyberlink_nt_low(src)
	new /obj/item/autosurgeon/organ/shield_blade(src)
	new /obj/item/autosurgeon/organ/shield_blade/l(src)
