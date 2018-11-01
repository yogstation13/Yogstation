/obj/item/storage/belt/mining/medical
	icon_state = "explorer2"
	item_state = "explorer2"
	name = "medical webbing"
	desc = "A combat belt cherished by emergency medics in every corner of the galaxy."

/obj/item/storage/belt/mining/medical/Initialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.can_hold = typecacheof(list(
		/obj/item/pickaxe,
		/obj/item/bodybag,
		/obj/item/healthanalyzer,
		/obj/item/stack/medical,
		/obj/item/extinguisher/mini,
		/obj/item/clothing/mask/breath,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/stack/medical/gauze,
		/obj/item/lighter,
		/obj/item/radio,
		/obj/item/clothing/gloves/,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/key/,
		/obj/item/stack/sheet/animalhide,
		/obj/item/stack/sheet/sinew,
		/obj/item/stack/sheet/bone,
		/obj/item/gps,
		/obj/item/stack/ore/bluespace_crystal,
		/obj/item/reagent_containers/food/drinks
	))
