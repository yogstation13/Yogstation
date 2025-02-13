/obj/item/ammo_casing/c65xeno
	name = "6.5mm Anti-Xeno frangible bullet casing"
	desc = "An unusual 6.5mm caseless round, designed for minimum property damage, maximum xenomorph shredding"
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "40sol"
	caliber = CALIBER_C65XENO
	projectile_type = /obj/projectile/bullet/c65xeno

/obj/item/ammo_casing/c65xeno/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/c65xeno/evil
	name = "6.5mm FMJ bullet casing"
	desc = "A 6.5mm caseless frangible round with the projectile replaced by a terrestial military round. Much more effective against armor, and at breaking windows."
	caliber = CALIBER_C65XENO
	projectile_type = /obj/projectile/bullet/c65xeno/evil
	can_be_printed = FALSE

/obj/item/ammo_casing/c65xeno/pierce
	name = "6.5mm Subcaliber tungsten sabot round"
	desc = "A 6.5mm caseless round loaded with a subcaliber tungsten penetrator. Designed to punch straight through targets."
	projectile_type = /obj/projectile/bullet/c65xeno/pierce

	custom_materials = AMMO_MATS_AP
	advanced_print_req = TRUE

/obj/item/ammo_casing/c65xeno/pierce/evil
	name = "6.5mm UDS"
	desc = "A 6.5mm Uranium Discarding Sabot. No, NOT depleted uranium. Prepare to be irradiated."
	projectile_type = /obj/projectile/bullet/c65xeno/pierce/evil

	can_be_printed = FALSE

/obj/item/ammo_casing/c65xeno/incendiary
	name = "6.5mm Subcaliber incendiary round"
	desc = "A 6.5mm caseless round tipped with an extremely flammable compound. Leaves no flaming trail, only igniting targets on impact."
	projectile_type = /obj/projectile/bullet/c65xeno/incendiary

	custom_materials = AMMO_MATS_TEMP
	advanced_print_req = TRUE

/obj/item/ammo_casing/c65xeno/incendiary/evil
	name = "6.5mm Inferno round"
	desc = "A 6.5mm caseless round designed to leave a trail of EXTREMLY flammable substance behind it in flight. Do not smoke within 30 meters of these."
	projectile_type = /obj/projectile/bullet/c65xeno/incendiary/evil

	can_be_printed = FALSE


/obj/item/ammo_box/magazine/c65xeno_drum
	name = "\improper 6.5mm drum magazine"
	desc = "A hefty 120 round drum of 6.5mm frangible rounds, designed for minimal damage to company property."

	icon = 'monkestation/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "c65xeno_drum"

	multiple_sprites = AMMO_BOX_FULL_EMPTY

	w_class = WEIGHT_CLASS_BULKY

	ammo_type = /obj/item/ammo_casing/c65xeno
	caliber = CALIBER_C65XENO
	max_ammo = 120

/obj/item/ammo_box/magazine/c65xeno_drum/pierce
	name = "\improper 6.5mm AP drum magazine"
	desc = "A hefty 120 round drum of 6.5mm saboted tungsten penetrators, designed to punch through multiple targets. Warning: Liable to break windows."

	icon = 'monkestation/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "c65xeno_drumP"

	ammo_type = /obj/item/ammo_casing/c65xeno/pierce
	max_ammo = 120

/obj/item/ammo_box/magazine/c65xeno_drum/incendiary
	name = "\improper 6.5mm incendiary drum magazine"
	desc = "A hefty 120 round drum of 6.5mm rounds tipped with an incendiary compound."

	icon = 'monkestation/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "c65xeno_drumI"

	ammo_type = /obj/item/ammo_casing/c65xeno/incendiary
	max_ammo = 120

/obj/item/ammo_box/magazine/c65xeno_drum/evil
	name = "\improper 6.5mm FMJ drum magazine"
	desc = "A hefty 120 round drum of 6.5mm FMJ rounds."

	icon = 'monkestation/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "c65xeno_drumevil"

	ammo_type = /obj/item/ammo_casing/c65xeno/evil
	max_ammo = 120

/obj/item/ammo_box/magazine/c65xeno_drum/pierce/evil
	name = "\improper 6.5mm UDS drum magazine"
	desc = "A hefty 120 round drum of 6.5mm Uranium Discarding Sabot rounds. No, NOT depleted uranium. Prepare for your enemies to be irradiated."

	icon = 'monkestation/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "c65xeno_drumPevil"

	ammo_type = /obj/item/ammo_casing/c65xeno/pierce/evil
	max_ammo = 120

/obj/item/ammo_box/magazine/c65xeno_drum/incendiary/evil
	name = "\improper 6.5mm Inferno drum magazine"
	desc = "A hefty 120 round drum of 6.5mm inferno rounds. They leave a trail of fire as they fly."

	icon = 'monkestation/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "c65xeno_drumIevil"

	ammo_type = /obj/item/ammo_casing/c65xeno/incendiary/evil
	max_ammo = 120