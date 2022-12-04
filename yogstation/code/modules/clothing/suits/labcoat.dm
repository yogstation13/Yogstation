//Mining Medic
/obj/item/clothing/suit/toggle/labcoat/emt/explorer
	name = "mining medic's jacket"
	desc = "A protective jacket for medical emergencies on off-world planets. Has MM embossed into it."
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	cold_protection = CHEST|ARMS
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	heat_protection = CHEST|ARMS
	flags_prot = HIDEJUMPSUIT
	armor = list(MELEE = 30, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 100, RAD = 50, FIRE = 50, ACID = 50, WOUND = 10)
	allowed = list(/obj/item/analyzer,/obj/item/stack/medical,/obj/item/dnainjector,/obj/item/reagent_containers/dropper,/obj/item/reagent_containers/syringe,/obj/item/reagent_containers/autoinjector,/obj/item/healthanalyzer,/obj/item/flashlight/pen,/obj/item/reagent_containers/glass/bottle,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/pill,/obj/item/storage/pill_bottle,/obj/item/paper,/obj/item/melee/classic_baton/telescopic,/obj/item/soap,/obj/item/sensor_device,/obj/item/tank/internals, /obj/item/hypospray)
	resistance_flags = FIRE_PROOF

//Brig Physician
/obj/item/clothing/suit/toggle/labcoat/emt/physician
	name = "brig physician's jacket"
	desc = "A protective jacket for medical emergencies on off-world planets. Has BP embossed into it."
	mob_overlay_icon = 'yogstation/icons/mob/clothing/suit/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "labcoat_emtsec"

/obj/item/clothing/suit/toggle/labcoat/physician
	name = "brig physician's labcoat"
	desc = "A white labcoat with red medical crosses. Has BP embossed into it."
	mob_overlay_icon = 'yogstation/icons/mob/clothing/suit/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "labcoat_sec"
	item_state = "labcoat_sec"
