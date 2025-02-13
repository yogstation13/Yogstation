// Base Sol rifle

/obj/item/gun/ballistic/automatic/quarad_lmg
	name = "\improper Qarad Light Machinegun"
	desc = "A spotless, if outdated machinegun. The same model was used to great effect against xenomorph incursions in the past, hopefully this one doesn't have any manufacturing defects...."

	icon = 'monkestation/icons/obj/weapons/guns/guns48x.dmi'
	icon_state = "outomaties"

	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_worn.dmi'
	worn_icon_state = "outomaties"

	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_righthand.dmi'
	inhand_icon_state = "outomaties"

	bolt_type = BOLT_TYPE_OPEN

	accepted_magazine_type = /obj/item/ammo_box/magazine/c65xeno_drum
	spawn_magazine_type = /obj/item/ammo_box/magazine/c65xeno_drum

	SET_BASE_PIXEL(-8, 0)

	special_mags = TRUE

	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE

	fire_sound = 'monkestation/code/modules/blueshift/sounds/rifle_heavy.ogg'
	suppressed_sound = 'monkestation/code/modules/blueshift/sounds/suppressed_rifle.ogg'
	can_suppress = TRUE

	can_bayonet = FALSE

	suppressor_x_offset = 12

	actions_types = list()

	burst_size = 1
	fire_delay = 0.2 SECONDS

	recoil = 3
	wield_recoil = 0.75
	spread = 12.5

/obj/item/gun/ballistic/automatic/quarad_lmg/Initialize(mapload)
	. = ..()

	give_autofire()

/// Separate proc for handling auto fire just because one of these subtypes isn't otomatica
/obj/item/gun/ballistic/automatic/quarad_lmg/proc/give_autofire()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/quarad_lmg/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/quarad_lmg/examine_more(mob/user)
	. = ..()

	. += "The Qarad light machinegun is an old weapon, dating back to the largest of the \
		xenomorph containment efforts. It's specially-tooled 6.5mm cartridges have \
		poor effect on humans, being designed for much more durable targets.  \
		Despite it's age and suboptimal design, it will still spit bullets down-range \
		like nothing else. After a string of expensive xenomorph breaches on research stations,\
		NT pulled these machine guns out of deep storage, many still in their original packaging."



/obj/item/gun/ballistic/automatic/quarad_lmg/evil
	name = "\improper Suspicious Qarad Light Machinegun"
	desc = "A heavily modified machinegun, complete with bluespace barrel extender! More bullet per bullet, more barrel per inch!"

	icon_state = "outomaties_evil"
	worn_icon = 'monkestation/icons/mob/inhands/gunsx48_worn.dmi'
	worn_icon_state = "outomaties_evil"
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/guns_lefthandx48.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/guns_righthandx48.dmi'
	inhand_icon_state = "outomaties_evil"
	spawn_magazine_type = /obj/item/ammo_box/magazine/c65xeno_drum/evil
	fire_delay = 0.1 SECONDS
	recoil = 2
	wield_recoil = 0.25
	spread = 8
	projectile_wound_bonus = 10
	projectile_damage_multiplier = 1.3

/obj/item/storage/toolbox/guncase/skyrat/quarad_guncase
	name = "\improper Quarad light machinegun storage case"

	weapon_to_spawn = /obj/item/gun/ballistic/automatic/quarad_lmg
	extra_to_spawn = /obj/item/ammo_box/magazine/c65xeno_drum
	var/extra_to_spawn2 = /obj/item/ammo_box/magazine/c65xeno_drum/pierce
	var/extra_to_spawn3 = /obj/item/ammo_box/magazine/c65xeno_drum/incendiary

/obj/item/storage/toolbox/guncase/skyrat/quarad_guncase/PopulateContents()
	new weapon_to_spawn (src)
	new extra_to_spawn (src)
	new extra_to_spawn2 (src)
	new extra_to_spawn3 (src)

/obj/item/storage/toolbox/guncase/skyrat/quarad_guncase/evil   ///Currently unavailable, exists for easy testing and admeming
	name = "\improper EVIL Quarad light machinegun storage case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/quarad_lmg/evil
	extra_to_spawn = /obj/item/ammo_box/magazine/c65xeno_drum/evil
	extra_to_spawn2 = /obj/item/ammo_box/magazine/c65xeno_drum/pierce/evil
	extra_to_spawn3 = /obj/item/ammo_box/magazine/c65xeno_drum/incendiary/evil