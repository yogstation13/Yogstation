/obj/item/storage/belt/civilprotection
	name = "civil protection belt"
	desc = "Heavy duty belt for containing metrocop standard gear."
	icon_state = "civilprotection"
	item_state = "civilprotection"
	w_class = WEIGHT_CLASS_BULKY
	content_overlays = TRUE

/obj/item/storage/belt/civilprotection/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.max_combined_w_class = 18
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.set_holdable(list(
		/obj/item/melee/baton,
		/obj/item/melee/classic_baton,
		/obj/item/grenade,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash/handheld,
		/obj/item/clothing/glasses,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_box,
		/obj/item/storage/box/rubbershot,
		/obj/item/storage/box/lethalshot,
		/obj/item/storage/box/breacherslug,
		/obj/item/storage/box/beanbag,
		/obj/item/reagent_containers/food/snacks/donut,
		/obj/item/kitchen/knife/combat,
		/obj/item/flashlight/seclite,
		/obj/item/melee/classic_baton/telescopic,
		/obj/item/radio,
		/obj/item/pinpointer/tracker,
		/obj/item/clothing/gloves,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/gun/ballistic/revolver/tracking,
		/obj/item/holosign_creator/security,
		/obj/item/shield/riot/tele,
		/obj/item/ammo_box/magazine/usp9mm,
		/obj/item/ammo_box/a357,
		/obj/item/ammo_box/magazine/ar2,
		/obj/item/reagent_containers/pill/patch/medkit/vial,
		/obj/item/barrier_taperoll/police
		))

/obj/item/storage/belt/civilprotection/full/PopulateContents()
	SSwardrobe.provide_type(/obj/item/ammo_box/magazine/usp9mm, src)
	SSwardrobe.provide_type(/obj/item/restraints/handcuffs, src)
	SSwardrobe.provide_type(/obj/item/melee/baton/loaded, src)
	SSwardrobe.provide_type(/obj/item/barrier_taperoll/police, src)
	SSwardrobe.provide_type(/obj/item/flashlight/seclite, src)
	SSwardrobe.provide_type(/obj/item/reagent_containers/pill/patch/medkit/vial, src)
	update_appearance(UPDATE_ICON)

/obj/item/storage/belt/civilprotection/divisionleadfull/PopulateContents()
	SSwardrobe.provide_type(/obj/item/ammo_box/a357, src)
	SSwardrobe.provide_type(/obj/item/restraints/handcuffs, src)
	SSwardrobe.provide_type(/obj/item/melee/baton/loaded, src)
	SSwardrobe.provide_type(/obj/item/barrier_taperoll/police, src)
	SSwardrobe.provide_type(/obj/item/flashlight/seclite, src)
	SSwardrobe.provide_type(/obj/item/reagent_containers/pill/patch/medkit/vial, src)
	update_appearance(UPDATE_ICON)

/obj/item/storage/belt/civilprotection/overwatch
	name = "overwatch belt"
	desc = "Heavy duty belt for containing overwatch standard gear."

/obj/item/storage/belt/civilprotection/overwatch/PopulateContents()
	SSwardrobe.provide_type(/obj/item/grenade/syndieminibomb/bouncer, src)
	SSwardrobe.provide_type(/obj/item/restraints/handcuffs, src)
	SSwardrobe.provide_type(/obj/item/ammo_box/magazine/ar2, src)
	SSwardrobe.provide_type(/obj/item/ammo_box/magazine/ar2, src)
	SSwardrobe.provide_type(/obj/item/ammo_box/magazine/ar2, src)
	SSwardrobe.provide_type(/obj/item/flashlight/seclite, src)
	update_appearance(UPDATE_ICON)
